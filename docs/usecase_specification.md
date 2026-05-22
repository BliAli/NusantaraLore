# Use Case Diagram & Spesifikasi Use Case
## Aplikasi NusantaraLore - Ensiklopedia Digital Budaya Nusantara

---

## 1.4.1 Use Case Diagram

Use Case Diagram merupakan diagram yang menggambarkan interaksi antara aktor (pengguna) dengan sistem Nusantara Lore untuk menunjukkan fungsi-fungsi yang tersedia. Aktor utama dalam sistem ini adalah Pengguna, yang berinteraksi dengan berbagai fungsionalitas inti aplikasi. Selain itu, terdapat aktor sekunder berupa sistem eksternal seperti Google Gemini AI, OpenStreetMap, ExchangeRate API, serta perangkat keras (sensor accelerometer, gyroscope, dan sistem biometrik).

*(Sisipkan gambar hasil render dari file `1_usecase_diagram.puml` di sini)*

**Gambar 1.4.1.1** Use Case Diagram NusantaraLore

---

### Identifikasi Aktor

| No | Aktor | Tipe | Deskripsi |
|---|---|---|---|
| 1 | Pengguna | Primer | Pengguna aplikasi yang mengakses seluruh fitur ensiklopedia budaya, mini-games, AI chat, peta budaya, dan utilitas konversi |
| 2 | Google Gemini AI | Sekunder (Sistem) | Layanan AI generatif dari Google yang menyediakan kemampuan percakapan untuk fitur "Ki Dalang" (AI Penjaga Budaya) |
| 3 | OpenStreetMap (flutter_map) | Sekunder (Sistem) | Penyedia tile peta gratis yang digunakan untuk menampilkan peta persebaran budaya Nusantara |
| 4 | ExchangeRate API | Sekunder (Sistem) | Layanan API konversi mata uang untuk fitur estimasi harga souvenir/tiket pertunjukan budaya |
| 5 | Sensor Accelerometer | Sekunder (Hardware) | Sensor perangkat mobile yang mendeteksi goyangan (shake) untuk fitur acak puzzle dan discovery mode |
| 6 | Sensor Gyroscope | Sekunder (Hardware) | Sensor perangkat mobile yang mendeteksi kemiringan (tilt) untuk fitur rotasi peta budaya |
| 7 | Sistem Biometrik | Sekunder (Hardware) | Modul biometrik perangkat (sidik jari / Face ID) untuk autentikasi dan verifikasi pengguna |

---

### Daftar Use Case

| No | Kode UC | Nama Use Case | Paket / Modul |
|---|---|---|---|
| 1 | UC-01 | Login | Autentikasi |
| 2 | UC-02 | Register | Autentikasi |
| 3 | UC-03 | Logout | Autentikasi |
| 4 | UC-04 | Login Biometrik | Autentikasi |
| 5 | UC-05 | Setup PIN Cadangan | Autentikasi |
| 6 | UC-06 | Hash Password (SHA-256) | Autentikasi |
| 7 | UC-07 | Kelola Session (JWT) | Autentikasi |
| 8 | UC-08 | Jelajah Legenda | Eksplorasi Budaya |
| 9 | UC-09 | Lihat Detail Budaya | Eksplorasi Budaya |
| 10 | UC-10 | Cari Budaya | Eksplorasi Budaya |
| 11 | UC-11 | Tambah ke Bookmark | Eksplorasi Budaya |
| 12 | UC-12 | Tambah ke Koleksi | Eksplorasi Budaya |
| 13 | UC-13 | Lihat Peta Budaya | Peta Budaya (LBS) |
| 14 | UC-14 | Lihat Budaya Terdekat | Peta Budaya (LBS) |
| 15 | UC-15 | Tilt Rotasi Peta | Peta Budaya (LBS) |
| 16 | UC-16 | Main Kuis Mitos & Fakta | Arena Budaya (Games) |
| 17 | UC-17 | Main Puzzle Batik | Arena Budaya (Games) |
| 18 | UC-18 | Main Tebak Wayang | Arena Budaya (Games) |
| 19 | UC-19 | Lihat Leaderboard | Arena Budaya (Games) |
| 20 | UC-20 | Goyangkan HP Untuk Acak Puzzle | Arena Budaya (Games) |
| 21 | UC-21 | Tanya Jawab Budaya dengan AI | AI Penjaga (Ki Dalang) |
| 22 | UC-22 | Ceritakan Legenda | AI Penjaga (Ki Dalang) |
| 23 | UC-23 | Reset Sesi Percakapan | AI Penjaga (Ki Dalang) |
| 24 | UC-24 | Lihat Profil | Profil & Pengaturan |
| 25 | UC-25 | Edit Username | Profil & Pengaturan |
| 26 | UC-26 | Edit Password | Profil & Pengaturan |
| 27 | UC-27 | Ubah Foto Profil | Profil & Pengaturan |
| 28 | UC-28 | Verifikasi Biometrik Sebelum Edit | Profil & Pengaturan |
| 29 | UC-29 | Lihat Bookmark | Profil & Pengaturan |
| 30 | UC-30 | Lihat Riwayat Kuis | Profil & Pengaturan |
| 31 | UC-31 | Konversi Mata Uang | Utilitas |
| 32 | UC-32 | Konversi Zona Waktu | Utilitas |
| 33 | UC-33 | Dapatkan XP | Gamifikasi |
| 34 | UC-34 | Naik Level | Gamifikasi |
| 35 | UC-35 | Lihat Pencapaian | Gamifikasi |
| 36 | UC-36 | Terima Daily Reminder | Notifikasi |
| 37 | UC-37 | Terima Notifikasi Achievement | Notifikasi |
| 38 | UC-38 | Atur Pengingat Harian | Notifikasi |
| 39 | UC-39 | Shake Discovery (Konten Acak) | Discovery Mode |

