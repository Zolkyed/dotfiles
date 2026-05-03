# Scripts

## Bootstrap

```bash
# Install Ansible, age, sops, collections, then run the playbook
bash scripts/run_once_install-ansible.sh
```

On first run, auto-generates an age key at `~/.config/sops/age/keys.txt` if one does not exist.

## kdot — KDE profile manager

Deployed to `~/.local/bin/kdot` by Ansible. Works from anywhere.

```bash
kdot --export [profile]   # Save + export → kde/konsave/<profile>_YYYY-MM-DD.knsv
kdot --import [profile]   # Import latest .knsv archive for that profile
kdot --list               # List tracked archives + konsave -l
kdot --push               # git add new .knsv files, commit, push
```

Override the repo path: `DOTFILES_DIR=/path/to/repo kdot --export`
