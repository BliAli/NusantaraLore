# NusantaraLore — CLAUDE.md

> Ensiklopedia Digital Budaya Nusantara berbasis Flutter
> Tagline: *"Jelajahi Warisan, Hidupkan Legenda"*

---

## 🗂️ Project Overview

NusantaraLore adalah aplikasi mobile Flutter yang berfungsi sebagai ensiklopedia interaktif budaya Indonesia, mencakup legenda, mitos, tradisi, artefak, wayang, batik, dan kekayaan budaya Nusantara lainnya. Aplikasi ini gamified, berbasis AI, dan mendukung LBS (Location Based Service).

**Platform:** Android & iOS  
**Framework:** Flutter (Dart)  
**Min SDK:** Android 21 / iOS 13  
**Arsitektur:** Clean Architecture (Feature-first folder structure)  
**State Management:** Riverpod  
**Database Lokal:** Hive (cache & user data) + SQLite via sqflite (relational data)  
**Backend:** Supabase (opsional, untuk fitur sosial & sinkronisasi)

---

## 📁 Struktur Folder Project

```
nusantaralore/
├── lib/
│   ├── main.dart
│   ├── app.dart                         # Root widget & GoRouter setup
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart          # Palet warna utama
│   │   │   ├── app_strings.dart         # Semua string & teks UI
│   │   │   └── app_routes.dart          # Nama route konstanta
│   │   ├── database/
│   │   │   ├── hive_service.dart        # Inisialisasi & akses Hive
│   │   │   └── sqlite_service.dart      # Inisialisasi & query SQLite
│   │   ├── security/
│   │   │   ├── encryption_service.dart  # AES-256 & SHA-256
│   │   │   └── session_manager.dart     # JWT session handling
│   │   ├── network/
│   │   │   ├── api_client.dart          # Dio HTTP client
│   │   │   └── connectivity_service.dart
│   │   └── utils/
│   │       ├── date_utils.dart
│   │       └── location_utils.dart
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── auth_repository.dart
│   │   │   │   └── auth_local_datasource.dart
│   │   │   ├── domain/
│   │   │   │   ├── auth_usecase.dart
│   │   │   │   └── user_model.dart
│   │   │   └── presentation/
│   │   │       ├── login_screen.dart
│   │   │       ├── register_screen.dart
│   │   │       └── biometric_screen.dart
│   │   │
│   │   ├── home/
│   │   │   └── presentation/
│   │   │       ├── home_screen.dart
│   │   │       └── home_controller.dart
│   │   │
│   │   ├── explore/
│   │   │   ├── data/
│   │   │   │   ├── budaya_repository.dart
│   │   │   │   └── budaya_local_datasource.dart
│   │   │   ├── domain/
│   │   │   │   ├── budaya_model.dart
│   │   │   │   └── legenda_model.dart
│   │   │   └── presentation/
│   │   │       ├── explore_screen.dart
│   │   │       ├── budaya_map_screen.dart
│   │   │       └── budaya_detail_screen.dart
│   │   │
│   │   ├── games/
│   │   │   └── presentation/
│   │   │       ├── games_menu_screen.dart
│   │   │       ├── kuis_mitos_screen.dart
│   │   │       ├── puzzle_batik_screen.dart
│   │   │       └── tebak_wayang_screen.dart
│   │   │
│   │   ├── ai_penjaga/
│   │   │   ├── data/
│   │   │   │   └── gemini_repository.dart
│   │   │   └── presentation/
│   │   │       └── penjaga_screen.dart
│   │   │
│   │   ├── converter/
│   │   │   └── presentation/
│   │   │       ├── converter_screen.dart
│   │   │       ├── currency_converter.dart
│   │   │       └── timezone_converter.dart
│   │   │
│   │   ├── search/
│   │   │   └── presentation/
│   │   │       └── search_screen.dart
│   │   │
│   │   └── profile/
│   │       └── presentation/
│   │           └── profile_screen.dart
│   │
│   └── shared/
│       ├── widgets/
│       │   ├── batik_border.dart        # Ornamen batik dekoratif
│       │   ├── wayang_icon.dart         # Ikon bergaya wayang
│       │   └── loading_indicator.dart
│       └── providers/
│           └── global_providers.dart
│
├── assets/
│   ├── data/
│   │   ├── legenda.json
│   │   ├── budaya.json
│   │   ├── wayang.json
│   │   ├── batik.json
│   │   └── provinsi.json
│   ├── images/
│   └── fonts/
│
├── test/
├── pubspec.yaml
└── CLAUDE.md                            # ← file ini
```

