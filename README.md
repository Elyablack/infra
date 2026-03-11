
# Infrastructure Automation

Infrastructure management and backup automation for the monitoring stack.

This repository contains Ansible playbooks, automation scripts, and documentation used to manage and protect the VPS environment.

---

## Architecture

Mac (control node) → VPS

Automation tasks include:

- VPS backups
- restore testing
- infrastructure automation via Ansible
- scheduled backup jobs

---

## Repository Structure

```
infra
├── ansible.cfg
├── inventory
│ └── hosts
├── playbooks
│ └── backup_vps.yml
├── scripts
│ ├── run_backup.sh
│ └── restore_vps.sh
├── backups
├── docs
└── README.md
```

---

## Backup Workflow

Backups include:

- `/srv/monitoring`
- `/etc`

Backup process:

```
VPS
│
│ ansible
▼
tar archive
│
▼
Mac
```

Backup archive example:

```
vps-backup-YYYY-MM-DD-HHMM.tar.gz
```
---

## Running Backup

Run backup playbook:

```
ansible-playbook playbooks/backup_vps.yml
```

Download backups from VPS:

```
rsync -avz vps:/srv/backups/ ~/infra/backups/
```

---

## Restore Testing

Test restore safely without touching the running system:

```
~/infra/scripts/restore_vps.sh ~/infra/backups/.tar.gz test
```

This will:

- upload the archive to VPS
- extract it in `/tmp/vps-restore`
- verify directory structure

---

## Restore (apply)

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

Backups are scheduled via **macOS launchd**.

Job:

```
com.elvira.infra-backup
```

Runs daily and executes:

```
scripts/run_backup.sh
```
---

## Disaster Recovery Plan

If VPS is lost:

1. create new VPS
2. bootstrap base environment
3. upload backup archive
4. restore files
5. start services

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
