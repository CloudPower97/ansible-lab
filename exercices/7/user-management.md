# User Management & Sudo

This exercise walks you through automating basic user and permission management on Linux servers using Ansible. Even if you already know how to create users and edit sudoers files by hand, an Ansible playbook ensures you enforce the same configuration consistently across all your machines—no more manual SSH sessions or typos in `/etc/sudoers.d/`.

## How It Works

1. Hosts & Privilege Escalation

   ```yaml
   - hosts: targets
   become: yes
   ```

   - `hosts: targets` ties the play to the inventory group named “targets.”
   - `become: yes` ensures every task runs with root privileges, which is required for user and group management.

2. Defining Variables

   ```yaml
   vars:
   lab_user: labuser
   lab_pass: "$6$rounds=4096$saltsalt$..."
   ```

   - `lab_user` holds the username you’ll create.
   - `lab_pass` stores a pre-hashed password (here the hash of `P@ssw0rd123!`). Using a hash means you never expose plaintext passwords in your playbook or logs.

3. Ensuring an Admin Group Exists

   ```yaml
   - name: Ensure 'admins' group exists
   group:
       name: admins
       state: present
   ```

   The `group` module declares that a Unix group called `admins` must be present. If it’s missing, Ansible creates it; if it already exists, nothing happens.

4. Creating the Lab User

   ```yaml
    - name: Create lab user
        user:
        name: "{{ lab_user }}"
        password: "{{ lab_pass }}"
        groups: admins
        shell: /bin/bash
   ```

   - `user.name` picks the username from your variable.
   - `user.password` uses the hashed password, so on creation the account is instantly accessible with the intended credentials.
   - `groups: admins` automatically adds the user to the admins group.
   - `shell: /bin/bash` sets their default shell.

5. Granting Passwordless Sudo

   ```yaml
   - name: Grant passwordless sudo for admins
       copy:
           dest: /etc/sudoers.d/admins
           content: |
           %admins ALL=(ALL) NOPASSWD:ALL
           mode: "0440"
   ```

   Using the `copy` module, this task drops a sudoers fragment that lets anyone in the `admins` group run any command as any user—without being prompted for a password. The file’s mode `0440` ensures it’s read-only for root and the wheel of sudoers parsing.

## Why This Matters

- **Repeatability**: Run the playbook dozens of times; users and groups will only be created if missing, and sudo rules only applied once.
- **Security**: By hashing the password in the playbook, you avoid leaking secrets, while still automating account setup.
- **Audit & Documentation**: Your source-controlled playbook is the single source of truth for who has access and at what privilege level.

## Test

```bash
ssh labuser@target1  # password P@ssw0rd123!
sudo whoami  # should return 'root' without prompt
```

## Next Steps

- **Password Rotation:** Integrate a lookup or Vault plugin to fetch time-limited credentials instead of a static hash.
- **Role Separation:** Split user creation and sudo provisioning into separate roles for cleaner organization.
- **Fine-Grained Permissions:** Replace the broad %admins ALL=(ALL) NOPASSWD:ALL rule with specific command lists for least privilege.
- **Cleanup:** Add tasks to remove users or groups when they’re no longer needed, preventing stale accounts.

By the end of this exercise, you’ll have a fully automated, version-controlled user-management workflow—consistent, secure, and ready for scale.
