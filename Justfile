set shell := ["bash", "-cu"]

ANSIBLE_DIR := "ansible"
PLAYBOOK := "playbooks/setup.yml"
VAULT_FILE := "ansible/inventory/group_vars/vault.yml"

# ─── Ansible ────────────────────────────────────────────────────────────

run host="desktop" v="-v":
    cd {{ANSIBLE_DIR}} && ansible-playbook {{PLAYBOOK}} -l {{host}} {{v}}

check host="desktop":
    cd {{ANSIBLE_DIR}} && ansible-playbook {{PLAYBOOK}} --check --diff -l {{host}}

tags host="desktop" tags="all":
    cd {{ANSIBLE_DIR}} && ansible-playbook {{PLAYBOOK}} -l {{host}} --tags {{tags}}

bootstrap:
    bash scripts/run_once_install-ansible.sh

rebuild host="desktop":
    just run {{host}}
    just apply

lint:
    cd {{ANSIBLE_DIR}} && ansible-lint

# ─── Vault ──────────────────────────────────────────────────────────────

vault-edit:
    sops {{VAULT_FILE}}

vault-view:
    sops -d {{VAULT_FILE}}

# ─── Chezmoi ────────────────────────────────────────────────────────────

apply:
    chezmoi apply --no-tty --force

diff:
    chezmoi diff

# ─── Konsave ─────────────────────────────────────────────────────────────

konsave-install host="desktop":
    cd {{ANSIBLE_DIR}} && ansible-playbook {{PLAYBOOK}} -l {{host}} --tags konsave

konsave-import host="desktop":
    cd {{ANSIBLE_DIR}} && ansible-playbook {{PLAYBOOK}} -l {{host}} --tags konsave-import

konsave-export host="desktop":
    cd {{ANSIBLE_DIR}} && ansible-playbook {{PLAYBOOK}} -l {{host}} --tags konsave-export

konsave-delete host="desktop":
    cd {{ANSIBLE_DIR}} && ansible-playbook {{PLAYBOOK}} -l {{host}} --tags konsave-delete

# ─── Help ───────────────────────────────────────────────────────────────

default:
    @just --list