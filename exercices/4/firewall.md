# Why Automate Firewall Configuration?

1. Consistency at Scale
   Manually configuring iptables or UFW on dozens or hundreds of servers is error-prone. A single typo can leave a host exposed. Ansible playbooks guarantee that every node converges on the exact same rule set, eliminating configuration drift.

2. Repeatable Compliance
   Whether you’re subject to PCI-DSS, SOC-2, or your own internal security policy, an automated playbook serves as living documentation of your control baseline. You can re-run it anytime to prove—or restore—compliance.

3. Rapid Remediation
   In the event of a security incident or audit finding, applying a one-click playbook across all affected hosts is far faster (and less disruptive) than manual intervention.

4. Documentation & Audit Trails
   Every run of your playbook is logged. You can track exactly when rules were changed and by whom, which is crucial for forensic analysis and change management.

## Structure Breakdown

1. Play Definition
   - `hosts`: targets: Runs against the inventory group labeled targets.
   - `become`: yes: Elevates privileges so `UFW` can modify firewall rules and service states.
2. Task 1 – Install UFW
   - Uses the `apt` module to ensure the `ufw` package is present.
   - `update_cache`: yes refreshes the apt cache only when necessary, so playbook runs remain efficient.
3. Task 2 – Allow SSH
   - Employs the ufw module to add a permanent rule permitting inbound TCP on port 22.
   - This explicit allow ensures you don’t lock yourself out when you later set a default “deny” policy.
4. Task 3 – Deny All Other Traffic
   - Establishes a default deny policy for any unspecified incoming connections.
   - By default, UFW applies policies for both incoming and outgoing traffic; you could extend this playbook to explicitly manage egress rules as well.
     Task 4 – Enable UFW
     Activates the firewall if it isn’t already running.
     enabled: yes ensures idempotency—UFW stays enabled across reboots without repeated toggles.

## Run

```bash
ansible-playbook -i inventory.ini playbook-03-firewall.yml
```

## Verify

```bash
ssh root@target1 ufw status verbose
ssh root@target1 nc -zv localhost 80 || echo 'Port 80 blocked'
```
