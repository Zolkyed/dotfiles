# Chezmoi

User dotfiles managed by [chezmoi](https://www.chezmoi.io/). Applied automatically by Ansible (`home/user/dotfiles` role) or manually:

```bash
chezmoi apply
```

## Source → target mapping

Chezmoi strips the `dot_` prefix on apply:

| Source | Target |
|---|---|
| `dot_gitconfig` | `~/.gitconfig` |
| `dot_gitconfig-github` | `~/.gitconfig-github` |
| `dot_gitconfig-gitlab` | `~/.gitconfig-gitlab` |
| `dot_config/fastfetch/` | `~/.config/fastfetch/` |
| `dot_config/kitty/` | `~/.config/kitty/` |
| `dot_config/mpv/` | `~/.config/mpv/` |
| `dot_config/vscode/settings.json` | `~/.config/vscode/settings.json` |
| `dot_config/vscode/keybindings.json` | `~/.config/vscode/keybindings.json` |
| `dot_zshrc` | `~/.zshrc` |

## Git identity

`dot_gitconfig` uses `includeIf hasconfig` to load per-remote identity:
- GitHub repos → `~/.gitconfig-github` (Zolkyed)
- GitLab repos → `~/.gitconfig-gitlab` (Charles Hamelin)

## Editing

Edit files directly in this repo under `chezmoi/`, then re-run `chezmoi apply` or the Ansible playbook.
