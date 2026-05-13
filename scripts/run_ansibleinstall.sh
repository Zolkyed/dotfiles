#!/usr/bin/env bash
# Bootstrap: installs Ansible + secrets tooling then runs the playbook.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------------------------
# Passwordless sudo
# ---------------------------------------------------------------------------
install_passwordless_sudo() {
    local bootstrap_user="${BOOTSTRAP_USER:-${SUDO_USER:-$USER}}"
    local sudoers_file="/etc/sudoers.d/dotfiles-nopasswd"
    local visudo tmp

    visudo="$(command -v visudo)" || { echo "ERROR: visudo not found" >&2; exit 1; }
    echo "    granting passwordless sudo to: ${bootstrap_user}"

    tmp="$(mktemp)"
    printf '%s ALL=(ALL:ALL) NOPASSWD: ALL\n' "$bootstrap_user" >"$tmp"

    if ! "$visudo" -cf "$tmp"; then
        rm -f "$tmp"
        exit 1
    fi

    sudo install -o root -g root -m 0440 "$tmp" "$sudoers_file"
    rm -f "$tmp"
}

install_passwordless_sudo

# ---------------------------------------------------------------------------
# Update package cache + install Ansible, age, sops
# ---------------------------------------------------------------------------
echo "==> Updating package cache..."
sudo pacman -Syu --noconfirm

echo "==> Installing Ansible, age, and sops..."
sudo pacman -S --needed --noconfirm ansible age sops

# ---------------------------------------------------------------------------
# Ansible collections
# ---------------------------------------------------------------------------
echo "==> Installing Ansible collections..."
ansible-galaxy collection install -r "${SCRIPT_DIR}/../ansible/requirements.yml"

# ---------------------------------------------------------------------------
# Run playbook
# ---------------------------------------------------------------------------
echo "==> Running Ansible playbook..."
cd "${SCRIPT_DIR}/../ansible"

target_host="${BOOTSTRAP_HOST:-${1:-}}"
case "$target_host" in
    desktop | laptop | server) ;;
    *)
        echo "ERROR: Specify a bootstrap host: desktop, laptop, or server." >&2
        echo "Usage: $0 [desktop|laptop|server]" >&2
        exit 1
        ;;
esac

ansible-playbook -i inventory/local.yml playbooks/setup.yml -l "$target_host"
echo "==> Setup complete."
