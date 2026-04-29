import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/database/hive_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<dynamic> _allData = [];
  List<dynamic> _results = [];
  List<String> _searchHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/legenda.json');
      final data = json.decode(jsonString);
      _allData = data['legenda'] as List<dynamic>? ?? [];
      if (mounted) setState(() => _isLoading = false);
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _loadHistory() {
    final box = HiveService.searchHistory;
    final history = box.get('history');
    if (history != null) {
      _searchHistory = List<String>.from(history);
    }
  }

  Future<void> _saveHistory(String query) async {
    _searchHistory.remove(query);
    _searchHistory.insert(0, query);
    if (_searchHistory.length > 10) {
      _searchHistory = _searchHistory.take(10).toList();
    }
    await HiveService.searchHistory.put('history', _searchHistory);
  }

  void _search(String query) {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }

    _saveHistory(query.trim());

    final q = query.toLowerCase();
    setState(() {
      _results = _allData.where((item) {
        final judul = (item['judul'] ?? item['nama'] ?? '').toString().toLowerCase();
        final asal = (item['asal'] ?? item['provinsi'] ?? '').toString().toLowerCase();
        final ringkasan = (item['ringkasan'] ?? '').toString().toLowerCase();
        final tags = (item['tags'] as List<dynamic>?)
                ?.map((t) => t.toString().toLowerCase())
                .toList() ??
            [];
        final tokoh = (item['tokoh'] as List<dynamic>?)
                ?.map((t) => t.toString().toLowerCase())
                .toList() ??
            [];

        return judul.contains(q) ||
            asal.contains(q) ||
            ringkasan.contains(q) ||
            tags.any((t) => t.contains(q)) ||
            tokoh.any((t) => t.contains(q));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorBackground,
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: AppStrings.searchHint,
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          onChanged: _search,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() => _results = []);
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _searchController.text.isEmpty
              ? _buildHistory()
              : _results.isEmpty
                  ? _buildEmpty()
                  : _buildResults(),
    );
  }

  Widget _buildHistory() {
    if (_searchHistory.isEmpty) {
      return const Center(
        child: Text(
          'Cari legenda, tradisi, atau tokoh budaya',
          style: TextStyle(color: kColorTextLight),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Riwayat Pencarian',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._searchHistory.map((q) => ListTile(
              leading: const Icon(Icons.history, color: kColorTextLight),
              title: Text(q),
              onTap: () {
                _searchController.text = q;
                _search(q);
              },
            )),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 64,
              color: kColorTextLight.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text(AppStrings.noResults),
          const SizedBox(height: 8),
          const Text(
            AppStrings.popularContent,
            style: TextStyle(color: kColorTextLight),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final grouped = <String, List<dynamic>>{};
    for (final item in _results) {
      final kategori = (item['kategori'] ?? 'Lainnya').toString();
      grouped.putIfAbsent(kategori, () => []).add(item);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '${_results.length} hasil ditemukan',
          style: const TextStyle(color: kColorTextLight, fontSize: 13),
        ),
        const SizedBox(height: 12),
        for (final entry in grouped.entries) ...[
          Text(
            entry.key.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: kColorPrimary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          ...entry.value.map((item) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(item['judul'] ?? item['nama'] ?? ''),
                  subtitle: Text(item['asal'] ?? item['provinsi'] ?? ''),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context
                      .go(AppRoutes.budayaDetailPath(item['id'] ?? '')),
                ),
              )),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
