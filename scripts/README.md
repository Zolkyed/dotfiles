# Scripts

## run_once_install-ansible.sh

Full bootstrap for fresh Debian or Arch Linux machines. Installs all dependencies
then runs the Ansible playbook:

```bash
bash scripts/run_once_install-ansible.sh
```

What it does:

1. Detects distro family (Debian or Arch)
2. Updates package cache
3. Installs base dependencies (python, pip, curl)
4. Installs `just` (optional command runner)
5. Installs Ansible (via apt, pacman, or pip fallback)
6. Installs `age` encryption tool
7. Bootstraps the SOPS age identity from `AGE_KEY_BOOTSTRAP` or
   `AGE_KEY_BOOTSTRAP_FILE`
8. Installs `sops` (latest GitHub release for Debian, pacman for Arch)
9. Installs Ansible collections from `requirements.yml`
10. Prompts to set hostname if not already `desktop` or `laptop`
11. Runs the playbook with `--ask-become-pass`

The bootstrap writes the key to `~/.config/sops/age/keys.txt` by default. For
an existing machine key:

```bash
AGE_KEY_BOOTSTRAP='AGE-SECRET-KEY-...' bash scripts/run_once_install-ansible.sh
```

## vault.sh

Encrypt or decrypt all SOPS vault files in the repo:

```bash
bash scripts/vault.sh encrypt
bash scripts/vault.sh decrypt
```

Operates on:
- `ansible/inventory/group_vars/vault.yml`
- `ansible/inventory/host_vars/desktop/vault.yml`
- `ansible/inventory/host_vars/laptop/vault.yml`
- `ansible/inventory/host_vars/server/vault.yml`
