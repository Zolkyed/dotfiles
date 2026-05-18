# dotfiles

Arch Linux provisioning + user environment.

![desktop](assets/wallpaper.png)

## Quick start

```bash
git clone https://github.com/Zolkyed/dotfiles ~/dotfiles
cd ~/dotfiles
just ansibleinstall desktop
```

Run `just` to list all commands.

## Design

- **Ansible** → packages, services, users, boot config
- **Chezmoi** → shell, editor, terminal, theme
- **SOPS + age** → secrets encrypted at rest
- **`group_vars/all.yml`** → user defaults and host feature presets
- **`host_vars/<host>/vars.yml`** → active preset selection

## Hosts

| Host | Preset features |
|---|---|
| desktop | audio, bluetooth, vpn, firewall, docker, virtualization, plasma, gaming, dev, ai, media, … |
| laptop | audio, bluetooth, vpn, firewall, docker, virtualization, plasma, dev, ai, media, … |
| server | vpn, firewall, docker, virtualization |

## References

- [shricodev/dotfiles](https://github.com/shricodev/dotfiles)
- [KDE monochrome in the night](https://www.reddit.com/r/unixporn/comments/1qimvm8/kde_monochrome_in_the_night/)
