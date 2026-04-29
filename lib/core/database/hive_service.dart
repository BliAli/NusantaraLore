import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String userBox = 'userBox';
  static const String sessionBox = 'sessionBox';
  static const String koleksiBox = 'koleksiBox';
  static const String bookmarkBox = 'bookmarkBox';
  static const String cacheBox = 'cacheBox';
  static const String searchHistoryBox = 'searchHistoryBox';

  static Future<void> init() async {
    await Hive.initFlutter();

    await Future.wait([
      Hive.openBox(userBox),
      Hive.openBox<String>(sessionBox),
      Hive.openBox<List>(koleksiBox),
      Hive.openBox<List>(bookmarkBox),
      Hive.openBox(cacheBox),
      Hive.openBox<List<String>>(searchHistoryBox),
    ]);
  }

  static Box get user => Hive.box(userBox);
  static Box<String> get session => Hive.box<String>(sessionBox);
  static Box<List> get koleksi => Hive.box<List>(koleksiBox);
  static Box<List> get bookmark => Hive.box<List>(bookmarkBox);
  static Box get cache => Hive.box(cacheBox);
  static Box<List<String>> get searchHistory =>
      Hive.box<List<String>>(searchHistoryBox);

  static Future<void> clearAll() async {
    await Future.wait([
      user.clear(),
      session.clear(),
      koleksi.clear(),
      bookmark.clear(),
      cache.clear(),
      searchHistory.clear(),
    ]);
  }

  static Future<void> cacheWithTtl(
    String key,
    dynamic value, {
    Duration ttl = const Duration(hours: 1),
  }) async {
    final expiry = DateTime.now().add(ttl).millisecondsSinceEpoch;
    await cache.put(key, {'data': value, 'expiry': expiry});
  }

  static dynamic getCached(String key) {
    final cached = cache.get(key);
    if (cached == null) return null;
    final expiry = cached['expiry'] as int;
    if (DateTime.now().millisecondsSinceEpoch > expiry) {
      cache.delete(key);
      return null;
    }
    return cached['data'];
  }
}
