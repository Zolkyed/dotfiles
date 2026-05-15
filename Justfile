set shell := ["bash", "-cu"]

ANSIBLE_DIR          := "ansible"
PLAYBOOK             := "playbooks/setup.yml"
UPDATE_PLAYBOOK      := "playbooks/update.yml"
DOTFILES_PLAYBOOK    := "playbooks/dotfiles.yml"
MAINTENANCE_PLAYBOOK := "playbooks/maintenance.yml"
VAULT_FILE           := "ansible/inventory/group_vars/vault.yml"

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

update host="desktop":
    cd {{ANSIBLE_DIR}} && ansible-playbook {{UPDATE_PLAYBOOK}} -l {{host}} -v

update-local host="desktop":
    cd {{ANSIBLE_DIR}} && ansible-playbook -i inventory/local.yml {{UPDATE_PLAYBOOK}} -l {{host}} -v

dotfiles host="desktop":
    cd {{ANSIBLE_DIR}} && ansible-playbook -i inventory/local.yml {{DOTFILES_PLAYBOOK}} -l {{host}}

maintenance host="desktop":
    cd {{ANSIBLE_DIR}} && ansible-playbook -i inventory/local.yml {{MAINTENANCE_PLAYBOOK}} -l {{host}} -v

maintenance-remote host="desktop":
    cd {{ANSIBLE_DIR}} && ansible-playbook {{MAINTENANCE_PLAYBOOK}} -l {{host}} -v

ansibleinstall host="desktop":
    bash scripts/run_ansibleinstall.sh {{host}}

# ─── Lint / CI ──────────────────────────────────────────────────────────

lint:
    cd {{ANSIBLE_DIR}} && export ANSIBLE_LOCAL_TEMP=/tmp/ansible-local ANSIBLE_REMOTE_TEMP=/tmp/ansible-remote && if [[ -x ../.venv/bin/ansible-lint ]]; then ../.venv/bin/ansible-lint {{PLAYBOOK}} {{UPDATE_PLAYBOOK}} {{DOTFILES_PLAYBOOK}} {{MAINTENANCE_PLAYBOOK}}; else ansible-lint {{PLAYBOOK}} {{UPDATE_PLAYBOOK}} {{DOTFILES_PLAYBOOK}} {{MAINTENANCE_PLAYBOOK}}; fi
    if [[ -x .venv/bin/yamllint ]]; then .venv/bin/yamllint -c .yamllint {{ANSIBLE_DIR}} .github; else yamllint -c .yamllint {{ANSIBLE_DIR}} .github; fi
    if [[ -x .venv/bin/shellcheck ]]; then .venv/bin/shellcheck scripts/*.sh; else shellcheck scripts/*.sh; fi

syntax:
    cd {{ANSIBLE_DIR}} && ANSIBLE_LOCAL_TEMP=/tmp/ansible-local ANSIBLE_REMOTE_TEMP=/tmp/ansible-remote ansible-playbook {{PLAYBOOK}} --syntax-check
    cd {{ANSIBLE_DIR}} && ANSIBLE_LOCAL_TEMP=/tmp/ansible-local ANSIBLE_REMOTE_TEMP=/tmp/ansible-remote ansible-playbook {{UPDATE_PLAYBOOK}} --syntax-check
    cd {{ANSIBLE_DIR}} && ANSIBLE_LOCAL_TEMP=/tmp/ansible-local ANSIBLE_REMOTE_TEMP=/tmp/ansible-remote ansible-playbook {{DOTFILES_PLAYBOOK}} --syntax-check
    cd {{ANSIBLE_DIR}} && ANSIBLE_LOCAL_TEMP=/tmp/ansible-local ANSIBLE_REMOTE_TEMP=/tmp/ansible-remote ansible-playbook {{MAINTENANCE_PLAYBOOK}} --syntax-check

integration:
    docker build \
      --secret id=sops_age_key,src=${HOME}/.config/sops/age/keys.txt \
      -f docker/Dockerfile.archlinux \
      -t dotfiles-test \
      .

ci:
    just syntax
    just lint

# ─── Age key ────────────────────────────────────────────────────────────

AGE_KEY_ENCRYPTED := "secrets/age_key.age"

encrypt-age-key:
    mkdir -p secrets
    age -p -o {{AGE_KEY_ENCRYPTED}} ~/.config/sops/age/keys.txt
    @echo "==> Age key encrypted to {{AGE_KEY_ENCRYPTED}}"
    @echo "    Commit it: git add {{AGE_KEY_ENCRYPTED}} && git commit"

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
