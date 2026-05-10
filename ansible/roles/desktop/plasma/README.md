# plasma

KDE Plasma desktop role — installs packages and deploys global keybinds.

## What this role does

- Installs `plasma_packages` (defined in `group_vars/debian.yml` / `group_vars/archlinux.yml`)
- Deploys per-host KDE global shortcuts (`files/keybinds/<hostname>.ini` → `~/.config/kglobalshortcutsrc`)
- Deploys mouse button rebinds and pointer settings (`files/kcminputrc` → `~/.config/kcminputrc`, desktop only)

## What chezmoi manages

All user-space Plasma config files live in `chezmoi/` and are applied by
`chezmoi apply`. Add them with `chezmoi add ~/.config/<file>` on a
configured machine.

| File | What it controls |
|---|---|
| `~/.config/kwinrc` | KWin rules, compositing, tiling |
| `~/.config/kdeglobals` | Theme, colors, fonts, icon set |
| `~/.config/plasma-org.kde.plasma.desktop-appletsrc` | Panel layout, widgets |
| `~/.config/plasmashellrc` | Panel visibility, screen mapping |
| `~/.config/kxkbrc` | Keyboard layout |
| `~/.config/konsolerc` | Terminal settings |
| `~/.local/share/konsole/*.profile` | Konsole profiles |
| `~/.config/dolphinrc` | File manager settings |
| `~/.config/spectaclerc` | Screenshot tool settings |
| `~/.config/breezerc` | Window decoration settings |
| `~/.local/share/color-schemes/` | Custom color schemes |

## Adding a Plasma config to chezmoi

```bash
# On a configured machine, capture the current state:
chezmoi add ~/.config/kwinrc
chezmoi add ~/.config/kdeglobals

# Then commit from the dotfiles repo:
cd ~/dotfiles
git add chezmoi/dot_config/kwinrc chezmoi/dot_config/kdeglobals
git commit -m "feat: add plasma kwin and global config"
```

https://github.com/shalva97/kde-configuration-files
