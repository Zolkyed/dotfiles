# Ansible

Full machine provisioning for Debian and Arch Linux — 31 roles, one playbook.

## Usage

```bash
# Bootstrap a machine from scratch
just bootstrap desktop

# Remote (SSH)
just run desktop
just run laptop

# Local (no SSH)
just run-local desktop

# Dry-run
just check desktop

# Lint + syntax check
just ci
```

Or run ansible-playbook directly:

```bash
cd ansible

# Remote
ansible-playbook playbooks/setup.yml -l desktop

# Local
ansible-playbook -i inventory/local.yml playbooks/setup.yml -l desktop

# Dry-run
ansible-playbook -i inventory/local.yml playbooks/setup.yml --check --diff -l desktop
```

## Inventory

| File | Connection | Use case |
|---|---|---|
| `inventory/hosts.yml` | SSH | Target machines by hostname |
| `inventory/local.yml` | Local | Run on the current machine without SSH |

Hosts: `desktop`, `laptop`, `server`.
Each has `host_vars/<host>/vars.yml` (overrides) and `host_vars/<host>/vault.yml` (secrets).

## Variables

| Variable | File | Notes |
|---|---|---|
| Feature flags, user settings, Flatpaks | `group_vars/all.yml` | Shared defaults; override per host |
| Shared secrets | `group_vars/vault.yml` | SOPS-encrypted |
| Package/service names | `group_vars/debian.yml`, `group_vars/archlinux.yml` | Distro-specific names only |
| Host overrides (flags, monitors) | `host_vars/<host>/vars.yml` | Per-machine |
| Host secrets (SSH keys) | `host_vars/<host>/vault.yml` | SOPS-encrypted |

## Roles

### system/

| Role | Tag | Purpose |
|---|---|---|
| `sysctl` | `sysctl` | Hostname, kernel parameters |
| `sudoers` | `sudoers` | Passwordless sudo drop-in |
| `packages` | `packages` | Core, utility, media, office, fun packages |
| `fonts` | `fonts` | Distro fonts + Nerd Fonts from GitHub releases |
| `bluetooth` | `bluetooth` | bluez + blueman |
| `docker` | `docker` | Docker CE + compose/buildx plugin |
| `fail2ban` | `fail2ban` | jail.local for sshd |
| `firewall` | `firewall` | ufw allow/deny rules |
| `networking` | `networking` | NetworkManager + systemd-resolved |
| `nvidia` | `nvidia` | NVIDIA DRM modesetting |
| `splashboot` | `splashboot` | Plymouth theme + initramfs |
| `sshd` | `sshd` | sshd hardening (root login, pubkey, port) |
| `virtualization` | `virtualization` | KVM/QEMU or VirtualBox |
| `vpn` | `vpn` | WireGuard + OpenVPN |

### desktop/

| Role | Tag | Purpose |
|---|---|---|
| `plasma` | `plasma` | KDE Plasma packages + global keybinds |
| `hyprland` | `hyprland` | Hyprland packages |
| `niri` | `niri` | Niri packages |

Desktop configs (kwinrc, kdeglobals, panel layout, etc.) are managed by chezmoi.

### apps/

| Role | Tag | Purpose |
|---|---|---|
| `browser` | `browser` | Browser install + managed extension policy |
| `dev` | `dev` | Dev tools, nvm, rustup, npm globals |
| `flatpak` | `flatpak` | Flathub remote + app installs |
| `gaming` | `gaming` | Steam, Lutris, Wine, multilib/i386 |
| `hayase` | `hayase` | Hayase anime sync (.deb or AppImage) |
| `konsave` | `konsave` | KDE profile manager via pipx |
| `mihon` | `mihon` | Mihon manga reader desktop entry |
| `rclone` | `rclone` | rclone config for Google Drive |
| `vscode` | `vscode` | VS Code native package |

### user/

| Role | Tag | Purpose |
|---|---|---|
| `account` | `user` | User account, shell, groups |
| `bin` | `bin` | Custom scripts + konsavectl aliases + homectl config |
| `dotfiles` | `dotfiles` | chezmoi install + `apply --force` |
| `ssh_keys` | `ssh_keys` | Deploy SSH keys from SOPS vault |
| `xdg` | `xdg` | Default browser, editor, media player, MIME handlers |

## Feature flags

All optional roles are gated in `group_vars/all.yml`:

```yaml
bluetooth_enabled: true
docker_enabled:    true
gaming_enabled:    false
nvidia_enabled:    false
plasma_enabled:    true
# ...
```

Override per machine in `host_vars/<host>/vars.yml`.

## Supported distributions

`setup.yml` asserts `os_family` is `Debian` or `Archlinux` at startup.
Ubuntu is treated as Debian. Other derivatives are not supported.
