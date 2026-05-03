# Secrets

Secrets are encrypted with [SOPS](https://github.com/getsops/sops) + [age](https://github.com/FiloSottile/age).  
`vault.yml` is safe to commit — it is encrypted at rest.

## Prerequisites

```bash
# Install age
sudo apt install age

# sops is installed automatically by the Ansible playbook,
# or manually via the bootstrap script: scripts/run_once_install-ansible.sh
```

## First-time setup

### 1. Generate your age key (once per machine)

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
```

The public key printed (e.g. `age1...`) goes into `.sops.yaml`.  
The private key in `~/.config/sops/age/keys.txt` **never** leaves your machine.

### 2. Generate SSH keys

```bash
ssh-keygen -t ed25519 -C "charl@desktop" -f ~/.ssh/id_ed25519_github -N ""
ssh-keygen -t ed25519 -C "charl@desktop" -f ~/.ssh/id_ed25519_gitlab -N ""
```

### 3. Populate and encrypt vault.yml

```bash
cd ~/projects/dotfiles

cat > secrets/vault.yml <<EOF
vault_ssh_private_key_github: |
$(sed 's/^/    /' ~/.ssh/id_ed25519_github)
vault_ssh_public_key_github: $(cat ~/.ssh/id_ed25519_github.pub)
vault_ssh_private_key_gitlab: |
$(sed 's/^/    /' ~/.ssh/id_ed25519_gitlab)
vault_ssh_public_key_gitlab: $(cat ~/.ssh/id_ed25519_gitlab.pub)
EOF

# Encrypt in-place (uses .sops.yaml to find your age public key)
sops --encrypt --in-place secrets/vault.yml
```

### 4. Verify

```bash
# Should show encrypted ciphertext
cat secrets/vault.yml

# Should show decrypted values
sops --decrypt secrets/vault.yml
```

## Editing secrets later

```bash
sops secrets/vault.yml
```

This opens your `$EDITOR` with the decrypted content and re-encrypts on save.

## How it works

- `.sops.yaml` at the repo root defines which age key encrypts which files
- The Ansible playbook uses `community.sops.load_vars` to decrypt at runtime
- sops reads the private key automatically from `~/.config/sops/age/keys.txt`
