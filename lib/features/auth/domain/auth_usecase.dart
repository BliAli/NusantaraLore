import '../data/auth_repository.dart';
import 'user_model.dart';
import '../../../core/security/encryption_service.dart';
import '../../../core/security/session_manager.dart';

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
}
