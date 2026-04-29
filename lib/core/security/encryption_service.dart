import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static const _storage = FlutterSecureStorage();
  static const _aesKeyKey = 'aes_master_key';
  static const _ivKey = 'aes_iv';

  static String generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Encode(saltBytes);
  }

  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  static Future<void> initAesKey() async {
    final existingKey = await _storage.read(key: _aesKeyKey);
    if (existingKey != null) return;

    final key = encrypt.Key.fromSecureRandom(32);
    final iv = encrypt.IV.fromSecureRandom(16);

    await _storage.write(key: _aesKeyKey, value: base64Encode(key.bytes));
    await _storage.write(key: _ivKey, value: base64Encode(iv.bytes));
  }

  static Future<String> encryptData(String plaintext) async {
    final keyStr = await _storage.read(key: _aesKeyKey);
    final ivStr = await _storage.read(key: _ivKey);
    if (keyStr == null || ivStr == null) {
      throw StateError('AES key not initialized. Call initAesKey() first.');
    }

    final key = encrypt.Key(Uint8List.fromList(base64Decode(keyStr)));
    final iv = encrypt.IV(Uint8List.fromList(base64Decode(ivStr)));
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    return encrypter.encrypt(plaintext, iv: iv).base64;
  }

  static Future<String> decryptData(String ciphertext) async {
    final keyStr = await _storage.read(key: _aesKeyKey);
    final ivStr = await _storage.read(key: _ivKey);
    if (keyStr == null || ivStr == null) {
      throw StateError('AES key not initialized. Call initAesKey() first.');
    }

    final key = encrypt.Key(Uint8List.fromList(base64Decode(keyStr)));
    final iv = encrypt.IV(Uint8List.fromList(base64Decode(ivStr)));
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    return encrypter.decrypt64(ciphertext, iv: iv);
  }

  static Future<void> storeSalt(String userId, String salt) async {
    await _storage.write(key: 'salt_$userId', value: salt);
  }

  static Future<String?> getSalt(String userId) async {
    return _storage.read(key: 'salt_$userId');
  }
}
