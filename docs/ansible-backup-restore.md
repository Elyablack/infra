# Backup and Restore Runbook

Operational runbook describing backup creation, verification and restoration procedures for the VPS environment.

---

## Backup Scope

The backup archive includes:

```
/srv/monitoring
/etc
```

These directories contain:

- monitoring stack configuration
- application configuration
- system configuration required for service operation

---

## Backup Creation

Backup is created using an Ansible playbook.

Run manually:
```
cd ~/infra
ansible-playbook playbooks/backup_vps.yml
```

This will:

1. create a compressed archive on the VPS
2. store it in:

```
/srv/backups
```

Archive format:

```
vps-backup-YYYY-MM-DD-HHMM.tar.gz
```

---

## Download Backup to Mac

Download backups from VPS:

```
rsync -avz vps:/srv/backups/ ~/infra/backups/
```

Local storage location:

```
~/infra/backups
```

---

## Backup Verification

Verify archive contents before restore:

```
tar -tzf ~/infra/backups/.tar.gz | head
```

Expected structure:

```
srv/monitoring
etc
```

---

## Restore Test (Safe Mode)

Test restore without touching the running system.

Run:

```
~/infra/scripts/restore_vps.sh ~/infra/backups/.tar.gz test
```

Test mode performs:

- upload archive to VPS
- extraction in temporary directory
- directory structure validation

Temporary location:

```
/tmp/vps-restore
```
---

## Restore Procedure

Run actual restore:

```
~/infra/scripts/restore_vps.sh ~/infra/backups/.tar.gz apply
```

This will restore:

```
/srv/monitoring
/etc
```

---

## Service Recovery

After restore, restart monitoring services:

```
ssh vps
cd /srv/monitoring
docker compose up -d
```

Verify containers:

```
docker compose ps
```

Expected services:

- prometheus
- alertmanager
- grafana
- loki
- promtail
- tg-relay
- demo-app

---

## Disaster Recovery Scenario

If the VPS is lost:

1. create a new VPS
2. configure SSH access
3. upload backup archive
4. run restore procedure
5. start monitoring stack

```
cd /srv/monitoring
docker compose up -d
```
---

## Backup Location Summary

VPS:

```
/srv/backups
```

Mac:

```
~/infra/backups
```

