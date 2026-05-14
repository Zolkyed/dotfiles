# dotfiles

Arch Linux provisioning + user environment.

![desktop](assets/wallpaper.png)

## Quick start

```bash
git clone https://github.com/Zolkyed/dotfiles ~/dotfiles
cd ~/dotfiles
just ansibleinstall desktop
```

## Commands

```bash
just setup-dev       # create .venv with linters
just run <host>      # run playbook via SSH
just run-local <host># run playbook locally
just check <host>    # dry-run
just lint            # yamllint + shellcheck + ansible-lint
just vault-edit      # edit SOPS vault
just vault-view      # view SOPS vault
just apply           # chezmoi apply
just diff            # chezmoi diff
```

## Structure

```
.
├── ansible/                    # provisioning
│   ├── playbooks/setup.yml     # single playbook
│   ├── inventory/
│   │   ├── hosts.yml           # SSH inventory
│   │   ├── local.yml           # local inventory
│   │   └── {group,host}_vars/  # config + secrets
│   └── roles/{system,desktop,apps,user}/
├── archinstall/                 # ISO installer config
├── assets/                     # icons, wallpapers
├── chezmoi/                    # user dotfiles
│   ├── dot_zshrc
│   └── dot_config/{helix,kitty,tmux,yazi,zsh}/
├── docker/                     # CI test image
├── scripts/                    # bootstrap helpers
├── secrets/                    # encrypted age key
└── Justfile
```

## Design

- **Ansible** → packages, services, users, boot config
- **Chezmoi** → shell, editor, terminal, theme
- **SOPS + age** → secrets encrypted at rest
- **`all.yml`** → presets + shared defaults
- **`archlinux.yml`** → profile-based package data
- **`host_vars/<host>/vars.yml`** → per-machine overrides

## Host presets

| Host | Profiles |
|---|---|
| desktop | audio, bluetooth, nvidia, plasma, browser, dev, flatpak, media, office, gaming, ai, docker, virtualization, ... |
| laptop | same as desktop |
| server | vpn, firewall, bootloader, docker, virtualization |

## References

- [shricodev/dotfiles](https://github.com/shricodev/dotfiles)
- [KDE monochrome in the night](https://www.reddit.com/r/unixporn/comments/1qimvm8/kde_monochrome_in_the_night/)
