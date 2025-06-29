#!/bin/bash

# Menghentikan eksekusi jika ada error
set -e

# --- Menunggu Vault Siap ---
echo "Menunggu Vault untuk siap di http://vault:8200..."

until $(curl --output /dev/null --silent --head --fail http://vault:8200/v1/sys/health); do
    printf '.'
    sleep 2
done

echo "Vault sudah siap!"

# --- Login ke Vault ---
vault login "$VAULT_TOKEN"
echo "Login ke Vault berhasil."

# --- Mengaktifkan Secret Engine (KV v2) ---
vault secrets enable -path=secret kv-v2 || true
echo "KV v2 secret engine di path 'secret/' telah dipastikan aktif."

# --- Menulis Rahasia Awal ---
echo "Menulis rahasia awal ke Vault..."

# Membuat Database URL dari environment variables
DATABASE_URL="postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}?sslmode=disable"

# --- PERUBAHAN DI SINI: Tambahkan kredensial untuk S3/Minio ---
# Ini adalah kredensial default dari container Minio
S3_ENDPOINT="http://minio:9000"
S3_REGION="us-east-1" # Region default, bisa apa saja untuk Minio
S3_ACCESS_KEY="minioadmin"
S3_SECRET_KEY="minioadmin"
S3_BUCKET="prism-files"

# Menyimpan semua rahasia ke Vault
vault kv put secret/prism \
    jwt_secret_key="ini-rahasia-banget-dari-vault-otomatis" \
    database_url="${DATABASE_URL}" \
    google_oauth_client_id="${GOOGLE_CLIENT_ID}" \
    google_oauth_client_secret="${GOOGLE_CLIENT_SECRET}" \
    microsoft_oauth_client_id="${MICROSOFT_CLIENT_ID}" \
    microsoft_oauth_client_secret="${MICROSOFT_CLIENT_SECRET}" \
    mailtrap_host="${MAILTRAP_HOST}" \
    mailtrap_port="${MAILTRAP_PORT}" \
    mailtrap_user="${MAILTRAP_USER}" \
    mailtrap_pass="${MAILTRAP_PASS}" \
    s3_endpoint="${S3_ENDPOINT}" \
    s3_region="${S3_REGION}" \
    s3_access_key="${S3_ACCESS_KEY}" \
    s3_secret_key="${S3_SECRET_KEY}" \
    s3_bucket="${S3_BUCKET}"

echo "Rahasia berhasil ditulis ke 'secret/data/prism'."

# --- MENULIS KONFIGURASI KE CONSUL KV ---
echo "Menulis konfigurasi awal ke Consul KV..."

export CONSUL_HTTP_ADDR="http://consul:8500"

# Konfigurasi Global
consul kv put config/global/log_level "info"
consul kv put config/global/environment "development"
consul kv put config/global/jaeger_endpoint "jaeger:4317"
consul kv put config/global/redis_addr "cache-redis:6379"

# Konfigurasi per Service
consul kv put config/prism-auth-service/port "8080"
consul kv put config/prism-user-service/port "8080"
consul kv put config/prism-user-service/grpc_port "9001"
consul kv put config/prism-notification-service/port "8080"

# --- PERUBAHAN DI SINI: Tambahkan konfigurasi untuk file-service ---
consul kv put config/prism-file-service/port "8080"
consul kv put config/prism-file-service/storage_backend "s3" # Default ke "local" untuk dev. Ganti jadi "s3" untuk tes S3.
consul kv put config/prism-file-service/s3_use_path_style "true" # Penting untuk Minio
consul kv put config/prism-file-service/max_size_mb "15"
consul kv put config/prism-file-service/allowed_mime_types "image/jpeg,image/png,application/pdf,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet,text/plain"

echo "Konfigurasi berhasil ditulis ke Consul."
echo "Setup Vault dan Consul selesai."
