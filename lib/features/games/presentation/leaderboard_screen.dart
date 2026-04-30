import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/gamification_service.dart';

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _leaderboard.isEmpty
              ? _buildEmpty()
              : _buildList(),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events,
              size: 64, color: kColorTextLight.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text(
            'Belum ada data peringkat.\nMainkan game untuk masuk leaderboard!',
            textAlign: TextAlign.center,
            style: TextStyle(color: kColorTextLight),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _leaderboard.length,
      itemBuilder: (context, index) {
        final item = _leaderboard[index];
        final rank = index + 1;
        final username = item['username'] ?? '';
        final totalXp = (item['total_xp'] as int?) ?? 0;
        final level = GamificationService.levelFromXp(totalXp);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: rank <= 3 ? _podiumColor(rank) : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: rank <= 3 ? Colors.white : kColorPrimary,
              child: rank <= 3
                  ? Icon(_podiumIcon(rank), color: _podiumIconColor(rank))
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
                color: rank <= 3 ? Colors.white : kColorText,
              ),
            ),
            subtitle: Text(
              'Level $level',
              style: TextStyle(
                color: rank <= 3
                    ? Colors.white.withValues(alpha: 0.8)
                    : kColorTextLight,
              ),
            ),
            trailing: Text(
              '$totalXp XP',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: rank <= 3 ? Colors.white : kColorPrimary,
              ),
            ),
          ),
        );
      },
    );
  }

  Color _podiumColor(int rank) {
    return switch (rank) {
      1 => const Color(0xFFD4A017),
      2 => const Color(0xFF8D8D8D),
      3 => const Color(0xFFCD7F32),
      _ => kColorSurface,
    };
  }

  IconData _podiumIcon(int rank) {
    return switch (rank) {
      1 => Icons.emoji_events,
      2 => Icons.workspace_premium,
      3 => Icons.military_tech,
      _ => Icons.person,
    };
  }

  Color _podiumIconColor(int rank) {
    return switch (rank) {
      1 => const Color(0xFFD4A017),
      2 => const Color(0xFF8D8D8D),
      3 => const Color(0xFFCD7F32),
      _ => kColorPrimary,
    };
  }
}
