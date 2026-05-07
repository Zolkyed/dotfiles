# dotfiles

Full machine provisioning and user environment for Debian and Arch Linux.

## Architecture

| Layer | Tool | Responsibility |
|---|---|---|
| System | Ansible | Packages, services, drivers, users |
| Dotfiles | Chezmoi | Shell, editor, app config |
| Desktop | Ansible | Hyprland, Niri |
| Secrets | SOPS + age | SSH keys, tokens, credentials |

## Quick start

```bash
# Clone
git clone https://github.com/Zolkyed/dotfiles ~/dotfiles
cd ~/dotfiles

# Bootstrap: installs Ansible, sops, age, collections, then runs the playbook
bash scripts/run_once_install-ansible.sh
```

```bash
# Local CI/lint tooling
just setup-dev
just ci
```

```bash
# Run remotely (SSH)
just run desktop
just run laptop

# Run on the local machine (no SSH)
just run-local desktop

# Dry-run
just check desktop
```

## Repository structure

```
.
├── ansible/
│   ├── ansible.cfg
│   ├── .ansible-lint
│   ├── requirements.yml
│   ├── inventory/
│   │   ├── hosts.yml              # remote inventory (ansible_host resolves via DNS/SSH)
│   │   ├── local.yml              # local inventory (ansible_connection: local)
│   │   ├── group_vars/
│   │   │   ├── all.yml            # feature flags, user settings, shared Flatpaks/fonts
│   │   │   ├── Debian.yml         # Debian package/service names
│   │   │   ├── Archlinux.yml      # Arch package/service names
│   │   │   └── vault.yml          # shared secrets (HA token, rclone, webhook)
│   │   └── host_vars/
│   │       ├── desktop/
│   │       │   ├── vars.yml       # gaming, monitor overrides
│   │       │   └── vault.yml      # per-host SSH keys
│   │       ├── laptop/
│   │       │   ├── vars.yml       # monitor overrides
│   │       │   └── vault.yml
│   │       └── server/
│   │           ├── vars.yml       # disables all desktop/UI features
│   │           └── vault.yml
│   ├── playbooks/
│   │   └── setup.yml              # single playbook, tag-controlled
│   └── roles/
│       ├── system/
│       │   ├── sysctl/            # hostname, kernel parameters
│       │   ├── aur/               # paru AUR helper install
│       │   ├── fonts/             # distro fonts + Nerd Fonts
│       │   ├── docker/            # Docker CE + compose/buildx
│       │   ├── virtualization/    # KVM/QEMU or VirtualBox
│       │   ├── networking/        # NetworkManager + systemd-resolved
│       │   ├── vpn/               # WireGuard + OpenVPN
│       │   ├── sshd/              # sshd hardening
│       │   ├── firewall/          # ufw rules
│       │   ├── fail2ban/          # fail2ban with sshd jail
│       │   ├── splashboot/        # Plymouth splash
│       ├── desktop/
│       │   ├── hyprland/          # Hyprland packages + config
│       │   ├── niri/              # Niri packages + config
│       └── home/
│           ├── user/              # user account, groups, zsh shell
│           ├── packages/          # core, utility, media, office, system, fun
│           ├── rclone/            # rclone config for Google Drive
│           ├── konsave/           # install konsave
│           ├── hayase/            # Hayase anime sync (deb or AppImage)
│           ├── flatpak/           # Flathub remotes + user apps
│           ├── dotfiles/          # chezmoi install + apply
│           ├── browser/           # browser install + managed policy
│           ├── ssh_keys/          # deploy keys from vault
│           ├── dev/               # dev tools, nvm, rustup
│           ├── ai/                # opencode CLI assistant
│           ├── bin/               # custom scripts + homectl config
│           └── gaming/            # Steam, Lutris, multilib, AUR packages
├── chezmoi/                       # user dotfiles (applied by chezmoi)
│   ├── dot_gitconfig              # → ~/.gitconfig
│   ├── dot_gitconfig-github       # → ~/.gitconfig-github
│   ├── dot_gitconfig-gitlab       # → ~/.gitconfig-gitlab
│   ├── dot_gitignore_global       # → ~/.gitignore_global
│   ├── dot_zshrc                  # → ~/.zshrc
│   ├── dot_ssh/                   # → ~/.ssh/
│   └── dot_config/
│       ├── fastfetch/             # → ~/.config/fastfetch/
│       ├── kitty/                 # → ~/.config/kitty/
│       ├── mpv/                   # → ~/.config/mpv/
│       └── vscode/                # → ~/.config/vscode/
├── scripts/
│   └── run_once_install-ansible.sh
├── .github/workflows/
│   └── ci.yml                     # GitHub Actions CI (syntax, lint, inventory, tags)
├── .sops.yaml                     # SOPS age key configuration
├── .pre-commit-config.yaml        # pre-commit hooks (yaml, ansible-lint, shellcheck)
├── .yamllint                      # yamllint config
├── .editorconfig
├── Justfile                       # just task runner
└── requirements.txt               # pip dependencies (ansible, sops, ansible-lint, etc.)
```

