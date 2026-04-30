import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthLocalDatasource {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveBiometricEnabled(
      String username, bool enabled) async {
    await _storage.write(
      key: 'biometric_$username',
      value: enabled.toString(),
    );
  }

  static Future<bool> isBiometricEnabled(String username) async {
    final value = await _storage.read(key: 'biometric_$username');
    return value == 'true';
  }

  static Future<void> savePin(String username, String encryptedPin) async {
    await _storage.write(key: 'pin_$username', value: encryptedPin);
  }

  static Future<String?> getPin(String username) async {
    return _storage.read(key: 'pin_$username');
  }
}
