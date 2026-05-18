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

2. Fix SSH KEYS and link to github to be able to clone via SSH

3. run_ansibleinstall.sh still mutates sudo before Ansible owns sudoers. It works, but bootstrap vs desired-state
  overlap is slightly messy.

4. AI hooks to test code locally

5. Fix docker

6. ...