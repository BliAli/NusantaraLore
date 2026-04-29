import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';

class BudayaDetailScreen extends StatefulWidget {
  final String budayaId;

  const BudayaDetailScreen({super.key, required this.budayaId});

  @override
  State<BudayaDetailScreen> createState() => _BudayaDetailScreenState();
}

class _BudayaDetailScreenState extends State<BudayaDetailScreen> {
  Map<String, dynamic>? _budaya;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBudaya();
  }

  Future<void> _loadBudaya() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/legenda.json');
      final data = json.decode(jsonString);
      final legenda = data['legenda'] as List<dynamic>? ?? [];

      final found = legenda.firstWhere(
        (item) => item['id'] == widget.budayaId,
        orElse: () => null,
      );

      if (mounted) {
        setState(() {
          _budaya = found != null ? Map<String, dynamic>.from(found) : null;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_budaya == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tidak Ditemukan')),
        body: const Center(child: Text('Konten budaya tidak ditemukan.')),
      );
    }

    return Scaffold(
      backgroundColor: kColorBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _budaya!['judul'] ?? _budaya!['nama'] ?? '',
                style: const TextStyle(fontSize: 16),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      kColorPrimary,
                      kColorPrimary.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: const Center(
                  child:
                      Icon(Icons.auto_stories, size: 64, color: Colors.white54),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16, color: kColorPrimary),
                      const SizedBox(width: 4),
                      Text(
                        _budaya!['asal'] ?? _budaya!['provinsi'] ?? '',
                        style: const TextStyle(color: kColorPrimary),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: kColorSecondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _budaya!['kategori'] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: kColorPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_budaya!['tokoh'] != null) ...[
                    const Text(
                      'Tokoh',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: (_budaya!['tokoh'] as List<dynamic>)
                          .map((t) => Chip(
                                label: Text(t.toString()),
                                backgroundColor:
                                    kColorAccent.withValues(alpha: 0.1),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Text(
                    'Ringkasan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _budaya!['ringkasan'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_budaya!['isi_lengkap'] != null &&
                      (_budaya!['isi_lengkap'] as String).isNotEmpty) ...[
                    const Text(
                      'Cerita Lengkap',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _budaya!['isi_lengkap'],
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (_budaya!['tags'] != null) ...[
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: (_budaya!['tags'] as List<dynamic>)
                          .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: kColorPrimary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '#$tag',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: kColorPrimary,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