---

### Relasi Antar Use Case

#### Relasi <<include>> (Wajib Terjadi)

| Use Case Sumber | Use Case Tujuan | Keterangan |
|---|---|---|
| UC-01 Login | UC-06 Hash Password (SHA-256) | Login wajib melakukan hashing password untuk validasi |
| UC-01 Login | UC-07 Kelola Session (JWT) | Login berhasil wajib membuat JWT session token |
| UC-02 Register | UC-06 Hash Password (SHA-256) | Registrasi wajib meng-hash password sebelum disimpan |
| UC-02 Register | UC-07 Kelola Session (JWT) | Setelah registrasi berhasil, session langsung dibuat |
| UC-04 Login Biometrik | UC-07 Kelola Session (JWT) | Login biometrik berhasil wajib mengambil session JWT tersimpan |
| UC-25 Edit Username | UC-28 Verifikasi Biometrik | Sebelum edit username, pengguna wajib verifikasi biometrik |
| UC-26 Edit Password | UC-28 Verifikasi Biometrik | Sebelum edit password, pengguna wajib verifikasi biometrik |
| UC-26 Edit Password | UC-06 Hash Password (SHA-256) | Password baru wajib di-hash sebelum disimpan |
| UC-27 Ubah Foto Profil | UC-28 Verifikasi Biometrik | Sebelum ubah foto, pengguna wajib verifikasi biometrik |
| UC-16 Main Kuis Mitos & Fakta | UC-33 Dapatkan XP | Menyelesaikan kuis otomatis memberikan XP |
| UC-17 Main Puzzle Batik | UC-33 Dapatkan XP | Menyelesaikan puzzle otomatis memberikan XP |
| UC-18 Main Tebak Wayang | UC-33 Dapatkan XP | Menyelesaikan tebak wayang otomatis memberikan XP |
| UC-33 Dapatkan XP | UC-34 Naik Level | XP yang terkumpul otomatis dihitung untuk kenaikan level |
| UC-21 Tanya Jawab Budaya | UC-23 Reset Sesi Percakapan | Sesi chat otomatis di-reset jika topik baru dimulai |

#### Relasi <<extend>> (Opsional / Kondisional)

