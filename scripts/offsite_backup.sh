#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="/Users/elvira/infra/backups"
LATEST="$(ls -t "$BACKUP_DIR"/vps-backup-*.tar.gz | head -n1)"

echo "Latest backup:"
echo "$LATEST"

echo
echo "Uploading to admin..."
rsync -avz "$LATEST" admin:~/infra-backups/
ssh admin 'ls -t ~/infra-backups/vps-backup-*.tar.gz 2>/dev/null | tail -n +8 | xargs -r rm -f'

echo
echo "Uploading to lab..."
rsync -avz "$LATEST" lab:~/infra-backups/
ssh lab 'ls -t ~/infra-backups/vps-backup-*.tar.gz 2>/dev/null | tail -n +8 | xargs -r rm -f'

echo
echo "Offsite backup completed."