---

## 📦 Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0

  # Navigation
  go_router: ^13.0.0

  # Database
  hive_flutter: ^1.1.0
  sqflite: ^2.3.0
  path_provider: ^2.1.0

  # Auth & Security
  local_auth: ^2.2.0              # Biometric (fingerprint/face)
  crypto: ^3.0.3                  # SHA-256 hashing
  encrypt: ^5.0.3                 # AES-256 enkripsi
  flutter_secure_storage: ^9.0.0  # Simpan key & token secara aman

  # LBS & Maps
  geolocator: ^11.0.0
  flutter_map: ^6.0.0
  latlong2: ^0.9.0
  geocoding: ^3.0.0

  # Sensor
  sensors_plus: ^4.0.0            # Accelerometer & Gyroscope
  camera: ^0.10.0                 # Kamera untuk scan batik

  # AI / LLM
  google_generative_ai: ^0.4.0    # Gemini API

  # Network
  dio: ^5.4.0
  connectivity_plus: ^5.0.0

  # Notifikasi
  flutter_local_notifications: ^17.0.0
  timezone: ^0.9.0

  # Currency API
  # (Gunakan Dio + ExchangeRate-API, tidak perlu package khusus)

  # Game Engine
  flame: ^1.15.0                  # Untuk puzzle & mini games

  # UI
  flutter_animate: ^4.5.0
  cached_network_image: ^3.3.0
  lottie: ^3.0.0                  # Animasi Lottie
  shimmer: ^3.0.0                 # Loading skeleton

  # Utilities
  intl: ^0.19.0
  uuid: ^4.3.0
  shared_preferences: ^2.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  hive_generator: ^2.0.0
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
  flutter_lints: ^3.0.0
```

---

## 🔐 Sistem Auth & Keamanan

### Aturan Enkripsi — WAJIB DIIKUTI

- Password user di-hash dengan **SHA-256 + salt unik per user** sebelum disimpan
- Salt disimpan terpisah di `flutter_secure_storage`
- Data sensitif (token, profil) dienkripsi dengan **AES-256** sebelum masuk Hive
- Session token berupa **JWT** dengan expiry 7 hari
- Refresh token disimpan di `flutter_secure_storage`, BUKAN SharedPreferences
- JANGAN simpan password plaintext di mana pun

### Biometric Flow
```
1. User login pertama kali → gunakan username + password
2. Setelah login berhasil → tawarkan aktifkan biometric
3. Login berikutnya → cek biometric tersedia → gunakan local_auth
4. Jika biometric gagal 3x → fallback ke PIN 6 digit
5. PIN tersimpan terenkripsi di flutter_secure_storage
```

### Session Management
```dart
// Session dianggap aktif jika:
// - JWT token belum expired (< 7 hari)
// - Token tersimpan di secure storage
// Auto-logout jika app tidak dibuka > 7 hari
// Cek session di app startup (main.dart → SplashScreen)
```

---

## 🗃️ Database Schema

### Hive Boxes
| Box Name | Tipe Data | Isi |
|---|---|---|
| `userBox` | Map | Profil user, preferensi, level, XP |
| `sessionBox` | String | JWT token (terenkripsi) |
| `koleksiBox` | List | ID budaya yang sudah dijelajahi |
| `bookmarkBox` | List | ID konten yang di-bookmark |
| `cacheBox` | Map | Cache response API (currency, dll) |

### SQLite Tables

```sql
-- Konten Budaya
CREATE TABLE budaya (
  id TEXT PRIMARY KEY,
  nama TEXT NOT NULL,
  provinsi TEXT,
  kategori TEXT,    -- 'legenda' | 'tradisi' | 'artefak' | 'seni' | 'kuliner'
  deskripsi TEXT,
  isi_lengkap TEXT,
  gambar_url TEXT,
  lat REAL,
  lng REAL,
  tags TEXT,        -- JSON array sebagai string
  created_at TEXT
);

-- Progress Gamifikasi
CREATE TABLE user_progress (
  user_id TEXT PRIMARY KEY,
  total_xp INTEGER DEFAULT 0,
  level INTEGER DEFAULT 1,
  badges TEXT,      -- JSON array
  streak_days INTEGER DEFAULT 0,
  last_active TEXT
);

