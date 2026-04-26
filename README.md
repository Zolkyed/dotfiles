- Ansible   → system setup
- chezmoi   → user config
- scripts   → actions
- themes    → assets
- secrets   → keys


```
.
├── README.md
├── ansible
│   ├── README.md
│   ├── ansible.cfg
│   ├── group_vars
│   │   ├── Archlinux.yml
│   │   ├── Debian.yml
│   │   └── all.yml
│   ├── host_vars
│   │   ├── desktop.yml
│   │   └── laptop.yml
│   ├── inventory
│   │   └── hosts.yml
│   ├── playbooks
│   │   └── setup.yml
│   ├── roles
│   │   ├── desktop
│   │   │   ├── hyprland
│   │   │   │   ├── defaults
│   │   │   │   │   └── main.yml
│   │   │   │   ├── handlers
│   │   │   │   │   └── main.yml
│   │   │   │   ├── tasks
│   │   │   │   │   └── main.yml
│   │   │   │   └── templates
│   │   │   ├── kde
│   │   │   │   ├── defaults
│   │   │   │   │   └── main.yml
│   │   │   │   ├── handlers
│   │   │   │   │   └── main.yml
│   │   │   │   ├── tasks
│   │   │   │   │   └── main.yml
│   │   │   │   └── templates
│   │   │   └── niri
│   │   │       ├── defaults
│   │   │       │   └── main.yml
│   │   │       ├── handlers
│   │   │       │   └── main.yml
│   │   │       ├── tasks
│   │   │       │   └── main.yml
│   │   │       └── templates
│   │   ├── display_manager
│   │   │   ├── defaults
│   │   │   │   └── main.yml
│   │   │   ├── handlers
│   │   │   │   └── main.yml
│   │   │   └── tasks
│   │   │       └── main.yml
│   │   ├── konsave
│   │   ├── system
│   │   │   ├── bluetooth
│   │   │   │   ├── defaults
│   │   │   │   │   └── main.yml
│   │   │   │   ├── handlers
│   │   │   │   │   └── main.yml
│   │   │   │   └── tasks
│   │   │   │       └── main.yml
│   │   │   ├── bootloader
│   │   │   │   ├── defaults
│   │   │   │   │   └── main.yml
│   │   │   │   ├── handlers
│   │   │   │   │   └── main.yml
│   │   │   │   ├── tasks
│   │   │   │   │   └── main.yml
│   │   │   │   └── templates
│   │   │   │       └── grub.j2
│   │   │   ├── networking
│   │   │   │   ├── defaults
│   │   │   │   │   └── main.yml
│   │   │   │   ├── handlers
│   │   │   │   │   └── main.yml
│   │   │   │   ├── tasks
│   │   │   │   │   └── main.yml
│   │   │   │   └── templates
│   │   │   │       └── resolved.conf.j2
│   │   │   └── packages
│   │   │       ├── defaults
│   │   │       │   └── main.yml
│   │   │       └── tasks
│   │   │           └── main.yml
│   │   └── user
│   │       ├── defaults
│   │       │   └── main.yml
│   │       └── tasks
│   │           └── main.yml
│   └── vars
├── chezmoi
│   ├── dot_config
│   │   ├── bash
│   │   ├── git
│   │   │   └── config.tmpl
│   │   ├── hypr
│   │   │   ├── hypridle.conf
│   │   │   ├── hyprland.conf
│   │   │   ├── hyprlock.conf
│   │   │   └── hyprpaper.conf
│   │   ├── mako
│   │   │   └── config
│   │   ├── niri
│   │   │   └── config.kdl
│   │   ├── waybar
│   │   │   ├── config
│   │   │   └── style.css
│   │   ├── wofi
│   │   │   ├── config
│   │   │   └── style.css
│   │   └── zsh
│   │       ├── conf.d
│   │       │   ├── aliases.zsh
│   │       │   ├── completions.zsh
│   │       │   ├── exports.zsh
│   │       │   └── plugins.zsh
│   │       └── dot_zshrc.tmpl
│   └── themes
│       ├── assets
│       │   ├── fonts
│       │   └── wallpapers
│       ├── color-schemes
│       │   ├── catppuccin
│       │   └── dracula
│       └── dot_theme.toml
├── kde
│   └── konsave
├── scripts
│   ├── konsave
│   │   ├── export.sh
│   │   ├── import.sh
│   │   └── list.sh
│   └── run_once_install-ansible.sh
└── secrets
    └── README.md
```