| Use Case Dasar | Use Case Ekstensi | Kondisi |
|---|---|---|
| UC-01 Login | UC-04 Login Biometrik | Jika pengguna sudah pernah mengaktifkan biometrik |
| UC-01 Login | UC-05 Setup PIN Cadangan | Jika login pertama kali dan pengguna memilih aktifkan biometrik |
| UC-17 Main Puzzle Batik | UC-20 Goyangkan HP Acak Puzzle | Jika pengguna menggoyangkan perangkat saat bermain puzzle |
| UC-33 Dapatkan XP | UC-35 Lihat Pencapaian | Jika XP mencapai milestone tertentu (100/500/1000 XP) |
| UC-35 Lihat Pencapaian | UC-37 Notifikasi Achievement | Jika pengguna unlock badge baru atau naik level |
| UC-13 Lihat Peta Budaya | UC-15 Tilt Rotasi Peta | Jika pengguna memiringkan perangkat (sensor gyroscope aktif) |
| UC-38 Atur Pengingat Harian | UC-36 Terima Daily Reminder | Jika pengguna mengaktifkan notifikasi pengingat |
| UC-08 Jelajah Legenda | UC-39 Shake Discovery | Jika pengguna menggoyangkan perangkat di halaman eksplorasi |
| UC-21 Tanya Jawab Budaya | UC-22 Ceritakan Legenda | Jika pengguna meminta AI menceritakan legenda tertentu |

---

## Spesifikasi Use Case (Detail)

### UC-01: Login

| Elemen | Deskripsi |
|---|---|
| **Kode** | UC-01 |
| **Nama** | Login |
| **Aktor** | Pengguna |
| **Deskripsi** | Pengguna masuk ke dalam sistem menggunakan username dan password yang telah terdaftar |
| **Pre-condition** | Pengguna sudah memiliki akun terdaftar di sistem; Aplikasi menampilkan halaman login |
| **Post-condition** | Pengguna berhasil masuk dan diarahkan ke halaman Home |
| **Relasi** | <<include>> UC-06 Hash Password, <<include>> UC-07 Kelola Session; <<extend>> UC-04 Login Biometrik, <<extend>> UC-05 Setup PIN |
| **Skenario Utama** | 1. Pengguna membuka aplikasi NusantaraLore |
| | 2. Sistem menampilkan halaman login |
| | 3. Pengguna memasukkan username dan password |
| | 4. Pengguna menekan tombol "Masuk" |
| | 5. Sistem melakukan hashing password dengan SHA-256 + salt |
| | 6. Sistem memvalidasi kredensial dengan data di Hive |
| | 7. Sistem membuat JWT session token |
| | 8. Sistem menyimpan token di flutter_secure_storage |
| | 9. Sistem mengarahkan pengguna ke halaman Home |
| **Skenario Alternatif** | **5a.** Jika biometrik aktif, sistem menampilkan opsi Login Biometrik |
| | **7a.** Jika login pertama kali, sistem menawarkan Setup PIN Cadangan |
| **Skenario Gagal** | **6a.** Username tidak ditemukan → Tampilkan pesan "Pengguna tidak ditemukan" |
| | **6b.** Password salah → Tampilkan pesan "Login Gagal" |

---

### UC-02: Register

| Elemen | Deskripsi |
|---|---|
| **Kode** | UC-02 |
| **Nama** | Register |
| **Aktor** | Pengguna |
| **Deskripsi** | Pengguna mendaftarkan akun baru ke dalam sistem dengan mengisi data diri |
| **Pre-condition** | Pengguna belum memiliki akun; Aplikasi menampilkan halaman register |
| **Post-condition** | Akun baru berhasil dibuat; Pengguna otomatis login dan masuk ke halaman Home |
| **Relasi** | <<include>> UC-06 Hash Password, <<include>> UC-07 Kelola Session |
| **Skenario Utama** | 1. Pengguna menekan tombol "Daftar" di halaman login |
| | 2. Sistem menampilkan form registrasi |
| | 3. Pengguna mengisi username, email, dan password |
| | 4. Pengguna menekan tombol "Daftar" |
| | 5. Sistem memvalidasi kelengkapan dan format data |
| | 6. Sistem men-generate salt unik dan menyimpan di secure storage |
| | 7. Sistem melakukan hashing password dengan SHA-256 + salt |
| | 8. Sistem menyimpan data pengguna ke Hive |
| | 9. Sistem membuat JWT session token dan menyimpannya |
| | 10. Sistem mengarahkan pengguna ke halaman Home |
| **Skenario Gagal** | **5a.** Username sudah terdaftar → Tampilkan pesan "Username sudah digunakan" |
| | **5b.** Format data tidak valid → Tampilkan pesan error validasi |

---

### UC-04: Login Biometrik

