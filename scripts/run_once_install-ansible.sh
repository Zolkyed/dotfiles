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
# Base dependencies
# ---------------------------------------------------------------------------
echo "==> Installing base dependencies..."
if [[ "$DISTRO" == "debian" ]]; then
    sudo apt-get install -y software-properties-common python3 python3-pip curl
else
    sudo pacman -S --needed --noconfirm python python-pip curl inetutils
fi

# ---------------------------------------------------------------------------
# Ansible
# ---------------------------------------------------------------------------
echo "==> Installing Ansible..."
if [[ "$DISTRO" == "debian" ]]; then
    sudo apt-get install -y ansible
else
    if ! sudo pacman -S --needed --noconfirm ansible 2>/dev/null; then
        echo "    ansible not found in pacman repos, installing via pip..."
        pip install --user ansible
        export PATH="$HOME/.local/bin:$PATH"
    fi
fi

# Ensure ansible-playbook is reachable regardless of install method
export PATH="$HOME/.local/bin:/usr/bin:$PATH"

echo "==> Verifying Ansible installation..."
ansible --version

# ---------------------------------------------------------------------------
# age
# ---------------------------------------------------------------------------
echo "==> Installing age..."
pkg_install age age

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
# Hostname
# ---------------------------------------------------------------------------
echo "==> Setting hostname..."
current_hostname="$(hostname)"
if [[ "$current_hostname" != "desktop" && "$current_hostname" != "laptop" ]]; then
    echo "Current hostname is '${current_hostname}'."
    read -rp "Is this machine a desktop or laptop? [desktop/laptop]: " machine_type
    if [[ "$machine_type" == "desktop" || "$machine_type" == "laptop" ]]; then
        sudo hostnamectl set-hostname "$machine_type"
        echo "Hostname set to '${machine_type}'."
    else
        echo "Invalid input. Must be 'desktop' or 'laptop'. Aborting." >&2
        exit 1
    fi
fi

# ---------------------------------------------------------------------------
# Run playbook
# ---------------------------------------------------------------------------
echo "==> Running Ansible playbook..."
cd "${SCRIPT_DIR}/../ansible"
ansible-playbook playbooks/setup.yml -l "$(hostname)" --ask-become-pass

echo "==> Setup complete."
