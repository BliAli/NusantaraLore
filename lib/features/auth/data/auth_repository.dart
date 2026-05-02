import '../domain/user_model.dart';
import '../../../core/database/hive_service.dart';

class AuthRepository {
  UserModel? getUser(String username) {
    final data = HiveService.user.get(username);
    if (data == null) return null;
    return UserModel.fromMap(Map<String, dynamic>.from(data));
  }

  Future<void> saveUser(UserModel user) async {
    await HiveService.user.put(user.username, user.toMap());
  }

  bool userExists(String username) {
    return HiveService.user.containsKey(username);
  }

  Future<void> deleteUser(String username) async {
    await HiveService.user.delete(username);
  }
}
