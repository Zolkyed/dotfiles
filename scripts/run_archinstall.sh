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
SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}"
export SOPS_AGE_KEY_FILE

require_tty() {
    if [[ ! -r /dev/tty ]]; then
        echo "ERROR: Interactive mode needs a TTY." >&2
        exit 1
    fi
}

enable_iso_ssh() {
    if [[ "${EUID}" -ne 0 ]]; then
        echo "ERROR: ISO SSH setup must run as root." >&2
        exit 1
    fi

    pacman -Sy --needed --noconfirm openssh
    install -d -m 0700 /root/.ssh

    if [[ -n "${ISO_SSH_PUBLIC_KEY:-}" ]]; then
        printf '%s\n' "$ISO_SSH_PUBLIC_KEY" >>/root/.ssh/authorized_keys
        chmod 0600 /root/.ssh/authorized_keys
        passwd -l root >/dev/null
        echo "==> Installed root authorized key and locked root password login."
    else
        echo "==> Set a temporary root password for SSH."
        require_tty
        if ! passwd </dev/tty; then
            echo "ERROR: Failed to set temporary root password." >&2
            echo "Use a stronger temporary password or rerun with ISO_SSH_PUBLIC_KEY set." >&2
            exit 1
        fi
        grep -q '^PermitRootLogin yes$' /etc/ssh/sshd_config ||
            printf '\nPermitRootLogin yes\n' >>/etc/ssh/sshd_config
    fi

    systemctl enable --now sshd
    echo "==> SSH enabled. Connect with:"
    echo "    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@<ip>"
    ip -brief address
}

prompt_host() {
    local selected_host

    require_tty
    while true; do
        read -r -p "Host [desktop/laptop/server]: " selected_host </dev/tty
        case "$selected_host" in
            desktop | laptop | server)
                printf '%s\n' "$selected_host"
                return
                ;;
            *)
                echo "Invalid host." >&2
                ;;
        esac
    done
}

select_disk() {
    local disks=()
    local disk
    local selected_disk
    local stable_disk
    local selected_index

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
            selected_index="${REPLY}"
            stable_disk="$(find /dev/disk/by-id -maxdepth 1 -type l ! -name '*-part*' -samefile "$selected_disk" | sort | head -n 1)"
            if [[ -z "$stable_disk" ]]; then
                stable_disk="$selected_disk"
            fi
            echo "Selected disk ${selected_index}: ${stable_disk}" >&2
            printf '%s\n' "$stable_disk"
            return
        fi
        echo "Invalid selection." >&2
    done </dev/tty
}

install_iso_tools() {
    if [[ "${EUID}" -eq 0 ]] && command -v pacman >/dev/null 2>&1; then
        pacman -Sy --needed --noconfirm git just sops age openssh
    fi
}

# After archinstall runs, copy the SOPS key into the installed system
post_install_copy_key() {
    local installed_root="/mnt"
    local dest="${installed_root}/root/.config/sops/age/keys.txt"
    mkdir -p "$(dirname "$dest")"
    install -m 0600 "$SOPS_AGE_KEY_FILE" "$dest"
    echo "==> SOPS age key copied to installed system."
}

if [[ "$RUNNING_FROM_REPO" -eq 0 ]]; then
    install_iso_tools

    if [[ ! -d "$REPO_DIR/.git" ]]; then
        echo "==> Cloning dotfiles..."
        git clone "$REPO_URL" "$REPO_DIR"
    else
        echo "==> Updating dotfiles..."
        git -C "$REPO_DIR" pull --ff-only
    fi

    exec "${REPO_DIR}/scripts/run_archinstall.sh" "$@"
fi

if [[ $# -eq 0 ]]; then
    install_iso_tools

    if [[ ! -f "$SOPS_AGE_KEY_FILE" ]]; then
        enable_iso_ssh
        echo
        echo "Copy your SOPS key from another machine:"
        echo "  scp -O ~/.config/sops/age/keys.txt root@<iso-ip>:/root/.config/sops/age/keys.txt"
        echo
        mkdir -p "$(dirname "$SOPS_AGE_KEY_FILE")"
        while [[ ! -f "$SOPS_AGE_KEY_FILE" ]]; do
            require_tty
            read -r -p "Press Enter after keys.txt has been copied to ${SOPS_AGE_KEY_FILE}..." </dev/tty
        done
        chmod 600 "$SOPS_AGE_KEY_FILE"
    fi

    host="$(prompt_host)"
    target_disk="$(select_disk)"
else
    host="${1:-}"
    target_disk="${ARCHINSTALL_DISK:-${2:-}}"
fi

case "$host" in
    desktop | laptop | server) ;;
    *)
        echo "ERROR: Specify an archinstall host: desktop, laptop, or server." >&2
        echo "Usage: $0 [desktop|laptop|server] /dev/disk/by-id/..." >&2
        echo "Or run $0 with no arguments for interactive mode." >&2
        exit 1
        ;;
