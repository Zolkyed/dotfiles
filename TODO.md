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

3. Fix SSH KEYS and link to github to be able to clone via SSH

4. Gitlab and github remote distinction

5. run_ansibleinstall.sh still mutates sudo before Ansible owns sudoers. It works, but bootstrap vs desired-state
  overlap is slightly messy.

6. inject_facts_as_vars = false must support this new format

7. AI hooks to test code locally

8. Unecessary complexity multilib for pacman must look at rest of the code later..

9. Not a fan of distribution of the font between default and groups vars....

10. Handlers either all sudo or none sudo ....

11. Fix docker

12. ...