#!/bin/bash

#script ini jika mau backup db tidak dari pod melainkan langsung via pg_dump ke localhost

# --- KONFIGURASI ---
DB_HOST="127.0.0.1"        # Wajib IP angka agar bypass Peer Auth
DB_PORT="5432"
DB_USER="userpostgres"         # Username database
DB_NAME="dbname"    # Nama database spesifik
DB_PASS="passwordkuwat"    # Password database
AWS_BUCKET="bucketmu"
AWS_FOLDER="backup/foldermu" # Folder di dalam bucket (opsional)

# Penamaan file dengan Timestamp
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
FILENAME="namain_aja_terserah_${DB_NAME}_${TIMESTAMP}.sql.gz"
TEMP_FILE="/tmp/${FILENAME}"

# --- EKSEKUSI ---
export PGPASSWORD="${DB_PASS}"

echo "[START] Memulai backup ${DB_NAME} (Port ${DB_PORT})..."

# Perintah pg_dump memaksa via TCP
CMD="pg_dump -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} ${DB_NAME}"

if $CMD | gzip > "${TEMP_FILE}"; then
    
    FILESIZE=$(stat -c%s "$TEMP_FILE")
    # Validasi size (backup kosong biasanya cuma 20 bytes header gzip)
    if [ "$FILESIZE" -lt 100 ]; then
        echo "[ERROR] File backup terlalu kecil ($FILESIZE bytes). Password salah atau DB kosong."
        rm "${TEMP_FILE}"
        exit 1
    fi

    echo "[SUCCESS] Dump OK: ${TEMP_FILE} ($FILESIZE bytes)"
    
    echo "[UPLOAD] Mengupload ke S3..."
    if aws s3 cp "${TEMP_FILE}" "s3://${AWS_BUCKET}/${AWS_FOLDER}/${FILENAME}"; then
        echo "[SUCCESS] Upload S3 Berhasil."
    else
        echo "[ERROR] Gagal upload ke S3!"
        exit 1
    fi

    rm "${TEMP_FILE}"
    echo "[CLEANUP] Selesai."

else
    echo "[ERROR] pg_dump GAGAL! Kemungkinan Password salah."
    [ -f "$TEMP_FILE" ] && rm "$TEMP_FILE"
    exit 1
fi

unset PGPASSWORD