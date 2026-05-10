# Chezmoi

User dotfiles managed by [chezmoi](https://www.chezmoi.io/).
Applied automatically by the Ansible `user/dotfiles` role, or manually:

```bash
just apply   # chezmoi apply --no-tty --force
just diff    # chezmoi diff
```

## Template variables

`.chezmoi.toml.tmpl` exposes these variables to all `.tmpl` files:

| Variable | Type | Values |
|---|---|---|
| `{{ .hostname }}` | string | `desktop`, `laptop`, `server` |
| `{{ .isDesktop }}` | bool | `true` on desktop host |
| `{{ .isLaptop }}` | bool | `true` on laptop host |
| `{{ .isServer }}` | bool | `true` on server host |
| `{{ .isArch }}` | bool | `true` on Arch Linux |
| `{{ .isDebian }}` | bool | `true` on Debian / Ubuntu |

Usage example:

```
{{ if not .isServer }}
# desktop/laptop-only config
{{ end }}
```

## Source → target mapping

Chezmoi strips the `dot_` prefix and evaluates `.tmpl` files on apply:

| Source | Target |
|---|---|
| `.chezmoi.toml.tmpl` | `~/.config/chezmoi/chezmoi.toml` |
| `run_once_onchange_add-known-hosts.sh` | *(runs once, adds github.com / gitlab.com / bitbucket.org)* |
| `dot_gitconfig` | `~/.gitconfig` |
| `dot_gitconfig-github` | `~/.gitconfig-github` |
| `dot_gitconfig-gitlab` | `~/.gitconfig-gitlab` |
| `dot_gitignore_global` | `~/.gitignore_global` |
| `dot_zshrc.tmpl` | `~/.zshrc` |
| `dot_ssh/config.tmpl` | `~/.ssh/config` |
| `dot_config/atuin/` | `~/.config/atuin/` |
| `dot_config/bat/` | `~/.config/bat/` |
| `dot_config/Code/User/` | `~/.config/Code/User/` |
| `dot_config/fastfetch/` | `~/.config/fastfetch/` |
| `dot_config/hypr/` | `~/.config/hypr/` |
| `dot_config/kitty/` | `~/.config/kitty/` |
| `dot_config/lazygit/` | `~/.config/lazygit/` |
| `dot_config/mpv/` | `~/.config/mpv/` |
| `dot_config/niri/` | `~/.config/niri/` |
| `dot_config/starship.toml` | `~/.config/starship.toml` |
| `dot_config/tmux/` | `~/.config/tmux/` |

## Git identity

`dot_gitconfig` routes identity via `includeIf hasconfig` based on remote URL:

| Remote | Identity file |
|---|---|
| `https://github.com/**` | `~/.gitconfig-github` (Zolkyed) |
| `git@github.com:**` | `~/.gitconfig-github` (Zolkyed) |
| `https://gitlab.info.uqam.ca/**` | `~/.gitconfig-gitlab` (Charles Hamelin) |
| `git@gitlab.info.uqam.ca:**` | `~/.gitconfig-gitlab` (Charles Hamelin) |

## Editing

Edit files directly under `chezmoi/`, then run `just apply`.
Never edit `~/.zshrc`, `~/.gitconfig`, etc. directly — chezmoi will overwrite them.
