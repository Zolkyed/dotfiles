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
import json, os, subprocess, sys

src, dest, disk = sys.argv[1:]
real_disk = os.path.realpath(disk)

with open(src, encoding="utf-8") as fh:
    data = json.load(fh)

mod = data["disk_config"]["device_modifications"][0]
mod["device"] = real_disk

parts = mod["partitions"]
if parts:
    disk_bytes = int(subprocess.run(["blockdev", "--getsize64", real_disk],
        capture_output=True, text=True, check=True).stdout.strip())
    sector_bytes = int(subprocess.run(["blockdev", "--getss", real_disk],
        capture_output=True, text=True, check=True).stdout.strip())
    align_bytes = 1024**2
    gpt_tail_bytes = 34 * sector_bytes
    unit_map = {"B": 1, "sectors": sector_bytes, "MiB": 1024**2, "GiB": 1024**3, "TiB": 1024**4}

    def bytes_from(value):
        return value["value"] * unit_map.get(value.get("unit", "B"), 1)

    def align_up(value):
        return ((value + align_bytes - 1) // align_bytes) * align_bytes

    def align_down(value):
        return (value // align_bytes) * align_bytes

    for part in parts:
        if "size" in part and "length" not in part:
            part["length"] = part.pop("size")
        for key in ("start", "length"):
            if key in part and "sector_size" in part[key]:
                part[key]["sector_size"] = {"unit": "B", "value": sector_bytes}

    for prev, current in zip(parts, parts[1:]):
        prev_end = bytes_from(prev["start"]) + bytes_from(prev["length"])
        current["start"] = {
            "sector_size": {"unit": "B", "value": sector_bytes},
            "unit": "B",
            "value": align_up(prev_end),
        }

    last = parts[-1]
    start_bytes = bytes_from(last["start"])
    usable_end = align_down(disk_bytes - gpt_tail_bytes)
    remaining = usable_end - start_bytes
    if remaining <= 0:
        raise SystemExit(f"target disk is too small for configured partition start: {real_disk}")
    last["length"] = {
        "sector_size": {"unit": "B", "value": sector_bytes},
        "unit": "B",
        "value": remaining,
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

archinstall --config "$tmp_config" --creds "$creds" --silent
echo "==> Done. Reboot, then clone this repo and run './scripts/run_ansibleinstall.sh <desktop|laptop|server>'"