esac

if [[ -z "$target_disk" ]]; then
    echo "ERROR: Specify the target disk to wipe." >&2
    echo "Usage: $0 ${host} /dev/disk/by-id/..." >&2
    echo "Or run $0 with no arguments for interactive mode." >&2
    exit 1
fi

if [[ ! -b "$target_disk" ]]; then
    echo "ERROR: Target disk is not a block device: $target_disk" >&2
    exit 1
fi

config="${REPO_DIR}/archinstall/user_configuration.json"
creds="${REPO_DIR}/archinstall/user_credentials.json"

if [[ ! -f "$config" ]]; then
    echo "ERROR: Missing config: $config" >&2
    echo "Generate one with archinstall --dry-run, then copy it into this path." >&2
    exit 1
fi

if [[ ! -f "$creds" ]]; then
    echo "ERROR: Missing SOPS-encrypted credentials: $creds" >&2
    exit 1
fi

if [[ ! -f "$SOPS_AGE_KEY_FILE" ]]; then
    echo "ERROR: Missing SOPS age key: $SOPS_AGE_KEY_FILE" >&2
    echo "Copy keys.txt there or set SOPS_AGE_KEY_FILE before running." >&2
    exit 1
fi

tmp_config="$(mktemp)"
tmp_creds="$(mktemp)"
cleanup() {
    rm -f "$tmp_config"
    rm -f "$tmp_creds"
}
trap cleanup EXIT

python - "$config" "$tmp_config" "$host" "$target_disk" <<'PY'
import json
import os
import subprocess
import sys

src, dest, hostname, disk = sys.argv[1:]

with open(src, encoding="utf-8") as fh:
    data = json.load(fh)

data["hostname"] = hostname

mod = data["disk_config"]["device_modifications"][0]
real_disk = os.path.realpath(disk)
mod["device"] = real_disk

for partition in mod["partitions"]:
    if "length" in partition and "size" not in partition:
        partition["size"] = partition.pop("length")

parts = mod["partitions"]
if parts:
    disk_bytes = int(
        subprocess.run(
            ["blockdev", "--getsize64", real_disk],
            capture_output=True, text=True, check=True,
        ).stdout.strip()
    )
    sector_bytes = int(
        subprocess.run(
            ["blockdev", "--getpbsz", real_disk],
            capture_output=True, text=True, check=True,
        ).stdout.strip()
    )
    last = parts[-1]
    size_val = last.get("size", {}).get("value", 0)
    if size_val == 0:  # 0 or missing means "fill remaining"
        start_unit = last["start"].get("unit", "B")
        start_val  = last["start"]["value"]
        unit_map = {"B": 1, "MiB": 1024**2, "GiB": 1024**3, "TiB": 1024**4}
        start_bytes = start_val * unit_map.get(start_unit, 1)
        remaining = disk_bytes - start_bytes
        # Align down to physical sector boundary
        remaining = (remaining // sector_bytes) * sector_bytes
        last["size"] = {
            "sector_size": {"unit": "B", "value": sector_bytes},
            "unit": "B",
            "value": remaining,
        }

with open(dest, "w", encoding="utf-8") as fh:
    json.dump(data, fh, indent=2)
    fh.write("\n")
PY

sops --decrypt "$creds" >"$tmp_creds"
echo "==> Decrypted credentials:" && python -m json.tool "$tmp_creds"

echo "==> Running archinstall for ${host}"
echo "    target disk: ${target_disk}"
echo "    THIS WILL WIPE THE TARGET DISK"

if [[ $# -eq 0 ]]; then
    require_tty
    read -r -p "Type WIPE to continue: " confirm </dev/tty
    if [[ "$confirm" != "WIPE" ]]; then
        echo "Aborted."
        exit 1
    fi
elif [[ "${ARCHINSTALL_CONFIRM_WIPE:-}" != "1" ]]; then
    echo "ERROR: Set ARCHINSTALL_CONFIRM_WIPE=1 to allow non-interactive disk wipe." >&2
    exit 1
fi

archinstall --config "$tmp_config" --creds "$tmp_creds" --silent
post_install_copy_key