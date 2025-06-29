# 🚀 Panduan Penggunaan Koleksi Postman untuk Prism ERP

Dokumen ini adalah panduan lengkap untuk menggunakan koleksi Postman "Prism Enterprise Services" untuk menguji seluruh fungsionalitas microservices Prism ERP.

## ✅ Prasyarat

Sebelum memulai, pastikan Anda telah memenuhi persyaratan berikut:

1.  **Postman Terinstal**: Pastikan Anda memiliki aplikasi Postman versi terbaru.
2.  **Layanan Berjalan**: Semua microservices (Auth, User, File, Notification) dan infrastruktur pendukungnya (Database, Redis, Vault, Consul, Traefik) harus sudah berjalan. Cara termudah adalah dengan menjalankan `make up` dari direktori root monorepo.
3.  **Koleksi Telah Diimpor**: Anda telah mengimpor file `Prism Enterprise Services.postman_collection.json` ke dalam Postman.

## ⚙️ Konfigurasi Awal

Satu-satunya konfigurasi manual yang perlu Anda lakukan adalah memastikan variabel `base_url` sudah benar.

1.  Klik pada nama koleksi ("Prism Enterprise Services") di sidebar Postman.
2.  Pilih tab **Variables**.
3.  Pastikan `base_url` memiliki nilai `http://localhost:8000`. Port `8000` adalah port yang diekspos oleh Traefik (reverse proxy) yang akan mengarahkan request ke layanan yang sesuai.

Variabel lain seperti `jwt_token`, `refresh_token`, `user_id_to_manage`, dll., **akan terisi secara otomatis** oleh skrip yang ada di dalam koleksi saat Anda menjalankan request tertentu.

## 🧪 Alur Kerja Pengujian Umum

Berikut adalah urutan yang disarankan untuk menguji API secara menyeluruh.

### 1. Registrasi & Login

Ini adalah alur paling dasar untuk mendapatkan token akses.

1.  **Register User**: Buka `Auth Service > Register User`. Kirim request ini untuk membuat pengguna baru.
2.  **Login (Step 1)**: Buka `Auth Service > Login (Step 1 - Password)`. Gunakan email dan password yang sama dengan yang Anda daftarkan. Kirim request.
    -   **Hasil**: Skrip *test* akan secara otomatis menyimpan `access_token` dan `refresh_token` ke dalam variabel koleksi (`jwt_token` dan `refresh_token`).

### 2. Mengakses Rute Terproteksi

Setelah login, Anda bisa menguji endpoint yang memerlukan otentikasi.

1.  Buka `User Service > My Profile > Get My Profile`.
2.  Kirim request. Anda tidak perlu mengatur header `Authorization` secara manual, karena sudah dikonfigurasi untuk menggunakan variabel `{{jwt_token}}`.
3.  Jika berhasil, Anda akan melihat detail profil pengguna yang baru saja login.

### 3. Menguji Refresh Token

1.  Tunggu hingga token akses Anda kedaluwarsa (default 15 menit), atau sengaja ubah isinya agar tidak valid.
2.  Buka `Auth Service > Refresh Access Token`. Variabel `refresh_token` sudah terisi dari langkah login.
3.  Kirim request.
    -   **Hasil**: Anda akan mendapatkan `access_token` dan `refresh_token` yang baru. Skrip *test* akan otomatis memperbarui variabel koleksi.

### 4. Alur Manajemen 2FA

1.  **Login** terlebih dahulu untuk mendapatkan `jwt_token` yang valid.
2.  **Setup 2FA**: Buka `Auth Service > 2FA Management > Setup 2FA`. Kirim request.
    -   **Hasil**: Anda akan mendapatkan QR code (base64) dan *secret*. Skrip akan menyimpan *secret* ke variabel `{{2fa_secret}}`.
3.  **Scan QR Code**: Gunakan aplikasi authenticator (Google Authenticator, Authy, dll.) untuk memindai QR code (Anda bisa menggunakan *online base64 to image converter* untuk melihat gambarnya).
4.  **Verify & Enable 2FA**: Buka `Auth Service > 2FA Management > Verify & Enable 2FA`.
    -   Variabel `secret` sudah terisi otomatis.
    -   Masukkan 6-digit kode dari aplikasi authenticator Anda ke dalam field `code` pada body request.
    -   Kirim request untuk mengaktifkan 2FA.
5.  **Test Login dengan 2FA**:
    -   Jalankan `Auth Service > Login (Step 1 - Password)` lagi. Kali ini, response akan berisi `is_2fa_required: true`.
    -   Buka `Auth Service > Login (Step 2 - 2FA Code)`. Email sudah terisi otomatis.
    -   Masukkan kode 6-digit baru dari aplikasi authenticator Anda ke field `code`.
    -   Kirim request. Anda akan mendapatkan token akses dan refresh yang baru.

### 5. Alur Administratif (RBAC)

Alur ini memerlukan pengguna dengan peran `admin`.

1.  **Buat Pengguna Admin**:
    -   **Login sebagai admin yang ada**. Jika belum ada, Anda harus membuatnya secara manual di database dengan mengubah `role_id` seorang user menjadi ID dari peran `admin`.
    -   **Dapatkan ID Pengguna Biasa**: Jalankan `User Service > Admin > Get All Users` untuk mendapatkan daftar pengguna. Skrip akan menyimpan ID pengguna pertama ke variabel `{{user_id_to_manage}}`.
    -   **Update Role**: Buka `User Service > Admin > RBAC Management > Update User Role`. Pastikan ID di URL sudah terisi dan body request berisi `{"role": "admin"}`. Kirim request untuk mempromosikan pengguna tersebut menjadi admin.
2.  **Login sebagai Admin Baru**: Jalankan alur login untuk pengguna yang baru saja Anda promosikan untuk mendapatkan token dengan hak akses admin.
3.  **Uji Endpoint Admin**: Gunakan token admin baru untuk menguji semua endpoint di bawah folder `User Service > Admin`.

### 6. Alur File Service

1.  **Login** sebagai pengguna mana pun.
2.  **Upload File**: Buka `File Service > Upload File`.
    -   Di tab *Body*, pilih *form-data*.
    -   Klik pada field `file` dan pilih sebuah file dari komputer Anda.
    -   Kirim request.
    -   **Hasil**: Skrip *test* akan menyimpan `id` unik dari file yang di-upload ke variabel `{{last_uploaded_file_id}}`.
3.  **Download File**: Buka `File Service > Download File`.
    -   URL sudah otomatis terisi dengan ID dari file yang baru di-upload.
    -   Kirim request. Postman akan memberi opsi untuk menyimpan file yang di-download.

Selamat, Anda telah berhasil menguji semua alur utama di ekosistem Prism ERP!
