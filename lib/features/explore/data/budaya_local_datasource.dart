import '../../../core/database/hive_service.dart';

class BudayaLocalDatasource {
  static List<String> getKoleksi() {
    final data = HiveService.koleksi.get('items');
    if (data == null) return [];
    return List<String>.from(data);
  }

  static Future<void> addToKoleksi(String budayaId) async {
    final current = getKoleksi();
    if (!current.contains(budayaId)) {
      current.add(budayaId);
      await HiveService.koleksi.put('items', current);
    }
  }

  static List<String> getBookmarks() {
    final data = HiveService.bookmark.get('items');
    if (data == null) return [];
    return List<String>.from(data);
  }

  static Future<void> toggleBookmark(String budayaId) async {
    final current = getBookmarks();
    if (current.contains(budayaId)) {
      current.remove(budayaId);
    } else {
      current.add(budayaId);
    }
    await HiveService.bookmark.put('items', current);
  }

  static bool isBookmarked(String budayaId) {
    return getBookmarks().contains(budayaId);
  }
}
