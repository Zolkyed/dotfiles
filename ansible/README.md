# Ansible

Arch Linux provisioning.

## Inventory

| File | Connection |
|---|---|
| `inventory/hosts.yml` | SSH |
| `inventory/local.yml` | Local |

Hosts: `desktop`, `laptop`, `server`.

## Vars

| File | Contents |
|---|---|
| `group_vars/all.yml` | user, presets, feature flags |
| `group_vars/vault.yml` | shared secrets (SOPS) |
| `host_vars/<host>/vars.yml` | active preset |
| `host_vars/<host>/vault.yml` | SSH keys (SOPS) |

Package, service, Flatpak, AUR, npm, and pipx lists live in each role's `defaults/main.yml`.

## Features

Each host activates a preset which enables a list of features. Features gate optional roles. GPU features (`nvidia_gpu`, `amd_gpu`, `intel_gpu`) are auto-detected from `lspci`.

```yaml
# host_vars/desktop/vars.yml
active_preset: desktop

# group_vars/all.yml
presets:
  desktop:
    features: [audio, plasma, browser, gaming, ...]
```

## Playbooks

| Playbook | Purpose |
|---|---|
| `setup.yml` | One-time provisioning |
| `update.yml` | Package upgrades |
| `dotfiles.yml` | Apply chezmoi dotfiles |
| `maintenance.yml` | Housekeeping (orphans, journal, caches) |
