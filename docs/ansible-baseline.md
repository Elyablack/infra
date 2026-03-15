# Ansible Baseline Configuration

Operational documentation describing the baseline system configuration applied to infrastructure nodes using Ansible.

This playbook ensures that all hosts share a consistent operating environment required for monitoring, automation, and maintenance tasks.

---

## Playbook Location

```
playbooks/common_baseline.yml
```

Run manually:

```
cd ~/infra
ansible-playbook playbooks/common_baseline.yml
```

---

## Purpose

This playbook establishes a consistent system baseline across all infrastructure nodes.

It performs the following actions:

- installs common system utilities
- configures system timezone
- enables fail2ban protection
- ensures passwordless sudo access for the administrative user

This prevents configuration drift and guarantees predictable host behaviour.

---

## Package Installation

The playbook installs the following packages:

```
curl
wget
vim
git
jq
rsync
htop
unzip
ca-certificates
gnupg
lsb-release
fail2ban
```

These utilities are required for:

- automation scripts
- troubleshooting
- system inspection
- backup operations
- monitoring tasks

---

## Timezone Configuration

All infrastructure nodes are configured to use:

```
UTC
```

Using a consistent timezone ensures that timestamps match across:

- system logs
- Prometheus metrics
- backup timestamps
- alert evaluations

---

## Fail2ban Protection

The playbook ensures that fail2ban is installed and running.

Verify service status:

```
systemctl status fail2ban
```

Fail2ban protects the host against repeated authentication attempts and common abuse patterns.

---

## Administrative Access

The playbook ensures that the administrative user can execute privileged commands without password prompts.

Configuration file:

```
/etc/sudoers.d/90-admin1
```

Content:

```
admin1 ALL=(ALL) NOPASSWD:ALL
```

This configuration is required for automation tools such as Ansible.

---

## Verification

Check timezone:

```
timedatectl
```

Expected output:

```
Time zone: UTC
```

Check fail2ban status:

```
systemctl is-active fail2ban
```

Expected output:

```
active
```

Verify sudo configuration:

```
sudo -n true
```

Expected behaviour:

- no output
- exit code 0

---

## Idempotency

The playbook is **idempotent**.

Running the playbook multiple times will not modify the system if the desired configuration is already applied.

Example:

```
ansible-playbook playbooks/common_baseline.yml
```

The playbook will only update hosts where configuration drift occurred.
