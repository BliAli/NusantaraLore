import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/database/hive_service.dart';
import '../../../core/database/sqlite_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  List<String> _searchHistory = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _isLoading = true);
    _saveHistory(query.trim());

    final rows = await SqliteService.search(query.trim());
    if (mounted) {
      setState(() {
        _results = rows;
        _isLoading = false;
      });
    }
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
    final grouped = <String, List<Map<String, dynamic>>>{};
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
                  title: Text(item['nama'] ?? ''),
                  subtitle: Text(item['provinsi'] ?? ''),
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
