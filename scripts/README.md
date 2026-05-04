# Scripts

## Bootstrap

```bash
# Install Ansible, age, sops, collections, then run the playbook
bash scripts/run_once_install-ansible.sh
```

On first run, auto-generates an age key at `~/.config/sops/age/keys.txt` if one does not exist.
