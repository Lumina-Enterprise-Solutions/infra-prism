# Prism ERP - Infrastructure

Selamat datang di repositori infrastruktur untuk Prism ERP. Repositori ini berisi semua konfigurasi yang diperlukan untuk menjalankan seluruh tumpukan backend Prism ERP secara lokal atau di lingkungan produksi menggunakan Docker Compose.

Arsitektur ini dirancang sebagai microservices, dengan semua komponen yang diperlukan untuk development, testing, monitoring, dan deployment.

## ✨ Fitur & Komponen

-   **Containerization**: Seluruh tumpukan didefinisikan dalam `docker-compose.yml`.
-   **API Gateway**: [Traefik](httpsa://traefik.io/traefik/) sebagai reverse proxy dan API gateway.
-   **Database**: PostgreSQL (Relasional), Redis (Cache), MongoDB (Dokumen).
-   **Service Discovery**: [Consul](https://www.consul.io/) untuk registrasi dan discovery layanan.
-   **Secret Management**: [HashiCorp Vault](https://www.vaultproject.io/) untuk mengelola rahasia secara aman.
-   **Observability Stack (Monitoring)**:
    -   [Prometheus](https://prometheus.io/) untuk pengumpulan metrik.
    -   [Grafana](https://grafana.com/) untuk visualisasi dan dashboard.
    -   [Loki](https://grafana.com/oss/loki/) untuk agregasi log.
    -   [Jaeger](https://www.jaegertracing.io/) untuk distributed tracing.
    -   [cAdvisor](https://github.com/google/cadvisor) untuk metrik performa container.
-   **Penyimpanan File**: Mendukung penyimpanan lokal (via volume Docker) dan [Minio](https://min.io/) (Object Storage S3-compatible) untuk pengembangan lokal.
-   **Automasi**: `Makefile` untuk menyederhanakan alur kerja.
-   **CI/CD**: Pipeline GitHub Actions untuk deployment otomatis ke server pengembangan.

##  Prerequisites

Pastikan perangkat Anda telah terinstal:
*   [Docker](https://www.docker.com/get-started)
*   [Docker Compose](https://docs.docker.com/compose/install/) (biasanya sudah termasuk dalam Docker Desktop)
*   `make` (terinstal secara default di Linux/macOS, bisa diinstal via [Chocolatey](https://chocolatey.org/packages/make) di Windows)

## 🚀 Memulai

1.  **Clone Repositori**:
    ```bash
    git clone <URL_REPOSITORI_ANDA>
    cd infra-prism
    ```

2.  **Konfigurasi Lingkungan**:
    Salin file `.env.example` menjadi `.env`. File ini berisi variabel default yang dibutuhkan oleh Docker Compose.
    ```bash
    cp .env.example .env
    ```
    Anda bisa mengubah nilai di dalam `.env` jika diperlukan, tetapi nilai default sudah cocok untuk lingkungan lokal.

3.  **Jalankan Tumpukan Aplikasi**:
    Gunakan `Makefile` untuk menjalankan semua layanan.

    *   **Untuk Pengembang (Development)**: Perintah ini akan membangun image dari source code di monorepo Anda dan menyertakan layanan tambahan seperti Minio.
        ```bash
        make up ENV=local
        ```

    *   **Untuk Staging/Produksi**: Perintah ini akan menarik image yang sudah jadi dari container registry (misal: GHCR) dan tidak menyertakan layanan khusus dev.
        ```bash
        make up ENV=prod
        ```

4.  **Menghentikan Tumpukan Aplikasi**:
    ```bash
    make down
    ```
    Untuk membersihkan semua data (volume), gunakan `make clean`.

## ⚙️ Perintah Makefile yang Berguna

-   `make up ENV=<local|prod>`: Menjalankan semua container di background. Default `ENV=local`.
-   `make down`: Menghentikan dan menghapus semua container.
-   `make ps`: Menampilkan status semua container yang berjalan.
-   `make logs s=<nama_service>`: Melihat log dari service tertentu (misal: `make logs s=auth-service`).
-   `make logs`: Melihat log dari semua service.
-   `make clean`: Menghentikan container dan menghapus semua volume data. **Hati-hati, data akan hilang!**
-   `make help`: Menampilkan semua perintah yang tersedia.

## 🌐 Mengakses Layanan

Setelah menjalankan `make up`, Anda dapat mengakses berbagai dashboard dan UI dari browser Anda:

| Layanan               | URL                            | Kredensial (jika ada)                 |
| --------------------- | ------------------------------ | ------------------------------------- |
| **Aplikasi (API)**    | `http://localhost:8000`        | -                                     |
| **Grafana**           | `http://localhost:3000`        | `admin` / `admin`                     |
| **Traefik Dashboard** | `http://localhost:8081`        | -                                     |
| **Jaeger Tracing**    | `http://localhost:16686`       | -                                     |
| **Prometheus**        | `http://localhost:9090`        | -                                     |
| **Vault UI**          | `http://localhost:8200`        | Token: `root-token-for-dev`           |
| **Consul UI**         | `http://localhost:8500`        | -                                     |
| **Minio Console**     | `http://localhost:9001`        | `minioadmin` / `minioadmin`           |

## 📦 Integrasi Monorepo

Konfigurasi `docker-compose.local.yml` dirancang untuk bekerja dalam struktur monorepo. Perhatikan bagian `build` di setiap layanan aplikasi:
```yaml
# contoh di user-service
build:
  context: ..
  dockerfile: services/prism-user-service/Dockerfile.mono
