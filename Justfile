set shell := ["bash", "-cu"]

ANSIBLE_DIR := "ansible"
PLAYBOOK    := "playbooks/setup.yml"
VAULT_FILE  := "ansible/inventory/group_vars/vault.yml"

# ─── Dev environment ────────────────────────────────────────────────────

setup-dev:
    python -m venv .venv
    .venv/bin/python -m pip install --upgrade pip
    .venv/bin/pip install ansible-lint yamllint shellcheck-py
    ANSIBLE_LOCAL_TEMP=/tmp/ansible-local ANSIBLE_REMOTE_TEMP=/tmp/ansible-remote \
        .venv/bin/ansible-galaxy collection install -r {{ANSIBLE_DIR}}/requirements.yml

# ─── Ansible ────────────────────────────────────────────────────────────

run host="desktop":
    cd {{ANSIBLE_DIR}} && ansible-playbook {{PLAYBOOK}} -l {{host}} -v

run-local host="desktop":
    cd {{ANSIBLE_DIR}} && ansible-playbook -i inventory/local.yml {{PLAYBOOK}} -l {{host}} -v

check host="desktop":
    cd {{ANSIBLE_DIR}} && ansible-playbook -i inventory/local.yml {{PLAYBOOK}} --check --diff -l {{host}}

ansibleinstall host="desktop":
    bash scripts/run_ansibleinstall.sh {{host}}

archinstall host="desktop" disk="":
    bash scripts/run_archinstall.sh {{host}} {{disk}}

# ─── Lint / CI ──────────────────────────────────────────────────────────

lint:
    cd {{ANSIBLE_DIR}} && export ANSIBLE_LOCAL_TEMP=/tmp/ansible-local ANSIBLE_REMOTE_TEMP=/tmp/ansible-remote && if [[ -x ../.venv/bin/ansible-lint ]]; then ../.venv/bin/ansible-lint {{PLAYBOOK}}; else ansible-lint {{PLAYBOOK}}; fi
    if [[ -x .venv/bin/yamllint ]]; then .venv/bin/yamllint -c .yamllint {{ANSIBLE_DIR}} .github; else yamllint -c .yamllint {{ANSIBLE_DIR}} .github; fi
    if [[ -x .venv/bin/shellcheck ]]; then .venv/bin/shellcheck scripts/*.sh; else shellcheck scripts/*.sh; fi

syntax:
    cd {{ANSIBLE_DIR}} && ANSIBLE_LOCAL_TEMP=/tmp/ansible-local ANSIBLE_REMOTE_TEMP=/tmp/ansible-remote ansible-playbook {{PLAYBOOK}} --syntax-check

ci:
    just syntax
    just lint

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

# ─── Help ───────────────────────────────────────────────────────────────

default:
    @just --list
