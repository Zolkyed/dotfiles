# Scripts

## run_once_install-ansible.sh

Full bootstrap for fresh Debian or Arch Linux machines. Installs all dependencies
then runs the Ansible playbook:

```bash
bash scripts/run_once_install-ansible.sh desktop
```

What it does:

1. Detects distro family (Debian or Arch)
2. Updates package cache
3. Installs Ansible
4. Installs `age`
5. Exports `SOPS_AGE_KEY_FILE` (defaults to `~/.config/sops/age/keys.txt`)
6. Installs `sops` (latest GitHub release for Debian, pacman for Arch)
7. Installs Ansible collections from `requirements.yml`
8. Installs a validated passwordless sudoers drop-in for the bootstrap user
9. Runs the local playbook

Put the age identity at `~/.config/sops/age/keys.txt`, or set
`SOPS_AGE_KEY_FILE` before running. The sudoers drop-in is installed for
`${SUDO_USER:-$USER}` by default; set `BOOTSTRAP_USER` to override it.

To choose the local inventory host:

```bash
bash scripts/run_once_install-ansible.sh desktop
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
