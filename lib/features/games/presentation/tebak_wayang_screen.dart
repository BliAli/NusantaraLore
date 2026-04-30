import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/gamification_service.dart';

class TebakWayangScreen extends StatefulWidget {
  const TebakWayangScreen({super.key});

  @override
  State<TebakWayangScreen> createState() => _TebakWayangScreenState();
}

class _TebakWayangScreenState extends State<TebakWayangScreen> {
  final _wayangData = <Map<String, dynamic>>[];
  int _currentIndex = 0;
  int _score = 0;
  int _timeLeft = 20;
  Timer? _timer;
  bool _answered = false;
  String? _selectedAnswer;
  List<String> _options = [];
  bool _isLoading = true;
  bool _gameFinished = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/legenda.json');
      final data = json.decode(jsonString);
      final legenda = data['legenda'] as List<dynamic>? ?? [];

      final allTokoh = <String>{};
      for (final item in legenda) {
        final tokoh = item['tokoh'] as List<dynamic>?;
        if (tokoh != null) {
          for (final t in tokoh) {
            allTokoh.add(t.toString());
          }
        }
      }

      final tokohList = allTokoh.toList()..shuffle(Random());
      for (final tokoh in tokohList.take(10)) {
        final others = (tokohList.toList()..remove(tokoh))..shuffle(Random());
        _wayangData.add({
          'nama': tokoh,
          'options': [tokoh, ...others.take(3)]..shuffle(Random()),
        });
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (_wayangData.isNotEmpty) {
            _options = List<String>.from(_wayangData[0]['options']);
          }
        });
        _startTimer();
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _timeLeft = 20);
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

    final correctAnswer = _wayangData[_currentIndex]['nama'];
    final isCorrect = answer == correctAnswer;

    setState(() {
      _answered = true;
      _selectedAnswer = answer;
      if (isCorrect) {
        final timeBonus = (_timeLeft * 2);
        _score += 10 + timeBonus;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_currentIndex < _wayangData.length - 1) {
        setState(() {
          _currentIndex++;
          _answered = false;
          _selectedAnswer = null;
          _options = List<String>.from(_wayangData[_currentIndex]['options']);
        });
        _startTimer();
      } else {
        setState(() => _gameFinished = true);
        _saveResult();
      }
    });
  }

  Future<void> _saveResult() async {
    await GamificationService.saveQuizResult(
      quizType: 'tebak_wayang',
      skor: _score,
    );
    await GamificationService.awardXp(_score);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorBackground,
      appBar: AppBar(
        title: const Text('Tebak Wayang'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text('Skor: $_score',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _gameFinished
              ? _buildResult()
              : _wayangData.isEmpty
                  ? const Center(child: Text('Data wayang tidak tersedia'))
                  : _buildQuestion(),
    );
  }

  Widget _buildQuestion() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Soal ${_currentIndex + 1}/${_wayangData.length}'),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _timeLeft <= 5 ? kColorError : kColorAccent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$_timeLeft dtk',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  Icons.person,
                  size: 120,
                  color: Colors.white24,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Siapakah tokoh wayang ini?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...List.generate(_options.length, (index) {
            final option = _options[index];
            final correctAnswer = _wayangData[_currentIndex]['nama'];
            Color? bgColor;

            if (_answered) {
              if (option == correctAnswer) {
                bgColor = kColorSuccess.withValues(alpha: 0.2);
              } else if (option == _selectedAnswer) {
                bgColor = kColorError.withValues(alpha: 0.2);
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _answered ? null : () => _onAnswer(option),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: bgColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: _answered && option == correctAnswer
                          ? kColorSuccess
                          : kColorPrimary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(option),
                ),
              ),
            );
          }),
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
            const Icon(Icons.theater_comedy,
                size: 80, color: kColorSecondary),
            const SizedBox(height: 16),
            const Text(
              'Permainan Selesai!',
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
                  _answered = false;
                  _selectedAnswer = null;
                  _gameFinished = false;
                  if (_wayangData.isNotEmpty) {
                    _options =
                        List<String>.from(_wayangData[0]['options']);
                  }
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
