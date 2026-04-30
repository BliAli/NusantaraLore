import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/security/encryption_service.dart';
import '../../../core/security/session_manager.dart';
import '../../../core/database/hive_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final username = _usernameController.text.trim();
      final password = _passwordController.text;

      final userBox = HiveService.user;
      final userData = userBox.get(username);

      if (userData == null) {
        _showError('Pengguna tidak ditemukan');
        return;
      }

      final salt = await EncryptionService.getSalt(username);
      if (salt == null) {
        _showError('Data pengguna rusak');
        return;
      }

      final hashedPassword = EncryptionService.hashPassword(password, salt);
      if (hashedPassword != userData['password']) {
        _showError(AppStrings.loginFailed);
        return;
      }

      await SessionManager.createSession(username, username);

      if (mounted) {
        final alreadyEnabled = await SessionManager.isBiometricEnabled();
        if (!mounted) return;
        if (!alreadyEnabled) {
          await _offerBiometric();
        } else {
          context.go(AppRoutes.home);
        }
      }
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: kColorError),
    );
  }

  Future<void> _offerBiometric() async {
    final localAuth = LocalAuthentication();
    final canCheck = await localAuth.canCheckBiometrics;
    final isSupported = await localAuth.isDeviceSupported();

    if (!canCheck || !isSupported) {
      if (mounted) context.go(AppRoutes.home);
      return;
    }

    if (!mounted) return;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Login Biometrik'),
        content: const Text(
          'Aktifkan sidik jari / wajah untuk login cepat di lain waktu?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Nanti Saja'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Aktifkan'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final authenticated = await localAuth.authenticate(
        localizedReason: 'Verifikasi untuk mengaktifkan biometrik',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated && mounted) {
        await _setupPin();
        await SessionManager.setBiometricEnabled(true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login biometrik berhasil diaktifkan!'),
              backgroundColor: kColorAccent,
            ),
          );
        }
      }
    }

    if (mounted) context.go(AppRoutes.home);
  }

  Future<void> _setupPin() async {
    final pinController = TextEditingController();
    String? error;

    final pin = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Buat PIN Cadangan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('PIN 6 digit digunakan jika biometrik gagal.'),
              const SizedBox(height: 16),
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                obscureText: true,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 8),
                decoration: InputDecoration(
                  counterText: '',
                  errorText: error,
                  hintText: '------',
                ),
                onChanged: (_) {
                  if (error != null) setDialogState(() => error = null);
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (pinController.text.length != 6) {
                  setDialogState(() => error = 'PIN harus 6 digit');
                  return;
                }
                Navigator.pop(ctx, pinController.text);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );

    pinController.dispose();

    if (pin != null) {
      final hashedPin = EncryptionService.hashPassword(pin, 'pin_salt');
      await SessionManager.storePin(hashedPin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.temple_buddhist,
                      size: 80, color: kColorPrimary),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.appName,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: kColorPrimary,
                      fontFamily: 'CinzelDecorative',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.tagline,
                    style: TextStyle(
                      fontSize: 14,
                      color: kColorTextLight,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 48),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.username,
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: AppStrings.password,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(AppStrings.login),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.register),
                    child: const Text(
                      'Belum punya akun? Daftar',
                      style: TextStyle(color: kColorPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