## Role execution order

The playbook applies roles sequentially with tag-based gating:

```
sysctl → user → aur → packages → hayase
→ fonts → flatpak → docker → virtualization
→ dotfiles → browser → ssh_keys → dev → bin → networking → vpn
→ sshd → firewall → fail2ban → splashboot → rclone → konsave
→ ai → gaming → hyprland → niri
```

All roles are gated behind feature flags in `group_vars/all.yml`. Host-specific
overrides go in `host_vars/<host>/vars.yml`.

## Sources of truth

| What | File |
|---|---|
| Feature flags and global defaults | `ansible/inventory/group_vars/all.yml` |
| Shared secrets (HA, rclone, webhook) | `ansible/inventory/group_vars/vault.yml` |
| Distro package and service names | `ansible/inventory/group_vars/Debian.yml`, `ansible/inventory/group_vars/Archlinux.yml` |
| Host overrides (feature flags, monitors) | `ansible/inventory/host_vars/<host>/vars.yml` |
| Host secrets (SSH keys) | `ansible/inventory/host_vars/<host>/vault.yml` |
| KDE keybinds | `ansible/roles/home/bin/keybinds/<host>.ini` |
| Chezmoi dotfiles | `chezmoi/` |
| Bootstrap script | `scripts/run_once_install-ansible.sh` |

## Konsave Management

Konsave profile tooling is split between provisioning and day-to-day commands:

- **home/konsave** — installs konsave via pipx for KDE profile management
- **home/bin** — installs one `konsavectl` script and aliases it as `konsave-list`, `konsave-import`, `konsave-export`, and `konsave-remove`

Konsave installation is handled by `home/konsave`.
Google Drive access stays separate in `home/rclone`.
KDE keybind overrides are installed by `home/bin` and applied automatically
after `konsave-import`.

After the playbook has run once, day-to-day KDE profile management is done
directly from the shell:

```bash
konsave-list
konsave-import
konsave-export plasma-may-2026
konsave-remove plasma-may-2026
```

The commands default to `gdrive:konsave/`. Override that with
`KONSAVE_RCLONE_REMOTE` and `KONSAVE_RCLONE_PATH` if needed.

## Secrets

Encrypted with SOPS + age. Configuration lives in `.sops.yaml` at the repo root.
Secrets files match the pattern `ansible/inventory/**/vault.yml`:

```bash
# Edit shared secrets
sops ansible/inventory/group_vars/vault.yml

# Edit per-host secrets
sops ansible/inventory/host_vars/desktop/vault.yml
```

Fresh machines need the existing age identity before SOPS can decrypt the
vaults:

```bash
install -Dm600 /path/to/keys.txt ~/.config/sops/age/keys.txt
bash scripts/run_once_install-ansible.sh desktop
```

## Design philosophy

- **Ansible** → how the system is built
- **Chezmoi** → how the user environment looks
- **Desktop roles** → Hyprland and Niri
- **SOPS + age** → how secrets stay private
- `all.yml` → one place for shared feature flags, Flatpaks, fonts, and user defaults
- `Debian.yml` / `Archlinux.yml` → distro package and service names only
- `host_vars/<host>/vars.yml` → per-machine overrides (flags, monitors)
