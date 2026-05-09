# Chezmoi

User dotfiles managed by [chezmoi](https://www.chezmoi.io/). Applied automatically by Ansible (`home/dotfiles` role) or manually:

```bash
chezmoi apply
# or use just:
just apply
just diff
```

## Source → target mapping

Chezmoi strips the `dot_` prefix on apply:

| Source | Target |
|---|---|
| `dot_gitconfig` | `~/.gitconfig` |
| `dot_gitconfig-github` | `~/.gitconfig-github` |
| `dot_gitconfig-gitlab` | `~/.gitconfig-gitlab` |
| `dot_gitignore_global` | `~/.gitignore_global` |
| `dot_zshrc` | `~/.zshrc` |
| `dot_ssh/config.tmpl` | `~/.ssh/config` |
| `dot_config/fastfetch/` | `~/.config/fastfetch/` |
| `dot_config/hypr/` | `~/.config/hypr/` |
| `dot_config/kitty/` | `~/.config/kitty/` |
| `dot_config/mpv/` | `~/.config/mpv/` |
| `dot_config/niri/` | `~/.config/niri/` |
| `dot_config/Code/User/settings.json` | `~/.config/Code/User/settings.json` |
| `dot_config/Code/User/keybindings.json` | `~/.config/Code/User/keybindings.json` |

## Git identity

`dot_gitconfig` uses `includeIf hasconfig` to load per-remote identity:
- GitHub repos → `~/.gitconfig-github` (Zolkyed)
- GitLab repos → `~/.gitconfig-gitlab` (Charles Hamelin)

## Editing

Edit files directly in this repo under `chezmoi/`, then re-run `chezmoi apply` or the Ansible playbook.