| Elemen | Deskripsi |
|---|---|
| **Kode** | UC-04 |
| **Nama** | Login Biometrik |
| **Aktor** | Pengguna, Sistem Biometrik |
| **Deskripsi** | Pengguna masuk ke sistem menggunakan sidik jari atau Face ID tanpa memasukkan password |
| **Pre-condition** | Pengguna sudah mengaktifkan fitur biometrik; Perangkat mendukung biometrik |
| **Post-condition** | Pengguna berhasil login dan diarahkan ke halaman Home |
| **Relasi** | <<extend>> UC-01 Login; <<include>> UC-07 Kelola Session |
| **Skenario Utama** | 1. Sistem mendeteksi biometrik aktif untuk akun pengguna |
| | 2. Sistem menampilkan dialog autentikasi biometrik |
| | 3. Pengguna melakukan scan sidik jari / Face ID |
| | 4. Sistem Biometrik memverifikasi identitas pengguna |
| | 5. Sistem mengambil JWT token tersimpan dari secure storage |
| | 6. Sistem mengarahkan pengguna ke halaman Home |
| **Skenario Gagal** | **4a.** Biometrik gagal → Sistem meminta coba lagi (max 3 kali) |
| | **4b.** Biometrik gagal 3 kali → Fallback ke input PIN 6 digit |
| | **4c.** PIN salah → Tampilkan pesan error, kembali ke login manual |

---

### UC-08: Jelajah Legenda

| Elemen | Deskripsi |
|---|---|
| **Kode** | UC-08 |
| **Nama** | Jelajah Legenda |
| **Aktor** | Pengguna |
| **Deskripsi** | Pengguna menjelajahi daftar legenda dan cerita rakyat Nusantara yang tersimpan di database lokal |
| **Pre-condition** | Pengguna sudah login; Data legenda tersedia di assets JSON / SQLite |
| **Post-condition** | Daftar legenda ditampilkan; Pengguna dapat memilih legenda untuk dilihat detailnya |
| **Relasi** | <<extend>> UC-39 Shake Discovery |
| **Skenario Utama** | 1. Pengguna membuka menu "Jelajah" dari bottom navigation |
| | 2. Sistem memuat data legenda dari `assets/data/legenda.json` |
| | 3. Sistem menampilkan daftar legenda dalam bentuk card (gambar, judul, asal daerah) |
| | 4. Pengguna dapat melakukan scroll untuk melihat lebih banyak konten |
| | 5. Pengguna mengetuk salah satu card legenda |
| | 6. Sistem membuka halaman Detail Budaya (UC-09) |
| **Skenario Alternatif** | **3a.** Pengguna menggoyangkan perangkat → Tampilkan konten acak (UC-39 Shake Discovery) |

---

### UC-10: Cari Budaya

| Elemen | Deskripsi |
|---|---|
| **Kode** | UC-10 |
| **Nama** | Cari Budaya |
| **Aktor** | Pengguna |
| **Deskripsi** | Pengguna melakukan pencarian konten budaya berdasarkan kata kunci |
| **Pre-condition** | Pengguna sudah login; Data budaya tersedia di SQLite |
| **Post-condition** | Hasil pencarian ditampilkan dan dikelompokkan berdasarkan kategori |
| **Skenario Utama** | 1. Pengguna mengetuk ikon pencarian di halaman Explore |
| | 2. Sistem menampilkan SearchBar dengan keyboard aktif |
| | 3. Pengguna mengetik kata kunci (nama budaya / legenda / tokoh / provinsi) |
| | 4. Sistem melakukan query SQLite `LIKE '%query%'` |
| | 5. Sistem menampilkan hasil dikelompokkan: Legenda, Tradisi, Artefak, Seni |
| | 6. Sistem menyimpan riwayat pencarian ke Hive (max 10 history) |
| **Skenario Alternatif** | **5a.** Tidak ada hasil → Tampilkan empty state dengan saran konten populer |

---

### UC-13: Lihat Peta Budaya

