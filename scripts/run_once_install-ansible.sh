#!/usr/bin/env bash
# Bootstrap script: installs Ansible + secrets tooling on Debian/Ubuntu then runs the playbook.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Updating apt cache..."
sudo apt-get update -y

echo "==> Installing Ansible dependencies..."
sudo apt-get install -y software-properties-common python3 python3-pip

echo "==> Installing Ansible..."
sudo apt-get install -y ansible

echo "==> Verifying Ansible installation..."
ansible --version

echo "==> Installing age (required for SOPS secret decryption)..."
sudo apt-get install -y age

echo "==> Installing sops..."
SOPS_VERSION=$(curl -s https://api.github.com/repos/getsops/sops/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
curl -fsSLo /tmp/sops.deb "https://github.com/getsops/sops/releases/download/${SOPS_VERSION}/sops_${SOPS_VERSION#v}_amd64.deb"
sudo apt-get install -y /tmp/sops.deb
rm /tmp/sops.deb

echo "==> Checking age key..."
AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"
if [[ ! -f "$AGE_KEY_FILE" ]]; then
  echo "    No age key found at $AGE_KEY_FILE."
  echo "    Generating a new key..."
  mkdir -p "$(dirname "$AGE_KEY_FILE")"
  age-keygen -o "$AGE_KEY_FILE"
  echo
  echo "    *** ACTION REQUIRED ***"
  echo "    Your new age public key is:"
  grep "public key" "$AGE_KEY_FILE"
  echo "    Update .sops.yaml with this key, then re-encrypt secrets/vault.yml:"
  echo "      sops updatekeys secrets/vault.yml"
  echo
else
  echo "    Age key found: $AGE_KEY_FILE"
fi

echo "==> Installing Ansible collections..."
ansible-galaxy collection install -r "${SCRIPT_DIR}/../ansible/requirements.yml"

echo "==> Running Ansible playbook..."
cd "${SCRIPT_DIR}/../ansible"

ansible-playbook playbooks/setup.yml --ask-become-pass

echo "==> Setup complete."
