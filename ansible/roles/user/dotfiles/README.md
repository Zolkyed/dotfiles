# user/dotfiles

Installs chezmoi and keeps the home directory in sync with the dotfiles Git repo.

## Workflow

**Initial setup**
- Creates `~/.local/bin` and `~/.config`.
- Installs chezmoi.
- Clones the dotfiles repo to `~/.local/share/chezmoi`.
- Applies dotfiles to the home directory.

**Subsequent runs**
- Pulls the latest changes from Git.
- Applies any updated dotfiles — only files that actually changed are touched.

**Manual chezmoi use**

Ansible and chezmoi don't conflict. You can run chezmoi directly at any time:

```bash
chezmoi diff
chezmoi edit ~/.zshrc
chezmoi apply
```

The next Ansible run will pull and re-apply, overwriting any manual edits that differ from the repo.

## Variables

| Variable | Default | Description |
|---|---|---|
| `chezmoi_bin` | `{{ user_home }}/.local/bin/chezmoi` | Path to the chezmoi binary |
| `dotfiles_repo_dir` | `{{ user_home }}/.local/share/dotfiles` | Where the full repo is cloned |
| `chezmoi_source_dir` | `{{ dotfiles_repo_dir }}/chezmoi` | Chezmoi source (subdirectory inside the repo) |
| `dotfiles_repo` | `https://github.com/Zolkyed/dotfiles.git` | Dotfiles Git repo |
| `dotfiles_repo_branch` | `main` | Branch to track |
