#!/usr/bin/env bash
set -euo pipefail

BACKUP_FILE="${1:-}"
MODE="${2:-test}"
CHECKSUM_FILE="${BACKUP_FILE}.sha256"

if [ -z "$BACKUP_FILE" ]; then
  echo "Usage: $0 /Users/elvira/infra/backups/<backup-file>.tar.gz [test|apply]"
  exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
  echo "Backup file not found: $BACKUP_FILE"
  exit 1
fi

if [ ! -f "$CHECKSUM_FILE" ]; then
  echo "Checksum file not found: $CHECKSUM_FILE"
  exit 1
fi

if [ "$MODE" != "test" ] && [ "$MODE" != "apply" ]; then
  echo "Mode must be 'test' or 'apply'"
  exit 1
fi

echo "==> Verifying backup integrity (local)"
shasum -a 256 -c "$CHECKSUM_FILE"

REMOTE_TMP="/tmp/vps-restore"
REMOTE_BACKUP="$REMOTE_TMP/$(basename "$BACKUP_FILE")"
REMOTE_EXTRACT="$REMOTE_TMP/extract"

echo "==> Preparing remote restore directory"
ssh vps "sudo rm -rf $REMOTE_TMP && sudo mkdir -p $REMOTE_TMP && sudo chown admin1:admin1 $REMOTE_TMP"

echo "==> Uploading backup archive"
rsync -avz "$BACKUP_FILE" "vps:$REMOTE_BACKUP"

echo "==> Verifying checksum on VPS"
LOCAL_HASH="$(shasum -a 256 "$BACKUP_FILE" | awk '{print $1}')"
REMOTE_HASH="$(ssh vps "shasum -a 256 $REMOTE_BACKUP | awk '{print \$1}'")"

if [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
  echo "Checksum mismatch!"
  echo "Local:  $LOCAL_HASH"
  echo "Remote: $REMOTE_HASH"
  exit 1
fi

echo "Checksum verified successfully"

echo "==> Extracting archive on VPS"
ssh vps "sudo mkdir -p $REMOTE_EXTRACT && sudo tar -xzf $REMOTE_BACKUP -C $REMOTE_EXTRACT"

echo "==> Checking extracted content"
ssh vps "sudo test -d $REMOTE_EXTRACT/srv/monitoring && sudo test -d $REMOTE_EXTRACT/etc && echo 'Archive structure OK'"

if [ "$MODE" = "test" ]; then
  echo "==> TEST MODE ONLY"
  echo "Archive uploaded and extracted successfully."
  echo "Extracted paths on VPS:"
  ssh vps "sudo ls -ld $REMOTE_EXTRACT/srv/monitoring $REMOTE_EXTRACT/etc"
  exit 0
fi

echo "==> APPLY MODE: restoring files"
ssh vps <<EOF
set -euo pipefail
sudo rsync -a "$REMOTE_EXTRACT/srv/monitoring/" /srv/monitoring/
sudo rsync -a "$REMOTE_EXTRACT/etc/" /etc/
sudo chown -R root:root /etc
echo "Restore completed on VPS"
EOF

echo "==> Checking services"
ssh vps 'cd /srv/monitoring && docker compose ps'
