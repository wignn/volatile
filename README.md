# vasvault

Deskripsi
-
`vasvault` adalah aplikasi mobile berbasis Flutter untuk mengelola workspace dan file bersama. Proyek ini berisi UI, layanan API, dan integrasi penyimpanan untuk mengunggah, melihat, dan mengelola anggota workspace.

Fitur utama
-
- Manajemen workspace dan anggota (roles: owner, admin, viewer).
- Unggah, tampilkan, dan hapus file dalam suatu workspace.
- Pratinjau file eksternal melalui URL.

Persyaratan
-
- Flutter SDK (sesuai `pubspec.yaml`).
- Android Studio, Xcode atau tooling build lain untuk target platform.
- Paket tambahan yang digunakan proyek didefinisikan di `pubspec.yaml`.

Instalasi & Menjalankan
-
1. Clone repository:

```bash
	git clone https://github.com/wignn/volatile.git vasvault
```
2. Masuk ke direktori proyek:

	cd vasvault

3. Install dependensi:

	flutter pub get

4. Jalankan aplikasi (contoh di emulator Android):

	flutter run

Konfigurasi lingkungan
-
- Base URL dan API key dapat diatur melalui variabel lingkungan build (`--dart-define`) atau file konfigurasi sesuai pipeline build Anda. Contoh penggunaan:

  flutter run --dart-define=BASE_URL=https://api.example.com --dart-define=API_KEY=your_api_key

Struktur proyek (ringkasan)
-
- `lib/` — Kode sumber aplikasi Flutter
  - `page/` — Halaman UI
  - `services/` — Panggilan API dan logika layanan
  - `models/` — Model data (mis. `Workspace`, `WorkspaceMember`)
  - `utils/` — Utilitas seperti `SessionManager`
  - `theme/` — Tema dan warna aplikasi
- `assets/` — Ikon dan aset statis
- `android/`, `ios/`, `windows/`, `web/`, `macos/`, `linux/` — Native platform folders


Catatan implementasi penting
-
- `SessionManager` menyimpan token dan ID user di `SharedPreferences`. Pastikan kunci konsisten saat menyimpan dan membaca ID pengguna.
- Hak akses tombol manajemen anggota tergantung pada role yang di-fetch dari API; role `owner` dan `admin` dapat mengakses fungsi tambah/kelola anggota.


Troubleshooting
-
- Jika tombol tidak aktif: periksa nilai ID user yang tersimpan (`SessionManager`) dan respons API anggota workspace.
- Masalah network: aktifkan log debug dan cek `baseUrl` konfigurasi.

