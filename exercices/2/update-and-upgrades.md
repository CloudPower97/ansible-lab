# Update and upgrades

This exercise walks you through a comprehensive approach to system patch management: first, refreshing the local package index to fetch metadata about available updates (apt update), then performing a full distribution upgrade (apt dist-upgrade) to ensure all installed packages are brought to their most recent stable versions.

Beyond manual updates, we introduce the unattended-upgrades package, which automates the application of security-relevant package updates on a scheduled basis, minimizing the window of exposure without requiring human intervention.

This foundational step ensures that subsequent hardening measures are applied on a fully up-to-date system, reducing the risk of basing security configurations on outdated or vulnerable software. Automated security updates represent a proactive defense-in-depth strategy, allowing teams to focus on higher-level security tasks while ensuring baseline protections remain current.

## Run

```bash
ansible-playbook -i inventory.ini playbook-update-and-upgrades.yml
```

## Verify

```bash
ssh root@target1 apt list --upgradable
ssh root@target1 unattended-upgrade -d && tail /var/log/unattended-upgrades/unattended-upgrades.log
```
