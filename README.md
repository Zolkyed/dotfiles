# dotfiles

Full machine provisioning and user environment for Debian and Arch Linux.

## Architecture

| Layer | Tool | Responsibility |
|---|---|---|
| System | Ansible | Packages, services, drivers, users |
| Dotfiles | Chezmoi | Shell, editor, app config |
| Desktop | Ansible | Plasma, Hyprland, Niri packages |
| Secrets | SOPS + age | SSH keys, tokens, credentials |

## Quick start

```bash
# Clone
git clone https://github.com/Zolkyed/dotfiles ~/dotfiles
cd ~/dotfiles

# Bootstrap: installs Ansible, sops, age, collections, then runs the playbook
just bootstrap desktop
```

```bash
# Local dev tooling
just setup-dev   # create .venv with ansible-lint, yamllint, shellcheck-py
just ci          # syntax check + full lint
just lint        # yamllint + shellcheck + ansible-lint
just syntax      # ansible-playbook --syntax-check
```

```bash
# Run remotely (SSH)
just run desktop
just run laptop

# Run on the local machine (no SSH)
just run-local desktop

# Dry-run
just check desktop

# Vault management
just vault-edit
just vault-view

# Chezmoi
just apply
just diff
```

## Repository structure

```
.
├── ansible/
│   ├── ansible.cfg
│   ├── requirements.yml           # Ansible Galaxy collections
│   ├── inventory/
│   │   ├── hosts.yml              # remote inventory (SSH)
│   │   ├── local.yml              # local inventory (no SSH)
│   │   ├── group_vars/
│   │   │   ├── all.yml            # feature flags, user settings, shared Flatpaks
│   │   │   ├── debian.yml         # Debian package/service names
│   │   │   ├── archlinux.yml      # Arch package/service names
│   │   │   └── vault.yml          # shared secrets (SOPS-encrypted)
│   │   └── host_vars/
│   │       ├── desktop/{vars.yml,vault.yml}
│   │       ├── laptop/{vars.yml,vault.yml}
│   │       └── server/{vars.yml,vault.yml}
│   ├── playbooks/
│   │   └── setup.yml              # single playbook, tag-controlled
│   └── roles/
│       ├── system/
│       │   ├── bluetooth/         # bluez + blueman
│       │   ├── docker/            # Docker CE + compose/buildx
│       │   ├── fail2ban/          # sshd jail
│       │   ├── firewall/          # ufw rules
│       │   ├── fonts/             # distro fonts + Nerd Fonts
│       │   ├── networking/        # NetworkManager + systemd-resolved
│       │   ├── nvidia/            # NVIDIA DRM modesetting
│       │   ├── packages/          # core, utility, media, office, fun packages
│       │   ├── splashboot/        # Plymouth splash
│       │   ├── sshd/              # sshd hardening
│       │   ├── sudoers/           # passwordless sudo drop-in
│       │   ├── sysctl/            # hostname, kernel parameters
│       │   ├── virtualization/    # KVM/QEMU or VirtualBox
│       │   └── vpn/               # WireGuard + OpenVPN
│       ├── desktop/
│       │   ├── hyprland/          # Hyprland packages
│       │   ├── niri/              # Niri packages
│       │   └── plasma/            # KDE Plasma packages
│       ├── apps/
│       │   ├── browser/           # browser + managed extension policy
│       │   ├── dev/               # dev tools, nvm, rustup
│       │   ├── flatpak/           # Flathub + app installs
│       │   ├── gaming/            # Steam, Lutris, Wine
│       │   ├── hayase/            # anime sync (.deb or AppImage)
│       │   ├── konsave/           # KDE profile manager
│       │   ├── mihon/             # manga reader desktop entry
│       │   ├── rclone/            # Google Drive config
│       │   └── vscode/            # VS Code native package
│       └── user/
│           ├── account/           # user account, shell, groups
│           ├── bin/               # custom scripts + homectl config
│           ├── dotfiles/          # chezmoi install + apply
│           ├── ssh_keys/          # deploy keys from vault
│           └── xdg/               # default apps + MIME handlers
├── chezmoi/                       # user dotfiles (applied by chezmoi)
│   ├── .chezmoi.toml.tmpl         # chezmoi config + template data vars
│   ├── run_once_onchange_add-known-hosts.sh
│   ├── dot_gitconfig              # → ~/.gitconfig
│   ├── dot_gitconfig-github       # → ~/.gitconfig-github
│   ├── dot_gitconfig-gitlab       # → ~/.gitconfig-gitlab
│   ├── dot_gitignore_global       # → ~/.gitignore_global
│   ├── dot_zshrc.tmpl             # → ~/.zshrc
│   ├── dot_ssh/config.tmpl        # → ~/.ssh/config
│   └── dot_config/
│       ├── atuin/                 # → ~/.config/atuin/
│       ├── bat/                   # → ~/.config/bat/
│       ├── Code/User/             # → ~/.config/Code/User/
│       ├── fastfetch/             # → ~/.config/fastfetch/
│       ├── hypr/                  # → ~/.config/hypr/
│       ├── kitty/                 # → ~/.config/kitty/
│       ├── lazygit/               # → ~/.config/lazygit/
│       ├── mpv/                   # → ~/.config/mpv/
│       ├── niri/                  # → ~/.config/niri/
│       ├── starship.toml          # → ~/.config/starship.toml
│       └── tmux/                  # → ~/.config/tmux/
├── docker/
│   ├── Dockerfile.ubuntu          # Ubuntu integration test image
│   ├── Dockerfile.archlinux       # Arch Linux integration test image
│   └── .dockerignore
├── scripts/
│   └── run_once_install-ansible.sh
├── .github/
│   ├── dependabot.yml             # Docker + GitHub Actions auto-updates
│   └── workflows/ci.yml           # lint + integration tests
├── .sops.yaml                     # SOPS age key config
├── .pre-commit-config.yaml        # yamllint, ansible-lint, shellcheck, vault check
├── .yamllint
├── .editorconfig
└── Justfile
```

