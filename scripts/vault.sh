#!/usr/bin/env bash
# Encrypt or decrypt all SOPS vault files in the repo.
# Usage: ./scripts/vault.sh encrypt
#        ./scripts/vault.sh decrypt
set -euo pipefail
SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/key}"
export SOPS_AGE_KEY_FILE

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

VAULT_FILES=(
  "ansible/inventory/group_vars/vault.yml"
  "ansible/inventory/host_vars/desktop/vault.yml"
  "ansible/inventory/host_vars/laptop/vault.yml"
)

if [[ $# -ne 1 || ( "$1" != "encrypt" && "$1" != "decrypt" ) ]]; then
  echo "Usage: $0 [encrypt|decrypt]" >&2
  exit 1
fi

ACTION="$1"

for rel_path in "${VAULT_FILES[@]}"; do
  file="${REPO_ROOT}/${rel_path}"

  if [[ ! -f "$file" ]]; then
    echo "Skipping (not found): ${rel_path}"
    continue
  fi

  if [[ "$ACTION" == "encrypt" ]]; then
    if sops --input-type yaml filestatus "$file" 2>/dev/null | grep -q '"encrypted": true'; then
      echo "Already encrypted: ${rel_path}"
    else
      sops --encrypt --in-place "$file"
      echo "Encrypted: ${rel_path}"
    fi
  else
    if sops --input-type yaml filestatus "$file" 2>/dev/null | grep -q '"encrypted": false'; then
      echo "Already decrypted: ${rel_path}"
    else
      sops --decrypt --in-place "$file"
      echo "Decrypted: ${rel_path}"
    fi
  fi
done
