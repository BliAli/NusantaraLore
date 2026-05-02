import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/security/session_manager.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/domain/auth_usecase.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  final _localAuth = LocalAuthentication();
  final _authUseCase = AuthUseCase(AuthRepository());
  final _imagePicker = ImagePicker();

  // State
  bool _isAuthenticated = false;
  bool _isAuthenticating = false;
  String _currentUsername = '';
  String? _profilePhotoPath;

  // Username editing
  final _usernameController = TextEditingController();
  bool _isUpdatingUsername = false;
  String? _usernameError;

  // Password editing
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isUpdatingPassword = false;
  String? _passwordError;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final user = await SessionManager.getCurrentUser();
    if (user != null && mounted) {
      final username = user['name'] ?? user['sub'] ?? '';
      final photo = _authUseCase.getProfilePhoto(username);
      setState(() {
        _currentUsername = username;
        _usernameController.text = username;
        _profilePhotoPath = photo;
      });
    }
  }

  Future<void> _authenticateBiometric() async {
    setState(() => _isAuthenticating = true);

    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();

      if (!canCheck || !isSupported) {
        if (mounted) {
          _showSnackBar('Biometrik tidak tersedia.', isError: true);
          setState(() => _isAuthenticating = false);
        }
        return;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Verifikasi identitas Anda untuk mengedit profil',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (mounted) {
        setState(() {
          _isAuthenticated = authenticated;
          _isAuthenticating = false;
        });
        if (authenticated) _animController.forward();
        if (!authenticated) {
          _showSnackBar('Verifikasi biometrik gagal.', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAuthenticating = false);
        _showSnackBar('Terjadi kesalahan: $e', isError: true);
      }
    }
  }

  // ── Profile Photo ─────────────────────────────────────────────────────

  Future<void> _pickProfilePhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pilih Foto Profil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kColorPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt, color: kColorPrimary),
                ),
                title: const Text('Kamera'),
                subtitle: const Text('Ambil foto baru'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kColorSecondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      const Icon(Icons.photo_library, color: kColorSecondary),
                ),
                title: const Text('Galeri'),
                subtitle: const Text('Pilih dari galeri'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              if (_profilePhotoPath != null)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kColorError.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete, color: kColorError),
                  ),
                  title: const Text('Hapus Foto'),
                  subtitle: const Text('Kembali ke default'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _removeProfilePhoto();
                  },
                ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked == null) return;

      // Copy to app documents directory for persistence
      final appDir = await getApplicationDocumentsDirectory();
      final photoDir = Directory('${appDir.path}/profile_photos');
      if (!await photoDir.exists()) {
        await photoDir.create(recursive: true);
      }

      final ext = picked.path.split('.').last;
      final savedPath =
          '${photoDir.path}/${_currentUsername}_${DateTime.now().millisecondsSinceEpoch}.$ext';
      await File(picked.path).copy(savedPath);

      // Save to database
      final success =
          await _authUseCase.updateProfilePhoto(_currentUsername, savedPath);

      if (success && mounted) {
        setState(() => _profilePhotoPath = savedPath);
        _showSnackBar('Foto profil berhasil diubah!');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Gagal mengubah foto: $e', isError: true);
      }
    }
  }

  Future<void> _removeProfilePhoto() async {
    final success =
        await _authUseCase.updateProfilePhoto(_currentUsername, '');
    if (success && mounted) {
      setState(() => _profilePhotoPath = null);
      _showSnackBar('Foto profil dihapus.');
    }
  }

  // ── Username Update ───────────────────────────────────────────────────

  Future<void> _updateUsername() async {
    final newUsername = _usernameController.text.trim();

    if (newUsername.isEmpty) {
      setState(() => _usernameError = 'Username tidak boleh kosong');
      return;
    }
    if (newUsername.length < 3) {
      setState(() => _usernameError = 'Username minimal 3 karakter');
      return;
    }
    if (newUsername == _currentUsername) {
      setState(() => _usernameError = 'Username sama dengan yang lama');
      return;
    }

    setState(() {
      _isUpdatingUsername = true;
      _usernameError = null;
    });

    final success =
        await _authUseCase.updateUsername(_currentUsername, newUsername);

    if (mounted) {
      setState(() => _isUpdatingUsername = false);

      if (success) {
        _currentUsername = newUsername;
        _showSnackBar('Username berhasil diubah!');
        // Navigate back to profile after short delay
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) context.go(AppRoutes.profile);
      } else {
        setState(() => _usernameError = 'Username sudah digunakan');
      }
    }
  }

  // ── Password Update ───────────────────────────────────────────────────

  Future<void> _updatePassword() async {
    final oldPass = _oldPasswordController.text;
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      setState(() => _passwordError = 'Semua field harus diisi');
      return;
    }
    if (newPass.length < 6) {
      setState(() => _passwordError = 'Password baru minimal 6 karakter');
      return;
    }
    if (newPass != confirmPass) {
      setState(() => _passwordError = 'Konfirmasi password tidak cocok');
      return;
    }
    if (oldPass == newPass) {
      setState(
          () => _passwordError = 'Password baru harus berbeda dari yang lama');
      return;
    }

    setState(() {
      _isUpdatingPassword = true;
      _passwordError = null;
    });

    final success =
        await _authUseCase.updatePassword(_currentUsername, oldPass, newPass);

    if (mounted) {
      setState(() => _isUpdatingPassword = false);

      if (success) {
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        _showSnackBar('Password berhasil diubah!');
        // Navigate back to profile after short delay
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) context.go(AppRoutes.profile);
      } else {
        setState(() => _passwordError = 'Password lama salah');
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? kColorError : kColorSuccess,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorBackground,
      appBar: AppBar(
        title: const Text('Edit Profil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.profile),
        ),
      ),
      body: _isAuthenticated ? _buildEditForm() : _buildBiometricGate(),
    );
  }

  Widget _buildBiometricGate() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    kColorPrimary.withValues(alpha: 0.15),
                    kColorSecondary.withValues(alpha: 0.1),
                  ],
                ),
                border: Border.all(
                  color: kColorPrimary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.fingerprint,
                size: 64,
                color: kColorPrimary,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Verifikasi Identitas',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kColorText,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Untuk keamanan, verifikasi biometrik diperlukan\nsebelum mengubah data profil Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: kColorTextLight,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isAuthenticating ? null : _authenticateBiometric,
                icon: _isAuthenticating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.fingerprint),
                label: Text(
                  _isAuthenticating
                      ? 'Memverifikasi...'
                      : 'Verifikasi Sekarang',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kColorSecondary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: kColorSecondary.withValues(alpha: 0.2),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined,
                      color: kColorSecondary, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Data Anda dilindungi dengan enkripsi dan verifikasi biometrik.',
                      style: TextStyle(fontSize: 12, color: kColorTextLight),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditForm() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Verified badge
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    kColorSuccess.withValues(alpha: 0.1),
                    kColorSuccess.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: kColorSuccess.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: kColorSuccess.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.verified_user,
                        color: kColorSuccess, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Identitas Terverifikasi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: kColorSuccess,
                          ),
                        ),
                        Text(
                          'Anda dapat mengedit profil sekarang',
                          style:
                              TextStyle(fontSize: 11, color: kColorTextLight),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Profile Photo Section ────────────────────────────────
            _buildSectionCard(
              title: 'Foto Profil',
              icon: Icons.camera_alt_outlined,
              child: Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickProfilePhoto,
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: kColorPrimary.withValues(alpha: 0.3),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      kColorPrimary.withValues(alpha: 0.15),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: _profilePhotoPath != null &&
                                      File(_profilePhotoPath!).existsSync()
                                  ? Image.file(
                                      File(_profilePhotoPath!),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color:
                                          kColorPrimary.withValues(alpha: 0.1),
                                      child: Center(
                                        child: Text(
                                          _currentUsername.isNotEmpty
                                              ? _currentUsername[0]
                                                  .toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: kColorPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: kColorPrimary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ketuk untuk mengubah foto',
                      style: TextStyle(
                        fontSize: 12,
                        color: kColorTextLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Username Section ─────────────────────────────────────
            _buildSectionCard(
              title: 'Ubah Username',
              icon: Icons.person_outline,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username Baru',
                      hintText: 'Masukkan username baru',
                      prefixIcon:
                          const Icon(Icons.alternate_email, size: 20),
                      errorText: _usernameError,
                    ),
                    onChanged: (_) {
                      if (_usernameError != null) {
                        setState(() => _usernameError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _isUpdatingUsername ? null : _updateUsername,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isUpdatingUsername
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Simpan Username'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Password Section ─────────────────────────────────────
            _buildSectionCard(
              title: 'Ubah Password',
              icon: Icons.lock_outline,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _oldPasswordController,
                    obscureText: _obscureOld,
                    decoration: InputDecoration(
                      labelText: 'Password Lama',
                      prefixIcon: const Icon(Icons.lock_clock, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureOld
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscureOld = !_obscureOld),
                      ),
                    ),
                    onChanged: (_) {
                      if (_passwordError != null) {
                        setState(() => _passwordError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _newPasswordController,
                    obscureText: _obscureNew,
                    decoration: InputDecoration(
                      labelText: 'Password Baru',
                      prefixIcon:
                          const Icon(Icons.lock_outline, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNew
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscureNew = !_obscureNew),
                      ),
                    ),
                    onChanged: (_) {
                      if (_passwordError != null) {
                        setState(() => _passwordError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password Baru',
                      prefixIcon:
                          const Icon(Icons.lock_reset, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 20,
                        ),
                        onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    onChanged: (_) {
                      if (_passwordError != null) {
                        setState(() => _passwordError = null);
                      }
                    },
                  ),
                  if (_passwordError != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: kColorError, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _passwordError!,
                            style: const TextStyle(
                                color: kColorError, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _isUpdatingPassword ? null : _updatePassword,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isUpdatingPassword
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Simpan Password'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kColorSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kColorSecondary.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kColorPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: kColorPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kColorText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
