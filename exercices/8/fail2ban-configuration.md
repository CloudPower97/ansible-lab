# Fail2Ban Configuration

In this exercise, you’ll see how to leverage Ansible to install and configure Fail2Ban across one or more Linux servers—locking down SSH against brute-force attacks without touching each machine by hand. Even if you’re comfortable installing packages and editing files via SSH, a playbook makes the process repeatable, idempotent, and version-controlled

## How It Works

1. Targeting Hosts & Escalating Privileges

   ```yaml
   - hosts: targets
   become: yes
   ```

   - `hosts: targets`: Runs the play on every server in your targets inventory group.
   - `become: yes`: Elevates all tasks to root, needed for package installation and service management.

2. Installing Fail2Ban

   ```yaml
   - name: Install fail2ban
     apt:
       name: fail2ban
       state: present
       update_cache: yes
   ```

   - Uses the `apt` module to ensure the `fail2ban` package is installed.
   - `update_cache: yes` refreshes the local package index so you don’t hit “package not found” errors on fresh systems.

3. Configuring the SSH Jail

   ```yaml
   - name: Configure SSH jail
   copy:
       dest: /etc/fail2ban/jail.d/ssh.local
       content: |
       [sshd]
       enabled = true
       port    = ssh
       maxretry = 3
   ```

   - The `copy` module drops a custom jail configuration into `/etc/fail2ban/jail.d/ssh.local`.
   - `[sshd] section`:
     - `enabled = true` activates monitoring of SSH login attempts.
     - `port = ssh` tells Fail2Ban to watch the default SSH port (usually 22).
     - `maxretry = 3` blocks an IP after three failed password attempts.

4. Restarting the Fail2Ban Service

   ```yaml
   - name: Restart fail2ban
     service:
       name: fail2ban
       state: restarted
   ```

   Uses the `service` module to restart `Fail2Ban` immediately, so your new jail takes effect without waiting for a manual reload or server reboot.

## Why This Matters

- `Automated Hardening:` Enforce consistent protection against brute-force SSH attacks on every node.
- `Idempotency:` Run the playbook repeatedly; Ansible won’t reinstall or reconfigure if nothing’s changed.
- `Version Control & Audit:` Your playbook becomes the single source of truth for how Fail2Ban is set up, simplifying reviews and audits.
- `Reduced Mean Time to Secure:` Spin up new servers with SSH protection enabled out of the box—no “oops, I forgot to configure Fail2Ban” mishaps.

## Test

```bash
for i in {1..3}; do ssh wrong@target1; done
ssh root@target1 fail2ban-client status sshd  # your IP should be banned
```

## Next Steps

- **Extend Jails:** Add more jails (e.g., for `nginx`, `postfix`, or custom services) by dropping additional `.local` files under /etc/fail2ban/jail.d/.
- **Customize Ban Times:** Tweak parameters like bantime, findtime, or ignoreip to suit your threat model.
- **Email Alerts:** Create an action in /etc/fail2ban/jail.local that sends notifications (using sender and action = %(action_mw)s) whenever a ban occurs.
- **Centralized Monitoring:** Integrate with ELK/EFK stacks or SIEM solutions so you can aggregate and visualize ban events from all servers.
- **Testing & Dry-Run:** Use ansible-playbook playbook-fail2ban.yml --check to verify changes without applying them, and --diff to see exactly what Ansible will modify.
