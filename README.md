# dotfiles

Full machine provisioning and user environment for Arch Linux.

## Desktop

![desktop](assets/desktop.png)

## Quick start

```bash
git clone https://github.com/Zolkyed/dotfiles ~/dotfiles
cd ~/dotfiles

just bootstrap desktop
```

## Commands

```bash
# Dev tooling
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

# Vault
just vault-edit
just vault-view

# Chezmoi
just apply              # apply all dotfiles
just diff               # show pending changes

chezmoi status          # list files with pending changes
chezmoi update          # git pull source + apply
chezmoi edit ~/.zshrc   # edit a managed file in $EDITOR
```

## Structure

```
.
├── ansible/
│   ├── ansible.cfg
│   ├── requirements.yml           # Ansible Galaxy collections
│   ├── inventory/
│   │   ├── hosts.yml              # remote inventory (SSH)
│   │   ├── local.yml              # local inventory (no SSH)
│   │   ├── group_vars/
│   │   │   ├── all.yml            # feature flags, presets

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
│   │   ├── ai/                # AI CLI tools (opencode-ai, codex, claude-code)
│       │   ├── flatpak/           # Flathub + app installs
│       │   ├── gaming/            # Steam, Lutris, Wine
│   │   ├── hayase/            # anime sync (AppImage)
│       │   ├── konsave/           # KDE profile manager
│   │   ├── media/             # mpv, ffmpeg, yt-dlp, media tooling
│   │   ├── mihon/             # manga reader desktop entry
│   │   └── rclone/            # Google Drive config
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
│   └── Dockerfile.archlinux       # Arch Linux integration test image
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

## Design

- **Ansible** → system state: packages, services, users, drivers
- **Chezmoi** → user environment: shell, editor, app config
- **SOPS + age** → secrets stay encrypted at rest in the repo
- `all.yml` → single source for feature flags and shared defaults
- `archlinux.yml` → profile-based package data
- `host_vars/<host>/vars.yml` → per-machine overrides only
monochrome for theme

## References

- [shricodev/dotfiles](https://github.com/shricodev/dotfiles/tree/f7814b58179c5ece4a59f4c0396c91cb30e75f3c)
- [KDE monochrome in the night](https://www.reddit.com/r/unixporn/comments/1qimvm8/kde_monochrome_in_the_night/)
- [KDE Plasma — who said DEs can't be beautiful](https://www.reddit.com/r/unixporn/comments/1srpss0/kde_plasma_who_said_desktop_environments_cant_be/)
- https://www.reddit.com/r/unixporn/comments/1g5im30/kde_plasma_minimalist_monochrome_because_color_is/