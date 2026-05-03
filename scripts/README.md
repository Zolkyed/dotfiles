# Scripts

## konsave helpers

These helper scripts keep KDE profile archives in this repository so they can be
versioned and tracked by git.

- Export to tracked file: `scripts/konsave/export.sh [profile_name] [archive_name]`
- Import from tracked file: `scripts/konsave/import.sh [archive_name]`
- List tracked and local profiles: `scripts/konsave/list.sh`

Tracked archive location:

- `kde/konsave/*.knsv`
