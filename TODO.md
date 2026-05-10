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


### [ ] system/power
Power management and thermal tuning.

#### Manage
- tlp
- power-profiles-daemon
- thermald
- suspend settings
- lid behavior
- CPU governors
- AMD/Intel tuning

#### Notes
- Especially useful for laptops
- Related to existing `fan-toggle` utility

---

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

### [x] system/bootloader
Unified bootloader and kernel boot management.

#### Manage
- GRUB / systemd-boot
- kernel parameters
- unified kernel images
- Secure Boot
- microcode
- boot entry cleanup

#### Notes
Complements existing:
- splashboot
- nvidia

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