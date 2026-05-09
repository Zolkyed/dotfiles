set shell := ["bash", "-cu"]

ANSIBLE_DIR := "ansible"
PLAYBOOK := "playbooks/setup.yml"
VAULT_FILE := "ansible/inventory/group_vars/vault.yml"

# ─── Ansible ────────────────────────────────────────────────────────────

setup-dev:
    python -m venv .venv
    .venv/bin/python -m pip install --upgrade pip
    .venv/bin/pip install -r requirements.txt
    ANSIBLE_LOCAL_TEMP=/tmp/ansible-local ANSIBLE_REMOTE_TEMP=/tmp/ansible-remote .venv/bin/ansible-galaxy collection install -r {{ANSIBLE_DIR}}/requirements.yml

run host="desktop" v="-v":
    cd {{ANSIBLE_DIR}} && ansible-playbook {{PLAYBOOK}} -l {{host}} {{v}}

run-local host="desktop" v="-v":
    cd {{ANSIBLE_DIR}} && ansible-playbook -i inventory/local.yml {{PLAYBOOK}} -l {{host}} {{v}}

check host="desktop":
    cd {{ANSIBLE_DIR}} && ansible-playbook {{PLAYBOOK}} --check --diff -l {{host}}

check-local host="desktop":
    cd {{ANSIBLE_DIR}} && ansible-playbook -i inventory/local.yml {{PLAYBOOK}} --check --diff -l {{host}}

tags host="desktop" tags="all":
    cd {{ANSIBLE_DIR}} && ansible-playbook {{PLAYBOOK}} -l {{host}} --tags {{tags}}

tags-local host="desktop" tags="all":
    cd {{ANSIBLE_DIR}} && ansible-playbook -i inventory/local.yml {{PLAYBOOK}} -l {{host}} --tags {{tags}}

bootstrap host="desktop":
    bash scripts/run_once_install-ansible.sh {{host}}

rebuild host="desktop":
    just run {{host}}
    just apply

lint:
    just lint-ansible
    just lint-yaml
    just lint-shell

lint-ansible:
    cd {{ANSIBLE_DIR}} && export ANSIBLE_LOCAL_TEMP=/tmp/ansible-local ANSIBLE_REMOTE_TEMP=/tmp/ansible-remote && if [[ -x ../.venv/bin/ansible-lint ]]; then ../.venv/bin/ansible-lint {{PLAYBOOK}}; else ansible-lint {{PLAYBOOK}}; fi

lint-yaml:
    if [[ -x .venv/bin/yamllint ]]; then .venv/bin/yamllint -c .yamllint {{ANSIBLE_DIR}} .github; else yamllint -c .yamllint {{ANSIBLE_DIR}} .github; fi

lint-shell:
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
