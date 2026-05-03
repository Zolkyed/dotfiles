# dotfiles

Full machine provisioning and user environment for Debian/Ubuntu + KDE Plasma.

## Architecture

| Layer | Tool | Responsibility |
|---|---|---|
| System | Ansible | Packages, services, drivers, users |
| Dotfiles | Chezmoi | Shell, editor, app config |
| KDE profiles | konsave / kdot | KDE Plasma snapshots |
| Secrets | SOPS + age | SSH keys, tokens, credentials |
| Scripts | kdot, bootstrap | Operational helpers |

## Quick start

```bash
# Clone
git clone https://github.com/Zolkyed/dotfiles ~/projects/dotfiles
cd ~/projects/dotfiles

# Bootstrap: installs Ansible, sops, age, collections, then runs the playbook
bash scripts/run_once_install-ansible.sh
```

```bash
# Run manually (Ansible already installed)
cd ansible
ansible-playbook playbooks/setup.yml -l desktop
ansible-playbook playbooks/setup.yml -l laptop

# Dry-run
ansible-playbook playbooks/setup.yml --check --diff -l desktop
```

## Repository structure

```
.
├── ansible/                  # System provisioning
│   ├── ansible.cfg
│   ├── requirements.yml      # community.general, ansible.posix, community.sops, community.docker
│   ├── inventory/
│   │   ├── hosts.yml
│   │   ├── group_vars/
│   │   │   ├── all.yml       # flatpak_apps, user_groups  ← single source of truth
│   │   │   └── Debian.yml    # base_packages              ← OS-specific names
│   │   └── host_vars/
│   │       ├── desktop.yml   # extra_packages, machine_type, monitor
│   │       └── laptop.yml
│   ├── playbooks/
│   │   └── setup.yml         # Full playbook + post_tasks report
│   └── roles/
│       ├── system/
│       │   ├── packages/     # apt base + extra packages
│       │   ├── flatpak/      # Flathub remotes + apps
│       │   ├── fonts/        # Nerd Fonts
│       │   ├── docker/       # Docker CE + compose plugin
│       │   ├── nvidia/       # Proprietary driver, nouveau blacklist
│       │   ├── vm/           # KVM/QEMU + virt-manager
│       │   ├── gaming/       # Steam, Lutris, gamemode, Heroic
│       │   ├── networking/   # NetworkManager + systemd-resolved
│       │   ├── ssh/          # sshd hardening
│       │   ├── bluetooth/    # bluez
│       │   ├── bootloader/   # GRUB (BIOS + UEFI)
│       │   └── display_manager/ # SDDM
│       ├── desktop/
│       │   ├── kde/          # KDE Plasma packages
│       │   ├── kde/themes/   # kwriteconfig6 theme settings
│       │   └── konsave/      # pipx install + profile import
│       └── user/
│           ├── (main)        # User account, shell, groups
│           ├── dotfiles/     # chezmoi install + apply --force
│           ├── git/          # Verify git config deployed by chezmoi
│           ├── ssh_keys/     # Deploy keys from vault
│           ├── dev/          # Dev tools, nvm, rustup
│           └── bin/          # Custom scripts → ~/.local/bin
│               └── files/
│                   ├── kdot        # KDE profile manager
│                   └── ha-fan-toggle
├── chezmoi/                  # User dotfiles (applied by chezmoi)
│   ├── dot_gitconfig         # → ~/.gitconfig
│   ├── dot_gitconfig-github  # → ~/.gitconfig-github
│   ├── dot_gitconfig-gitlab  # → ~/.gitconfig-gitlab
│   └── dot_config/
│       ├── fastfetch/        # → ~/.config/fastfetch/
│       ├── git/              # (legacy, kept for reference)
│       ├── kitty/            # → ~/.config/kitty/
│       ├── mpv/              # → ~/.config/mpv/
│       ├── vscode/           # → ~/.config/vscode/
│       └── zsh/              # → ~/.config/zsh/.zshrc
├── kde/
│   ├── README.md             # KDE keybinds reference
│   └── konsave/              # Tracked .knsv profile archives
├── scripts/
│   └── run_once_install-ansible.sh  # Bootstrap script
├── secrets/
│   ├── README.md             # SOPS + age setup guide
│   └── vault.yml             # Encrypted credentials
└── .github/
    └── workflows/
        └── ci.yml            # lint + syntax-check + dry-run
```

## Sources of truth

| What | File |
|---|---|
| Flatpak apps | `ansible/inventory/group_vars/all.yml` → `flatpak_apps` |
| User groups | `ansible/inventory/group_vars/all.yml` → `user_groups` |
| Debian packages | `ansible/inventory/group_vars/Debian.yml` → `base_packages` |
| Host packages | `ansible/inventory/host_vars/<host>.yml` → `extra_packages` |

## KDE profile management

`kdot` is deployed to `~/.local/bin` by Ansible and works from anywhere:

```bash
kdot --export            # Save KDE profile → kde/konsave/default_YYYY-MM-DD.knsv
kdot --import            # Import latest .knsv for profile
kdot --list              # List tracked archives + konsave -l
kdot --push              # git add new .knsv files, commit, push
```

## Secrets

Encrypted with SOPS + age. See [secrets/README.md](secrets/README.md) for full setup.

```bash
# Edit secrets
sops secrets/vault.yml
```

## CI

GitHub Actions runs on every push/PR:
- `lint` — ansible-lint
- `syntax-check` — `--syntax-check` against localhost
- `dry-run` — `--check` inside a `debian:bookworm` container

## Design philosophy

- **Ansible** → how the system is built
- **Chezmoi** → how the user environment looks
- **kdot** → how KDE profiles are versioned
- **SOPS** → how secrets stay private
- `all.yml` → one place to add a flatpak or group