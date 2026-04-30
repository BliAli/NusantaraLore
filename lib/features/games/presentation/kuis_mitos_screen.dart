import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/gamification_service.dart';

class KuisMitosScreen extends StatefulWidget {
  const KuisMitosScreen({super.key});

  @override
  State<KuisMitosScreen> createState() => _KuisMitosScreenState();
}

class _KuisMitosScreenState extends State<KuisMitosScreen> {
  List<Map<String, dynamic>> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  int _streak = 0;
  int _timeLeft = 30;
  Timer? _timer;
  bool _answered = false;
  bool? _lastAnswerCorrect;
  bool _isLoading = true;
  bool _quizFinished = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/legenda.json');
      final data = json.decode(jsonString);
      final legenda = data['legenda'] as List<dynamic>? ?? [];

      final random = Random();
      final questions = <Map<String, dynamic>>[];

      for (final item in legenda.take(10)) {
        final isMitos = random.nextBool();
        questions.add({
          'pertanyaan':
              '${item['judul'] ?? item['nama']}: ${item['ringkasan'] ?? ''}',
          'jawaban': isMitos ? 'Mitos' : 'Fakta',
          'penjelasan': 'Ini adalah ${isMitos ? 'mitos' : 'fakta'} dari ${item['asal'] ?? 'Nusantara'}.',
        });
      }

      if (mounted) {
        setState(() {
          _questions = questions;
          _isLoading = false;
        });
        _startTimer();
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _timeLeft = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft <= 0) {
        timer.cancel();
        _onAnswer(null);
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  void _onAnswer(String? answer) {
    if (_answered) return;
    _timer?.cancel();

    final correct = answer == _questions[_currentIndex]['jawaban'];

    setState(() {
      _answered = true;
      _lastAnswerCorrect = correct;
      if (correct) {
        _score += 10;
        _streak++;
        if (_streak >= 3) {
          _score += 20;
          _streak = 0;
        }
      } else {
        _streak = 0;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_currentIndex < _questions.length - 1) {
        setState(() {
          _currentIndex++;
          _answered = false;
          _lastAnswerCorrect = null;
        });
        _startTimer();
      } else {
        setState(() => _quizFinished = true);
        _saveResult();
      }
    });
  }

  Future<void> _saveResult() async {
    await GamificationService.saveQuizResult(
      quizType: 'mitos_fakta',
      skor: _score,
    );
    await GamificationService.awardXp(_score);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorBackground,
      appBar: AppBar(
        title: const Text('Kuis Mitos vs Fakta'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                'Skor: $_score',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _quizFinished
              ? _buildResult()
              : _questions.isEmpty
                  ? const Center(child: Text('Tidak ada soal tersedia'))
                  : _buildQuestion(),
    );
  }

  Widget _buildQuestion() {
    final q = _questions[_currentIndex];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Soal ${_currentIndex + 1}/${_questions.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _timeLeft <= 10 ? kColorError : kColorAccent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$_timeLeft detik',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _timeLeft / 30,
            backgroundColor: Colors.grey[300],
            color: _timeLeft <= 10 ? kColorError : kColorPrimary,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    q['pertanyaan'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_answered && _lastAnswerCorrect != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: _lastAnswerCorrect!
                    ? kColorSuccess.withValues(alpha: 0.1)
                    : kColorError.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _lastAnswerCorrect! ? 'Benar! +10 XP' : 'Salah!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _lastAnswerCorrect! ? kColorSuccess : kColorError,
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _answered ? null : () => _onAnswer('Mitos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kColorPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('MITOS', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _answered ? null : () => _onAnswer('Fakta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kColorAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('FAKTA', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 80, color: kColorSecondary),
            const SizedBox(height: 16),
            const Text(
              'Kuis Selesai!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Skor Akhir: $_score',
              style: const TextStyle(fontSize: 32, color: kColorPrimary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentIndex = 0;
                  _score = 0;
                  _streak = 0;
                  _answered = false;
                  _lastAnswerCorrect = null;
                  _quizFinished = false;
                });
                _startTimer();
              },
              child: const Text('Main Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
