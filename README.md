# Dotfiles & System Configuration Structure

This repository is organized into clear layers separating system provisioning, user configuration, automation, themes, and sensitive data.

---

## 🧩 High-Level Architecture

- **Ansible** → System setup (machine provisioning, packages, services)
- **Chezmoi** → User configuration (dotfiles, shell, apps)
- **Scripts** → Automation and operational actions
- **Themes** → Shared visual assets and color schemes
- **Secrets** → Sensitive data (keys, private configs)

---

## 📁 Repository Structure

~~~
.
├── README.md
├── ansible
├── chezmoi
├── kde
├── scripts
└── secrets
~~~

---

## ⚙️ Ansible (System Setup)

Handles full machine provisioning across Debian/Ubuntu machines.

### Responsibilities
- Install system packages and Flatpak apps
- Configure services (networking, bluetooth, display manager)
- Setup KDE Plasma desktop environment
- Manage bootloader (GRUB) and system-level configs
- Create and configure the user account
- Deploy dotfiles via chezmoi
- Restore KDE profile via konsave

### Usage

```bash
# Bootstrap: installs Ansible + collections, then runs the playbook
bash scripts/run_once_install-ansible.sh

# Or run directly (Ansible already installed)
cd ansible
ansible-playbook playbooks/setup.yml -l desktop
ansible-playbook playbooks/setup.yml -l laptop

# Dry-run (no changes applied)
ansible-playbook playbooks/setup.yml --check --diff -l desktop
```

### Key Structure

~~~
ansible/
├── ansible.cfg
├── requirements.yml
├── inventory/
│   ├── hosts.yml
│   ├── group_vars/
│   │   ├── all.yml
│   │   ├── Debian.yml
│   │   └── Archlinux.yml
│   └── host_vars/
│       ├── desktop.yml
│       └── laptop.yml
├── playbooks/
│   └── setup.yml
└── roles/
    ├── system/
    │   ├── packages/        # Base apt packages
    │   ├── flatpak/         # Flatpak + Flathub apps
    │   ├── bluetooth/       # bluez service
    │   ├── bootloader/      # GRUB config
    │   ├── display_manager/ # SDDM
    │   ├── networking/      # NetworkManager + systemd-resolved
    │   ├── docker/          # Docker CE + compose
    │   ├── nvidia/          # Proprietary driver + extras
    │   ├── fonts/           # System + Nerd Fonts
    │   ├── gaming/          # Steam, Lutris, gamemode
    │   └── vm/              # KVM/QEMU + virt-manager
    ├── desktop/
    │   ├── kde/             # KDE Plasma packages
    │   ├── kde/themes/      # kwriteconfig6 theme settings
    │   ├── konsave/         # KDE profile restore
    │   ├── hyprland/
    │   └── niri/
~~~

---

## 🏠 Chezmoi (User Configuration)

Manages per-user dotfiles and application configuration.

### Responsibilities
- Shell setup (zsh, bash)
- Window manager configs (Hyprland, Niri)
- UI tools (Waybar, Wofi, Mako)
- Git, terminal, and CLI configs

### Key Structure

~~~
chezmoi/
├── dot_config/
│   ├── bash/
│   ├── git/
│   ├── hypr/
│   ├── mako/
│   ├── niri/
│   ├── waybar/
│   ├── wofi/
│   └── zsh/
└── themes/
    ├── assets/
    │   ├── fonts/
    │   └── wallpapers/
    ├── color-schemes/
    │   ├── catppuccin/
    │   └── dracula/
    └── dot_theme.toml
~~~

---

## 🎨 Themes (Design System)

Centralized theme assets shared across tools.

### Contains
- Color schemes (Catppuccin, Dracula)
- Fonts
- Wallpapers
- Theme configuration (`theme.toml`)

### Purpose
Ensures consistent visual identity across:
- Terminal
- Shell
- Window manager
- GUI apps

---

## 🧪 Scripts (Automation Layer)

Utility scripts for system operations and workflows.

### Structure

~~~
scripts/
├── konsave/
│   ├── export.sh
│   ├── import.sh
│   └── list.sh
└── run_once_install-ansible.sh
~~~

### Use Cases
- One-time bootstrap installs
- KDE profile backup/restore
- Automation of repetitive setup tasks

---

## 🔐 Secrets (Sensitive Data)

Isolated storage for sensitive configuration.

~~~
secrets/
└── README.md
~~~

### Contents
- API keys
- Private credentials
- Machine-specific secrets

---

## 🖥 KDE Profiles

~~~
kde/
└── konsave
~~~

Used for KDE desktop environment snapshots and restoration using `konsave`.

---

## 🧠 Design Philosophy

This setup follows a separation-of-concerns model:

- **Ansible** → *How the system is built*
- **Chezmoi** → *How the user environment looks*
- **Scripts** → *How actions are automated*
- **Themes** → *How everything looks visually*
- **Secrets** → *What must stay private*

---

## 🔗 Reference

Based on:
https://github.com/shalva97/kde-configuration-files