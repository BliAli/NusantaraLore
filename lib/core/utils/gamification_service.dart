import 'package:uuid/uuid.dart';

import '../database/hive_service.dart';
import '../database/sqlite_service.dart';
import '../security/session_manager.dart';
import 'notification_service.dart';

class GamificationService {
  static const _xpPerLevel = 100;

  static int levelFromXp(int xp) => (xp / _xpPerLevel).floor() + 1;

  static int xpForNextLevel(int currentXp) {
    final currentLevel = levelFromXp(currentXp);
    return currentLevel * _xpPerLevel;
  }

  static double progressToNextLevel(int currentXp) {
    final currentLevel = levelFromXp(currentXp);
    final xpIntoLevel = currentXp - ((currentLevel - 1) * _xpPerLevel);
    return xpIntoLevel / _xpPerLevel;
  }

  static Future<String?> _getUserId() async {
    final user = await SessionManager.getCurrentUser();
    return user?['name'] ?? user?['sub'];
  }

  static Future<void> _ensureUserProgress(String userId) async {
    final rows = await SqliteService.query(
      'user_progress',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    if (rows.isEmpty) {
      await SqliteService.insert('user_progress', {
        'user_id': userId,
        'total_xp': 0,
        'level': 1,
        'badges': '[]',
        'streak_days': 0,
        'last_active': DateTime.now().toIso8601String(),
      });
    }
  }

  static Future<Map<String, dynamic>?> getUserProgress() async {
    final userId = await _getUserId();
    if (userId == null) return null;

    await _ensureUserProgress(userId);
    final rows = await SqliteService.query(
      'user_progress',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  static Future<int> awardXp(int xp) async {
    final userId = await _getUserId();
    if (userId == null) return 0;

    await _ensureUserProgress(userId);

    final rows = await SqliteService.query(
      'user_progress',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    final current = rows.first;
    final oldXp = (current['total_xp'] as int?) ?? 0;
    final newXp = oldXp + xp;
    final oldLevel = levelFromXp(oldXp);
    final newLevel = levelFromXp(newXp);

    await SqliteService.update(
      'user_progress',
      {
        'total_xp': newXp,
        'level': newLevel,
        'last_active': DateTime.now().toIso8601String(),
      },
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    // Sync to Hive for profile screen
    final userData = HiveService.user.get(userId);
    if (userData != null) {
      userData['xp'] = newXp;
      userData['level'] = newLevel;
      await HiveService.user.put(userId, userData);
    }

    // Update leaderboard
    await SqliteService.insert('leaderboard', {
      'user_id': userId,
      'username': userId,
      'total_xp': newXp,
      'rank': 0,
      'updated_at': DateTime.now().toIso8601String(),
    });

    if (newLevel > oldLevel) {
      await NotificationService.showLevelUp(newLevel);
    }

    if (newXp >= 100 && oldXp < 100) {
      await NotificationService.showAchievement('Penjelajah Pemula — 100 XP pertama!');
    }
    if (newXp >= 500 && oldXp < 500) {
      await NotificationService.showAchievement('Budayawan Muda — Mencapai 500 XP!');
    }
    if (newXp >= 1000 && oldXp < 1000) {
      await NotificationService.showAchievement('Ki Dalang Junior — Mencapai 1000 XP!');
    }

    return newXp;
  }

  static Future<void> saveQuizResult({
    required String quizType,
    required int skor,
  }) async {
    final userId = await _getUserId();
    if (userId == null) return;

    await SqliteService.insert('quiz_history', {
      'id': const Uuid().v4(),
      'user_id': userId,
      'quiz_type': quizType,
      'skor': skor,
      'waktu_selesai': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> getQuizHistory() async {
    final userId = await _getUserId();
    if (userId == null) return [];

    return SqliteService.query(
      'quiz_history',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'waktu_selesai DESC',
      limit: 20,
    );
  }

  static Future<List<Map<String, dynamic>>> getLeaderboard() async {
    return SqliteService.query(
      'leaderboard',
      orderBy: 'total_xp DESC',
      limit: 10,
    );
  }
}