| Elemen | Deskripsi |
|---|---|
| **Kode** | UC-13 |
| **Nama** | Lihat Peta Budaya |
| **Aktor** | Pengguna, OpenStreetMap |
| **Deskripsi** | Pengguna melihat persebaran lokasi asal budaya Nusantara pada peta interaktif |
| **Pre-condition** | Pengguna sudah login; GPS permission diberikan (opsional); Data koordinat budaya tersedia |
| **Post-condition** | Peta ditampilkan dengan marker lokasi budaya; Pengguna dapat tap marker untuk lihat info |
| **Relasi** | <<extend>> UC-15 Tilt Rotasi Peta |
| **Skenario Utama** | 1. Pengguna membuka menu Peta Budaya |
| | 2. Sistem meminta izin akses GPS (jika belum diberikan) |
| | 3. Pengguna mengizinkan akses GPS |
| | 4. Sistem mendapatkan koordinat lokasi pengguna via Geolocator |
| | 5. Sistem memuat tile peta dari OpenStreetMap via flutter_map |
| | 6. Sistem menampilkan marker pada koordinat setiap budaya (dari field lat/lng di SQLite) |
| | 7. Pengguna mengetuk marker → Tampilkan info singkat budaya |
| | 8. Pengguna memiringkan perangkat → Peta berotasi (UC-15, opsional) |
| **Skenario Alternatif** | **3a.** Pengguna menolak GPS → Tampilkan UI fallback "Browse by Provinsi" tanpa crash |

---

### UC-14: Lihat Budaya Terdekat

| Elemen | Deskripsi |
|---|---|
| **Kode** | UC-14 |
| **Nama** | Lihat Budaya Terdekat |
| **Aktor** | Pengguna, OpenStreetMap |
| **Deskripsi** | Sistem menghitung dan menampilkan 10 budaya terdekat dari lokasi pengguna menggunakan rumus Haversine |
| **Pre-condition** | GPS permission diberikan; Koordinat pengguna berhasil didapatkan |
| **Post-condition** | Daftar 10 budaya terdekat ditampilkan di Home Screen beserta jarak |
| **Skenario Utama** | 1. Sistem mendapatkan koordinat GPS pengguna |
| | 2. Sistem menghitung jarak Haversine antara koordinat pengguna dan koordinat setiap budaya |
| | 3. Sistem mengurutkan berdasarkan jarak terdekat |
| | 4. Sistem menampilkan maksimal 10 budaya terdekat di Home Screen |
| | 5. Pengguna dapat mengetuk item untuk melihat detail budaya |

---

### UC-16: Main Kuis Mitos & Fakta

| Elemen | Deskripsi |
|---|---|
| **Kode** | UC-16 |
| **Nama** | Main Kuis Mitos & Fakta |
| **Aktor** | Pengguna |
| **Deskripsi** | Pengguna menjawab kuis untuk menentukan apakah pernyataan tentang budaya Nusantara adalah mitos atau fakta |
| **Pre-condition** | Pengguna sudah login; Data soal tersedia di `assets/data/kuis.json` |
| **Post-condition** | Skor kuis disimpan di SQLite `quiz_history`; XP diberikan (UC-33) |
| **Relasi** | <<include>> UC-33 Dapatkan XP |
| **Skenario Utama** | 1. Pengguna memilih "Kuis Mitos & Fakta" dari menu Arena Budaya |
| | 2. Sistem memuat dan mengacak 10 soal dari database |
| | 3. Sistem menampilkan pernyataan pertama dengan timer 30 detik |
| | 4. Pengguna memilih jawaban "Mitos" atau "Fakta" |
| | 5. Sistem menampilkan feedback benar/salah dengan animasi (flutter_animate) |
| | 6. Langkah 3-5 diulang untuk setiap soal |
| | 7. Sistem menampilkan hasil akhir (skor, benar/total) |
| | 8. Sistem menyimpan skor ke `quiz_history` dan memberikan XP |
| | 9. Scoring: jawaban benar = +10 XP, streak 3x berturut-turut = bonus +20 XP |
| **Skenario Alternatif** | **4a.** Timer habis → Jawaban dianggap salah, lanjut soal berikutnya |

---

### UC-17: Main Puzzle Batik

