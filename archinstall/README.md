# Archinstall

ISO installer inputs. Keep minimal — Ansible owns the real config.

## Workflow

**1. Prepare SOPS key** — `~/.config/sops/age/keys.txt`

**2. Boot ISO** and run:

```bash
curl -fsSL https://raw.githubusercontent.com/Zolkyed/dotfiles/main/scripts/run_archinstall.sh | bash
```

Without a SOPS key, SSH is enabled so you can copy it from another machine:

```bash
scp -O ~/.config/sops/age/keys.txt root@<iso-ip>:/root/.config/sops/age/keys.txt
```

Or pass a public key:

```bash
curl -fsSL https://raw.githubusercontent.com/Zolkyed/dotfiles/main/scripts/run_archinstall.sh |
    ISO_SSH_PUBLIC_KEY="$(cat ~/.ssh/id_ed25519.pub)" bash
```

**3. Select disk** — `./scripts/run_archinstall.sh /dev/disk/by-id/your-disk`

The selected disk is wiped.

**4. Reboot** into the installed system.

**5. Restore SOPS key** in the installed system.

**6. Bootstrap:**

```bash
git clone https://github.com/Zolkyed/dotfiles.git ~/dotfiles
cd ~/dotfiles
./scripts/run_ansibleinstall.sh desktop
```

## Layout

- GRUB, 1 GiB EFI at `/boot`, Btrfs for the rest
- Subvolumes: `/`, `/home`, `/var/cache/pacman/pkg`, `/var/log`
- CA/US mirrors

Generate config with `archinstall --dry-run`, copy from `/var/log/archinstall/`.
Encrypt credentials with `sops --encrypt --in-place archinstall/user_credentials.json`.
