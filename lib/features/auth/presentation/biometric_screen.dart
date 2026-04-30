import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/security/encryption_service.dart';
import '../../../core/security/session_manager.dart';

class BiometricScreen extends StatefulWidget {
  const BiometricScreen({super.key});

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final _pinController = TextEditingController();
  bool _canCheckBiometrics = false;
  int _failedAttempts = 0;
  bool _showPinFallback = false;
  String? _pinError;

  @override
  void initState() {
    super.initState();
    _initBiometric();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _initBiometric() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (mounted) {
        setState(() => _canCheckBiometrics = canCheck && isDeviceSupported);
      }
      if (canCheck && isDeviceSupported) {
        _authenticate();
      } else {
        setState(() => _showPinFallback = true);
      }
    } catch (_) {
      if (mounted) setState(() => _showPinFallback = true);
    }
  }

  Future<void> _authenticate() async {
    if (_failedAttempts >= 3) {
      setState(() => _showPinFallback = true);
      return;
    }

    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: AppStrings.biometricPrompt,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        if (mounted) context.go(AppRoutes.home);
      } else {
        setState(() => _failedAttempts++);
        if (_failedAttempts >= 3) {
          setState(() => _showPinFallback = true);
        }
      }
    } catch (_) {
      setState(() {
        _failedAttempts++;
        if (_failedAttempts >= 3) _showPinFallback = true;
      });
    }
  }

  Future<void> _verifyPin() async {
    final input = _pinController.text;
    if (input.length != 6) {
      setState(() => _pinError = 'PIN harus 6 digit');
      return;
    }

    final storedHash = await SessionManager.getPin();
    if (storedHash == null) {
      setState(() => _pinError = 'PIN belum diatur');
      return;
    }

    final inputHash = EncryptionService.hashPassword(input, 'pin_salt');
    if (inputHash == storedHash) {
      if (mounted) context.go(AppRoutes.home);
    } else {
      setState(() => _pinError = 'PIN salah');
      _pinController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child:
                _showPinFallback ? _buildPinInput() : _buildBiometricPrompt(),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricPrompt() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _canCheckBiometrics ? Icons.fingerprint : Icons.lock,
          size: 80,
          color: kColorPrimary,
        ),
        const SizedBox(height: 24),
        const Text(
          AppStrings.appName,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: kColorPrimary,
            fontFamily: 'CinzelDecorative',
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _canCheckBiometrics
              ? AppStrings.biometricPrompt
              : 'Biometrik tidak tersedia',
          style: const TextStyle(fontSize: 16, color: kColorTextLight),
        ),
        if (_failedAttempts > 0 && _failedAttempts < 3) ...[
          const SizedBox(height: 8),
          Text(
            'Gagal $_failedAttempts/3 percobaan',
            style: const TextStyle(color: kColorError, fontSize: 13),
          ),
        ],
        const SizedBox(height: 32),
        if (_canCheckBiometrics)
          ElevatedButton.icon(
            onPressed: _authenticate,
            icon: const Icon(Icons.fingerprint),
            label: const Text('Autentikasi'),
          ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() => _showPinFallback = true),
          child: const Text('Gunakan PIN', style: TextStyle(color: kColorPrimary)),
        ),
      ],
    );
  }

  Widget _buildPinInput() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.pin, size: 64, color: kColorPrimary),
        const SizedBox(height: 24),
        const Text(
          AppStrings.pinFallback,
          style: TextStyle(fontSize: 16, color: kColorTextLight),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: 200,
          child: TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            obscureText: true,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, letterSpacing: 8),
            decoration: InputDecoration(
              counterText: '',
              errorText: _pinError,
            ),
            onChanged: (_) {
              if (_pinError != null) setState(() => _pinError = null);
            },
            onSubmitted: (_) => _verifyPin(),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _verifyPin,
          child: const Text('Verifikasi'),
        ),
        const SizedBox(height: 16),
        if (_canCheckBiometrics)
          TextButton(
            onPressed: () {
              setState(() {
                _showPinFallback = false;
                _failedAttempts = 0;
              });
              _authenticate();
            },
            child: const Text(
              'Gunakan biometrik',
              style: TextStyle(color: kColorPrimary),
            ),
          ),
      ],
    );
  }
}
