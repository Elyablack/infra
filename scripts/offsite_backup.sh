#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="/Users/elvira/infra/backups"
LATEST="$(ls -t "$BACKUP_DIR"/vps-backup-*.tar.gz | head -n1)"

echo "Latest backup:"
echo "$LATEST"

upload_backup() {
  local host="$1"

  echo
  echo "Uploading to ${host}..."

  ssh "$host" 'mkdir -p ~/infra-backups'
  rsync -avz "$LATEST"* "${host}:~/infra-backups/"
  ssh "$host" 'ls -t ~/infra-backups/vps-backup-*.tar.gz 2>/dev/null | tail -n +8 | xargs -r rm -f'
}

upload_backup admin
upload_backup lab
upload_backup pc

echo
echo "Offsite backup completed."
