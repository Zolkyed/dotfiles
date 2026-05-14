# Archinstall

This folder stores the Arch Linux installer inputs only.

Keep this stage small:

- `user_configuration.json`: disk layout, bootloader, base install choices.
- `user_credentials.json`: SOPS-encrypted passwords and user credentials.
- Ansible remains the source of truth for real package and service state.
- Chezmoi remains the source of truth for user dotfiles.

## Full Workflow

### 1. Prepare SOPS Key

Your SOPS Age private key must be available as `keys.txt`. Keep it outside git,
for example on an encrypted USB drive or password manager.

Expected default path:

```bash
~/.config/sops/age/keys.txt
```

You can also use a custom path:

```bash
export SOPS_AGE_KEY_FILE=/path/to/keys.txt
```

### 2. Boot Arch ISO

The easiest path is the interactive ISO installer:

```bash
curl -fsSL https://raw.githubusercontent.com/Zolkyed/dotfiles/main/scripts/run_archinstall.sh | bash
```

It installs live ISO tools, clones this repo, shows a numbered physical disk
picker, and runs archinstall. If `keys.txt` is missing, the script
enables SSH so you can copy it from another machine.

Copy your key from another machine when SSH is enabled:

```bash
scp -O ~/.config/sops/age/keys.txt root@<iso-ip>:/root/.config/sops/age/keys.txt
```

Manual setup uses the same pieces:

Install only the tools needed to clone the repo and decrypt secrets:

```bash
pacman -Sy git
```

If you prefer key-only SSH, pass your public key:

```bash
curl -fsSL https://raw.githubusercontent.com/Zolkyed/dotfiles/main/scripts/run_archinstall.sh |
    ISO_SSH_PUBLIC_KEY="$(cat ~/.ssh/id_ed25519.pub)" bash
```

Then connect from another machine:

```bash
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@<iso-ip>
```

Without `ISO_SSH_PUBLIC_KEY`, the script prompts for a temporary root password
for SSH. Use a strong temporary password; weak passwords can be rejected by the
ISO password policy.

Bring in the SOPS key. Example with a mounted USB drive:

```bash
mkdir -p ~/.config/sops/age
cp /run/media/usb/keys.txt ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

### 3. Clone Repo

```bash
git clone https://github.com/Zolkyed/dotfiles.git
cd dotfiles
```

If you copied the key before cloning, keep it at:

```bash
~/.config/sops/age/keys.txt
```

Verify decryption works:

```bash
sops --decrypt archinstall/user_credentials.json >/dev/null
```

### 4. Select Disk

Show disks before selecting:

```bash
lsblk -dpo NAME,SIZE,MODEL,TRAN,SERIAL,TYPE
```

Run archinstall:

```bash
./scripts/run_archinstall.sh /dev/disk/by-id/your-disk
```

The selected disk is wiped.

### 5. Reboot

After archinstall completes, reboot into the installed system.

### 6. Restore SOPS Key In Installed System

Copy the same `keys.txt` into the installed user's home:

```bash
mkdir -p ~/.config/sops/age
cp /path/to/keys.txt ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

If using another path:

```bash
export SOPS_AGE_KEY_FILE=/path/to/keys.txt
```

### 7. Bootstrap Ansible

```bash
git clone https://github.com/Zolkyed/dotfiles.git ~/dotfiles
cd ~/dotfiles
./scripts/run_ansibleinstall.sh desktop
```

Bootstrap installs Ansible/SOPS tooling, loads encrypted Ansible vaults, runs
the setup playbook, and the dotfiles role applies chezmoi.

The checked-in `user_configuration.json` file uses a whole-disk layout with:

- GRUB
- 1 GiB EFI system partition mounted at `/boot`
- Btrfs root using the rest of the disk
- Btrfs subvolumes for `/`, `/home`, `/var/cache/pacman/pkg`, and `/var/log`
- Canada and United States mirrors

Create or update configs from the Arch ISO with:

```bash
archinstall --dry-run
```

Then copy the generated config from `/var/log/archinstall/`, fill
`user_credentials.json`, and encrypt credentials:

```bash
$EDITOR archinstall/user_credentials.json
sops --encrypt --in-place archinstall/user_credentials.json
```

The script renders a temporary config for the selected disk, then runs
archinstall. Hostname and machine profile remain owned by Ansible after first
boot. Choose `desktop`, `laptop`, or `server` only when running
`./scripts/run_ansibleinstall.sh <host>`.

Do not put the full workstation package list in archinstall JSON. Use only the
minimal packages needed to boot and run bootstrap tooling, such as `git`,
`curl`, `sudo`, and `networkmanager`. Secrets tooling, workstation packages,
services, Snapper, and dotfiles are managed after first boot through Ansible.