-- Riwayat Kuis
CREATE TABLE quiz_history (
  id TEXT PRIMARY KEY,
  user_id TEXT,
  quiz_type TEXT,   -- 'mitos_fakta' | 'tebak_wayang' | 'puzzle_batik'
  skor INTEGER,
  waktu_selesai TEXT,
  FOREIGN KEY (user_id) REFERENCES user_progress(user_id)
);

-- Leaderboard
CREATE TABLE leaderboard (
  user_id TEXT PRIMARY KEY,
  username TEXT,
  total_xp INTEGER,
  rank INTEGER,
  updated_at TEXT
);
```

---

## 🗺️ LBS — Location Based Service

### Implementasi
- Gunakan `geolocator` untuk ambil koordinat user
- Gunakan `flutter_map` dengan tile OpenStreetMap (GRATIS, tidak butuh billing)
- Marker pada peta menunjukkan lokasi asal budaya (dari field `lat`/`lng` di SQLite)
- Filter "Terdekat" → hitung jarak Haversine antara koordinat user dan koordinat budaya
- Tampilkan max 10 budaya terdekat di Home Screen

### Permission Handling
```dart
// Selalu minta permission secara graceful
// Jika user tolak → tampilkan UI fallback (browse by provinsi)
// JANGAN crash jika GPS tidak tersedia
```

---

## 🤖 AI Penjaga — Gemini Integration

### Konfigurasi
- Model: `gemini-1.5-flash` (gratis, cukup untuk project)
- API Key: simpan di `.env` file, JANGAN hardcode di source code
- Baca API key dengan `flutter_dotenv` atau environment variable

### System Prompt "Ki Dalang"
```
Kamu adalah Ki Dalang, seorang penjaga budaya Nusantara yang bijaksana dan ramah.
Kamu memiliki pengetahuan mendalam tentang legenda, mitos, tradisi, wayang, batik,
dan seluruh kekayaan budaya Indonesia. Jawab semua pertanyaan dalam Bahasa Indonesia
yang baik. Sesekali gunakan sapaan atau kata dalam bahasa Jawa halus (krama) untuk
memberikan kesan autentik, seperti "Nggih", "Matur nuwun", "Sugeng rawuh".
Jangan pernah keluar dari karakter sebagai Ki Dalang.
```

### Fitur AI
1. **Tanya Budaya** — user tanya → Gemini jawab dalam karakter Ki Dalang
2. **Ceritakan Legenda** — generate narasi dinamis dari nama legenda
3. **Roleplay Tokoh** — user bicara dengan tokoh legenda (Gatotkaca, Sangkuriang, dll)
4. **Analisis Gambar** — gunakan Gemini Vision untuk identifikasi motif batik dari foto
5. **Generate Cerita** — user input daerah + tokoh → AI buat cerita rakyat baru

### Context Management
- Simpan max **10 pesan terakhir** per sesi sebagai history
- Reset history saat user mulai topik baru
- JANGAN kirim seluruh database budaya ke Gemini — cukup kirim konteks relevan

---

## 🎮 Mini Games

### 1. Kuis Mitos vs Fakta
- Data soal dari `assets/data/kuis.json`
- Timer 30 detik per soal dengan CountdownTimer widget
- Scoring: jawaban benar = +10 XP, streak 3x = bonus +20 XP
- Gunakan `flutter_animate` untuk transisi soal

### 2. Puzzle Batik
- Engine: **Flame** (bukan Flutter biasa — Flame lebih cocok untuk drag-drop game)
- Potong gambar batik menjadi 9/16 tiles (tergantung level)
- Sensor Accelerometer → shake device → acak ulang posisi tiles
- Reward: unlock motif batik baru di koleksi

### 3. Tebak Wayang
- Tampilkan siluet/shadow wayang → pilih 4 opsi jawaban
- Timer 20 detik, makin cepat = makin banyak poin
- Reward: kartu koleksi tokoh wayang

### Leaderboard
- Data leaderboard disimpan lokal di SQLite
- Sort by total XP descending
- Tampilkan Top 10 dengan avatar & level

---

## 📡 Sensor Implementation

### Accelerometer (`sensors_plus`)
```dart
// Gunakan untuk:
// 1. Shake detection → discovery mode (random konten)
// 2. Shake di puzzle → reset posisi tiles
// Threshold shake: magnitude > 15 m/s²
// Debounce: min 1 detik antara dua shake event
```

### Gyroscope (`sensors_plus`)
```dart
// Gunakan untuk:
// 1. Tilt detection → rotasi peta budaya
// 2. Animasi interaktif di peta
// Update rate: normal mode (tidak perlu game mode)
```

---

## 🔄 Konverter

### Konversi Mata Uang
- API: **ExchangeRate-API** (`https://api.exchangerate-api.com/v4/latest/IDR`)
- Cache hasil di `cacheBox` Hive dengan TTL 1 jam
- Mata uang: IDR, USD, EUR, MYR, SGD
- Konteks UI: "Estimasi harga souvenir / tiket pertunjukan"
- Jika API gagal → tampilkan data cache terakhir + timestamp

