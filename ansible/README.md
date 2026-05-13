# Ansible

Full machine provisioning for Arch Linux.

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
| Package/service names | `group_vars/archlinux.yml` | Profile-based package data |
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
| `audio` | `audio` | PipeWire/WirePlumber user services |
| `bluetooth` | `bluetooth` | bluez + blueman |
| `docker` | `docker` | Docker CE + compose/buildx plugin |
| `fail2ban` | `fail2ban` | jail.local for sshd |
| `firewall` | `firewall` | ufw allow/deny rules |
| `networking` | `networking` | NetworkManager + systemd-resolved |
| `nvidia` | `nvidia` | NVIDIA DRM modesetting |
| `splashboot` | `splashboot` | Plymouth theme + initramfs |
| `sshd` | `sshd` | sshd hardening (root login, pubkey, port) |
| `virtualization` | `virtualization` | KVM/QEMU via libvirt |
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
| `ai` | `ai` | AI CLI tools (opencode-ai, codex, claude-code) |
| `flatpak` | `flatpak` | Flathub remote + app installs |
| `gaming` | `gaming` | Steam, Lutris, Wine, multilib/i386 |
| `konsave` | `konsave` | KDE profile manager via pipx |
| `mihon` | `mihon` | Mihon manga reader desktop entry |
| `rclone` | `rclone` | rclone config for Google Drive |


### user/

| Role | Tag | Purpose |
|---|---|---|
| `account` | `user` | User account, shell, groups |
| `bin` | `bin` | Custom scripts + homectl config |
| `dotfiles` | `dotfiles` | chezmoi install + `apply --force` |
| `ssh_keys` | `ssh_keys` | Deploy SSH keys from SOPS vault |
| `xdg` | `xdg` | Default browser, editor, media player, MIME handlers |

## Profiles

Optional packages and roles are selected in `group_vars/all.yml` with profile
lists:

```yaml
always_profiles:
  - core
  - shell
  - utility

presets:
  desktop:
    profiles:
      - audio
      - docker
      - plasma
      - gaming
```

Each host selects a preset in `host_vars/<host>/vars.yml`.