| Elemen | Deskripsi |
|---|---|
| **Kode** | UC-17 |
| **Nama** | Main Puzzle Batik |
| **Aktor** | Pengguna, Sensor Accelerometer |
| **Deskripsi** | Pengguna menyusun potongan gambar batik yang diacak menggunakan mekanisme drag & drop berbasis Flame Engine |
| **Pre-condition** | Pengguna sudah login; Gambar batik tersedia di assets |
| **Post-condition** | Puzzle terselesaikan; Motif batik baru di-unlock di koleksi; XP diberikan |
| **Relasi** | <<include>> UC-33 Dapatkan XP; <<extend>> UC-20 Goyangkan HP |
| **Skenario Utama** | 1. Pengguna memilih "Puzzle Batik" dari menu Arena Budaya |
| | 2. Sistem memilih gambar batik secara acak |
| | 3. Sistem memotong gambar menjadi 9 tiles (3x3) dan mengacak posisinya |
| | 4. Pengguna melakukan drag & drop tile ke posisi yang benar |
| | 5. Sistem memeriksa apakah puzzle sudah tersusun dengan benar |
| | 6. Puzzle selesai → Sistem menampilkan gambar utuh + info motif batik |
| | 7. Sistem menyimpan hasil dan memberikan XP |
| **Skenario Alternatif** | **4a.** Pengguna menggoyangkan HP (magnitude > 15 m/s²) → Posisi tile diacak ulang (UC-20) |

---

### UC-18: Main Tebak Wayang

| Elemen | Deskripsi |
|---|---|
| **Kode** | UC-18 |
| **Nama** | Main Tebak Wayang |
| **Aktor** | Pengguna |
| **Deskripsi** | Pengguna menebak nama tokoh wayang berdasarkan siluet/shadow yang ditampilkan |
| **Pre-condition** | Pengguna sudah login; Data wayang tersedia di `assets/data/wayang.json` |
| **Post-condition** | Skor disimpan; Kartu koleksi tokoh wayang di-unlock; XP diberikan |
| **Relasi** | <<include>> UC-33 Dapatkan XP |
| **Skenario Utama** | 1. Pengguna memilih "Tebak Wayang" dari menu Arena Budaya |
| | 2. Sistem mengacak 8 gambar wayang dari database |
| | 3. Sistem menampilkan siluet wayang pertama dengan timer 20 detik dan 4 opsi jawaban |
| | 4. Pengguna memilih salah satu jawaban (A/B/C/D) |
| | 5. Jika benar → Tampilkan "Benar!" + deskripsi tokoh; score += 10 + time bonus |
| | 6. Jika salah/timeout → Tampilkan "Salah!" / "Waktu Habis" + jawaban yang benar |
| | 7. Langkah 3-6 diulang untuk 8 soal |
| | 8. Sistem menampilkan hasil akhir (skor, akurasi, benar/total) |
| | 9. Sistem menyimpan hasil dan memberikan XP |

---

### UC-21: Tanya Jawab Budaya dengan AI

| Elemen | Deskripsi |
|---|---|
| **Kode** | UC-21 |
| **Nama** | Tanya Jawab Budaya dengan AI |
| **Aktor** | Pengguna, Google Gemini AI |
| **Deskripsi** | Pengguna berinteraksi dengan chatbot AI "Ki Dalang" untuk bertanya seputar budaya, legenda, mitos, wayang, batik, dan tradisi Nusantara |
| **Pre-condition** | Pengguna sudah login; Koneksi internet tersedia; API key Gemini valid |
| **Post-condition** | Percakapan ditampilkan dalam format bubble chat; Max 10 pesan terakhir disimpan per sesi |
| **Relasi** | <<include>> UC-23 Reset Sesi; <<extend>> UC-22 Ceritakan Legenda |
| **Skenario Utama** | 1. Pengguna membuka menu "Penjaga" dari bottom navigation |
| | 2. Sistem memeriksa apakah sesi chat sudah ada |
| | 3. Jika belum → Sistem inisialisasi GenerativeModel (gemini-1.5-flash) dengan system prompt "Ki Dalang" |
| | 4. Sistem menampilkan riwayat percakapan (jika ada) |
| | 5. Pengguna mengetik pertanyaan dan menekan kirim |
| | 6. Sistem menampilkan typing indicator |
| | 7. Sistem mengirim pertanyaan ke Gemini API beserta konteks relevan |
| | 8. AI merespons dalam karakter Ki Dalang (Bahasa Indonesia + sapaan Jawa halus) |
| | 9. Sistem menampilkan respons dalam bubble chat |
| **Skenario Alternatif** | **5a.** Pengguna meminta cerita legenda tertentu → AI generate narasi dinamis (UC-22) |
| | **5b.** Pengguna memulai topik baru → Reset history percakapan (UC-23) |
| **Skenario Gagal** | **7a.** API call gagal → Tampilkan pesan error + tombol retry |
| | **7b.** Tidak ada internet → Tampilkan pesan "Koneksi diperlukan untuk fitur AI" |

