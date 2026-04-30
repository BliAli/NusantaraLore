import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionManager {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _lastActiveKey = 'last_active';
  static const _sessionDuration = Duration(days: 7);

  static String _createJwt(String userId, String username) {
    final header = base64Url.encode(utf8.encode(
      '{"alg":"HS256","typ":"JWT"}',
    ));
    final now = DateTime.now();
    final expiry = now.add(_sessionDuration);
    final payload = base64Url.encode(utf8.encode(
      '{"sub":"$userId","name":"$username","iat":${now.millisecondsSinceEpoch ~/ 1000},"exp":${expiry.millisecondsSinceEpoch ~/ 1000}}',
    ));
    final signature = base64Url.encode(utf8.encode('$header.$payload'));
    return '$header.$payload.$signature';
  }

  static Future<void> createSession(String userId, String username) async {
    final token = _createJwt(userId, username);
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(
      key: _lastActiveKey,
      value: DateTime.now().toIso8601String(),
    );
  }

  static Future<bool> isSessionValid() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) return false;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;

      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      final exp = payload['exp'] as int;
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);

      if (DateTime.now().isAfter(expiryDate)) {
        await clearSession();
        return false;
      }

      final lastActive = await _storage.read(key: _lastActiveKey);
      if (lastActive != null) {
        final lastActiveDate = DateTime.parse(lastActive);
        if (DateTime.now().difference(lastActiveDate) > _sessionDuration) {
          await clearSession();
          return false;
        }
      }

      await _storage.write(
        key: _lastActiveKey,
        value: DateTime.now().toIso8601String(),
      );
      return true;
    } catch (_) {
      await clearSession();
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      return json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      ) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _lastActiveKey);
  }

  static Future<void> storePin(String encryptedPin) async {
    await _storage.write(key: 'user_pin', value: encryptedPin);
  }

  static Future<String?> getPin() async {
    return _storage.read(key: 'user_pin');
  }

  static const _biometricEnabledKey = 'biometric_enabled';

  static Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(
      key: _biometricEnabledKey,
      value: enabled.toString(),
    );
  }

  static Future<bool> isBiometricEnabled() async {
    final val = await _storage.read(key: _biometricEnabledKey);
    return val == 'true';
  }
}
