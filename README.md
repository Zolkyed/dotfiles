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

Handles full machine provisioning across different distributions and device types.

### Responsibilities
- Install system packages
- Configure services (networking, bluetooth, display manager)
- Setup desktop environments (KDE, Hyprland, Niri)
- Manage bootloader and system-level configs

### Key Structure

~~~
ansible/
├── ansible.cfg
├── group_vars/
│   ├── Archlinux.yml
│   ├── Debian.yml
│   └── all.yml
├── host_vars/
│   ├── desktop.yml
│   └── laptop.yml
├── inventory/
│   └── hosts.yml
├── playbooks/
│   └── setup.yml
├── roles/
│   ├── desktop/
│   │   ├── hyprland/
│   │   ├── kde/
│   │   └── niri/
│   ├── display_manager/
│   ├── system/
│   │   ├── bluetooth/
│   │   ├── bootloader/
│   │   ├── networking/
│   │   └── packages/
│   └── user/
└── vars/
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