---

### UC-25: Edit Username

| Elemen | Deskripsi |
|---|---|
| **Kode** | UC-25 |
| **Nama** | Edit Username |
| **Aktor** | Pengguna, Sistem Biometrik |
| **Deskripsi** | Pengguna mengubah username akunnya setelah melalui verifikasi biometrik |
| **Pre-condition** | Pengguna sudah login; Biometrik aktif di perangkat |
| **Post-condition** | Username berhasil diperbarui di database |
| **Relasi** | <<include>> UC-28 Verifikasi Biometrik |
| **Skenario Utama** | 1. Pengguna membuka halaman Edit Profil |
| | 2. Sistem melakukan verifikasi biometrik (UC-28) |
| | 3. Verifikasi berhasil → Formulir edit ditampilkan |
| | 4. Pengguna memasukkan username baru |
| | 5. Pengguna menekan "Simpan" |
| | 6. Sistem memvalidasi keunikan username |
| | 7. Sistem memperbarui data di Hive |
| | 8. Sistem menampilkan SnackBar "Username berhasil diubah" |
| **Skenario Gagal** | **2a.** Verifikasi biometrik gagal → Batalkan operasi, kembali ke halaman profil |
| | **6a.** Username sudah dipakai → Tampilkan pesan error |

---

### UC-31: Konversi Mata Uang

| Elemen | Deskripsi |
|---|---|
| **Kode** | UC-31 |
| **Nama** | Konversi Mata Uang |
| **Aktor** | Pengguna, ExchangeRate API |
| **Deskripsi** | Pengguna mengkonversi nilai mata uang untuk estimasi harga souvenir/tiket pertunjukan budaya |
| **Pre-condition** | Pengguna sudah login |
| **Post-condition** | Hasil konversi ditampilkan sesuai kurs terkini |
| **Skenario Utama** | 1. Pengguna membuka halaman Konverter |
| | 2. Pengguna memilih tab "Mata Uang" |
| | 3. Pengguna memasukkan nominal dan memilih mata uang asal (IDR/USD/EUR/MYR/SGD) |
| | 4. Pengguna memilih mata uang tujuan |
| | 5. Sistem mengambil kurs dari ExchangeRate API |
| | 6. Sistem meng-cache hasil di Hive `cacheBox` (TTL 1 jam) |
| | 7. Sistem menampilkan hasil konversi |
| **Skenario Alternatif** | **5a.** Data sudah di-cache dan belum expired → Gunakan data cache, skip API call |
| **Skenario Gagal** | **5b.** API gagal → Tampilkan data cache terakhir + timestamp "Data terakhir diperbarui: ..." |

---

### UC-32: Konversi Zona Waktu

| Elemen | Deskripsi |
|---|---|
| **Kode** | UC-32 |
| **Nama** | Konversi Zona Waktu |
| **Aktor** | Pengguna |
| **Deskripsi** | Pengguna mengkonversi waktu antar zona waktu Indonesia dan internasional untuk jadwal festival/pertunjukan budaya |
| **Pre-condition** | Pengguna sudah login |
| **Post-condition** | Waktu dalam zona waktu tujuan ditampilkan |
| **Skenario Utama** | 1. Pengguna membuka halaman Konverter |
| | 2. Pengguna memilih tab "Zona Waktu" |
| | 3. Pengguna memasukkan waktu dan memilih zona asal |
| | 4. Pengguna memilih zona tujuan |
| | 5. Sistem menghitung konversi menggunakan package `timezone` |
| | 6. Sistem menampilkan hasil konversi |
| **Zona yang didukung** | WIB (Asia/Jakarta, UTC+7), WITA (Asia/Makassar, UTC+8), WIT (Asia/Jayapura, UTC+9), London (Europe/London, GMT/BST), Tokyo (Asia/Tokyo, UTC+9) |

---

### UC-33: Dapatkan XP

