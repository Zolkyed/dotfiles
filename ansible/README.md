# Ansible

Full machine provisioning for Debian and Arch Linux — 38 roles, one playbook.

## Usage

```bash
# From repo root — bootstrap everything from scratch
bash scripts/run_once_install-ansible.sh

# From repo root with just (after just setup-dev)
just run desktop                  # remote (SSH)
just run-local desktop            # local (no SSH)
just check desktop                # dry-run
just tags desktop nvidia          # run specific tags
```

Or run ansible-playbook directly:

```bash
cd ansible

# Remote (SSH)
ansible-playbook playbooks/setup.yml -l desktop

# Local (no SSH)
ansible-playbook -i inventory/local.yml playbooks/setup.yml -l desktop

# Dry-run
ansible-playbook playbooks/setup.yml --check --diff -l desktop
```

## Inventory

Two inventory files share the same logical host names and group_vars/host_vars:

| File | Connection | Use case |
|---|---|---|
| `inventory/hosts.yml` | SSH (remote) | Target machines by hostname |
| `inventory/local.yml` | Local | Run on the current machine without SSH |

Hosts: `desktop`, `laptop`, `server`. Each has a `vars.yml` (overrides) and
`vault.yml` (encrypted secrets) under `host_vars/<host>/`.

## Inventory variables

| Variable | File | Notes |
|---|---|---|
| Feature flags, user settings, Flatpaks, fonts | `group_vars/all.yml` | Shared defaults; override per host |
| Shared secrets (HA token, rclone, webhook) | `group_vars/vault.yml` | SOPS-encrypted |
| Package/service names | `group_vars/Debian.yml`, `group_vars/Archlinux.yml` | OS-specific |
| Host overrides (flags, bootloader, monitors) | `host_vars/<host>/vars.yml` | Per-machine |
| Host SSH keys | `host_vars/<host>/vault.yml` | SOPS-encrypted |

## Roles

### system/

| Role | Purpose |
|---|---|
| `package_cache` | Update apt/pacman cache |
| `sysctl` | Hostname, kernel parameters |
| `btrfs` | Subvolumes, mounts, scrub/balance timers, quotas |
| `aur` | Install `paru` AUR helper |
| `locale` | Locale, timezone, console keymap |
| `fonts` | Distro font packages + Nerd Fonts |
| `docker` | Docker CE + compose/buildx plugin |
| `nvidia` | Proprietary driver, nouveau blacklist, initramfs |
| `virtualization` | KVM/QEMU or VirtualBox |
| `networking` | NetworkManager + systemd-resolved |
| `vpn` | WireGuard + OpenVPN packages |
| `sshd` | sshd hardening (root login, pubkey, port) |
| `firewall` | ufw with allow/deny rules |
| `fail2ban` | jail.local for sshd |
| `bluetooth` | bluez |
| `pipewire` | PipeWire + WirePlumber (user mode, lingering) |
| `splashboot` | Plymouth theme + initramfs |
| `bootloader` | GRUB (auto-detects BIOS vs UEFI) |
| `snapper` | btrfs snapshot configs + timeline/cleanup timers |
| `grub-btrfs` | grub-btrfs daemon for snapshot boot entries |
| `display_manager` | SDDM |

### desktop/

| Role | Purpose |
|---|---|
| `hyprland` | Hyprland packages + config (monitors, keybinds, animations) |
| `niri` | Niri packages + config (outputs, keybinds) |
| `kde/rclone` | rclone config for Google Drive |
| `kde/keybinds` | Per-host `kglobalshortcutsrc` overrides |
| `kde/konsave/konsave_install` | Install konsave via pipx |
| `kde/konsave/konsave_import` | Restore KDE profile from Google Drive (tagged `never`) |
| `kde/konsave/konsave_export` | Save KDE profile to Google Drive (tagged `never`) |
| `kde/konsave/konsave_delete` | Delete KDE profile from Google Drive (tagged `never`) |

### home/

| Role | Purpose |
|---|---|
| `user` | User account, shell, groups |
| `packages` | Core, utility, media, office, system, fun packages |
| `hayase` | Hayase anime sync (.deb or AppImage) |
| `flatpak` | Flathub remote + base and gaming apps |
| `dotfiles` | chezmoi install + `apply --force` |
| `browser` | Browser install (AUR) + managed extension policy |
| `ssh_keys` | Deploy SSH keys from SOPS vault |
| `dev` | Dev tools, nvm, rustup |
| `bin` | Custom scripts + homectl Home Assistant config |
| `ai` | opencode CLI assistant |
| `gaming` | Steam, Lutris, multilib/i386, AUR packages |

## Supported distributions

`setup.yml` fails early unless the target is Debian or Arch Linux.
Derivatives are intentionally not treated as supported targets.
