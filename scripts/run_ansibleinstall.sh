#!/usr/bin/env bash
# Bootstrap: installs Ansible + secrets tooling then runs the playbook.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}"
export SOPS_AGE_KEY_FILE
AGE_KEY_ENCRYPTED="${REPO_DIR}/secrets/age_key.age"

target_host="${BOOTSTRAP_HOST:-${1:-}}"
case "$target_host" in
    desktop | laptop | server) ;;
    *)
        echo "ERROR: Specify an Ansible install host: desktop, laptop, or server." >&2
        echo "Usage: $0 [desktop|laptop|server]" >&2
        exit 1
        ;;
esac

if [[ "${EUID}" -eq 0 && -z "${BOOTSTRAP_USER:-}" ]]; then
    echo "ERROR: Run this as the installed user, not root." >&2
    echo "If you really need root bootstrap, set BOOTSTRAP_USER and SOPS_AGE_KEY_FILE explicitly." >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# Passwordless sudo
# ---------------------------------------------------------------------------
install_passwordless_sudo() {
    local bootstrap_user="${BOOTSTRAP_USER:-${SUDO_USER:-$USER}}"
    local sudoers_file="/etc/sudoers.d/99-dotfiles-nopasswd"
    local visudo
    local tmp

    visudo="$(command -v visudo)" || { echo "ERROR: visudo not found" >&2; exit 1; }
    echo "==> Granting passwordless sudo to: ${bootstrap_user}"

    tmp="$(mktemp)"
    printf '%s ALL=(ALL:ALL) NOPASSWD: ALL\n' "$bootstrap_user" >"$tmp"

    if ! "$visudo" -cf "$tmp"; then
        rm -f "$tmp"
        exit 1
    fi

    sudo install -o root -g root -m 0440 "$tmp" "$sudoers_file"
    rm -f "$tmp"
}

# ---------------------------------------------------------------------------
# Step 1: Passwordless sudo
# ---------------------------------------------------------------------------
install_passwordless_sudo

# ---------------------------------------------------------------------------
# Step 2: Update package cache + install age, sops, Ansible
# ---------------------------------------------------------------------------
echo "==> Updating package cache..."
# -Sy only: avoid a full system upgrade mid-bootstrap
sudo pacman -Sy --noconfirm

echo "==> Installing age, sops, and Ansible..."
sudo pacman -S --needed --noconfirm age sops ansible

# ---------------------------------------------------------------------------
# Step 3: Decrypt age key (age is now guaranteed to be installed)
# ---------------------------------------------------------------------------
decrypt_age_key() {
    if [[ -f "$SOPS_AGE_KEY_FILE" ]]; then
        return
    fi
    if [[ ! -f "$AGE_KEY_ENCRYPTED" ]]; then
        echo "ERROR: No age key at ${SOPS_AGE_KEY_FILE} and no encrypted key at ${AGE_KEY_ENCRYPTED}" >&2
        echo "Encrypt your age key to ${AGE_KEY_ENCRYPTED} on a machine that has it, then commit the result." >&2
        exit 1
    fi
    mkdir -p "$(dirname "$SOPS_AGE_KEY_FILE")"
    # stderr suppressed intentionally; failure is caught and reported below
    if ! age -d -o "$SOPS_AGE_KEY_FILE" "$AGE_KEY_ENCRYPTED" 2>/dev/null; then
        rm -f "$SOPS_AGE_KEY_FILE"
        echo "ERROR: Failed to decrypt age key. Wrong passphrase?" >&2
        exit 1
    fi
    chmod 600 "$SOPS_AGE_KEY_FILE"
    echo "==> Age key decrypted to ${SOPS_AGE_KEY_FILE}"
}

decrypt_age_key

# ---------------------------------------------------------------------------
# Step 4: Ansible collections
# ---------------------------------------------------------------------------
echo "==> Installing Ansible collections..."
ansible-galaxy collection install -r "${REPO_DIR}/ansible/requirements.yml"

# ---------------------------------------------------------------------------
# Step 5: Run playbook
# ---------------------------------------------------------------------------
echo "==> Running Ansible playbook..."
cd "${REPO_DIR}/ansible"

ansible-playbook -i inventory/local.yml playbooks/setup.yml -l "$target_host"
echo "==> Setup complete."
