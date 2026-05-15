1.
What I Recommend For Your Repo SSH

Manual/physical or IPMI boot into Arch ISO
↓
SSH into live ISO
↓
run scripts/run_archinstall.sh
↓
reboot
↓
SSH into installed system
↓
just bootstrap server
↓
future changes: just run server

2. base-devel in user_configuration.json ?

3. Fix SSH KEYS and link to github to be able to clone via SSH

4. Gitlab and github remote distinction

5. run_ansibleinstall.sh still mutates sudo before Ansible owns sudoers. It works, but bootstrap vs desired-state
  overlap is slightly messy.


6. inject_facts_as_vars = false must support this new format