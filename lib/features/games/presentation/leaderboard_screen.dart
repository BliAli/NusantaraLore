import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/gamification_service.dart';
import '../../../shared/widgets/app_widgets.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Map<String, dynamic>> _leaderboard = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await GamificationService.getLeaderboard();
    if (mounted) {
      setState(() {
        _leaderboard = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorBackground,
      appBar: AppBar(title: const Text('Papan Peringkat')),
      body: NAsyncView(
        isLoading: _isLoading,
        isEmpty: _leaderboard.isEmpty,
        emptyState: const NEmptyState(
          icon: Icons.emoji_events,
          message: 'Belum ada data peringkat.\nMainkan game untuk masuk leaderboard!',
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _leaderboard.length,
          itemBuilder: (context, index) {
            final item = _leaderboard[index];
            final rank = index + 1;
            return _LeaderboardTile(
              rank: rank,
              username: item['username'] ?? '',
              totalXp: (item['total_xp'] as int?) ?? 0,
            );
          },
        ),
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final String username;
  final int totalXp;

  const _LeaderboardTile({
    required this.rank,
    required this.username,
    required this.totalXp,
  });

  bool get _isPodium => rank <= 3;

  @override
  Widget build(BuildContext context) {
    final level = GamificationService.levelFromXp(totalXp);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: _isPodium ? _podiumColor : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _isPodium ? Colors.white : kColorPrimary,
          child: _isPodium
              ? Icon(_podiumIcon, color: _podiumColor)
              : Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        title: Text(
          username,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _isPodium ? Colors.white : kColorText,
          ),
        ),
        subtitle: Text(
          'Level $level',
          style: TextStyle(
            color: _isPodium
                ? Colors.white.withValues(alpha: 0.8)
                : kColorTextLight,
          ),
        ),
        trailing: Text(
          '$totalXp XP',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _isPodium ? Colors.white : kColorPrimary,
          ),
        ),
      ),
    );
  }

  Color get _podiumColor => switch (rank) {
        1 => const Color(0xFFD4A017),
        2 => const Color(0xFF8D8D8D),
        3 => const Color(0xFFCD7F32),
        _ => kColorSurface,
      };

  IconData get _podiumIcon => switch (rank) {
        1 => Icons.emoji_events,
        2 => Icons.workspace_premium,
        3 => Icons.military_tech,
        _ => Icons.person,
      };
}
