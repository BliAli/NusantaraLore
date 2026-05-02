import '../data/auth_repository.dart';
import 'user_model.dart';
import '../../../core/security/encryption_service.dart';
import '../../../core/security/session_manager.dart';
import '../../../core/database/sqlite_service.dart';

class AuthUseCase {
  final AuthRepository _repository;

  AuthUseCase(this._repository);

  Future<UserModel?> login(String username, String password) async {
    final user = _repository.getUser(username);
    if (user == null) return null;

    final salt = await EncryptionService.getSalt(username);
    if (salt == null) return null;

    final hashedPassword = EncryptionService.hashPassword(password, salt);
    if (hashedPassword != user.password) return null;

    await SessionManager.createSession(username, username);
    return user;
  }

  Future<UserModel> register(String username, String password) async {
    final salt = EncryptionService.generateSalt();
    final hashedPassword = EncryptionService.hashPassword(password, salt);
    await EncryptionService.storeSalt(username, salt);

    final user = UserModel(
      username: username,
      password: hashedPassword,
      createdAt: DateTime.now().toIso8601String(),
    );

    await _repository.saveUser(user);
    await SessionManager.createSession(username, username);
    return user;
  }

  Future<void> logout() async {
    await SessionManager.clearSession();
  }

  Future<bool> isLoggedIn() async {
    return SessionManager.isSessionValid();
  }

  Future<void> addXp(String username, int xp) async {
    final user = _repository.getUser(username);
    if (user == null) return;

    final newXp = user.xp + xp;
    final newLevel = UserModel.levelFromXp(newXp);
    final updated = user.copyWith(xp: newXp, level: newLevel);
    await _repository.saveUser(updated);
  }

  /// Update username: re-key Hive entry, migrate salt & SQLite data, refresh session.
  Future<bool> updateUsername(String oldUsername, String newUsername) async {
    if (_repository.userExists(newUsername)) return false;

    final user = _repository.getUser(oldUsername);
    if (user == null) return false;

    // Get old salt
    final salt = await EncryptionService.getSalt(oldUsername);
    if (salt == null) return false;

    // 1. Store salt under new username first
    await EncryptionService.storeSalt(newUsername, salt);

    // 2. Save user under new key
    final updated = user.copyWith(username: newUsername);
    await _repository.saveUser(updated);

    // 3. Verify the new data is accessible before deleting old
    final verify = _repository.getUser(newUsername);
    final verifySalt = await EncryptionService.getSalt(newUsername);
    if (verify == null || verifySalt == null) {
      // Rollback: delete the incomplete new entry
      await _repository.deleteUser(newUsername);
      return false;
    }

    // 4. Delete old user data only after verification
    await _repository.deleteUser(oldUsername);

    // 5. Migrate SQLite user_progress & leaderboard data
    try {
      await SqliteService.update(
        'user_progress',
        {'user_id': newUsername},
        where: 'user_id = ?',
        whereArgs: [oldUsername],
      );
      await SqliteService.update(
        'quiz_history',
        {'user_id': newUsername},
        where: 'user_id = ?',
        whereArgs: [oldUsername],
      );
      await SqliteService.update(
        'leaderboard',
        {'user_id': newUsername, 'username': newUsername},
        where: 'user_id = ?',
        whereArgs: [oldUsername],
      );
    } catch (_) {
      // Non-critical: SQLite migration failure shouldn't block username change
    }

    // 6. Refresh session with new username
    await SessionManager.createSession(newUsername, newUsername);

    return true;
  }

  /// Update password: verify old password first, then hash new one.
  Future<bool> updatePassword(
      String username, String oldPassword, String newPassword) async {
    final user = _repository.getUser(username);
    if (user == null) return false;

    final salt = await EncryptionService.getSalt(username);
    if (salt == null) return false;

    // Verify old password
    final oldHash = EncryptionService.hashPassword(oldPassword, salt);
    if (oldHash != user.password) return false;

    // Hash new password with new salt
    final newSalt = EncryptionService.generateSalt();
    final newHash = EncryptionService.hashPassword(newPassword, newSalt);
    await EncryptionService.storeSalt(username, newSalt);

    final updated = user.copyWith(password: newHash);
    await _repository.saveUser(updated);

    // Refresh session
    await SessionManager.createSession(username, username);

    return true;
  }

  /// Update profile photo path in user data.
  Future<bool> updateProfilePhoto(String username, String photoPath) async {
    final user = _repository.getUser(username);
    if (user == null) return false;

    final updated = user.copyWith(profilePhoto: photoPath);
    await _repository.saveUser(updated);
    return true;
  }

  /// Get the current user's profile photo path.
  String? getProfilePhoto(String username) {
    final user = _repository.getUser(username);
    if (user == null) return null;
    final photo = user.profilePhoto;
    return photo.isNotEmpty ? photo : null;
  }
}
