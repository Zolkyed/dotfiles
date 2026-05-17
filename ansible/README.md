# Ansible

Arch Linux provisioning.

```bash
just ansibleinstall <host>   # full bootstrap
just run <host>              # remote
just run-local <host>        # local
just update                  # local system update
just update-remote <host>    # remote system update
just check <host>            # dry-run
just maintenance <host>      # local maintenance tasks
just syntax                  # Ansible syntax checks
just lint                    # ansible-lint, yamllint, shellcheck
```

## Inventory

| File | Connection |
|---|---|
| `inventory/hosts.yml` | SSH |
| `inventory/local.yml` | Local |

Hosts: `desktop`, `laptop`, `server`.

## Vars

| File | Contents |
|---|---|
| `group_vars/all.yml` | user, presets, feature flags |
| `group_vars/vault.yml` | shared secrets (SOPS) |
| `host_vars/<host>/vars.yml` | active preset |
| `host_vars/<host>/vault.yml` | SSH keys (SOPS) |

Package, service, Flatpak, AUR, npm, and pipx lists live in each role's
`defaults/main.yml`.

## Features

Each host activates a preset which enables a list of features. Features gate optional roles.

```yaml
# host_vars/desktop/vars.yml
active_preset: desktop

# group_vars/all.yml
presets:
  desktop:
    features: [audio, nvidia_gpu, plasma, browser, gaming, ...]
```

## Roles

### Always-on

| Role | Tag | Purpose |
|---|---|---|
| `system/kernel` | kernel | Kernel parameters, systemd-oomd |
| `user/account` | user | User creation and group membership |
| `system/sudoers` | sudoers | Passwordless sudo |
| `system/mirrors` | mirrors | Reflector mirror updates |
| `system/pacman` | pacman | pacman.conf, multilib, system upgrade |
| `system/aur` | aur | Paru install and config |
| `system/core` | core | Base packages and CLI tools |
| `user/shell` | shell | Zsh + plugins |
| `system/journald` | journald | Journal retention |
| `system/networking` | networking | Hostname, NetworkManager, systemd-resolved |
| `system/ntp` | ntp | systemd-timesyncd |
| `system/sshd` | sshd | SSH host keys and hardening |
| `system/maintenance` | maintenance | fstrim, btrfs scrub, pkgfile |
| `system/fonts` | fonts | System fonts + Nerd Fonts |
| `system/microcode` | microcode | CPU microcode (auto-detected) |
| `user/ssh_keys` | ssh_keys | Deploy SSH keys from vault |
| `user/bin` | bin | Custom scripts to ~/.local/bin |
| `user/dotfiles` | dotfiles | Chezmoi dotfile application |

### Conditional (feature-gated)

| Role | Tag | Feature | Purpose |
|---|---|---|---|
| `system/vpn` | vpn | `vpn` | WireGuard tools |
| `system/firmware` | firmware | `firmware` | fwupd refresh timer |
| `system/firewall` | firewall | `firewall` | UFW firewall |
| `system/fail2ban` | fail2ban | `fail2ban` | SSH jail |
| `system/audio` | audio | `audio` | PipeWire stack |
| `system/bluetooth` | bluetooth | `bluetooth` | bluez |
| `system/avahi` | avahi | `avahi` | mDNS / .local resolution |
| `system/nvidia_gpu` | nvidia_gpu | `nvidia_gpu` | NVIDIA drivers + DRM modesetting |
| `system/amd_gpu` | amd_gpu | `amd_gpu` | AMD GPU drivers |
| `system/intel_gpu` | intel_gpu | `intel_gpu` | Intel GPU drivers |
| `system/snapper` | snapper | `snapper` | Snapper + grub-btrfs snapshots |
| `system/splashboot` | splashboot | `splashboot` | Plymouth boot splash |
| `system/bootloader` | bootloader | `bootloader` | GRUB |
| `system/docker` | docker | `docker` | Docker CE |
| `system/virtualization` | virtualization | `virtualization` | libvirt + QEMU |
| `desktop/plasma` | plasma | `plasma` | KDE Plasma + SDDM |
| `desktop/wayland` | wayland | `wayland_common` | Wayland compositor tools |
| `desktop/hyprland` | hyprland | `hyprland` | Hyprland WM |
| `desktop/niri` | niri | `niri` | Niri WM |
| `apps/flatpak` | flatpak | `flatpak` | Flathub + base flatpaks |
| `apps/mihon` | mihon | `mihon` | Manga reader desktop entry |
| `apps/browser` | browser | `browser` | Brave + managed policies |
| `apps/rclone` | rclone | `rclone` | Google Drive sync |
| `apps/node` | node | `node` or `ai` dependency | Node.js via Volta |
| `apps/dev` | dev | `dev` | Dev tools (python, rust, gcc, …) |
| `apps/vscode` | vscode | `dev` | VS Code + extensions |
| `apps/media` | media | `media` | Media apps + konsave |
| `apps/office` | office | `office` | LibreOffice, Thunderbird, Zathura |
| `apps/gaming` | gaming | `gaming` | Steam, Lutris, Wine, … |
| `apps/ai` | ai | `ai` | AI CLI tools via Volta |
| `user/xdg` | xdg | `xdg` | XDG dirs and default apps |

### Shared utility

| Role | Purpose |
|---|---|
| `system/install` | Shared package install tasks (pacman, AUR, flatpak, pipx). Called via `include_role tasks_from: packages`. |

## Playbooks

| Playbook | Purpose |
|---|---|
| `playbooks/setup.yml` | One-time provisioning: users, package manager, packages, services, apps, dotfiles. |
| `playbooks/update.yml` | Recurring updates: mirrors, keyring, pacman/AUR/flatpak upgrades, cache cleanup. |
| `playbooks/dotfiles.yml` | Apply chezmoi dotfiles only. |
| `playbooks/maintenance.yml` | Housekeeping: orphan removal, journal vacuum, docker/snapper/paru cleanup. |
