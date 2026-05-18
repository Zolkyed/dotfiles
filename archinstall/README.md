# Archinstall

ISO installer inputs. Clones the repo, generates a disk config, and runs `archinstall --config --creds --silent`.

## Usage

```bash
curl -fsSL https://raw.githubusercontent.com/Zolkyed/dotfiles/main/scripts/run_archinstall.sh | bash
```

## Partition layout

- 1 GiB EFI at `/boot`, rest Btrfs
- Subvolumes: `@` `/`, `@home` `/home`, `@log` `/var/log`, `@pkg` `/var/cache/pacman/pkg`

## Post-install

```bash
# Laptop: connect Wi-Fi first
nmcli dev wifi connect "SSID" password "PASSWORD"

git clone https://github.com/Zolkyed/dotfiles.git && cd dotfiles
./scripts/run_ansibleinstall.sh desktop
```
