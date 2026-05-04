# dotfiles

Full machine provisioning and user environment for Debian/Ubuntu + KDE Plasma.

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
│   │   │   ├── all.yml       # desktop_environment, extra_packages, flatpak_apps, user_groups
│   │   │   └── Debian.yml    # base_packages              ← OS-specific names
│   │   └── host_vars/
│   │       ├── desktop.yml   # machine_type, monitor, bootloader overrides
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
│       │   ├── kde/          # KDE packages, konsave restore, + keybind settings
│       └── home/
│           └── user/
│               ├── (main)        # User account, shell, groups
│               ├── dotfiles/     # chezmoi install + apply --force
│               ├── ssh_keys/     # Deploy keys from vault
│               ├── dev/          # Dev tools, nvm, rustup
│               └── bin/          # Custom scripts → ~/.local/bin
│                   └── files/
│                       └── ha-fan-toggle
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
| Desktop environment | `ansible/inventory/group_vars/all.yml` → `desktop_environment` |
| Extra packages | `ansible/inventory/group_vars/all.yml` → `extra_packages` |
| Flatpak apps | `ansible/inventory/group_vars/all.yml` → `flatpak_apps` |
| User groups | `ansible/inventory/group_vars/all.yml` → `user_groups` |
| Debian packages | `ansible/inventory/group_vars/Debian.yml` → `base_packages` |
| KDE baseline snapshot | `ansible/roles/desktop/kde/defaults/main.yml` → `kde_konsave_profile_src`, `kde_konsave_profile_name` |
| KDE keybinds | `ansible/roles/desktop/kde/defaults/main.yml` → `kde_keybind_files` |

## KDE management

`ansible/roles/desktop/kde/` uses two layers:
- `kde_konsave_profile_src` / `kde_konsave_profile_name` restore a one-shot visual baseline from a `.knsv` package
- `kde_keybind_files` enforces keybinds idempotently with `community.general.kdeconfig`

If your `.knsv` file lives in a synced Google Drive folder, point `kde_konsave_profile_src` at that local synced path.

## Secrets

Encrypted with SOPS + age. See [secrets/README.md](secrets/README.md) for full setup.

```bash
# Edit secrets
sops secrets/vault.yml
```

## Design philosophy

- **Ansible** → how the system is built
- **Chezmoi** → how the user environment looks
- **KDE role** → installs KDE packages, restores a konsave baseline, and writes selected keybinds
- **SOPS** → how secrets stay private
- `all.yml` → one place to add a flatpak or group
