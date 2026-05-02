import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/gamification_service.dart';

class TebakWayangScreen extends StatefulWidget {
  const TebakWayangScreen({super.key});

  @override
  State<TebakWayangScreen> createState() => _TebakWayangScreenState();
}

class _TebakWayangScreenState extends State<TebakWayangScreen>
    with SingleTickerProviderStateMixin {
  static const _wayangList = [
    {'nama': 'Arjuna', 'gambar': 'assets/images/wayang/arjuna.jpg', 'deskripsi': 'Ksatria Pandawa ketiga, ahli memanah'},
    {'nama': 'Bima', 'gambar': 'assets/images/wayang/bima.jpg', 'deskripsi': 'Pandawa terkuat, berkuku Pancanaka'},
    {'nama': 'Gatotkaca', 'gambar': 'assets/images/wayang/gatotkaca.jpg', 'deskripsi': 'Putra Bima, otot kawat balung wesi'},
    {'nama': 'Semar', 'gambar': 'assets/images/wayang/semar.jpg', 'deskripsi': 'Punakawan bijaksana, pengasuh Pandawa'},
    {'nama': 'Hanoman', 'gambar': 'assets/images/wayang/hanoman.jpg', 'deskripsi': 'Kera putih sakti, setia pada Rama'},
    {'nama': 'Rahwana', 'gambar': 'assets/images/wayang/rahwana.jpg', 'deskripsi': 'Raja Alengka berkepala sepuluh'},
    {'nama': 'Srikandi', 'gambar': 'assets/images/wayang/srikandi.jpg', 'deskripsi': 'Pahlawan wanita, pemanah ulung'},
    {'nama': 'Kresna', 'gambar': 'assets/images/wayang/kresna.jpg', 'deskripsi': 'Raja Dwarawati, titisan Wisnu'},
    {'nama': 'Petruk', 'gambar': 'assets/images/wayang/petruk.jpg', 'deskripsi': 'Punakawan berhidung panjang'},
    {'nama': 'Nakula & Sadewa', 'gambar': 'assets/images/wayang/nakula_sadewa.jpg', 'deskripsi': 'Si kembar Pandawa termuda'},
  ];

  List<Map<String, String>> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  int _timeLeft = 15;
  Timer? _timer;
  bool _answered = false;
  String? _selectedAnswer;
  List<String> _options = [];
  bool _gameFinished = false;
  int _correctCount = 0;

  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _prepareQuestions();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  void _prepareQuestions() {
    final shuffled = List<Map<String, String>>.from(_wayangList)
      ..shuffle(Random());
    _questions = shuffled.take(min(8, shuffled.length)).toList();
    _generateOptions();
  }

  void _generateOptions() {
    if (_questions.isEmpty) return;
    final correctName = _questions[_currentIndex]['nama']!;
    final allNames =
        _wayangList.map((w) => w['nama']!).where((n) => n != correctName).toList()
          ..shuffle(Random());
    _options = [correctName, ...allNames.take(3)]..shuffle(Random());
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _timeLeft = 15);
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

    final correctAnswer = _questions[_currentIndex]['nama']!;
    final isCorrect = answer == correctAnswer;

    setState(() {
      _answered = true;
      _selectedAnswer = answer;
      if (isCorrect) {
        final timeBonus = (_timeLeft * 2);
        _score += 10 + timeBonus;
        _correctCount++;
      } else {
        // Shake animation on wrong answer
        _shakeController.forward(from: 0);
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_currentIndex < _questions.length - 1) {
        setState(() {
          _currentIndex++;
          _answered = false;
          _selectedAnswer = null;
          _generateOptions();
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

  void _restart() {
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _answered = false;
      _selectedAnswer = null;
      _gameFinished = false;
      _correctCount = 0;
    });
    _prepareQuestions();
    _startTimer();
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
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text('Skor: $_score',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
      body: _gameFinished
          ? _buildResult()
          : _questions.isEmpty
              ? const Center(child: Text('Data wayang tidak tersedia'))
              : _buildQuestion(),
    );
  }

  Widget _buildQuestion() {
    final currentWayang = _questions[_currentIndex];
    final correctAnswer = currentWayang['nama']!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Progress & timer bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Progress dots
              Row(
                children: List.generate(_questions.length, (i) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < _currentIndex
                          ? kColorSuccess
                          : i == _currentIndex
                              ? kColorPrimary
                              : kColorTextLight.withValues(alpha: 0.3),
                    ),
                  );
                }),
              ),
              // Timer
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _timeLeft <= 5
                      ? kColorError
                      : _timeLeft <= 10
                          ? kColorSecondary
                          : kColorAccent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$_timeLeft dtk',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Wayang image card
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      currentWayang['gambar']!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Container(
                        color: Colors.grey[900],
                        child: const Center(
                          child: Icon(Icons.person,
                              size: 120, color: Colors.white24),
                        ),
                      ),
                    ),
                    // Gradient overlay at bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                        child: Text(
                          'Soal ${_currentIndex + 1}/${_questions.length}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    // Show description after answering
                    if (_answered)
                      Positioned(
                        top: 12,
                        left: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: (_selectedAnswer == correctAnswer
                                    ? kColorSuccess
                                    : kColorError)
                                .withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _selectedAnswer == correctAnswer
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _selectedAnswer == correctAnswer
                                      ? 'Benar! ${currentWayang['deskripsi']}'
                                      : 'Salah! Jawaban: $correctAnswer',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Question text
          const Text(
            'Siapakah tokoh wayang ini?',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: kColorText,
            ),
          ),
          const SizedBox(height: 12),

          // Answer options
          ...List.generate(_options.length, (index) {
            final option = _options[index];
            Color? bgColor;
            Color borderColor = kColorPrimary.withValues(alpha: 0.2);
            Color textColor = kColorText;

            if (_answered) {
              if (option == correctAnswer) {
                bgColor = kColorSuccess.withValues(alpha: 0.15);
                borderColor = kColorSuccess;
                textColor = kColorSuccess;
              } else if (option == _selectedAnswer) {
                bgColor = kColorError.withValues(alpha: 0.15);
                borderColor = kColorError;
                textColor = kColorError;
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 20),
                    side: BorderSide(color: borderColor, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _answered && option == correctAnswer
                              ? kColorSuccess
                              : _answered && option == _selectedAnswer
                                  ? kColorError
                                  : kColorPrimary.withValues(alpha: 0.1),
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + index), // A, B, C, D
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: _answered &&
                                      (option == correctAnswer ||
                                          option == _selectedAnswer)
                                  ? Colors.white
                                  : kColorPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        option,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_answered && option == correctAnswer) ...[
                        const Spacer(),
                        const Icon(Icons.check_circle,
                            color: kColorSuccess, size: 20),
                      ],
                      if (_answered &&
                          option == _selectedAnswer &&
                          option != correctAnswer) ...[
                        const Spacer(),
                        const Icon(Icons.cancel,
                            color: kColorError, size: 20),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final percentage =
        _questions.isNotEmpty ? (_correctCount / _questions.length * 100) : 0;
    final emoji = percentage >= 80
        ? '🏆'
        : percentage >= 50
            ? '👏'
            : '💪';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [kColorSecondary, kColorPrimary],
                ),
              ),
              child: const Center(
                child: Icon(Icons.theater_comedy,
                    size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Permainan Selesai! $emoji',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Score card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kColorSurface,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: kColorSecondary.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    '$_score',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: kColorPrimary,
                    ),
                  ),
                  const Text('Total Skor',
                      style: TextStyle(color: kColorTextLight)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildResultStat(
                        'Benar',
                        '$_correctCount/${_questions.length}',
                        kColorSuccess,
                      ),
                      _buildResultStat(
                        'Akurasi',
                        '${percentage.round()}%',
                        kColorSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _restart,
                icon: const Icon(Icons.replay),
                label: const Text('Main Lagi'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(color: kColorTextLight)),
      ],
    );
  }
}
