#!/usr/bin/env bash
# Run archinstall with this repo's shared JSON install inputs.
set -euo pipefail

if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    SCRIPT_DIR="$(pwd)"
fi
if [[ -d "${SCRIPT_DIR}/../archinstall" ]]; then
    REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
    RUNNING_FROM_REPO=1
else
    REPO_DIR="${REPO_DIR:-/root/dotfiles}"
    RUNNING_FROM_REPO=0
fi
REPO_URL="${REPO_URL:-https://github.com/Zolkyed/dotfiles.git}"

if [[ "$RUNNING_FROM_REPO" -eq 0 ]]; then
    if [[ "${EUID}" -eq 0 ]] && command -v pacman >/dev/null 2>&1; then
        pacman -Sy --needed --noconfirm git
    fi

    if [[ ! -d "$REPO_DIR/.git" ]]; then
        echo "==> Cloning dotfiles..."
        git clone "$REPO_URL" "$REPO_DIR"
    else
        echo "==> Updating dotfiles..."
        git -C "$REPO_DIR" pull --ff-only
    fi

    exec "${REPO_DIR}/scripts/run_archinstall.sh" "$@"
fi

require_tty() {
    if [[ ! -r /dev/tty ]]; then
        echo "ERROR: Interactive mode needs a TTY." >&2
        exit 1
    fi
}

select_disk() {
    local disks=() disk selected_disk stable_disk

    while IFS= read -r disk; do
        [[ -b "$disk" ]] && disks+=("$disk")
    done < <(lsblk -dnpo NAME,TYPE | awk '$2 == "disk" && $1 !~ "/dev/(loop|zram|ram)" { print $1 }' | sort)

    if (( ${#disks[@]} == 0 )); then
        echo "ERROR: No target disks found." >&2
        exit 1
    fi

    echo "Target disks:" >&2
    lsblk -dpo NAME,SIZE,MODEL,TRAN,SERIAL,TYPE >&2
    echo >&2

    require_tty
    select selected_disk in "${disks[@]}"; do
        if [[ -n "${selected_disk:-}" ]]; then
            stable_disk="$(find /dev/disk/by-id -maxdepth 1 -type l ! -name '*-part*' -samefile "$selected_disk" | sort | head -n 1)"
            printf '%s\n' "${stable_disk:-$selected_disk}"
            return
        fi
        echo "Invalid selection." >&2
    done </dev/tty
}

target_disk="${ARCHINSTALL_DISK:-}"

case $# in
    0)
        ;;
    1)
        target_disk="$1"
        ;;
    *)
        echo "Usage: $0 [target-disk]" >&2
        exit 1
        ;;
esac

if [[ -z "$target_disk" ]]; then
    target_disk="$(select_disk)"
fi

if [[ -z "$target_disk" ]]; then
    echo "ERROR: Specify the target disk." >&2
    exit 1
fi

if [[ ! -b "$target_disk" ]]; then
    echo "ERROR: Not a block device: $target_disk" >&2
    exit 1
fi

config="${REPO_DIR}/archinstall/user_configuration.json"
creds="${REPO_DIR}/archinstall/user_credentials.json"

for f in "$config" "$creds"; do
    if [[ ! -f "$f" ]]; then
        echo "ERROR: Missing: $f" >&2
        exit 1
    fi
done

tmp_config="$(mktemp)"
cleanup() { rm -f "$tmp_config"; }
trap cleanup EXIT

python - "$config" "$tmp_config" "$target_disk" <<'PY'
import json, os, subprocess, sys, uuid

src, dest, disk = sys.argv[1:]
real_disk = os.path.realpath(disk)

disk_bytes = int(subprocess.run(["blockdev", "--getsize64", real_disk],
    capture_output=True, text=True, check=True).stdout.strip())

MiB            = 1024 ** 2
boot_start_mib = 1
boot_size_mib  = 1024                            # 1 GiB
root_start_mib = boot_start_mib + boot_size_mib  # 1025 MiB
disk_mib       = disk_bytes // MiB
root_size_mib  = disk_mib - root_start_mib - 1   # 1 MiB gap keeps us clear of backup GPT

if root_size_mib <= 0:
    raise SystemExit(f"disk too small: {real_disk}")

def sz(value, unit="MiB"):
    return {"value": value, "unit": unit}

with open(src, encoding="utf-8") as fh:
    data = json.load(fh)

data["disk_config"] = {
    "config_type": "default_layout",
    "btrfs_options": {"snapshot_config": None},
    "device_modifications": [{
        "device": real_disk,
        "wipe": True,
        "partitions": [
            {
                "obj_id": str(uuid.uuid4()),
                "type": "primary", "status": "create",
                "fs_type": "fat32", "flags": ["boot", "esp"],
                "mountpoint": "/boot", "mount_options": [], "btrfs": [], "dev_path": None,
                "start": sz(boot_start_mib),
                "size":  sz(boot_size_mib),
            },
            {
                "obj_id": str(uuid.uuid4()),
                "type": "primary", "status": "create",
                "fs_type": "btrfs", "flags": [],
                "mountpoint": None, "mount_options": ["compress=zstd"], "dev_path": None,
                "start": sz(root_start_mib),
                "size":  sz(root_size_mib),
                "btrfs": [
                    {"name": "@",     "mountpoint": "/"},
                    {"name": "@home", "mountpoint": "/home"},
                    {"name": "@log",  "mountpoint": "/var/log"},
                    {"name": "@pkg",  "mountpoint": "/var/cache/pacman/pkg"},
                ],
            },
        ],
    }],
}

with open(dest, "w", encoding="utf-8") as fh:
    json.dump(data, fh, indent=2)
    fh.write("\n")
PY

echo "==> Running archinstall"
echo "    target disk: ${target_disk}"
echo "    THIS WILL WIPE THE TARGET DISK"

require_tty
read -r -p "Type WIPE to continue: " confirm </dev/tty
if [[ "$confirm" != "WIPE" ]]; then
    echo "Aborted."
    exit 1
fi

archinstall --config "$tmp_config" --creds "$creds"
echo "==> Done. Reboot, then clone this repo and run './scripts/run_ansibleinstall.sh <desktop|laptop|server>'"