### Konversi Zona Waktu
- Gunakan package `timezone` (sudah include timezone data)
- Zona waktu yang didukung:
  - `Asia/Jakarta` → WIB (UTC+7)
  - `Asia/Makassar` → WITA (UTC+8)
  - `Asia/Jayapura` → WIT (UTC+9)
  - `Europe/London` → London (GMT/BST)
  - `Asia/Tokyo` → Tokyo/JST (UTC+9) — bonus
- Konteks UI: "Jadwal festival & pertunjukan budaya"

---

## 🔔 Notifikasi

### Tipe Notifikasi
```dart
// 1. Daily Reminder (scheduled, tiap pagi jam 08.00)
//    → "Budaya Hari Ini: [nama budaya acak]"

// 2. Quest Reminder (scheduled, tiap hari jam 19.00)
//    → "Kamu belum menyelesaikan daily quest hari ini!"

// 3. Achievement Notification (triggered on event)
//    → "Selamat! Kamu naik ke Level [X]!"
//    → "Badge baru terbuka: [nama badge]"

// 4. LBS Notification (triggered by geofence — opsional)
//    → "Kamu berada dekat asal legenda [nama]!"
```

### Setup
- Gunakan `flutter_local_notifications` untuk semua notifikasi lokal
- Minta permission notifikasi saat onboarding
- Jangan spam notifikasi — max 2 notif/hari untuk reminder

---

## 🔍 Fitur Search

### Scope Search
- Search by: nama budaya, nama legenda, nama tokoh, nama provinsi, tag
- Hasil dari SQLite menggunakan `LIKE '%query%'` query
- Search history disimpan di Hive (max 10 history terbaru)
- Autocomplete dari data lokal SQLite

### UI Search
- SearchBar selalu visible di Explore screen
- Hasil dikelompokkan: Legenda | Tradisi | Artefak | Seni
- Empty state jika tidak ada hasil → tampilkan saran konten populer

---

## 🎨 Design System

### Palet Warna
```dart
// Wajib gunakan konstanta dari app_colors.dart
// JANGAN hardcode warna di widget

const kColorPrimary    = Color(0xFF8B1A1A);  // Merah Batik
const kColorSecondary  = Color(0xFFD4A017);  // Emas Keraton
const kColorBackground = Color(0xFFFDF6E3);  // Krem Kertas Kuno
const kColorAccent     = Color(0xFF2C5F2E);  // Hijau Daun Jati
const kColorText       = Color(0xFF1A1A1A);  // Hitam Pekat
const kColorTextLight  = Color(0xFF6B6B6B);  // Abu-abu
```

### Typography
```dart
// Heading  → Cinzel Decorative (nuansa klasik, untuk judul besar)
// Body     → Nunito (modern, mudah dibaca, untuk konten)
// Caption  → Nunito Light
```

### Komponen UI
- Gunakan ornamen batik sebagai border/divider di `batik_border.dart`
- Card konten budaya selalu memiliki corner radius 12px
- Ikon navigasi bergaya wayang/shadow puppet
- Loading state gunakan Shimmer skeleton, BUKAN CircularProgressIndicator biasa

---

## 🧭 Navigasi (GoRouter)

