# Ansible

Arch Linux provisioning.

```bash
just ansibleinstall <host>   # full bootstrap
just run <host>              # remote
just run-local <host>        # local
just update <host>           # remote system update
just update-local <host>     # local system update
just check <host>            # dry-run
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
| `group_vars/archlinux.yml` | profile package/service names |
| `group_vars/vault.yml` | shared secrets (SOPS) |
| `host_vars/<host>/vars.yml` | active preset |
| `host_vars/<host>/vault.yml` | SSH keys (SOPS) |

## Roles

| Role | Tag | When | Purpose |
|---|---|---|---|
| `system/sysctl` | sysctl | always | hostname, kernel params |
| `system/sudoers` | sudoers | always | passwordless sudo |
| `system/mirrors` | mirrors | always | reflector mirror updates |
| `system/pacman` | pacman | always | pacman.conf |
| `system/aur` | aur | always | paru install + config |
| `system/packages` | packages | always | bulk package install |
| `system/pipx` | pipx | always | Python CLI tools |
| `system/npm` | npm | always | global npm tools through Volta |
| `system/journald` | journald | always | journal retention |
| `system/networking` | networking | always | NetworkManager + resolved |
| `system/sshd` | sshd | always | host keys, hardening |
| `system/maintenance` | maintenance | always | fstrim, btrfs scrub, pkgfile |
| `system/fonts` | fonts | always | Nerd Fonts |
| `system/microcode` | microcode | always | CPU microcode |
| `system/firmware` | firmware | profile | fwupd refresh timer |
| `system/firewall` | firewall | profile | UFW |
| `system/fail2ban` | fail2ban | profile | SSH jail |
| `system/audio` | audio | profile | PipeWire |
| `system/avahi` | avahi | profile | mDNS / .local hostname resolution |
| `system/bluetooth` | bluetooth | profile | bluez |
| `system/nvidia` | nvidia | profile | drivers + modesetting |
| `system/docker` | docker | profile | Docker CE |
| `system/virtualization` | virtualization | profile | libvirt |
| `system/bootloader` | bootloader | profile | GRUB |
| `system/snapper` | snapper | profile | Snapper + grub-btrfs |
| `system/splashboot` | splashboot | profile | Plymouth |
| `desktop/plasma` | plasma | profile | SDDM, keybinds |
| `apps/browser` | browser | profile | Brave + policies |
| `apps/flatpak` | flatpak | profile | Flathub + apps |
| `apps/mihon` | mihon | profile | manga desktop entry |
| `apps/rclone` | rclone | profile | Google Drive |
| `user/account` | user | always | user creation |
| `user/ssh_keys` | ssh_keys | always | deploy SSH keys |
| `user/bin` | bin | always | custom scripts |
| `user/dotfiles` | dotfiles | always | chezmoi |
| `user/xdg` | xdg | profile | default apps |

## Profiles

Profiles can enable a role or just add packages:

- Roles with `profile` in "When" only run if their profile is in `enabled_profiles`.
- Package-only profiles (core, shell, dev, media, gaming, office, vpn, ai, konsave) have no app role — system package roles install their packages from `archlinux.yml`.

```yaml
# all.yml
always_profiles: [core, shell, utility, networking, sshd]
presets:
  desktop:
    profiles: [audio, nvidia, plasma, browser, gaming]
```

## Playbooks

| Playbook | Purpose |
|---|---|
| `playbooks/setup.yml` | One-time provisioning and desired state: users, package manager config, package presence, services, apps, and dotfiles. |
| `playbooks/update.yml` | Recurring updates: mirror refresh, keyring update, pacman upgrade, AUR upgrade, Flatpak update, and cache cleanup. |
