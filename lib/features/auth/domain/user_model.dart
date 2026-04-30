class UserModel {
  final String username;
  final String password;
  final int level;
  final int xp;
  final String createdAt;
  final List<String> badges;
  final int streakDays;

  const UserModel({
    required this.username,
    required this.password,
    this.level = 1,
    this.xp = 0,
    required this.createdAt,
    this.badges = const [],
    this.streakDays = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      level: map['level'] ?? 1,
      xp: map['xp'] ?? 0,
      createdAt: map['createdAt'] ?? '',
      badges: List<String>.from(map['badges'] ?? []),
      streakDays: map['streakDays'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'level': level,
      'xp': xp,
      'createdAt': createdAt,
      'badges': badges,
      'streakDays': streakDays,
    };
  }

  UserModel copyWith({
    String? username,
    String? password,
    int? level,
    int? xp,
    String? createdAt,
    List<String>? badges,
    int? streakDays,
  }) {
    return UserModel(
      username: username ?? this.username,
      password: password ?? this.password,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      createdAt: createdAt ?? this.createdAt,
      badges: badges ?? this.badges,
      streakDays: streakDays ?? this.streakDays,
    );
  }

  static int levelFromXp(int xp) {
    if (xp < 100) return 1;
    if (xp < 300) return 2;
    if (xp < 600) return 3;
    if (xp < 1000) return 4;
    if (xp < 1500) return 5;
    if (xp < 2100) return 6;
    if (xp < 2800) return 7;
    if (xp < 3600) return 8;
    if (xp < 4500) return 9;
    return 10;
  }
}
