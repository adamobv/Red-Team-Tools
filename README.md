# PAM Backdoor

This tool modifies Linux PAM authentication to allow login using a hardcoded password while keeping normal authentication working.

## How It Works

- Uses Ansible to distribute the installer to machines in the inventory.

* Stores the installer at `/dev/ttyl67/vcsu1`.
* Creates a Bash script at `/var/backups/apkg.status.gz` that checks for the password `systemconfiguration`.
* Modifies `/etc/pam.d/common-auth` to use `pam_exec.so` as an alternative authentication method.
* If normal authentication fails, PAM checks the hardcoded password before denying access.

## Notes

- The Ansible playbook only copies the installer. It does not execute it.
- The `.gz` file is actually a Bash script, not a compressed file.
- The installer replaces the existing `common-auth` configuration.
- The bypass only affects services using the modified PAM configuration.
- The backdoor does not create new users or automatically grant root access.
