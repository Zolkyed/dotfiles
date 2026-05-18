# Archinstall

ISO installer inputs. Clones the repo, generates a disk config, and runs `archinstall --config --creds --silent`.

## Usage

```bash
curl -fsSL https://raw.githubusercontent.com/Zolkyed/dotfiles/main/scripts/run_archinstall.sh | bash
# or specify disk: bash -s /dev/disk/by-id/your-disk
# or: ARCHINSTALL_DISK=/dev/nvme0n1 bash scripts/run_archinstall.sh
```

## Partition layout

- 1 GiB EFI at `/boot`, rest Btrfs
- Subvolumes: `@` `/`, `@home` `/home`, `@log` `/var/log`, `@pkg` `/var/cache/pacman/pkg`

## Password hash

Generate a hash for `user_credentials.json`:

```bash
python -c "import crypt; print(crypt.crypt('your-password'))"
```

## Post-install

```bash
# Laptop: connect Wi-Fi first
nmcli dev wifi connect "SSID" password "PASSWORD"

git clone https://github.com/Zolkyed/dotfiles.git && cd dotfiles
./scripts/run_ansibleinstall.sh desktop
```
