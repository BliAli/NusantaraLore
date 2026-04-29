import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<dynamic> _allBudaya = [];
  List<dynamic> _filteredBudaya = [];
  String _selectedKategori = 'Semua';
  bool _isLoading = true;

  final _categories = [
    'Semua',
    AppStrings.categoryLegenda,
    AppStrings.categoryTradisi,
    AppStrings.categoryArtefak,
    AppStrings.categorySeni,
    AppStrings.categoryKuliner,
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/legenda.json');
      final data = json.decode(jsonString);
      final legenda = data['legenda'] as List<dynamic>? ?? [];

      if (mounted) {
        setState(() {
          _allBudaya = legenda;
          _filteredBudaya = legenda;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterByKategori(String kategori) {
    setState(() {
      _selectedKategori = kategori;
      if (kategori == 'Semua') {
        _filteredBudaya = _allBudaya;
      } else {
        _filteredBudaya = _allBudaya
            .where((b) =>
                (b['kategori'] as String?)?.toLowerCase() ==
                kategori.toLowerCase())
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorBackground,
      appBar: AppBar(
        title: const Text('Jelajah Budaya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.go(AppRoutes.search),
          ),
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () => context.go(AppRoutes.map),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat == _selectedKategori;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(cat),
                    selectedColor: kColorPrimary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : kColorText,
                    ),
                    onSelected: (_) => _filterByKategori(cat),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredBudaya.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off,
                                size: 64,
                                color:
                                    kColorTextLight.withValues(alpha: 0.5)),
                            const SizedBox(height: 16),
                            const Text(AppStrings.noResults),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredBudaya.length,
                        itemBuilder: (context, index) {
                          final item = _filteredBudaya[index];
                          return _buildBudayaCard(item);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudayaCard(dynamic item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () =>
            context.go(AppRoutes.budayaDetailPath(item['id'] ?? '')),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: kColorPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_stories,
                    color: kColorPrimary, size: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['judul'] ?? item['nama'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['asal'] ?? item['provinsi'] ?? '',
                      style: const TextStyle(
                        color: kColorTextLight,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['ringkasan'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: kColorTextLight),
            ],
          ),
        ),
      ),
    );
  }
}
