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
    just lint-ansible
    just lint-yaml
    just lint-shell

lint-ansible:
    cd {{ANSIBLE_DIR}} && ansible-lint

lint-yaml:
    yamllint -c {{ANSIBLE_DIR}}/.yamllint {{ANSIBLE_DIR}}

lint-shell:
    shellcheck scripts/*.sh

syntax:
    cd {{ANSIBLE_DIR}} && ANSIBLE_LOCAL_TEMP=/tmp/ansible-local ANSIBLE_REMOTE_TEMP=/tmp/ansible-remote ansible-playbook {{PLAYBOOK}} --syntax-check

list-tasks:
    cd {{ANSIBLE_DIR}} && ANSIBLE_LOCAL_TEMP=/tmp/ansible-local ANSIBLE_REMOTE_TEMP=/tmp/ansible-remote ansible-playbook {{PLAYBOOK}} --list-tasks

inventory:
    cd {{ANSIBLE_DIR}} && ANSIBLE_LOCAL_TEMP=/tmp/ansible-local ANSIBLE_REMOTE_TEMP=/tmp/ansible-remote ansible-inventory -i inventory/hosts.yml --list >/dev/null

test-tags:
    cd {{ANSIBLE_DIR}} && for tag in always package_cache user aur packages hayase locale fonts flatpak docker nvidia virtualization dotfiles ssh_keys dev bin networking sshd bluetooth pipewire bootloader display_manager rclone konsave konsave-import konsave-export konsave-delete keybinds ai gaming hyprland niri; do \
        output=$$(ANSIBLE_LOCAL_TEMP=/tmp/ansible-local ANSIBLE_REMOTE_TEMP=/tmp/ansible-remote ansible-playbook {{PLAYBOOK}} --list-tasks --tags "$$tag" 2>&1); \
        status=$$?; \
        task_count=$$(printf '%s\n' "$$output" | rg -c '^      .+TAGS:'); \
        if [[ "$$status" -ne 0 || "$$task_count" -eq 0 ]]; then \
            printf 'FAIL %s status=%s tasks=%s\n%s\n' "$$tag" "$$status" "$$task_count" "$$output"; \
            exit 1; \
        fi; \
        printf 'PASS %-18s %s tasks\n' "$$tag" "$$task_count"; \
    done

ci:
    just syntax
    just inventory
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

konsave-import host="desktop":
    cd {{ANSIBLE_DIR}} && ansible-playbook {{PLAYBOOK}} -l {{host}} --tags konsave-import

konsave-export host="desktop":
    cd {{ANSIBLE_DIR}} && ansible-playbook {{PLAYBOOK}} -l {{host}} --tags konsave-export

konsave-delete host="desktop":
    cd {{ANSIBLE_DIR}} && ansible-playbook {{PLAYBOOK}} -l {{host}} --tags konsave-delete

# ─── Help ───────────────────────────────────────────────────────────────

default:
    @just --list
