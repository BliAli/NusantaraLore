# Perancangan Sistem - NusantaraLore

Dokumentasi lengkap diagram UML untuk aplikasi **NusantaraLore - Ensiklopedia Digital Budaya Nusantara**.

## 📂 Daftar Diagram

Semua file `.puml` (PlantUML) berada di `docs/diagrams/`.

### Use Case Diagram

| No | File | Deskripsi |
|----|------|-----------|
| 1 | `usecase_combined.puml` | **Use Case Diagram (Gabungan)** — Semua fitur + 7 aktor dalam satu diagram |
| 2 | `usecase_diagram.drawio` | **Use Case Diagram (draw.io)** — Versi visual dengan garis berwarna per grup fitur |

#### Use Case Terpisah (per modul)
| No | File | Deskripsi |
|----|------|-----------|
| 1 | `uc_1_autentikasi.puml` | Use case: Register, Login, Logout, Biometrik, PIN |
| 2 | `uc_2_eksplorasi.puml` | Use case: Jelajah, Detail, Cari, Bookmark, Koleksi |
| 3 | `uc_3_peta.puml` | Use case: Peta Budaya, Budaya Terdekat, Tilt Rotasi |
| 4 | `uc_4_games.puml` | Use case: Kuis, Puzzle, Wayang, Leaderboard, Gamifikasi |
| 5 | `uc_5_ai.puml` | Use case: AI Ki Dalang, Ceritakan Legenda, Reset Sesi |
| 6 | `uc_7_utilitas.puml` | Use case: Konversi Mata Uang, Zona Waktu, Notifikasi |

### Sequence Diagram

| No | File | Deskripsi |
|----|------|-----------|
| 1 | `seq_01_register.puml` | Registrasi akun baru (SHA-256 + salt + JWT session) |
| 2 | `seq_02_login.puml` | Login username & password (verifikasi hash + JWT) |
| 3 | `seq_03_login_biometrik.puml` | Login biometrik + fallback PIN 6 digit |
| 4 | `seq_04_logout.puml` | Logout & session cleanup |
| 5 | `seq_05_eksplorasi_detail.puml` | Jelajah budaya, lihat detail, bookmark, koleksi |
| 6 | `seq_06_cari_budaya.puml` | Search budaya (autocomplete + SQLite LIKE query) |
| 7 | `seq_07_peta_lbs.puml` | Peta budaya + LBS (GPS, Haversine, Gyroscope tilt) |
| 8 | `seq_08_kuis_mitos.puml` | Kuis Mitos & Fakta (timer, streak bonus, XP, level up) |
| 9 | `seq_09_puzzle_batik.puml` | Puzzle Batik (Flame engine, drag-drop, shake acak) |
| 10 | `seq_10_tebak_wayang.puml` | Tebak Wayang (siluet, timer, kartu koleksi) |
| 11 | `seq_11_ai_penjaga.puml` | AI Ki Dalang (Gemini chat, history, reset sesi) |
| 12 | `seq_12_konversi_mata_uang.puml` | Konversi mata uang (ExchangeRate API + cache Hive) |
| 13 | `seq_13_konversi_zona_waktu.puml` | Konversi zona waktu (WIB, WITA, WIT, London, Tokyo) |
| 14 | `seq_14_edit_profil.puml` | Edit profil (verifikasi biometrik + ubah data) |
| 15 | `seq_15_notifikasi.puml` | Notifikasi lokal (daily reminder, quest, achievement) |
| 16 | `seq_16_leaderboard.puml` | Leaderboard, riwayat kuis, pencapaian |
| 17 | `seq_17_shake_discovery.puml` | Shake discovery (accelerometer → konten acak) |
| 18 | `seq_18_session_check.puml` | Session check pada app startup (splash screen) |

### Activity Diagram

| No | File | Deskripsi |
|----|------|-----------|
| 1 | `act_1_login_register.puml` | Alur autentikasi: login, register, biometrik |
| 2 | `act_2_edit_profil.puml` | Alur edit profil dengan verifikasi biometrik |
| 3 | `act_3_eksplorasi.puml` | Alur eksplorasi budaya + game |

## 🚀 Cara Import / Render

### Online (Paling Mudah)
1. Buka [plantuml.com](https://www.plantuml.com/plantuml/uml/)
2. Copy-paste isi file `.puml`
3. Klik **Submit** → diagram langsung muncul
4. Download sebagai PNG/SVG

### VS Code Extension
1. Install extension **"PlantUML"** (jebbs.plantuml)
2. Buka file `.puml`
3. `Alt+D` untuk preview
4. `Ctrl+Shift+P` → "PlantUML: Export Current Diagram"

### StarUML / Visual Paradigm
1. File > Import > PlantUML (.puml)

### Command Line
```bash
java -jar plantuml.jar docs/diagrams/*.puml
```

## 📋 Ringkasan Sistem

### Aktor
- **Pengguna** — User utama aplikasi
- **Sistem Biometrik** — Sidik jari / Face ID (local_auth)
- **Google Gemini AI** — Chatbot Ki Dalang (google_generative_ai)
- **Google Maps API** — Peta lokasi budaya
- **Sensor Accelerometer** — Goyangkan HP untuk acak puzzle

### Teknologi
| Layer | Teknologi |
|-------|-----------|
| Framework | Flutter (Dart) |
| State Management | Riverpod |
| Navigasi | GoRouter |
| Database Lokal | Hive + SQLite |
| Keamanan | FlutterSecureStorage + SHA-256 + AES-256-CBC |
| Autentikasi | JWT Session + Biometrik + PIN |
| LBS | Geolocator + Google Maps |
| AI | Google Generative AI (Gemini) |
| Sensor | sensors_plus (Accelerometer) |
| Kamera | image_picker |
