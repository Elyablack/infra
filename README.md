# Infrastructure Automation

![Ansible](https://img.shields.io/badge/-Ansible-464646?style=flat&logo=ansible&logoColor=56C0C0&color=008080)
![Linux](https://img.shields.io/badge/-Linux-464646?style=flat&logo=linux&logoColor=56C0C0&color=008080)
![Docker](https://img.shields.io/badge/-Docker-464646?style=flat&logo=docker&logoColor=56C0C0&color=008080)
![Bash](https://img.shields.io/badge/-Bash-464646?style=flat&logo=gnubash&logoColor=56C0C0&color=008080)
![SSH](https://img.shields.io/badge/-SSH-464646?style=flat&logo=gnubash&logoColor=56C0C0&color=008080)
![rsync](https://img.shields.io/badge/-rsync-464646?style=flat&logo=linux&logoColor=56C0C0&color=008080)
![DigitalOcean](https://img.shields.io/badge/-DigitalOcean-464646?style=flat&logo=digitalocean&logoColor=56C0C0&color=008080)
![Prometheus](https://img.shields.io/badge/-Prometheus-464646?style=flat&logo=prometheus&logoColor=56C0C0&color=008080)

Infrastructure management and backup automation for the monitoring stack.

This repository contains **Ansible playbooks, automation scripts, and operational documentation** used to manage and protect the VPS environment.

The infrastructure automation focuses on:

- baseline system configuration
- automated backups
- offsite backup replication
- restore testing
- operational runbooks

---

## Architecture

```
Mac (control node)
│
│ Ansible / rsync / SSH
▼
VPS
```

The Mac host acts as the **control node**, executing:

- Ansible automation
- scheduled backup jobs
- restore validation

The VPS hosts the monitoring stack.

---

## Infrastructure Automation

Infrastructure baseline is configured via **Ansible**.

Baseline configuration includes:

- system baseline configuration
- SSH hardening
- node_exporter textfile collector setup
- Docker runtime configuration

Run bootstrap:

```
ansible-playbook playbooks/bootstrap.yml
```

---

## Repository Structure

```
infra
├── ansible.cfg
├── inventory
│   └── hosts
├── playbooks
│   ├── bootstrap.yml
│   ├── common_baseline.yml
│   ├── ssh_hardening.yml
│   ├── node_exporter_textfile.yml
│   ├── docker_baseline.yml
│   └── backup_vps.yml
├── scripts
│   ├── run_backup.sh
│   ├── offsite_backup.sh
│   └── restore_vps.sh
├── backups
├── docs
└── README.md
```

---

## Backup Workflow

Backups include the following paths from the VPS:

- `/srv/monitoring`
- `/etc`

Backup process:

```
VPS
│
│ Ansible playbook
▼
tar archive
│
▼
Mac backup storage
│
▼
Offsite nodes
```

Backup archive format:

```
vps-backup-YYYY-MM-DD-HHMM.tar.gz
```
---

## Running Backup

Run backup playbook manually:

```
ansible-playbook playbooks/backup_vps.yml
```

Download backups from VPS:

```
rsync -avz vps:/srv/backups/ ~/infra/backups/
```

Local backup location:

```
~/infra/backups
```

---

## Backup Integrity

After downloading the archive, a **SHA256 checksum** is generated.

Example:

```
vps-backup-2026-03-13-1205.tar.gz
vps-backup-2026-03-13-1205.tar.gz.sha256
```

Checksum verification:

```
shasum -a 256 -c .sha256
```

---

## Offsite Backups

Latest backups are replicated to additional nodes:

- `admin`
- `lab`

Replication is performed via:

```
scripts/offsite_backup.sh
```

Older archives are automatically pruned to keep the most recent copies.

---

## Restore Testing

Restore tests can be performed without affecting the running system.

Test restore:

```
~/infra/scripts/restore_vps.sh ~/infra/backups/.tar.gz test
```

This will:

- upload archive to VPS
- extract it into a temporary directory
- verify directory structure

Temporary restore location:

```
/tmp/vps-restore
```

---

## Restore Procedure

Actual restore command:

```
~/infra/scripts/restore_vps.sh ~/infra/backups/.tar.gz apply
```

Restored paths:

```
/srv/monitoring
/etc
```

---

## Scheduled Backups

Backups are executed automatically via **macOS launchd**.

Job name:

```
com.elvira.infra-backup
```

The job executes:

```
scripts/run_backup.sh
```

This script performs:

1. backup creation on VPS
2. backup download to Mac
3. checksum generation
4. offsite replication
5. backup metric publication

---

## Backup Monitoring

Successful backup execution updates a metric exposed via **node_exporter textfile collector**.

Metric:

```
backup_last_success_unixtime
```

Prometheus monitors this metric and triggers an alert if backups become stale.

Alert rule:

```
time() - backup_last_success_unixtime > 93600
```

This alert is documented in the monitoring stack runbook.

---

## Disaster Recovery Plan

If the VPS is lost:

1. create a new VPS
2. configure SSH access
3. bootstrap baseline configuration

```
ansible-playbook playbooks/bootstrap.yml
```

4. upload backup archive
5. restore system files

```
~/infra/scripts/restore_vps.sh  apply
```

6. start monitoring stack

```
cd /srv/monitoring
docker compose up -d
```

---

## Related Project

Monitoring stack repository:

```
https://github.com/Elyablack/monitoring-stack
```

This repository contains:

- Prometheus
- Grafana
- Loki
- Alertmanager
- demo application
- dashboards
- alert rules
- runbooks
