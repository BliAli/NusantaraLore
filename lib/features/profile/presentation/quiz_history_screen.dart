import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/gamification_service.dart';

class QuizHistoryScreen extends StatefulWidget {
  const QuizHistoryScreen({super.key});

  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await GamificationService.getQuizHistory();
    if (mounted) {
      setState(() {
        _history = data;
        _isLoading = false;
      });
    }
  }

  String _quizLabel(String type) {
    return switch (type) {
      'mitos_fakta' => 'Kuis Mitos vs Fakta',
      'tebak_wayang' => 'Tebak Wayang',
      'puzzle_batik' => 'Puzzle Batik',
      _ => type,
    };
  }

  IconData _quizIcon(String type) {
    return switch (type) {
      'mitos_fakta' => Icons.quiz,
      'tebak_wayang' => Icons.theater_comedy,
      'puzzle_batik' => Icons.grid_view,
      _ => Icons.sports_esports,
    };
  }

  Color _quizColor(String type) {
    return switch (type) {
      'mitos_fakta' => kColorPrimary,
      'tebak_wayang' => kColorSecondary,
      'puzzle_batik' => kColorAccent,
      _ => kColorPrimary,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorBackground,
      appBar: AppBar(title: const Text('Riwayat Kuis')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history,
                          size: 64,
                          color: kColorTextLight.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum ada riwayat.\nMainkan game untuk mulai!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: kColorTextLight),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    final type = (item['quiz_type'] ?? '') as String;
                    final skor = (item['skor'] as int?) ?? 0;
                    final waktu = item['waktu_selesai'] as String?;

                    String timeStr = '';
                    if (waktu != null) {
                      try {
                        final dt = DateTime.parse(waktu);
                        timeStr = DateFormat('dd MMM yyyy, HH:mm', 'id_ID')
                            .format(dt);
                      } catch (_) {
                        timeStr = waktu;
                      }
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              _quizColor(type).withValues(alpha: 0.15),
                          child: Icon(_quizIcon(type),
                              color: _quizColor(type), size: 20),
                        ),
                        title: Text(
                          _quizLabel(type),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          timeStr,
                          style: const TextStyle(
                              fontSize: 12, color: kColorTextLight),
                        ),
                        trailing: Text(
                          '$skor XP',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kColorPrimary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
