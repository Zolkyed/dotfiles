# dotfiles

Full machine provisioning and user environment for Debian and Arch Linux.

## Architecture

| Layer | Tool | Responsibility |
|---|---|---|
| System | Ansible | Packages, services, drivers, users |
| Dotfiles | Chezmoi | Shell, editor, app config |
| KDE | Ansible | Packages, konsave baseline restore, and selected keybinds |
| Secrets | SOPS + age | SSH keys, tokens, credentials |
| Scripts | bootstrap | Operational helpers |

## Quick start

```bash
# Clone
git clone https://github.com/Zolkyed/dotfiles ~/projects/dotfiles
cd ~/projects/dotfiles

# Bootstrap: installs Ansible, sops, age, collections, then runs the playbook
bash scripts/run_once_install-ansible.sh
```

```bash
# Local CI/lint tooling
just setup-dev
just ci
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
│   │   │   ├── all.yml       # feature flags, user settings, shared Flatpaks/fonts
│   │   │   ├── Debian.yml    # Debian package/service names
│   │   │   └── Archlinux.yml # Arch package/service names
│   │   └── host_vars/
│   │       ├── desktop/vars.yml # host feature flags, monitor, bootloader overrides
│   │       └── laptop/vars.yml
│   ├── playbooks/
│   │   └── setup.yml         # Full setup playbook
│   └── roles/
│       ├── system/
│       │   ├── apt-architecture/ # Debian foreign architectures
│       │   ├── aur/          # Arch AUR helpers
│       │   ├── packages/     # distro package cache + base packages
│       │   ├── fonts/        # Nerd Fonts
│       │   ├── docker/       # Docker CE + compose plugin
│       │   ├── nvidia/       # Proprietary driver, nouveau blacklist
│       │   ├── virtualization/ # KVM/QEMU + virt-manager
│       │   ├── networking/   # NetworkManager + systemd-resolved
│       │   ├── sshd/         # sshd hardening
│       │   ├── bluetooth/    # bluez
│       │   ├── bootloader/   # GRUB (BIOS + UEFI)
│       │   └── display_manager/ # SDDM
│       ├── desktop/
│       │   ├── kde/          # rclone, konsave operations, and keybind settings
│       └── home/
│           ├── flatpak/      # Flathub remotes + user apps
│           └── user/
│               ├── (main)        # User account, shell, groups
│               ├── dotfiles/     # chezmoi install + apply --force
│               ├── ssh_keys/     # Deploy keys from vault
│               ├── dev/          # Dev tools, nvm, rustup
│               └── bin/          # Custom scripts → ~/.local/bin
│                   └── files/
│                       └── fan-toggle
├── chezmoi/                  # User dotfiles (applied by chezmoi)
│   ├── dot_gitconfig         # → ~/.gitconfig
│   ├── dot_gitconfig-github  # → ~/.gitconfig-github
│   ├── dot_gitconfig-gitlab  # → ~/.gitconfig-gitlab
│   ├── dot_zshrc             # → ~/.zshrc
│   └── dot_config/
│       ├── fastfetch/        # → ~/.config/fastfetch/
│       ├── kitty/            # → ~/.config/kitty/
│       ├── mpv/              # → ~/.config/mpv/
│       └── vscode/           # → ~/.config/vscode/
├── scripts/
│   └── run_once_install-ansible.sh  # Bootstrap script
├── secrets/
│   ├── README.md             # SOPS + age setup guide
│   └── vault.yml             # Encrypted credentials
└── .github/                  # reserved for future GitHub config
```

## Sources of truth

| What | File |
|---|---|
| Feature flags | `ansible/inventory/group_vars/all.yml` |
| Shared Flatpaks and Nerd Fonts | `ansible/inventory/group_vars/all.yml` |
| User and group defaults | `ansible/inventory/group_vars/all.yml` |
| Distro package names | `ansible/inventory/group_vars/Debian.yml`, `ansible/inventory/group_vars/Archlinux.yml` |
| Host overrides | `ansible/inventory/host_vars/<host>/vars.yml` |
| KDE keybinds | `ansible/roles/desktop/kde/keybinds/files/<host>.ini` |

## KDE management

`ansible/roles/desktop/kde/` is split into focused roles for rclone, konsave profile
operations, and host-specific keybind files.

## Secrets

Encrypted with SOPS + age. See [secrets/README.md](secrets/README.md) for full setup.

```bash
# Edit secrets
sops secrets/vault.yml
```

## Design philosophy

- **Ansible** → how the system is built
- **Chezmoi** → how the user environment looks
- **KDE roles** → manage rclone, konsave operations, and selected keybinds
- **SOPS** → how secrets stay private
- `all.yml` → one place for shared feature flags, Flatpaks, fonts, and user defaults
- `Debian.yml` / `Archlinux.yml` → distro package and service names only
