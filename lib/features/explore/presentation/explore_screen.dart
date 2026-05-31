import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/app_widgets.dart';

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
            child: NAsyncView(
              isLoading: _isLoading,
              isEmpty: _filteredBudaya.isEmpty,
              emptyState: const NEmptyState(
                icon: Icons.search_off,
                message: AppStrings.noResults,
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredBudaya.length,
                itemBuilder: (context, index) {
                  final item = _filteredBudaya[index];
                  return NBudayaCard(
                    title: item['judul'] ?? item['nama'] ?? '',
                    subtitle: item['asal'] ?? item['provinsi'] ?? '',
                    imageAsset: item['gambar'],
                    onTap: () =>
                        context.go(AppRoutes.budayaDetailPath(item['id'] ?? '')),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
