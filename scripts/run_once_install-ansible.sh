#!/usr/bin/env bash
# Bootstrap script: installs Ansible + secrets tooling on Debian/Ubuntu then runs the playbook.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Updating apt cache..."
sudo apt-get update -y

echo "==> Installing Ansible dependencies..."
sudo apt-get install -y software-properties-common python3 python3-pip curl

echo "==> Installing Ansible..."
sudo apt-get install -y ansible

echo "==> Verifying Ansible installation..."
ansible --version

echo "==> Installing age..."
sudo apt-get install -y age

echo "==> Installing sops (latest)..."
ARCH="$(dpkg --print-architecture)"
SOPS_VERSION="$(curl -fsSL https://api.github.com/repos/getsops/sops/releases/latest | grep '"tag_name"' | cut -d'"' -f4)"
SOPS_VERSION="${SOPS_VERSION#v}"

if command -v sops &>/dev/null; then
  INSTALLED="$(sops --version 2>&1 | grep -oP '\d+\.\d+\.\d+')"
  if dpkg --compare-versions "$INSTALLED" ge "$SOPS_VERSION"; then
    echo "    sops ${INSTALLED} already installed, skipping."
  else
    echo "    Upgrading sops ${INSTALLED} -> ${SOPS_VERSION}..."
    SOPS_URL="https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops_${SOPS_VERSION}_${ARCH}.deb"
    TMP_DEB="$(mktemp --suffix=.deb)"
    curl -fsSL "$SOPS_URL" -o "$TMP_DEB"
    sudo dpkg -i "$TMP_DEB"
    rm -f "$TMP_DEB"
  fi
else
  echo "    Installing sops ${SOPS_VERSION}..."
  SOPS_URL="https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops_${SOPS_VERSION}_${ARCH}.deb"
  TMP_DEB="$(mktemp --suffix=.deb)"
  curl -fsSL "$SOPS_URL" -o "$TMP_DEB"
  sudo dpkg -i "$TMP_DEB"
  rm -f "$TMP_DEB"
fi
sops --version

echo "==> Installing Ansible collections..."
ansible-galaxy collection install -r "${SCRIPT_DIR}/../ansible/requirements.yml"

echo "==> Setting hostname..."
current_hostname="$(hostname)"
if [[ "$current_hostname" != "desktop" && "$current_hostname" != "laptop" ]]; then
  echo "Current hostname is '$current_hostname'."
  read -rp "Is this machine a desktop or laptop? [desktop/laptop]: " machine_type
  if [[ "$machine_type" == "desktop" || "$machine_type" == "laptop" ]]; then
    sudo hostnamectl set-hostname "$machine_type"
    echo "Hostname set to '$machine_type'."
  else
    echo "Invalid input. Must be 'desktop' or 'laptop'. Aborting." >&2
    exit 1
  fi
fi

echo "==> Running Ansible playbook..."
cd "${SCRIPT_DIR}/../ansible"

ansible-playbook playbooks/setup.yml -l "$(hostname)" --ask-become-pass

echo "==> Setup complete."