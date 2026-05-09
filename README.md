# dotfiles

Full machine provisioning and user environment for Debian and Arch Linux.

## Architecture

| Layer | Tool | Responsibility |
|---|---|---|
| System | Ansible | Packages, services, drivers, users |
| Dotfiles | Chezmoi | Shell, editor, app config |
| Desktop | Ansible | Plasma, Hyprland, Niri |
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
# Local CI/lint tooling
just setup-dev
just ci
just lint
just syntax
```

```bash
# Container test matrix (same idea as CI)
docker build -f Dockerfile.ubuntu -t dotfiles-test-ubuntu .
docker build -f Dockerfile.archlinux -t dotfiles-test-archlinux .
```

```bash
# Run remotely (SSH)
just run desktop
just run laptop

# Run on the local machine (no SSH)
just run-local desktop

# Dry-run
just check desktop
just check-local desktop

# Run specific tags
just tags desktop tags=flatpak
just tags-local desktop tags=flatpak

# Rebuild (run playbook + apply chezmoi)
just rebuild desktop
```

```bash
# Vault management
just vault-edit
just vault-view
```

```bash
# Chezmoi
just apply
just diff
```

## Repository structure

```
.
├── Dockerfile.ubuntu               # Ubuntu test image (syntax, lint, safe playbook subset)
├── Dockerfile.archlinux            # Arch Linux test image (syntax, lint, safe playbook subset)
├── ansible/
│   ├── ansible.cfg
│   ├── .ansible-lint
│   ├── requirements.yml
│   ├── inventory/
│   │   ├── hosts.yml              # remote inventory (ansible_host resolves via DNS/SSH)
│   │   ├── local.yml              # local inventory (ansible_connection: local)
│   │   ├── group_vars/
│   │   │   ├── all.yml            # feature flags, user settings, shared Flatpaks/fonts
│   │   │   ├── debian.yml         # Debian package/service names
│   │   │   ├── archlinux.yml      # Arch package/service names
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
│       │   ├── aur/               # Arch AUR packages via kewlfft.aur
│       │   ├── docker/            # Docker CE + compose/buildx
│       │   ├── fail2ban/          # fail2ban with sshd jail
│       │   ├── firewall/          # ufw rules
│       │   ├── fonts/             # distro fonts + Nerd Fonts
│       │   ├── networking/        # NetworkManager + systemd-resolved
│       │   ├── splashboot/        # Plymouth splash
│       │   ├── sshd/              # sshd hardening
│       │   ├── sudoers/           # sudoers configuration
│       │   ├── sysctl/            # hostname, kernel parameters
│       │   ├── virtualization/    # KVM/QEMU or VirtualBox
│       │   └── vpn/               # WireGuard + OpenVPN
│       ├── desktop/
│       │   ├── plasma/            # Plasma desktop packages
│       │   ├── hyprland/          # Hyprland packages + config
│       │   └── niri/              # Niri packages + config
│       ├── apps/
│       │   ├── ai/                # opencode CLI assistant
│       │   ├── browser/           # browser install + managed policy
│       │   ├── dev/               # dev tools, nvm, rustup
│       │   ├── flatpak/           # Flathub remotes + user apps
│       │   ├── gaming/            # Steam, Lutris, multilib, AUR packages
│       │   ├── hayase/            # Hayase anime sync (deb or AppImage)
│       │   ├── konsave/           # install konsave
│       │   ├── rclone/            # rclone config for Google Drive
│       │   └── vscode/            # VS Code native packages
│       └── home/
│           ├── user/              # user account, groups, zsh shell
│           ├── packages/          # core, utility, media, office, system, fun
│           ├── dotfiles/          # chezmoi install + apply
│           ├── ssh_keys/          # deploy keys from vault
│           ├── bin/               # custom scripts + homectl config
│           └── xdg/               # default apps and MIME handlers
├── chezmoi/                       # user dotfiles (applied by chezmoi)
│   ├── dot_gitconfig              # → ~/.gitconfig
│   ├── dot_gitconfig-github       # → ~/.gitconfig-github
│   ├── dot_gitconfig-gitlab       # → ~/.gitconfig-gitlab
│   ├── dot_gitignore_global       # → ~/.gitignore_global
│   ├── dot_zshrc                  # → ~/.zshrc
│   ├── dot_ssh/                   # → ~/.ssh/
│   └── dot_config/
│       ├── Code/User/              # → ~/.config/Code/User/
│       ├── fastfetch/             # → ~/.config/fastfetch/
│       ├── hypr/                  # → ~/.config/hypr/
│       ├── kitty/                 # → ~/.config/kitty/
│       ├── mpv/                   # → ~/.config/mpv/
│       └── niri/                  # → ~/.config/niri/
├── scripts/
│   ├── run_once_install-ansible.sh
│   └── vault.sh
├── .github/workflows/
│   └── ci.yml                     # GitHub Actions CI (builds the Ubuntu/Arch test images)
├── .sops.yaml                     # SOPS age key configuration
├── .pre-commit-config.yaml        # pre-commit hooks (yaml, ansible-lint, shellcheck)
├── .yamllint                      # yamllint config
├── .editorconfig
├── Justfile                       # just task runner
└── requirements.txt               # pip dependencies (ansible-lint, yamllint, shellcheck-py)
```

## Container tests

Each Dockerfile installs the required collections, stubs the encrypted vault
files for container use, then runs:

- `ansible-playbook --syntax-check`
- `ansible-lint`
- `yamllint`
- `shellcheck`
- a safe local playbook subset: `--tags user,packages`

Run them manually with:

```bash
docker build -f Dockerfile.ubuntu -t dotfiles-test-ubuntu .
docker build -f Dockerfile.archlinux -t dotfiles-test-archlinux .
```

## Role execution order

The playbook applies roles sequentially with tag-based gating:

```
sysctl → user → sudoers → aur → packages → fonts → plasma → flatpak
→ vscode → hayase → browser → dev → ai → gaming → rclone → konsave
→ docker → virtualization
→ ssh_keys → bin → xdg → dotfiles → networking → vpn
→ sshd → firewall → fail2ban → splashboot → hyprland → niri
```

Optional roles are gated behind feature flags in `group_vars/all.yml`.
Host-specific overrides go in `host_vars/<host>/vars.yml`.

## Sources of truth

| What | File |
|---|---|
| Feature flags and global defaults | `ansible/inventory/group_vars/all.yml` |
| Shared secrets (HA, rclone, webhook) | `ansible/inventory/group_vars/vault.yml` |
| Distro package and service names | `ansible/inventory/group_vars/debian.yml`, `ansible/inventory/group_vars/archlinux.yml` |
| Host overrides (feature flags, monitors) | `ansible/inventory/host_vars/<host>/vars.yml` |
| Host secrets (SSH keys) | `ansible/inventory/host_vars/<host>/vault.yml` |
| KDE keybinds | `ansible/roles/home/bin/keybinds/<host>.ini` |
| Chezmoi dotfiles | `chezmoi/` |
| Bootstrap script | `scripts/run_once_install-ansible.sh` |
| Vault script | `scripts/vault.sh` |

## Konsave Management

Konsave profile tooling is split between provisioning and day-to-day commands:

- **apps/konsave** — installs konsave via pipx for KDE profile management
- **home/bin** — installs one `konsavectl` script and aliases it as `konsave-list`, `konsave-import`, `konsave-export`, and `konsave-remove`

Konsave installation is handled by `apps/konsave`.
Google Drive access stays separate in `apps/rclone`.
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
just bootstrap desktop
```

## Design philosophy

- **Ansible** → how the system is built
- **Chezmoi** → how the user environment looks
- **Desktop roles** → Plasma, Hyprland and Niri
- **SOPS + age** → how secrets stay private
- `all.yml` → one place for shared feature flags, Flatpaks, fonts, and user defaults
- `debian.yml` / `archlinux.yml` → distro package and service names only
- `host_vars/<host>/vars.yml` → per-machine overrides (flags, monitors)