| Elemen | Deskripsi |
|---|---|
| **Kode** | UC-33 |
| **Nama** | Dapatkan XP |
| **Aktor** | - (Sistem Internal) |
| **Deskripsi** | Sistem secara otomatis memberikan XP (Experience Points) kepada pengguna setelah menyelesaikan aktivitas games |
| **Pre-condition** | Pengguna menyelesaikan salah satu mini game |
| **Post-condition** | Total XP pengguna diperbarui di `user_progress` SQLite; Level dicek untuk kenaikan |
| **Relasi** | <<include>> UC-34 Naik Level; <<extend>> UC-35 Lihat Pencapaian |
| **Skenario Utama** | 1. Pengguna menyelesaikan mini game (kuis/puzzle/tebak wayang) |
| | 2. Sistem menghitung XP berdasarkan skor |
| | 3. Sistem memperbarui `total_xp` di tabel `user_progress` |
| | 4. Sistem menyinkronkan XP ke Hive |
| | 5. Sistem mengecek apakah XP cukup untuk naik level (UC-34) |
| | 6. Jika milestone tercapai → Tampilkan achievement (UC-35, opsional) |
| | 7. Sistem memperbarui leaderboard |

---

### UC-38: Atur Pengingat Harian

| Elemen | Deskripsi |
|---|---|
| **Kode** | UC-38 |
| **Nama** | Atur Pengingat Harian |
| **Aktor** | Pengguna |
| **Deskripsi** | Pengguna mengatur notifikasi pengingat harian untuk menjelajahi budaya atau menyelesaikan daily quest |
| **Pre-condition** | Pengguna sudah login; Permission notifikasi diberikan |
| **Post-condition** | Notifikasi dijadwalkan menggunakan flutter_local_notifications |
| **Relasi** | <<extend>> UC-36 Terima Daily Reminder |
| **Skenario Utama** | 1. Pengguna membuka halaman Pengaturan |
| | 2. Pengguna mengaktifkan toggle "Pengingat Harian" |
| | 3. Pengguna memilih waktu pengingat (default: 08.00 pagi) |
| | 4. Sistem menjadwalkan notifikasi harian via flutter_local_notifications |
| | 5. Setiap hari pada waktu yang ditentukan, pengguna menerima notifikasi: "Budaya Hari Ini: [nama budaya acak]" |
| **Tipe Notifikasi** | Daily Reminder (pagi jam 08.00), Quest Reminder (malam jam 19.00), Achievement (triggered on event) |
| **Batasan** | Maksimal 2 notifikasi per hari untuk menghindari spam |

---

### UC-39: Shake Discovery (Konten Acak)

| Elemen | Deskripsi |
|---|---|
| **Kode** | UC-39 |
| **Nama** | Shake Discovery (Konten Acak) |
| **Aktor** | Pengguna, Sensor Accelerometer |
| **Deskripsi** | Pengguna menggoyangkan perangkat untuk menemukan konten budaya secara acak (discovery mode) |
| **Pre-condition** | Pengguna berada di halaman Eksplorasi; Sensor accelerometer tersedia |
| **Post-condition** | Konten budaya acak ditampilkan |
| **Skenario Utama** | 1. Pengguna menggoyangkan perangkat mobile |
| | 2. Sensor accelerometer mendeteksi goyangan (magnitude > 15 m/s²) |
| | 3. Sistem menerapkan debounce (minimal 1 detik antar shake event) |
| | 4. Sistem memilih konten budaya secara acak dari database |
| | 5. Sistem menampilkan konten budaya acak dengan animasi transisi |

---

## Catatan Teknis Tambahan

### Penjelasan Relasi Use Case

- **<<include>>** : Relasi wajib (mandatory). Use case sumber SELALU menjalankan use case tujuan. Contoh: Login selalu melakukan Hash Password.

- **<<extend>>** : Relasi opsional (conditional). Use case ekstensi HANYA dijalankan jika kondisi tertentu terpenuhi. Contoh: Login Biometrik hanya muncul jika pengguna sudah mengaktifkan fitur biometrik.

### Teknologi yang Digunakan per Modul Use Case

| Modul | Package/Teknologi |
|---|---|
| Autentikasi | `crypto` (SHA-256), `flutter_secure_storage`, `local_auth` |
| Eksplorasi Budaya | `sqflite`, `hive_flutter`, `flutter_animate` |
| Peta Budaya (LBS) | `geolocator`, `flutter_map`, `latlong2` |
| Arena Budaya (Games) | `flame` (game engine), `sensors_plus` |
| AI Penjaga | `google_generative_ai` (Gemini API) |
| Konverter | `dio` (HTTP), `timezone` |
| Notifikasi | `flutter_local_notifications`, `timezone` |
| Profil | `local_auth`, `hive_flutter`, `camera` |
