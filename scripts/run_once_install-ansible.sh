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

echo "==> Installing just (optional dev command runner)..."
if [[ "$DISTRO" == "debian" ]]; then
    sudo apt-get install -y just || echo "    just package unavailable; install manually or run commands directly."
else
    sudo pacman -S --needed --noconfirm just
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
# age key bootstrap
# ---------------------------------------------------------------------------
SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}"
export SOPS_AGE_KEY_FILE

bootstrap_age_key() {
    local key_dir key_bootstrap key_bootstrap_file

    key_dir="$(dirname "$SOPS_AGE_KEY_FILE")"
    key_bootstrap="${AGE_KEY_BOOTSTRAP:-}"
    key_bootstrap_file="${AGE_KEY_BOOTSTRAP_FILE:-}"

    if [[ -s "$SOPS_AGE_KEY_FILE" ]]; then
        chmod 600 "$SOPS_AGE_KEY_FILE"
        echo "==> Using existing age key: ${SOPS_AGE_KEY_FILE}"
        return
    fi

    mkdir -p "$key_dir"
    chmod 700 "$key_dir"

    if [[ -n "$key_bootstrap_file" ]]; then
        if [[ ! -f "$key_bootstrap_file" ]]; then
            echo "ERROR: AGE_KEY_BOOTSTRAP_FILE does not exist: ${key_bootstrap_file}" >&2
            exit 1
        fi
        cp "$key_bootstrap_file" "$SOPS_AGE_KEY_FILE"
    elif [[ -n "$key_bootstrap" ]]; then
        printf '%s\n' "$key_bootstrap" >"$SOPS_AGE_KEY_FILE"
    else
        echo "ERROR: No age key found at ${SOPS_AGE_KEY_FILE}." >&2
        echo "Set AGE_KEY_BOOTSTRAP to your AGE-SECRET-KEY line, or set AGE_KEY_BOOTSTRAP_FILE to an existing key file." >&2
        exit 1
    fi

    chmod 600 "$SOPS_AGE_KEY_FILE"
    echo "==> Bootstrapped age key: ${SOPS_AGE_KEY_FILE}"
}

bootstrap_age_key

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
