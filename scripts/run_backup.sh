#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="/Users/elvira/infra/backups"
LOG="$BACKUP_DIR/backup.log"
ERR="$BACKUP_DIR/backup.err.log"

echo "=== backup start $(date -u '+%Y-%m-%d %H:%M:%S UTC') ===" >> "$LOG"

cd /Users/elvira/infra

/opt/homebrew/bin/ansible-playbook playbooks/backup_vps.yml >> "$LOG" 2>> "$ERR"

/usr/bin/rsync -avz vps:/srv/backups/ "$BACKUP_DIR/" >> "$LOG" 2>> "$ERR"

LATEST=$(ls -t "$BACKUP_DIR"/vps-backup-*.tar.gz | head -n1)

echo "Generating SHA256 for $LATEST" >> "$LOG"
shasum -a 256 "$LATEST" > "$LATEST.sha256"

/Users/elvira/infra/scripts/offsite_backup.sh >> "$LOG" 2>> "$ERR"

echo "=== backup end $(date -u '+%Y-%m-%d %H:%M:%S UTC') ===" >> "$LOG"
