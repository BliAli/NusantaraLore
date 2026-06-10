import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/database/sqlite_service.dart';
import '../../../core/utils/location_utils.dart';
import '../../../shared/widgets/app_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _nearbyBudaya = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final allBudaya = await SqliteService.query('budaya');
      final pos = await LocationUtils.getCurrentPosition();

      if (pos != null) {
        final withDistance = allBudaya.where((b) {
          return b['lat'] != null && b['lng'] != null;
        }).map((b) {
          final distance = LocationUtils.haversineDistance(
            pos.latitude,
            pos.longitude,
            (b['lat'] as num).toDouble(),
            (b['lng'] as num).toDouble(),
          );
          return {...b, 'distance': distance};
        }).toList();

        withDistance.sort((a, b) =>
            (a['distance'] as double).compareTo(b['distance'] as double));

        // Filter hanya budaya dalam radius 10 km
        final nearby = withDistance
            .where((b) => (b['distance'] as double) <= 10.0)
            .take(10)
            .toList();

        if (mounted) {
          setState(() {
            _nearbyBudaya = nearby;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _nearbyBudaya = allBudaya.take(10).toList();
            _isLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorBackground,
      appBar: AppBar(
        title: const Text(
          AppStrings.appName,
          style: TextStyle(fontFamily: 'CinzelDecorative'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.go(AppRoutes.search),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NGradientBanner(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selamat Datang!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'CinzelDecorative',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.tagline,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.go(AppRoutes.explore),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kColorSecondary,
                        foregroundColor: kColorText,
                      ),
                      child: const Text('Mulai Jelajah'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  NQuickAction(
                    icon: Icons.map,
                    label: 'Peta',
                    onTap: () => context.go(AppRoutes.map),
                  ),
                  const SizedBox(width: 12),
                  NQuickAction(
                    icon: Icons.sports_esports,
                    label: 'Arena',
                    onTap: () => context.go(AppRoutes.games),
                  ),
                  const SizedBox(width: 12),
                  NQuickAction(
                    icon: Icons.auto_awesome,
                    label: 'Ki Dalang',
                    onTap: () => context.go(AppRoutes.penjaga),
                  ),
                  const SizedBox(width: 12),
                  NQuickAction(
                    icon: Icons.currency_exchange,
                    label: 'Konversi',
                    onTap: () => context.go(AppRoutes.converter),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                AppStrings.nearbyBudaya,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kColorText,
                ),
              ),
              const SizedBox(height: 12),
              NAsyncView(
                isLoading: _isLoading,
                isEmpty: _nearbyBudaya.isEmpty,
                emptyState: const NEmptyState(
                  icon: Icons.explore_off,
                  message: 'Tidak ada budaya dalam radius 10 km.\nCoba jelajahi peta untuk menemukan!',
                ),
                child: Column(
                  children: _nearbyBudaya.map((b) {
                    final distance = b['distance'] as double?;
                    final sub = distance != null
                        ? '${b['provinsi'] ?? ''} • ${LocationUtils.formatDistance(distance)}'
                        : b['provinsi'] ?? '';
                    return NBudayaCard(
                      title: b['nama'] ?? '',
                      subtitle: sub,
                      imageAsset: b['gambar_url'] as String?,
                      onTap: () =>
                          context.go(AppRoutes.budayaDetailPath(b['id'] ?? '')),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
