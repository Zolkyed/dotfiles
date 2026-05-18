set shell := ["bash", "-cu"]

ANSIBLE_DIR          := "ansible"
PLAYBOOK             := "playbooks/setup.yml"
UPDATE_PLAYBOOK      := "playbooks/update.yml"
DOTFILES_PLAYBOOK    := "playbooks/dotfiles.yml"
CLEANUP_PLAYBOOK     := "playbooks/cleanup.yml"
VAULT_FILE           := "ansible/inventory/group_vars/vault.yml"

PLAYBOOKS := PLAYBOOK + " " + UPDATE_PLAYBOOK + " " + DOTFILES_PLAYBOOK + " " + CLEANUP_PLAYBOOK

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

run-local:
    cd {{ANSIBLE_DIR}} && ansible-playbook -i inventory/local.yml {{PLAYBOOK}} -l $(hostname) -v

check:
    cd {{ANSIBLE_DIR}} && ansible-playbook -i inventory/local.yml {{PLAYBOOK}} --check --diff -l $(hostname)

update:
    cd {{ANSIBLE_DIR}} && ansible-playbook -i inventory/local.yml {{UPDATE_PLAYBOOK}} -l $(hostname) -v

update-remote host="desktop":
    cd {{ANSIBLE_DIR}} && ansible-playbook {{UPDATE_PLAYBOOK}} -l {{host}} -v

dotfiles:
    cd {{ANSIBLE_DIR}} && ansible-playbook -i inventory/local.yml {{DOTFILES_PLAYBOOK}} -l $(hostname)

cleanup:
    cd {{ANSIBLE_DIR}} && ansible-playbook -i inventory/local.yml {{CLEANUP_PLAYBOOK}} -l $(hostname) -v

cleanup-remote host="desktop":
    cd {{ANSIBLE_DIR}} && ansible-playbook {{CLEANUP_PLAYBOOK}} -l {{host}} -v

ansibleinstall host="desktop":
    bash scripts/run_ansibleinstall.sh {{host}}

# ─── Lint / CI ──────────────────────────────────────────────────────────

_ansible-lint:
    cd {{ANSIBLE_DIR}} && \
    ANSIBLE_LOCAL_TEMP=/tmp/ansible-local ANSIBLE_REMOTE_TEMP=/tmp/ansible-remote \
    $([[ -x ../.venv/bin/ansible-lint ]] && echo ../.venv/bin/ansible-lint || echo ansible-lint) \
    {{PLAYBOOKS}}

_yamllint:
    $([[ -x .venv/bin/yamllint ]] && echo .venv/bin/yamllint || echo yamllint) -c .yamllint {{ANSIBLE_DIR}} .github

_shellcheck:
    $([[ -x .venv/bin/shellcheck ]] && echo .venv/bin/shellcheck || echo shellcheck) scripts/*.sh

lint: _ansible-lint _yamllint _shellcheck

syntax:
    cd {{ANSIBLE_DIR}} && \
    export ANSIBLE_LOCAL_TEMP=/tmp/ansible-local ANSIBLE_REMOTE_TEMP=/tmp/ansible-remote && \
    for p in {{PLAYBOOKS}}; do ansible-playbook "$p" --syntax-check; done

integration:
    docker build \
      --secret id=sops_age_key,src=${HOME}/.config/sops/age/keys.txt \
      -f docker/Dockerfile.archlinux \
      -t dotfiles-test \
      .

ci: syntax lint

# ─── Vault / Secrets ────────────────────────────────────────────────────

AGE_KEY_ENCRYPTED := "secrets/age_key.age"

encrypt-age-key:
    mkdir -p secrets
    age -p -o {{AGE_KEY_ENCRYPTED}} ~/.config/sops/age/keys.txt

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