### Route Structure
```dart
// Routes:
// /splash          → SplashScreen (cek session)
// /login           → LoginScreen
// /register        → RegisterScreen
// /home            → HomeScreen (shell route dengan bottom nav)
// /home/explore    → ExploreScreen
// /home/explore/:id → BudayaDetailScreen
// /home/map        → BudayaMapScreen
// /home/games      → GamesMenuScreen
// /home/games/kuis → KuisMitosScreen
// /home/games/puzzle → PuzzleBatikScreen
// /home/games/wayang → TebakWayangScreen
// /home/penjaga    → PenjagaScreen (AI Chat)
// /home/converter  → ConverterScreen
// /home/search     → SearchScreen
// /home/profile    → ProfileScreen
```

### Bottom Navigation
5 tab utama: **Home | Jelajah | Arena | Penjaga | Profil**

---

## 📊 Data Konten (JSON Lokal)

### Format `assets/data/legenda.json`
```json
{
  "legenda": [
    {
      "id": "LGD001",
      "judul": "Roro Jonggrang",
      "asal": "Yogyakarta",
      "provinsi": "DI Yogyakarta",
      "koordinat": { "lat": -7.752, "lng": 110.491 },
      "kategori": "legenda",
      "tokoh": ["Roro Jonggrang", "Bandung Bondowoso"],
      "ringkasan": "Kisah putri cantik yang dikutuk menjadi arca...",
      "isi_lengkap": "...",
      "gambar": "assets/images/legenda/roro_jonggrang.jpg",
      "tags": ["cinta", "kutukan", "candi", "jawa", "yogyakarta"]
    }
  ]
}
```

### Populate Data
- Minimal **30 konten** dari berbagai provinsi untuk demo yang layak
- Pastikan representasi setiap pulau besar: Jawa, Sumatra, Kalimantan, Sulawesi, Bali, Papua
- Fokuskan konten Yogyakarta & Jawa untuk demo LBS (karena developer di Yogyakarta)

---

## ✅ Checklist Kriteria Project

Pastikan semua kriteria berikut terpenuhi sebelum demo:

- [ ] **Login dengan enkripsi** — SHA-256 + AES-256, tanpa Firebase
- [ ] **Session management** — JWT, auto-logout 7 hari
- [ ] **Biometric login** — fingerprint/face via `local_auth`
- [ ] **Database** — Hive (cache) + SQLite (konten & gamifikasi)
- [ ] **LBS** — peta budaya berdasarkan lokasi, "budaya terdekat"
- [ ] **Mini games** — minimal 2 game (Kuis Mitos + Tebak Wayang)
- [ ] **Navigasi menu** — Bottom NavigationBar 5 tab + GoRouter
- [ ] **Konversi mata uang** — IDR, USD, EUR, MYR, SGD (min 3)
- [ ] **Konversi waktu** — WIB, WITA, WIT, London (wajib), Tokyo (bonus)
- [ ] **Sensor 1** — Accelerometer (shake untuk discovery/puzzle)
- [ ] **Sensor 2** — Gyroscope (tilt untuk peta / interaksi)
- [ ] **AI/LLM** — Gemini API sebagai "Ki Dalang"
- [ ] **Fitur search** — cari konten budaya dengan SQLite LIKE query
- [ ] **Notifikasi** — daily reminder + achievement notification

---

## ⚠️ Aturan Penting

1. **API Key** → JANGAN hardcode. Simpan di `.env`, tambahkan `.env` ke `.gitignore`
2. **Error handling** → Semua API call wajib ada try-catch + fallback UI
3. **Offline mode** → App harus tetap bisa buka konten lokal tanpa internet
4. **TIDAK menggunakan Firebase** untuk enkripsi/auth (sesuai kriteria project)
5. **Permission** → Selalu minta GPS & kamera permission secara graceful dengan penjelasan
6. **Testing** → Jalankan `flutter analyze` dan pastikan 0 error sebelum commit

---

## 🚀 Quick Start Commands

```bash
# Install dependencies
flutter pub get

# Generate Hive adapters & Riverpod providers
dart run build_runner build --delete-conflicting-outputs

# Run di emulator/device
flutter run

# Build APK release
flutter build apk --release

# Analisis kode
flutter analyze

# Jalankan test
flutter test
```

---

## 📞 API Keys & Environment

Buat file `.env` di root project (jangan di-commit ke git):
```
GEMINI_API_KEY=your_gemini_api_key_here
EXCHANGERATE_API_KEY=your_exchangerate_api_key_here
```

Tambahkan ke `.gitignore`:
```
.env
*.env
```

---

*File ini dibuat sebagai panduan pengembangan NusantaraLore untuk Project Akhir Teknologi Pemrograman Mobile.*
