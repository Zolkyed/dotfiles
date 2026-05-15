# Archinstall

ISO installer inputs.

The script clones the repo if not already present, generates a disk config with
dynamic partition sizing, and runs `archinstall --config --creds --silent`.

## Usage

```bash
# Interactive disk picker
curl -fsSL https://raw.githubusercontent.com/Zolkyed/dotfiles/main/scripts/run_archinstall.sh | bash

# Or specify disk directly
curl -fsSL ... | bash -s /dev/disk/by-id/your-disk

# Or with env vars
ARCHINSTALL_DISK=/dev/nvme0n1 bash scripts/run_archinstall.sh
```

Archinstall prompts for destructive disk confirmation before touching the disk.

## Password hash

`user_credentials.json` needs a password hash. Generate one:

```bash
python -c "import crypt; print(crypt.crypt('your-password'))"
```

Or create a temporary credentials file with `archinstall --dry-run` and copy the hash.

## Partition layout

- GRUB, 1 GiB EFI at `/boot`, rest is Btrfs
- Subvolumes: `@` `/`, `@home` `/home`, `@log` `/var/log`, `@pkg` `/var/cache/pacman/pkg`
- Sizing adapts to disk size

## Post-install

On a laptop, connect Wi-Fi before cloning the repo:

```bash
nmcli dev wifi list
nmcli dev wifi connect "SSID" password "PASSWORD"
```

```bash
git clone https://github.com/Zolkyed/dotfiles.git
cd dotfiles
./scripts/run_ansibleinstall.sh desktop
```

This grants passwordless sudo, installs age/sops/ansible, decrypts the age key
from `secrets/age_key.age` or `~/.config/sops/age/keys.txt`, and runs the playbook.
