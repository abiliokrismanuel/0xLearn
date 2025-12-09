#!/bin/bash

#ini script untuk backup postgresql pod di k3s dan upload ke S3

set -euo pipefail

NAMESPACE="postgres-ns"
POD_LABEL="app.kubernetes.io/name=postgresql"

BACKUP_DIR="/tmp/backup"
mkdir -p "$BACKUP_DIR"
TIMESTAMP=$(date +%Y%m%d%H%M%S)
BACKUP_FILE="pg_backup_biz_${TIMESTAMP}.sql.gz"
S3_BUCKET="s3://bucketmu/"

#ganti sesuai konfigurasi PostgreSQLmu
PG_USER="user"
PG_DB="database"

# Creds (Sebaiknya pakai env variable/secret, tapi untuk quick fix ok)
PG_PASSWORD="passwordkuat"
AWS_ACCESS_KEY_ID="acceskeyids3"
AWS_SECRET_ACCESS_KEY="secrets3"

export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"

# Ambil nama pod PostgreSQL
POD_NAME=$(kubectl get pods -n $NAMESPACE -l "$POD_LABEL" -o jsonpath="{.items[0].metadata.name}")
if [[ -z "$POD_NAME" ]]; then
  echo "❌ Tidak menemukan pod PostgreSQL"
  exit 1
fi

echo "Mulai backup PostgreSQL dari pod: $POD_NAME"

# Backup langsung dari pod dan simpan lokal
k3s kubectl exec -n "$NAMESPACE" "$POD_NAME" -- \
  bash -c "PGPASSWORD='$PG_PASSWORD' pg_dump -U $PG_USER $PG_DB" | gzip > "$BACKUP_DIR/$BACKUP_FILE"

if [[ ! -s "$BACKUP_DIR/$BACKUP_FILE" ]]; then
  echo "❌ Backup gagal atau hasil kosong!"
  exit 1
fi

echo "Backup berhasil: $BACKUP_DIR/$BACKUP_FILE"

echo "Upload ke S3: $S3_BUCKET$BACKUP_FILE"

aws s3 cp "$BACKUP_DIR/$BACKUP_FILE" "$S3_BUCKET"

if [[ $? -ne 0 ]]; then
  echo "❌ Upload ke S3 gagal!"
  exit 1
fi

echo "✅ Upload selesai."

# Hapus lokal setelah upload
rm -f "$BACKUP_DIR/$BACKUP_FILE"