import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/gamification_service.dart';

class PuzzleBatikScreen extends StatefulWidget {
  const PuzzleBatikScreen({super.key});

  @override
  State<PuzzleBatikScreen> createState() => _PuzzleBatikScreenState();
}

class _PuzzleBatikScreenState extends State<PuzzleBatikScreen> {
  late List<int> _tiles;
  int _moves = 0;
  bool _solved = false;
  StreamSubscription? _accelerometerSub;
  DateTime? _lastShake;

  @override
  void initState() {
    super.initState();
    _tiles = List.generate(9, (i) => i);
    _shuffle();
    _listenToAccelerometer();
  }

  @override
  void dispose() {
    _accelerometerSub?.cancel();
    super.dispose();
  }

  void _listenToAccelerometer() {
    _accelerometerSub = accelerometerEventStream().listen((event) {
      final magnitude =
          sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

      if (magnitude > 15) {
        final now = DateTime.now();
        if (_lastShake == null ||
            now.difference(_lastShake!) > const Duration(seconds: 1)) {
          _lastShake = now;
          _shuffle();
        }
      }
    });
  }

  void _shuffle() {
    setState(() {
      _tiles.shuffle(Random());
      _moves = 0;
      _solved = false;
    });
  }

  void _swapTiles(int fromIndex, int toIndex) {
    if (_solved) return;
    if (fromIndex == toIndex) return;

    setState(() {
      final temp = _tiles[fromIndex];
      _tiles[fromIndex] = _tiles[toIndex];
      _tiles[toIndex] = temp;
      _moves++;
      _checkSolved();
    });
  }

  void _checkSolved() {
    for (int i = 0; i < _tiles.length; i++) {
      if (_tiles[i] != i) return;
    }
    _solved = true;
    _saveResult();
  }

  Future<void> _saveResult() async {
    final xp = _moves <= 15 ? 50 : _moves <= 30 ? 30 : 10;
    await GamificationService.saveQuizResult(
      quizType: 'puzzle_batik',
      skor: xp,
    );
    await GamificationService.awardXp(xp);
  }

  final _colors = [
    const Color(0xFF8B1A1A),
    const Color(0xFFD4A017),
    const Color(0xFF2C5F2E),
    const Color(0xFF4A6FA5),
    const Color(0xFF8B4513),
    const Color(0xFF6B3FA0),
    const Color(0xFFCC5500),
    const Color(0xFF2F4F4F),
    const Color(0xFFB22222),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorBackground,
      appBar: AppBar(
        title: const Text('Puzzle Batik'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text('Langkah: $_moves'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Susun tiles sesuai urutan!\nGoyangkan HP untuk mengacak ulang.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kColorTextLight),
            ),
            const SizedBox(height: 16),
            if (_solved)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: kColorSuccess.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kColorSuccess),
                ),
                child: const Text(
                  'Selamat! Puzzle terpecahkan!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kColorSuccess,
                  ),
                ),
              ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  final tileValue = _tiles[index];
                  final isCorrect = tileValue == index;

                  return DragTarget<int>(
                    onAcceptWithDetails: (details) {
                      _swapTiles(details.data, index);
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Draggable<int>(
                        data: index,
                        feedback: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(8),
                          child: _buildTile(tileValue, isCorrect, true),
                        ),
                        childWhenDragging: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _buildTile(tileValue, isCorrect, false),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _shuffle,
              icon: const Icon(Icons.refresh),
              label: const Text('Acak Ulang'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(int value, bool isCorrect, bool isDragging) {
    return Container(
      width: isDragging ? 100 : null,
      height: isDragging ? 100 : null,
      decoration: BoxDecoration(
        color: _colors[value],
        borderRadius: BorderRadius.circular(8),
        border: isCorrect && !_solved
            ? Border.all(color: kColorSuccess, width: 2)
            : null,
        boxShadow: isDragging
            ? [BoxShadow(blurRadius: 8, color: Colors.black26)]
            : null,
      ),
      child: Center(
        child: Text(
          '${value + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
