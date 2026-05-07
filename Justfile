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

bootstrap:
    bash scripts/run_once_install-ansible.sh

rebuild host="desktop":
    just run {{host}}
    just apply

lint:
    just lint-ansible
    just lint-yaml
    just lint-shell

lint-ansible:
    cd {{ANSIBLE_DIR}} && if [[ -x ../.venv/bin/ansible-lint ]]; then ANSIBLE_LOCAL_TEMP=/tmp/ansible-local ANSIBLE_REMOTE_TEMP=/tmp/ansible-remote ../.venv/bin/ansible-lint; else ansible-lint; fi

lint-yaml:
    if [[ -x .venv/bin/yamllint ]]; then .venv/bin/yamllint -c .yamllint {{ANSIBLE_DIR}} .github; else yamllint -c .yamllint {{ANSIBLE_DIR}} .github; fi

lint-shell:
    if [[ -x .venv/bin/shellcheck ]]; then .venv/bin/shellcheck scripts/*.sh; else shellcheck scripts/*.sh; fi

syntax:
    cd {{ANSIBLE_DIR}} && ANSIBLE_LOCAL_TEMP=/tmp/ansible-local ANSIBLE_REMOTE_TEMP=/tmp/ansible-remote ansible-playbook {{PLAYBOOK}} --syntax-check

list-tasks:
    cd {{ANSIBLE_DIR}} && ANSIBLE_LOCAL_TEMP=/tmp/ansible-local ANSIBLE_REMOTE_TEMP=/tmp/ansible-remote ansible-playbook {{PLAYBOOK}} --list-tasks

inventory:
    cd {{ANSIBLE_DIR}} && ANSIBLE_LOCAL_TEMP=/tmp/ansible-local ANSIBLE_REMOTE_TEMP=/tmp/ansible-remote ansible-inventory -i inventory/hosts.yml --list >/dev/null

inventory-local:
    cd {{ANSIBLE_DIR}} && ANSIBLE_LOCAL_TEMP=/tmp/ansible-local ANSIBLE_REMOTE_TEMP=/tmp/ansible-remote ansible-inventory -i inventory/local.yml --list >/dev/null

test-tags:
    cd {{ANSIBLE_DIR}} && for tag in always sysctl user sudoers aur packages hayase fonts flatpak docker virtualization dotfiles browser ssh_keys dev bin networking vpn sshd firewall fail2ban splashboot rclone konsave ai gaming hyprland niri; do \
        output=$(ANSIBLE_LOCAL_TEMP=/tmp/ansible-local ANSIBLE_REMOTE_TEMP=/tmp/ansible-remote ansible-playbook {{PLAYBOOK}} --list-tasks --tags "$tag" 2>&1); \
        status=$?; \
        task_count=$(printf '%s\n' "$output" | rg -c '^      .+TAGS:'); \
        if [[ "$status" -ne 0 || "$task_count" -eq 0 ]]; then \
            printf 'FAIL %s status=%s tasks=%s\n%s\n' "$tag" "$status" "$task_count" "$output"; \
            exit 1; \
        fi; \
        printf 'PASS %-18s %s tasks\n' "$tag" "$task_count"; \
    done

ci:
    just syntax
    just inventory
    just inventory-local
    just list-tasks
    just test-tags
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

# ─── Konsave ─────────────────────────────────────────────────────────────

konsave-install host="desktop":
    cd {{ANSIBLE_DIR}} && ansible-playbook {{PLAYBOOK}} -l {{host}} --tags konsave

konsave-list:
    konsave-list

konsave-import profile="":
    konsave-import {{profile}}

konsave-export profile="":
    konsave-export {{profile}}

konsave-remove profile="":
    konsave-remove {{profile}}

# ─── Help ───────────────────────────────────────────────────────────────

default:
    @just --list
