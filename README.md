# Ansible exercises

This laboratory provides a guided, hands-on introduction to automating security tasks on Linux systems using Ansible, within a reproducible Docker environment. It covers everything from the fundamentals of Ansible to advanced validation and CI/CD integration.

## Goals and Learning Outcomes

By completing this lab, students will be able to:

Understand Ansible fundamentals: architecture, key concepts (control node, managed nodes, inventory, playbooks).

Write and execute both ad‑hoc commands and multi‑task playbooks for system hardening.

Automate common security tasks: system updates, SSH hardening, firewall configuration, password policies, audit logging.

Validate and test playbooks through linting, dry‑runs, and CI/CD pipelines.

Use Docker to create isolated, reproducible environments with multiple targets.

## Prerequisites

- Docker and Docker Compose installed on each student’s workstation.
- Basic familiarity with the Linux shell (navigating directories, editing files, running commands).
- No prior Ansible experience is required.

Each exercise includes:

- Introduction: What the exercise does, how it works, and why we’re doing it.
- Filename: Name of the playbook file.
- Playbook content: YAML defining the automation tasks.
- Run: Commands to execute the playbook.
- Verify/Test: Steps to confirm the desired state.

## Ansible Fundamentals

### What Is Ansible?

Ansible is an agentless automation framework that uses SSH (or WinRM for Windows) to manage remote hosts. Configuration is declared in human‑readable YAML files called playbooks.

### Key Components

- **Control Node:** Machine (or container) where Ansible is installed. Runs all commands and playbooks.
- **Managed Nodes:** Target systems (servers or containers) being configured.
- **Inventory:** A file (INI or YAML) listing managed nodes and grouping them for targeting.
- **Modules:** Standalone scripts (e.g., apt, service, lineinfile, ufw) that perform idempotent operations on hosts.
- **Playbooks:** YAML files defining plays (which hosts to target) and tasks (which modules to run).
- **Variables:** Dynamic values stored in playbooks, inventory, or group_vars and host_vars directories.
- **Handlers:** Special tasks triggered by other tasks to run at the end of a play (e.g., restart a service).
- **Roles:** A way to organize playbooks into reusable components with standardized directory structure.

### Basic Commands

- Ad‑hoc command (one‑off task):

```bash
ansible all -i inventory.ini -m ping
```

- Run a playbook:

```bash
ansible-playbook -i inventory.ini playbook.yml
```

- **Privilege escalation:**In playbooks, add become: yes to elevate privileges (sudo by default).

## Docker Lab Environment

We simulate a small network of Linux servers using Docker containers:

- control: Runs Ansible and holds all playbooks.

- target1 & target2: Two Ubuntu containers to be hardened.

After running `docker-compose up -d`, run `docker exec -it control bash` and verify you can `ssh root@target1` and `ssh root@target2` without password prompts.
