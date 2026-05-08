#!/usr/bin/env bash
# Bootstrap script: installs Ansible + secrets tooling then runs the playbook.
# Supports Debian (apt) and Arch Linux (pacman).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------------------------
# Distro detection
# ---------------------------------------------------------------------------
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        # shellcheck source=/dev/null
        source /etc/os-release
        distro_id="${ID:-}"
        distro_like=" ${ID_LIKE:-} "

        if [[ "$distro_id" == "debian" || "$distro_like" == *" debian "* ]]; then
            echo "debian"
        elif [[ "$distro_id" == "arch" || "$distro_like" == *" arch "* ]]; then
            echo "arch"
        else
            echo "unknown"
        fi
    else
        echo "unknown"
    fi
}

DISTRO="$(detect_distro)"
if [[ "$DISTRO" == "unknown" ]]; then
    echo "ERROR: Unsupported distribution family. Supported: Debian and Arch Linux." >&2
    exit 1
fi
echo "==> Detected distro family: ${DISTRO}"

# ---------------------------------------------------------------------------
# Package manager helpers
# ---------------------------------------------------------------------------
pkg_install() {
    # Usage: pkg_install <debian-pkg> [arch-pkg]
    # If arch-pkg is omitted it falls back to debian-pkg.
    local deb_pkg="$1"
    local arch_pkg="${2:-$1}"

    if [[ "$DISTRO" == "debian" ]]; then
        sudo apt-get install -y "$deb_pkg"
    else
        # pacman: skip if already installed (-S --needed is idempotent)
        sudo pacman -S --needed --noconfirm "$arch_pkg"
    fi
}

visudo_path() {
    if [[ "$DISTRO" == "debian" ]]; then
        echo "/usr/sbin/visudo"
    else
        echo "/usr/bin/visudo"
    fi
}

install_passwordless_sudo() {
    local bootstrap_user="${BOOTSTRAP_USER:-${SUDO_USER:-$USER}}"
    local sudoers_file="/etc/sudoers.d/dotfiles-nopasswd"
    local legacy_sudoers_file="/etc/sudoers.d/dotfiles-pacman-nopasswd"
    local visudo
    local tmp

    visudo="$(visudo_path)"
    if [[ ! -x "$visudo" ]]; then
        echo "ERROR: visudo not found at ${visudo}" >&2
        exit 1
    fi

    echo "    granting passwordless sudo to: ${bootstrap_user}"
    tmp="$(mktemp)"
    printf '%s ALL=(ALL:ALL) NOPASSWD: ALL\n' "$bootstrap_user" >"$tmp"

    if ! "$visudo" -cf "$tmp"; then
        rm -f "$tmp"
        exit 1
    fi

    sudo install -o root -g root -m 0440 "$tmp" "$sudoers_file"
    sudo rm -f "$legacy_sudoers_file"
    rm -f "$tmp"
}

# ---------------------------------------------------------------------------
# Update package cache
# ---------------------------------------------------------------------------
echo "==> Updating package cache..."
if [[ "$DISTRO" == "debian" ]]; then
    sudo apt-get update -y
else
    sudo pacman -Syu --noconfirm
fi

# ---------------------------------------------------------------------------
# Ansible
# ---------------------------------------------------------------------------
echo "==> Installing Ansible..."
pkg_install ansible ansible

# ---------------------------------------------------------------------------
# age
# ---------------------------------------------------------------------------
echo "==> Installing age..."
pkg_install age age

# ---------------------------------------------------------------------------
# SOPS age key path
# ---------------------------------------------------------------------------
SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}"
export SOPS_AGE_KEY_FILE
echo "==> Using SOPS age key file: ${SOPS_AGE_KEY_FILE}"

# ---------------------------------------------------------------------------
# sops
# ---------------------------------------------------------------------------
echo "==> Installing sops (latest)..."

# Arch: sops is in the community/extra repo
if [[ "$DISTRO" == "arch" ]]; then
    sudo pacman -S --needed --noconfirm sops
    sops --version
else
    # Debian: download the .deb from GitHub releases
    sudo apt-get install -y curl
    ARCH_DEB="$(dpkg --print-architecture)"
    SOPS_VERSION="$(curl -fsSL https://api.github.com/repos/getsops/sops/releases/latest \
        | grep '"tag_name"' | cut -d'"' -f4)"
    SOPS_VERSION="${SOPS_VERSION#v}"

    install_sops_deb() {
        local ver="$1"
        local url="https://github.com/getsops/sops/releases/download/v${ver}/sops_${ver}_${ARCH_DEB}.deb"
        local tmp
        tmp="$(mktemp --suffix=.deb)"
        curl -fsSL "$url" -o "$tmp"
        sudo dpkg -i "$tmp"
        rm -f "$tmp"
    }

    if command -v sops &>/dev/null; then
        INSTALLED="$(sops --version 2>&1 | grep -oP '\d+\.\d+\.\d+')"
        if dpkg --compare-versions "$INSTALLED" ge "$SOPS_VERSION"; then
            echo "    sops ${INSTALLED} already installed, skipping."
        else
            echo "    Upgrading sops ${INSTALLED} -> ${SOPS_VERSION}..."
            install_sops_deb "$SOPS_VERSION"
        fi
    else
        echo "    Installing sops ${SOPS_VERSION}..."
        install_sops_deb "$SOPS_VERSION"
    fi

    sops --version
fi

# ---------------------------------------------------------------------------
# Ansible collections
# ---------------------------------------------------------------------------
echo "==> Installing Ansible collections..."
ansible-galaxy collection install -r "${SCRIPT_DIR}/../ansible/requirements.yml"

# ---------------------------------------------------------------------------
# Passwordless sudo
# ---------------------------------------------------------------------------
echo "==> Installing passwordless sudoers drop-in..."
install_passwordless_sudo

# ---------------------------------------------------------------------------
# Run playbook
# ---------------------------------------------------------------------------
echo "==> Running Ansible playbook..."
cd "${SCRIPT_DIR}/../ansible"
target_host="${BOOTSTRAP_HOST:-${1:-}}"
case "$target_host" in
    desktop | laptop | server) ;;
    *)
        echo "ERROR: Choose a bootstrap host." >&2
        echo "Usage: $0 [desktop|laptop|server]" >&2
        exit 1
        ;;
esac
ansible-playbook -i inventory/local.yml playbooks/setup.yml -l "$target_host"

echo "==> Setup complete."
