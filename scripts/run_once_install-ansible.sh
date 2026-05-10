#!/usr/bin/env bash
# Bootstrap: installs Ansible + secrets tooling then runs the playbook.
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
    echo "ERROR: Unsupported distribution. Supported: Debian and Arch Linux." >&2
    exit 1
fi
echo "==> Detected distro family: ${DISTRO}"

# ---------------------------------------------------------------------------
# Package manager helpers
# ---------------------------------------------------------------------------
pkg_install() {
    # Usage: pkg_install <pkg> [arch-pkg]  (arch-pkg defaults to pkg)
    local deb_pkg="$1"
    local arch_pkg="${2:-$1}"

    if [[ "$DISTRO" == "debian" ]]; then
        sudo apt-get install -y "$deb_pkg"
    else
        sudo pacman -S --needed --noconfirm "$arch_pkg"
    fi
}

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
# Ansible + age
# ---------------------------------------------------------------------------
echo "==> Installing Ansible and age..."
pkg_install ansible
pkg_install age

# ---------------------------------------------------------------------------
# SOPS
# ---------------------------------------------------------------------------
SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}"
export SOPS_AGE_KEY_FILE
echo "==> Using SOPS age key file: ${SOPS_AGE_KEY_FILE}"

echo "==> Installing sops..."
if [[ "$DISTRO" == "arch" ]]; then
    sudo pacman -S --needed --noconfirm sops
else
    sudo apt-get install -y curl
    ARCH_DEB="$(dpkg --print-architecture)"
    SOPS_VERSION="$(curl -fsSL https://api.github.com/repos/getsops/sops/releases/latest \
        | grep '"tag_name"' | cut -d'"' -f4 | tr -d 'v')"

    install_sops_deb() {
        local tmp
        tmp="$(mktemp --suffix=.deb)"
        curl -fsSL "https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops_${SOPS_VERSION}_${ARCH_DEB}.deb" -o "$tmp"
        sudo dpkg -i "$tmp"
        rm -f "$tmp"
    }

    if command -v sops &>/dev/null; then
        INSTALLED="$(sops --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
        if dpkg --compare-versions "$INSTALLED" ge "$SOPS_VERSION"; then
            echo "    sops ${INSTALLED} already up to date, skipping."
        else
            echo "    Upgrading sops ${INSTALLED} -> ${SOPS_VERSION}..."
            install_sops_deb
        fi
    else
        echo "    Installing sops ${SOPS_VERSION}..."
        install_sops_deb
    fi
fi
sops --version

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
        echo "ERROR: Specify a bootstrap host: desktop, laptop, or server." >&2
        echo "Usage: $0 [desktop|laptop|server]" >&2
        exit 1
        ;;
esac

ansible-playbook -i inventory/local.yml playbooks/setup.yml -l "$target_host"
echo "==> Setup complete."