## Role execution order

```
sysctl → account → sudoers → packages → fonts
→ plasma → flatpak → vscode → hayase → mihon → browser → dev → gaming → rclone → konsave
→ nvidia → docker → virtualization
→ ssh_keys → bin → xdg → dotfiles
→ networking → bluetooth → vpn → sshd → firewall → fail2ban
→ splashboot → hyprland → niri
```

Optional roles are gated behind feature flags in `group_vars/all.yml`.
Host-specific overrides go in `host_vars/<host>/vars.yml`.

## Sources of truth

| What | File |
|---|---|
| Feature flags and global defaults | `ansible/inventory/group_vars/all.yml` |
| Shared secrets | `ansible/inventory/group_vars/vault.yml` |
| Distro package and service names | `ansible/inventory/group_vars/debian.yml`, `archlinux.yml` |
| Host overrides (flags, monitors) | `ansible/inventory/host_vars/<host>/vars.yml` |
| Host secrets (SSH keys) | `ansible/inventory/host_vars/<host>/vault.yml` |
| KDE keybinds | `ansible/roles/user/bin/keybinds/<host>.ini` |
| Chezmoi dotfiles | `chezmoi/` |
| Bootstrap script | `scripts/run_once_install-ansible.sh` |

## Secrets

Encrypted with SOPS + age. The age public key is in `.sops.yaml`.
All `ansible/inventory/**/vault.yml` files are encrypted.

```bash
# Edit shared secrets
just vault-edit

# Edit per-host secrets
sops ansible/inventory/host_vars/desktop/vault.yml
```

Fresh machines need the age identity before SOPS can decrypt:

```bash
install -Dm600 /path/to/keys.txt ~/.config/sops/age/keys.txt
just bootstrap desktop
```

## Design philosophy

- **Ansible** → system state: packages, services, users, drivers
- **Chezmoi** → user environment: shell, editor, app config
- **SOPS + age** → secrets stay encrypted at rest in the repo
- `all.yml` → single source for feature flags and shared defaults
- `debian.yml` / `archlinux.yml` → distro package names only, no logic
- `host_vars/<host>/vars.yml` → per-machine overrides only

https://github.com/shricodev/dotfiles/tree/f7814b58179c5ece4a59f4c0396c91cb30e75f3c  
https://www.reddit.com/r/unixporn/comments/1qimvm8/kde_monochrome_in_the_night/
https://www.reddit.com/r/unixporn/comments/1srpss0/kde_plasma_who_said_desktop_environments_cant_be/