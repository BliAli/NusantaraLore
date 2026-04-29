import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/database/sqlite_service.dart';

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
      final budaya = await SqliteService.query(
        'budaya',
        limit: 10,
        orderBy: 'created_at DESC',
      );
      if (mounted) {
        setState(() {
          _nearbyBudaya = budaya;
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kColorPrimary, Color(0xFFB22222)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
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
                  _buildQuickAction(
                    icon: Icons.map,
                    label: 'Peta',
                    onTap: () => context.go(AppRoutes.map),
                  ),
                  const SizedBox(width: 12),
                  _buildQuickAction(
                    icon: Icons.sports_esports,
                    label: 'Arena',
                    onTap: () => context.go(AppRoutes.games),
                  ),
                  const SizedBox(width: 12),
                  _buildQuickAction(
                    icon: Icons.auto_awesome,
                    label: 'Ki Dalang',
                    onTap: () => context.go(AppRoutes.penjaga),
                  ),
                  const SizedBox(width: 12),
                  _buildQuickAction(
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
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_nearbyBudaya.isEmpty)
                _buildEmptyState()
              else
                ..._nearbyBudaya.map(_buildBudayaCard),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: kColorSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kColorSecondary.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: kColorPrimary, size: 28),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudayaCard(Map<String, dynamic> budaya) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: kColorPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.temple_buddhist, color: kColorPrimary),
        ),
        title: Text(
          budaya['nama'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(budaya['provinsi'] ?? ''),
        trailing: const Icon(Icons.chevron_right),
        onTap: () =>
            context.go(AppRoutes.budayaDetailPath(budaya['id'] ?? '')),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.explore_off,
                size: 64, color: kColorTextLight.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text(
              'Belum ada data budaya.\nMulai jelajah untuk menemukan!',
              textAlign: TextAlign.center,
              style: TextStyle(color: kColorTextLight),
            ),
          ],
        ),
      ),
    );
  }
}
