# Chezmoi

User dotfiles managed by [chezmoi](https://www.chezmoi.io/). Applied automatically by Ansible (`user/dotfiles` role) or manually:

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
| `dot_config/vscode/` | `~/.config/vscode/` |
| `dot_config/zsh/.zshrc` | `~/.config/zsh/.zshrc` |

## Git identity

`dot_gitconfig` uses `includeIf hasconfig` to load per-remote identity:
- GitHub repos → `~/.gitconfig-github` (Zolkyed)
- GitLab repos → `~/.gitconfig-gitlab` (Charles Hamelin)

## Editing

Edit files directly in this repo under `chezmoi/`, then re-run `chezmoi apply` or the Ansible playbook.
