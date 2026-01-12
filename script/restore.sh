#!/bin/bash

#script ini kalau mau restore ke db pod

set -e # Stop script jika ada error

# --- KONFIGURASI ---
NAMESPACE="postgres-ns"
POD_LABEL="app.kubernetes.io/name=postgresql"
S3_BUCKET="s3://bucketmu/"
BACKUP_FILENAME="namafiledis3"

PG_USER="userajah"
PG_DB="dbmu" # Database target
MAINTENANCE_DB="postgres" # DB untuk koneksi awal

# Creds (Sebaiknya pakai env variable/secret, tapi untuk quick fix ok)
PG_PASSWORD="passwordkuat"
AWS_ACCESS_KEY_ID="acceskeyids3"
AWS_SECRET_ACCESS_KEY="secrets3"

export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"

# 1. Cari Pod
echo "Mencari Pod PostgreSQL..."
POD_NAME=$(kubectl get pods -n $NAMESPACE -l $POD_LABEL -o jsonpath="{.items[0].metadata.name}")

if [ -z "$POD_NAME" ]; then
  echo "Pod tidak ditemukan!"
  exit 1
fi
echo " Pod ditemukan: $POD_NAME"

# 2. Download dari S3 ke TEMP Local (File .gz tetap kecil)
echo " Download dari S3 ke Local..."
aws s3 cp "$S3_BUCKET$BACKUP_FILENAME" /tmp/restore_temp.sql.gz

# 3. Copy dari Local ke DALAM POD (Supaya restore dilakukan lokal di dalam pod)
echo "Upload file ke Pod (supaya tidak lewat network pipe)..."
kubectl cp /tmp/restore_temp.sql.gz $NAMESPACE/$POD_NAME:/tmp/restore_temp.sql.gz

# 4. PROSES RESTORE DI DALAM POD
echo " Memulai proses restore di dalam Pod..."

kubectl exec -n $NAMESPACE $POD_NAME -- bash -c "export PGPASSWORD='$PG_PASSWORD';

    echo 'Step 1: Import Data...';
    # Menggunakan zcat agar unzip dilakukan on-the-fly di dalam pod
    zcat /tmp/restore_temp.sql.gz | psql -U $PG_USER -d $PG_DB
"

# 5. Bersih-bersih
echo "Membersihkan file temporary..."
rm /tmp/restore_temp.sql.gz
kubectl exec -n $NAMESPACE $POD_NAME -- rm /tmp/restore_temp.sql.gz

echo "✅ RESTORE SELESAI SUKSES!"