# SSH Hardening

Secure Shell (SSH) is the de-facto standard for remote management of Unix-like systems. Unfortunately, its ubiquity makes it a primary target for attackers seeking:

1. Unauthorized root access via brute-force or credential stuffing
2. Protocol downgrade attacks that exploit vulnerabilities in older SSH implementations
3. Weak or default configurations that leave critical features (e.g., password authentication, port settings) wide open

Left unaddressed, these risks can lead to full system compromise, lateral movement within your network, and data exfiltration. By codifying SSH hardening in Ansible, you:

- Eliminate manual drift—every host automatically receives the same hardened configuration.
- Enable rapid remediation—a single playbook run reverses any unauthorized changes.
- Provide audit trails—Ansible logs and backups record exactly when and how settings changed.

## Structure Breakdown

1. Play definition (hosts: targets, become: yes)

   - Targets the group of hosts labeled targets in your inventory.
   - Uses privilege escalation (become: yes) to modify system files under root privileges.

2. Task: Disable root login over SSH

   - The lineinfile module ensures the /etc/ssh/sshd_config file contains PermitRootLogin no.
   - The regexp parameter matches any existing directive and replaces it—avoiding duplicate entries.
     backup: yes preserves the original configuration, enabling easy rollbacks if needed.

3. Task: Enforce SSH protocol 2

   - Guarantees that only SSH protocol version 2 is accepted—protocol 1 is deprecated and insecure.
   - Similar to the first task, it matches or inserts the Protocol 2 line using lineinfile.

4. Task: Restart SSH service
   - Applies changes immediately by restarting the ssh service (or sshd on some distributions).
   - Ensures any existing SSH sessions continue uninterrupted (Ansible’s handler patterns can further optimize this in more advanced playbooks).

## Idempotency and Safety

Ansible’s idempotent approach means running this playbook multiple times has no adverse effect once the desired state is reached. Key advantages:

- Safe Re-runs: Re-execute nightly or after configuration drift—only out-of-compliance hosts will change.

- Automatic Backups: With backup: yes, each change creates a timestamped copy of the original file under /etc/ssh/, allowing straightforward investigation or rollbacks.

- Declarative Clarity: You specify what the end state must be; Ansible figures out how to achieve it.

## Run

```bash
ansible-playbook -i inventory.ini playbook-02-ssh-hardening.yml
```

## Verify

```bash
ssh root@target1 grep '^PermitRootLogin' /etc/ssh/sshd_config
```
