# Ansible

Full machine provisioning for Debian/Ubuntu + KDE Plasma.

## Usage

```bash
# From repo root — bootstrap everything from scratch
bash scripts/run_once_install-ansible.sh

# Already installed
cd ansible
ansible-playbook playbooks/setup.yml -l desktop
ansible-playbook playbooks/setup.yml -l laptop

# Dry-run
ansible-playbook playbooks/setup.yml --check --diff -l desktop
```

## Inventory variables

| Variable | File | Notes |
|---|---|---|
| `desktop_environment` | `group_vars/all.yml` | Single source of truth |
| `extra_packages` | `group_vars/all.yml` | Single source of truth |
| `flatpak_apps` | `group_vars/all.yml` | Single source of truth |
| `user_groups` | `group_vars/all.yml` | Single source of truth |
| `base_packages` | `group_vars/Debian.yml` | OS-specific names |
| `machine_type`, `primary_monitor`, GRUB vars | `host_vars/<host>/vars.yml` | Per-machine overrides |

## Roles

### system/
| Role | Purpose |
|---|---|
| packages | apt base + extra packages |
| flatpak | Flathub remote + apps |
| fonts | Nerd Fonts |
| docker | Docker CE + compose plugin |
| nvidia | Proprietary driver, nouveau blacklist |
| vm | KVM/QEMU + virt-manager |
| gaming | Steam, Lutris, gamemode, Heroic |
| networking | NetworkManager + systemd-resolved |
| ssh | sshd hardening |
| bluetooth | bluez |
| bootloader | GRUB (auto-detects BIOS vs UEFI) |
| display_manager | SDDM |

### desktop/
| Role | Purpose |
|---|---|
| kde | KDE Plasma packages, optional konsave restore, and keybind settings |

### home/user/
| Role | Purpose |
|---|---|
| (main) | User account, shell, groups |
| dotfiles | chezmoi install + `apply --force` |
| ssh_keys | Deploy keys from SOPS vault |
| dev | Dev tools, nvm, rustup |
| bin | Custom scripts → `~/.local/bin` |

## Post-run report

After each playbook run a report is written to `~/ansible-setup-YYYY-MM-DD.log` listing:
- Tool versions (git, zsh, docker, flatpak, chezmoi)
- All installed flatpak apps
- All installed apt packages
