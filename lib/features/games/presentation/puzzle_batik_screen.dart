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
  bool _showPreview = false;
  StreamSubscription? _accelerometerSub;
  DateTime? _lastShake;
  int _currentBatikIndex = 0;

  static const _batikImages = [
    {'path': 'assets/images/batik/parang_rusak.jpg', 'nama': 'Parang Rusak'},
    {'path': 'assets/images/batik/mega_mendung.jpg', 'nama': 'Mega Mendung'},
    {'path': 'assets/images/batik/kawung.jpg', 'nama': 'Kawung'},
    {'path': 'assets/images/batik/truntum.jpg', 'nama': 'Truntum'},
    {'path': 'assets/images/batik/sidomukti.jpg', 'nama': 'Sidomukti'},
    {'path': 'assets/images/batik/ceplok.jpg', 'nama': 'Ceplok'},
    {'path': 'assets/images/batik/sekar_jagad.jpg', 'nama': 'Sekar Jagad'},
    {'path': 'assets/images/batik/batik_parang.jpg', 'nama': 'Batik Parang'},
  ];

  String get _currentImage => _batikImages[_currentBatikIndex]['path']!;
  String get _currentName => _batikImages[_currentBatikIndex]['nama']!;

  @override
  void initState() {
    super.initState();
    _currentBatikIndex = Random().nextInt(_batikImages.length);
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
      // Ensure puzzle is solvable
      while (!_isSolvable()) {
        _tiles.shuffle(Random());
      }
      _moves = 0;
      _solved = false;
    });
  }

  bool _isSolvable() {
    int inversions = 0;
    for (int i = 0; i < _tiles.length; i++) {
      for (int j = i + 1; j < _tiles.length; j++) {
        if (_tiles[i] > _tiles[j]) inversions++;
      }
    }
    return inversions.isEven;
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

  void _nextBatik() {
    setState(() {
      _currentBatikIndex =
          (_currentBatikIndex + 1) % _batikImages.length;
    });
    _shuffle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorBackground,
      appBar: AppBar(
        title: const Text('Puzzle Batik'),
        actions: [
          IconButton(
            icon: Icon(
              _showPreview ? Icons.visibility_off : Icons.visibility,
            ),
            tooltip: 'Lihat gambar asli',
            onPressed: () =>
                setState(() => _showPreview = !_showPreview),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text('$_moves langkah'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Batik name
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    kColorPrimary.withValues(alpha: 0.1),
                    kColorSecondary.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.palette, color: kColorPrimary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Motif: $_currentName',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kColorPrimary,
                      ),
                    ),
                  ),
                  Text(
                    'Goyangkan HP untuk acak',
                    style: TextStyle(
                      fontSize: 11,
                      color: kColorTextLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Preview image
            if (_showPreview) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  _currentImage,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Solved banner
            if (_solved)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: kColorSuccess.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kColorSuccess),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.celebration,
                        color: kColorSuccess, size: 32),
                    const SizedBox(height: 8),
                    const Text(
                      'Selamat! Puzzle terpecahkan! 🎉',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kColorSuccess,
                      ),
                    ),
                    Text(
                      'Diselesaikan dalam $_moves langkah',
                      style: const TextStyle(
                          color: kColorSuccess, fontSize: 13),
                    ),
                  ],
                ),
              ),

            // Puzzle grid
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _solved ? kColorSuccess : kColorPrimary,
                      width: 3,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
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
                                elevation: 8,
                                borderRadius: BorderRadius.circular(4),
                                child: SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: _buildImageTile(
                                      tileValue, isCorrect),
                                ),
                              ),
                              childWhenDragging: Container(
                                color: Colors.grey[300],
                              ),
                              child: _buildImageTile(tileValue, isCorrect),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _shuffle,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Acak Ulang'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _nextBatik,
                    icon: const Icon(Icons.skip_next, size: 18),
                    label: const Text('Motif Lain'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageTile(int tileValue, bool isCorrect) {
    // Calculate the crop region for this tile piece
    final row = tileValue ~/ 3;
    final col = tileValue % 3;

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileSize = constraints.maxWidth;
        final fullSize = tileSize * 3;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Cropped image piece
            ClipRect(
              child: OverflowBox(
                maxWidth: fullSize,
                maxHeight: fullSize,
                alignment: Alignment(
                  col == 0 ? -1.0 : col == 1 ? 0.0 : 1.0,
                  row == 0 ? -1.0 : row == 1 ? 0.0 : 1.0,
                ),
                child: Image.asset(
                  _currentImage,
                  width: fullSize,
                  height: fullSize,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Tile number overlay
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${tileValue + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Correct position indicator
            if (isCorrect && !_solved)
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: kColorSuccess,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check,
                      color: Colors.white, size: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}
