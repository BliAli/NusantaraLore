import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/database/hive_service.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../../shared/widgets/app_widgets.dart';

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
      body: NAsyncView(
        isLoading: _isLoading,
        isEmpty: _bookmarked.isEmpty,
        emptyState: const NEmptyState(
          icon: Icons.bookmark_border,
          message: 'Belum ada bookmark.\nTambahkan dari halaman detail budaya.',
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _bookmarked.length,
          itemBuilder: (context, index) {
            final item = _bookmarked[index];
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
    );
  }
}
