# 🔐 JWT + Fingerprint Session Flow (Flutter)

Dokumen ini menjelaskan mekanisme penggunaan **Access Token + Refresh Token + Biometric (Fingerprint)** untuk menjaga sesi login pada aplikasi mobile.

---

# 📌 Tujuan

- Menjaga keamanan session user
- Mencegah penyalahgunaan refresh token
- Menambahkan lapisan autentikasi lokal (biometrik)
- Memberikan UX yang tetap nyaman

---

# 🧠 Konsep Dasar

## Token

- **Access Token**
  - Umur pendek (misal: 15 menit)
  - Digunakan untuk request API

- **Refresh Token**
  - Umur panjang (misal: 7 hari)
  - Digunakan untuk mendapatkan access token baru

## Biometric (Fingerprint)

- Digunakan sebagai **gate** sebelum refresh token dipakai
- Mencegah akses tanpa izin saat app dibuka ulang

---

# 🔄 Alur Sistem

## 1. Login Awal

```text
User login
↓
Server kirim:
  - access_token
  - refresh_token
↓
App menyimpan:
  - access_token
  - refresh_token (secure storage)


2. App Dibuka (Cold Start)
App start
↓
Cek access token
↓
Apakah expired?
Jika TIDAK expired:
→ Masuk ke aplikasi
Jika expired:
→ Trigger fingerprint
3. Fingerprint Authentication
Minta autentikasi fingerprint
↓
Jika BERHASIL:
→ Lanjut ke refresh token
Jika GAGAL / CANCEL:
→ Logout
→ Hapus token
→ Redirect ke login screen
4. Refresh Token Flow
POST /refresh
↓
Kirim refresh_token
↓
Jika BERHASIL:
→ Terima access_token baru
→ Simpan token
→ Masuk ke aplikasi
Jika GAGAL:
→ Logout
→ Redirect ke login
🔁 Flow Diagram
APP OPEN
↓
Access Token valid?
 ├── YES → Masuk app
 └── NO
       ↓
   Fingerprint
       ↓
   ├── SUCCESS → Refresh Token
   │       ↓
   │   ├── SUCCESS → Masuk app
   │   └── FAIL → Login
   │
   └── FAIL → Login


