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

require_tty() {
    if [[ ! -r /dev/tty ]]; then
        echo "ERROR: Interactive mode needs a TTY." >&2
        exit 1
    fi
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
        pacman -Sy --needed --noconfirm git just openssh
    fi
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
    echo "ERROR: Missing credentials: $creds" >&2
    exit 1
fi

tmp_config="$(mktemp)"
cleanup() {
    rm -f "$tmp_config"
}
trap cleanup EXIT

python - "$config" "$tmp_config" "$host" "$target_disk" <<'PY'
import json
import sys

src, dest, hostname, disk = sys.argv[1:]

with open(src, encoding="utf-8") as fh:
    data = json.load(fh)

data["hostname"] = hostname

mod = data["disk_config"]["device_modifications"][0]
mod["device"] = disk

for partition in mod["partitions"]:
    if "length" in partition and "size" not in partition:
        partition["size"] = partition.pop("length")

with open(dest, "w", encoding="utf-8") as fh:
    json.dump(data, fh, indent=2)
    fh.write("\n")
PY

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

archinstall --config "$tmp_config" --creds "$creds"