#!/usr/bin/env bash
set -euo pipefail

echo "=== backup start $(date) ===" >> /Users/elvira/infra/backups/backup.log

cd /Users/elvira/infra

/opt/homebrew/bin/ansible-playbook playbooks/backup_vps.yml >> /Users/elvira/infra/backups/backup.log 2>> /Users/elvira/infra/backups/backup.err.log
/usr/bin/rsync -avz vps:/srv/backups/ /Users/elvira/infra/backups/ >> /Users/elvira/infra/backups/backup.log 2>> /Users/elvira/infra/backups/backup.err.log

echo "=== backup end $(date) ===" >> /Users/elvira/infra/backups/backup.log
