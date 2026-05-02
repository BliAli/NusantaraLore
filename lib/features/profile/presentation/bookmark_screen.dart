import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/database/hive_service.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  List<Map<String, dynamic>> _bookmarked = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final ids = List<String>.from(HiveService.bookmark.get('ids') ?? []);
    if (ids.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final jsonString =
          await rootBundle.loadString('assets/data/legenda.json');
      final data = json.decode(jsonString);
      final legenda = data['legenda'] as List<dynamic>? ?? [];

      final items = <Map<String, dynamic>>[];
      for (final item in legenda) {
        if (ids.contains(item['id'])) {
          items.add(Map<String, dynamic>.from(item));
        }
      }

      if (mounted) {
        setState(() {
          _bookmarked = items;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorBackground,
      appBar: AppBar(title: const Text('Bookmark')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookmarked.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bookmark_border,
                          size: 64,
                          color: kColorTextLight.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum ada bookmark.\nTambahkan dari halaman detail budaya.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: kColorTextLight),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bookmarked.length,
                  itemBuilder: (context, index) {
                    final item = _bookmarked[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: kColorPrimary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: (item['gambar'] != null &&
                                  (item['gambar'] as String).isNotEmpty)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    item['gambar'],
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                        Icons.auto_stories,
                                        color: kColorPrimary),
                                  ),
                                )
                              : const Icon(Icons.auto_stories,
                                  color: kColorPrimary),
                        ),
                        title: Text(
                          item['judul'] ?? item['nama'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle:
                            Text(item['asal'] ?? item['provinsi'] ?? ''),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context
                            .go(AppRoutes.budayaDetailPath(item['id'] ?? '')),
                      ),
                    );
                  },
                ),
    );
  }
}
