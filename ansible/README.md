# Ansible

Full machine provisioning for Debian and Arch Linux — 29 roles, one playbook.

## Usage

```bash
# From repo root — bootstrap everything from scratch
just bootstrap

# From repo root with just (after just setup-dev)
just run desktop                  # remote (SSH)
just run-local desktop            # local (no SSH)
just check desktop                # dry-run
just check-local desktop          # dry-run (local)
just tags desktop tags=flatpak    # run specific tags
just tags-local desktop tags=flatpak
just rebuild desktop              # run playbook + apply chezmoi
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
| Host overrides (flags, monitors) | `host_vars/<host>/vars.yml` | Per-machine |
| Host SSH keys | `host_vars/<host>/vault.yml` | SOPS-encrypted |

## Roles

### system/

| Role | Purpose |
|---|---|
| `sysctl` | Hostname, kernel parameters |
| `sudoers` | Sudoers configuration |
| `aur` | Install `paru` AUR helper |
| `fonts` | Distro font packages + Nerd Fonts |
| `docker` | Docker CE + compose/buildx plugin |
| `virtualization` | KVM/QEMU or VirtualBox |
| `networking` | NetworkManager + systemd-resolved |
| `vpn` | WireGuard + OpenVPN packages |
| `sshd` | sshd hardening (root login, pubkey, port) |
| `firewall` | ufw with allow/deny rules |
| `fail2ban` | jail.local for sshd |
| `splashboot` | Plymouth theme + initramfs |

### desktop/

| Role | Purpose |
|---|---|
| `hyprland` | Hyprland packages + config (monitors, keybinds, animations) |
| `niri` | Niri packages + config (outputs, keybinds) |

Konsave day-to-day commands are installed by the `home/bin` role. The public
commands are symlinks to one `konsavectl` shell script. Per-host KDE keybind
files are installed with `konsavectl` and applied after `konsave-import`.

### apps/

| Role | Purpose |
|---|---|
| `ai` | opencode CLI assistant |
| `browser` | Managed browser extension policy |
| `dev` | Dev tools, nvm, rustup |
| `flatpak` | Flatpak, Discover backend, Flathub remote, and app installs |
| `gaming` | Steam, Lutris, multilib/i386 |
| `hayase` | Hayase anime sync (.deb or AppImage) |
| `konsave` | Install konsave via pipx |
| `rclone` | rclone config for Google Drive |
| `vscode` | VS Code native packages |

### home/

| Role | Purpose |
|---|---|
| `user` | User account, shell, groups |
| `packages` | Core, utility, media, office, system, fun packages |
| `dotfiles` | chezmoi install + `apply --force` |
| `ssh_keys` | Deploy SSH keys from SOPS vault |
| `bin` | Custom scripts + homectl Home Assistant config |
| `xdg` | Default browser, editor, media player, and MIME handlers |

## Supported distributions

`setup.yml` fails early unless the target is Debian or Arch Linux.
Derivatives are intentionally not treated as supported targets.
