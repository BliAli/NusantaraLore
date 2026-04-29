import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class BiometricScreen extends StatefulWidget {
  const BiometricScreen({super.key});

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  int _failedAttempts = 0;
  bool _showPinFallback = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      setState(() => _canCheckBiometrics = canCheck && isDeviceSupported);
    } catch (_) {
      setState(() => _canCheckBiometrics = false);
    }
  }

  Future<bool> authenticate() async {
    if (_failedAttempts >= 3) {
      setState(() => _showPinFallback = true);
      return false;
    }

    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: AppStrings.biometricPrompt,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (!authenticated) {
        setState(() => _failedAttempts++);
      }
      return authenticated;
    } catch (_) {
      setState(() => _failedAttempts++);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorBackground,
      body: Center(
        child: _showPinFallback ? _buildPinInput() : _buildBiometricPrompt(),
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
        Text(
          _canCheckBiometrics
              ? AppStrings.biometricPrompt
              : 'Biometrik tidak tersedia',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        if (_canCheckBiometrics)
          ElevatedButton(
            onPressed: authenticate,
            child: const Text('Autentikasi'),
          ),
      ],
    );
  }

  Widget _buildPinInput() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.pin, size: 64, color: kColorPrimary),
          const SizedBox(height: 24),
          const Text(AppStrings.pinFallback, style: TextStyle(fontSize: 16)),
          const SizedBox(height: 24),
          TextFormField(
            keyboardType: TextInputType.number,
            maxLength: 6,
            obscureText: true,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, letterSpacing: 8),
            decoration: const InputDecoration(
              counterText: '',
            ),
          ),
        ],
      ),
    );
  }
}
