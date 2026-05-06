# Ansible

Full machine provisioning for Debian and Arch Linux.

## Usage

```bash
# From repo root - bootstrap everything from scratch
bash scripts/run_once_install-ansible.sh

# Run against a host over SSH
cd ansible
ansible-playbook playbooks/setup.yml -l desktop
ansible-playbook playbooks/setup.yml -l laptop

# Run directly on the current machine
ansible-playbook -i inventory/local.yml playbooks/setup.yml -l desktop

# Local CI/lint tooling
just setup-dev
just ci

# Dry-run
ansible-playbook playbooks/setup.yml --check --diff -l desktop
```

Inventory hosts default to SSH. `inventory/hosts.yml` maps `desktop`, `laptop`, and
`server` to same-named SSH hosts and uses `ansible_user: charl`. Override
`ansible_host` or `ansible_user` there if your SSH target names differ.

`inventory/local.yml` is for running directly on the current machine. It maps the
same logical hosts to `localhost` with `ansible_connection: local`, so your
`host_vars/desktop`, `host_vars/laptop`, and `host_vars/server` still apply.

## Inventory variables

| Variable | File | Notes |
|---|---|---|
| feature flags | `group_vars/all.yml` | Shared defaults; override per host |
| shared Flatpaks/fonts | `group_vars/all.yml` | Distro-agnostic app/font lists |
| user defaults/groups | `group_vars/all.yml` | Shared user settings |
| package/service variables | `group_vars/Debian.yml`, `group_vars/Archlinux.yml` | OS-specific names |
| host feature flags, desktop_monitors, GRUB vars | `host_vars/<host>/vars.yml` | Per-machine overrides |

## Roles

### system/
| Role | Purpose |
|---|---|
| packages | distro package cache + base packages |
| fonts | Nerd Fonts |
| docker | Docker CE + compose plugin |
| nvidia | Proprietary driver, nouveau blacklist |
| virtualization | KVM/QEMU + virt-manager |
| aur | Arch AUR helper (`paru`) |
| networking | NetworkManager + systemd-resolved |
| ssh | sshd hardening |
| bluetooth | bluez |
| bootloader | GRUB (auto-detects BIOS vs UEFI) |
| btrfs | Subvolumes, mounts, scrub/balance timers, quotas |
| snapper | Snapshot configs and timeline/cleanup timers |
| grub-btrfs | GRUB snapshot boot menu integration |
| display_manager | SDDM |

### desktop/
| Role | Purpose |
|---|---|
| kde | KDE Plasma rclone/konsave/keybind setup |

### home/
| Role | Purpose |
|---|---|
| flatpak | Flathub remote + user apps |
| (main) | User account, shell, groups |
| dotfiles | chezmoi install + `apply --force` |
| browser | Brave install + managed extension policy |
| home_ssh_keys | Deploy keys from SOPS vault |
| dev | Dev tools, nvm, rustup |
| bin | Custom scripts → `~/.local/bin` |
| gaming | Steam, Lutris, gamemode, Heroic |

## Supported distributions

`setup.yml` fails early unless the target is Debian or Arch Linux. Debian-family
and Arch-family derivatives are intentionally not treated as supported targets.
