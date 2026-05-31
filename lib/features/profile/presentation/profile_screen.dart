import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/database/hive_service.dart';
import '../../../core/security/session_manager.dart';
import '../../../core/utils/gamification_service.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/domain/auth_usecase.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with RouteAware {
  final _authUseCase = AuthUseCase(AuthRepository());

  String _username = '';
  int _level = 1;
  int _xp = 0;
  int _koleksiCount = 0;
  int _bookmarkCount = 0;
  String? _profilePhotoPath;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload every time this screen becomes visible
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = await SessionManager.getCurrentUser();
    if (user != null && mounted) {
      final username = user['name'] ?? user['sub'] ?? '';
      final progress = await GamificationService.getUserProgress();
      final photo = _authUseCase.getProfilePhoto(username);
      setState(() {
        _username = username;
        _profilePhotoPath = photo;
        _xp = (progress?['total_xp'] as int?) ?? 0;
        _level = GamificationService.levelFromXp(_xp);
        _koleksiCount = List<String>.from(
          HiveService.koleksi.get('ids') ?? [],
        ).length;
        _bookmarkCount = List<String>.from(
          HiveService.bookmark.get('ids') ?? [],
        ).length;
      });
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: kColorError),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await SessionManager.clearSession();
      if (mounted) context.go(AppRoutes.login);
    }
  }

  void _showSaranKesan() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Row(
                children: [
                  Icon(Icons.school, color: kColorPrimary),
                  SizedBox(width: 8),
                  Text(
                    'Saran & Kesan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kColorPrimary,
                    ),
                  ),
                ],
              ),
              const Text(
                'Mata Kuliah Teknologi Pemrograman Mobile',
                style: TextStyle(color: kColorTextLight, fontSize: 13),
              ),
              const SizedBox(height: 20),
              _buildSaranKesanSection(
                icon: Icons.favorite,
                title: 'Kesan',
                content:
                    'Mata kuliah TPM sangat menyenangkan dan menantang. '
                    'Saya mendapatkan banyak pengalaman baru dalam mengembangkan '
                    'aplikasi mobile menggunakan Flutter. Materi yang diajarkan '
                    'sangat relevan dengan kebutuhan industri saat ini, mulai dari '
                    'penggunaan sensor, LBS, hingga integrasi AI/LLM. '
                    'Proyek akhir ini menjadi wadah yang tepat untuk mengaplikasikan '
                    'seluruh ilmu yang telah dipelajari selama perkuliahan.',
              ),
              const SizedBox(height: 16),
              _buildSaranKesanSection(
                icon: Icons.lightbulb,
                title: 'Saran',
                content:
                    'Semoga ke depannya materi tentang state management dan '
                    'arsitektur aplikasi bisa lebih diperdalam. Akan sangat '
                    'bermanfaat juga jika ada sesi code review bersama agar '
                    'mahasiswa bisa saling belajar dari pendekatan yang berbeda. '
                    'Secara keseluruhan, mata kuliah ini sudah sangat baik dan '
                    'memberikan bekal yang kuat untuk berkarier di bidang '
                    'mobile development.',
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kColorPrimary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: kColorPrimary.withValues(alpha: 0.2),
                  ),
                ),
                child: const Column(
                  children: [
                    Text(
                      'NusantaraLore',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'CinzelDecorative',
                        color: kColorPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Dibuat dengan ❤️ untuk Tugas Akhir TPM',
                      style: TextStyle(fontSize: 12, color: kColorTextLight),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaranKesanSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kColorSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kColorSecondary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: kColorSecondary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(height: 1.6, fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorBackground,
      appBar: AppBar(title: const Text('Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kColorPrimary, Color(0xFFB22222)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Profile photo or initial
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white38, width: 3),
                    ),
                    child: ClipOval(
                      child: _profilePhotoPath != null &&
                              File(_profilePhotoPath!).existsSync()
                          ? Image.file(
                              File(_profilePhotoPath!),
                              width: 84,
                              height: 84,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.white24,
                              child: Center(
                                child: Text(
                                  _username.isNotEmpty
                                      ? _username[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _username,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: kColorSecondary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Level $_level',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$_xp XP',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value:
                                GamificationService.progressToNextLevel(_xp),
                            backgroundColor: Colors.white24,
                            color: kColorSecondary,
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_xp / ${GamificationService.xpForNextLevel(_xp)} XP ke Level ${_level + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard('Koleksi', '$_koleksiCount'),
                const SizedBox(width: 12),
                _buildStatCard('Bookmark', '$_bookmarkCount'),
                const SizedBox(width: 12),
                _buildStatCard('Level', '$_level'),
              ],
            ),
            const SizedBox(height: 24),
            _buildMenuItem(
              icon: Icons.edit,
              label: 'Edit Profil',
              onTap: () => context.go(AppRoutes.editProfile),
            ),
            _buildMenuItem(
              icon: Icons.currency_exchange,
              label: 'Konverter',
              onTap: () => context.go(AppRoutes.converter),
            ),
            _buildMenuItem(
              icon: Icons.bookmark,
              label: 'Bookmark',
              onTap: () => context.go(AppRoutes.bookmark),
            ),
            _buildMenuItem(
              icon: Icons.history,
              label: 'Riwayat Kuis',
              onTap: () => context.go(AppRoutes.quizHistory),
            ),
            _buildMenuItem(
              icon: Icons.info_outline,
              label: 'Tentang Aplikasi',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'NusantaraLore',
                  applicationVersion: '1.0.0',
                  applicationLegalese:
                      'Ensiklopedia Digital Budaya Nusantara',
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.rate_review,
              label: 'Saran & Kesan TPM',
              onTap: () => _showSaranKesan(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: kColorError),
                label: const Text('Keluar',
                    style: TextStyle(color: kColorError)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kColorError),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: kColorPrimary),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: kColorSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kColorSecondary.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kColorPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: kColorTextLight),
            ),
          ],
        ),
      ),
    );
  }
}
