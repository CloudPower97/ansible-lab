# Password Policy (PAM)

This exercise walks you through using Ansible to enforce a basic password‐quality policy across one or more Linux servers. Even if you’re comfortable writing scripts or manually editing configuration files, Ansible’s declarative playbooks offer repeatable, idempotent automation—no more juggling SSH sessions or worrying about missing a step.

## Context & Goals

You have a fleet of target machines that must comply with your organization’s security standards. In particular, every local user password should be at least 12 characters long, and users get only three attempts to choose a compliant password before the system rejects further tries. This playbook (playbook-password-policy.yml) installs the necessary PAM module and tweaks its configuration to meet those requirements

```bash
ssh root@target1 passwd root
# enter 'password' → expect BAD PASSWORD error
# enter 'P@ssw0rd123!' → expect success
```

## How It Works

1. Hosts & Privilege Escalation

   - `hosts: targets`
     Specifies the inventory group (e.g., [targets] in your hosts file) where this policy applies.
   - `become: yes`
     Ensures all tasks run with root privileges, since you’re installing packages and editing system config files.

2. Installing the PAM Quality Module

   ```yaml
   - name: Install libpam-pwquality
   apt:
       name: libpam-pwquality
       state: present
       update_cache: yes
   ```

   Uses the apt module to ensure libpam-pwquality is installed. The update_cache: yes flag refreshes the package index if needed. This module adds enforcement hooks into the PAM stack.

3. Enforcing Minimum Password Length

   ```yaml
   - name: Require minimum password length
   lineinfile:
       path: /etc/security/pwquality.conf
       regexp: "^minlen"
       line: "minlen = 12"
   ```

   The lineinfile module searches /etc/security/pwquality.conf for any existing minlen setting and replaces or adds the line minlen = 12. This guarantees a minimum length of 12 characters.

4. Limiting Password-Change Retries

   ```yaml
   - name: Limit password retries
     lineinfile:
       path: /etc/security/pwquality.conf
       regexp: "^retry"
       line: "retry = 3"
   ```

   Similarly, this ensures the retry parameter is set to 3, preventing infinite retries and encouraging users to choose acceptable passwords quickly.

## Why This Matters

- **Idempotency:** Run the playbook multiple times without unintended side effects—Ansible only makes changes when the system deviates from the desired state.
- **Consistency:** Enforce the same policy everywhere, from development servers to production nodes.
- **Auditability:** Your version-controlled playbook documents exactly how and when the configuration was applied.

## Next Steps

- **Dry‐run:** Add --check to your ansible-playbook command to preview changes.
- **Testing:** Use a staging group before rolling out to critical systems.
- **Extensions:** Consider adding parameters for complexity (e.g., requiring uppercase or special characters) by tweaking other pwquality.conf settings (like dcredit or ucredit).

By the end of this exercise, you’ll have a reusable Ansible playbook that hardens password policies at scale—no manual edits, no guesswork, just consistent, automated enforcement.
