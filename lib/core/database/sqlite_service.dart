import 'package:sqflite/sqflite.dart';

class SqliteService {
  static Database? _database;

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/nusantara_lore.db';

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE budaya (
        id TEXT PRIMARY KEY,
        nama TEXT NOT NULL,
        provinsi TEXT,
        kategori TEXT,
        deskripsi TEXT,
        isi_lengkap TEXT,
        gambar_url TEXT,
        lat REAL,
        lng REAL,
        tags TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE user_progress (
        user_id TEXT PRIMARY KEY,
        total_xp INTEGER DEFAULT 0,
        level INTEGER DEFAULT 1,
        badges TEXT,
        streak_days INTEGER DEFAULT 0,
        last_active TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE quiz_history (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        quiz_type TEXT,
        skor INTEGER,
        waktu_selesai TEXT,
        FOREIGN KEY (user_id) REFERENCES user_progress(user_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE leaderboard (
        user_id TEXT PRIMARY KEY,
        username TEXT,
        total_xp INTEGER,
        rank INTEGER,
        updated_at TEXT
      )
    ''');
  }

  static Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    return db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  static Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return db.update(table, data, where: where, whereArgs: whereArgs);
  }

  static Future<List<Map<String, dynamic>>> search(String query) async {
    final db = await database;
    return db.query(
      'budaya',
      where: 'nama LIKE ? OR deskripsi LIKE ? OR provinsi LIKE ? OR tags LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
    );
  }
}
