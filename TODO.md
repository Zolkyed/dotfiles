# TODO

## High Priority

### [ ] system/backup
Centralized backup and recovery orchestration.

#### Manage
- restic
- borg
- btrfs snapshots
- automatic timers
- encrypted backups
- retention policies

#### Suggested structure
```text
roles/system/backup/
├── defaults
├── handlers
├── tasks
├── templates
└── files
```

#### Notes
- Repo provisions systems well but lacks recovery automation
- Integrate with existing `rclone` role if possible


### [ ] system/secrets
Centralized secrets and credential management.

#### Manage
- age / sops
- gpg
- ssh-agent
- secret deployment
- API token handling

#### Notes
Existing secret-related systems:
- ansible vaults
- chezmoi templates
- SSH configs
- MPV AniList token

---
# Future Architecture

## [ ] Introduce profile/meta roles

As role count grows, composition becomes harder to manage.

### Consider
- meta-roles
- profiles
- tags
- composition layers

### Example
```yaml
roles:
  - profile/base
  - profile/desktop
  - profile/laptop
  - profile/gaming
```

Instead of manually managing large role lists.



Fix SSH KEYS, HELIX, YAZI, DISCORD, BTRFS, SSDM DISPLAY LOGIN, KEYBOARD, AI SKILLS,
AppImageLauncher, AppImagePool