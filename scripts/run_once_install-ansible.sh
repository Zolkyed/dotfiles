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

echo "==> Installing age..."
sudo apt install -y age

echo "==> Installing Ansible collections..."
ansible-galaxy collection install -r "${SCRIPT_DIR}/../ansible/requirements.yml"

echo "==> Running Ansible playbook..."
cd "${SCRIPT_DIR}/../ansible"

ansible-playbook playbooks/setup.yml --ask-become-pass

echo "==> Setup complete."
