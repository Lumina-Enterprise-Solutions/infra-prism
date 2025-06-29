# --- Stage 1: Ambil binary Consul ---
# Kita beri nama stage ini 'consul-builder'
FROM hashicorp/consul:1.21 AS consul-builder
# Tidak ada yang perlu dijalankan, kita hanya butuh file dari image ini.


# --- Stage 2: Bangun image akhir kita ---
# Gunakan image resmi Vault sebagai dasar
FROM hashicorp/vault:1.19

# Install dependensi yang kita butuhkan (tanpa consul)
RUN apk add --no-cache curl bash

# Salin binary 'consul' dari stage 'consul-builder'
# ke path yang bisa dieksekusi di image akhir kita.
COPY --from=consul-builder /bin/consul /usr/local/bin/consul

# Salin skrip setup kita ke dalam image
COPY setup.sh /usr/local/bin/setup.sh

# Pastikan kedua skrip bisa dieksekusi
RUN chmod +x /usr/local/bin/setup.sh /usr/local/bin/consul

# Perintah yang akan dijalankan saat container startup
ENTRYPOINT ["/usr/local/bin/setup.sh"]
