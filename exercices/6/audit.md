# Audit

In this exercise, you’ll use Ansible to automate the installation and configuration of Linux Audit (auditd) on one or more servers. Even if you’re used to manually installing packages and editing rules, Ansible’s playbooks let you declare your desired end state: no more typo-prone SSH sessions or forgotten steps. By the end, every node in your targets group will have auditd installed, be watching changes to sshd_config, and automatically restart the service to apply your rule.

## How It Works

1. Hosts & Privilege Escalation

   ```yaml
   - hosts: targets
   become: yes
   ```

   - hosts: targets selects the inventory group where the play will run (e.g., [targets] in your inventory).
   - become: yes ensures tasks execute as root, since you’re installing packages and editing system rules.

2. Installing the Audit Daemon

   ```yaml
   - name: Install auditd
   apt:
       name: auditd
       state: present
       update_cache: yes
   ```

   This task uses the apt module to guarantee that the auditd package is installed. update_cache: yes refreshes the package index to avoid “package not found” errors.

3. Adding an Audit Rule for SSH Configuration

   ```yaml
   - name: Add audit rule for sshd_config
   lineinfile:
       path: /etc/audit/audit.rules
       line: "-w /etc/ssh/sshd_config -p wa -k sshd_config_changes"
       insertafter: EOF
   ```

   Here, the lineinfile module appends a watch on /etc/ssh/sshd_config to the end of the audit rule file.

   - `-w … -p wa` tells auditd to log both write (`w`) and attribute (`a`) changes.
   - `-k sshd_config_change`s tags events with a key for easy filtering when you search your logs.

4. Restarting the Audit Service

   ```yaml
   - name: Restart auditd service
   service:
       name: auditd
       state: restarted
   ```

   After updating the rules file, you need to reload auditd so it picks up the new configuration.

## Why This Matters

- **Automated Compliance:** Ensures every server consistently tracks modifications to critical SSH settings.
- **Audit Trail:** Centralized, timestamped records of who changed sshd_config, strengthening forensic capabilities.
- **Idempotency:** Run the playbook repeatedly without duplicating rules or re-installing packages unnecessarily.

## Next Steps

- **Dry-Run First:** `Use ansible-playbook playbook-auditd.yml --check` to preview changes.
- **Group-Specific Rules:** Split into multiple rule files under `/etc/audit/rules.d/` for clearer organization.
- **Log Rotation & Archival:** Extend the playbook to set up auditd-plugins or configure /etc/audit/auditd.conf for custom rotation and remote log shipping.
- **Alerting:** Integrate with a SIEM or use ausearch and auditctl commands in an Ansible task to trigger real-time notifications on suspicious changes.

With this playbook in your toolkit, you’ll enforce critical audit policies at scale—no manual interventions, no configuration drift, just reliable, reproducible security controls.
