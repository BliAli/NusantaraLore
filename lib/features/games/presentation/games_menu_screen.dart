import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';

class GamesMenuScreen extends StatelessWidget {
  const GamesMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorBackground,
      appBar: AppBar(
        title: const Text('Arena Budaya'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildGameCard(
              context,
              title: AppStrings.kuisMitosFakta,
              description: 'Uji pengetahuanmu tentang mitos dan fakta budaya Nusantara!',
              icon: Icons.quiz,
              color: kColorPrimary,
              onTap: () => context.go(AppRoutes.kuisMitos),
            ),
            const SizedBox(height: 16),
            _buildGameCard(
              context,
              title: AppStrings.puzzleBatik,
              description: 'Susun potongan motif batik yang teracak!',
              icon: Icons.grid_view,
              color: kColorAccent,
              onTap: () => context.go(AppRoutes.puzzleBatik),
            ),
            const SizedBox(height: 16),
            _buildGameCard(
              context,
              title: AppStrings.tebakWayang,
              description: 'Tebak nama wayang dari siluetnya!',
              icon: Icons.theater_comedy,
              color: kColorSecondary,
              onTap: () => context.go(AppRoutes.tebakWayang),
            ),
            const Spacer(),
            InkWell(
              onTap: () => context.go(AppRoutes.leaderboard),
              borderRadius: BorderRadius.circular(12),
              child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kColorSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kColorSecondary.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.emoji_events, color: kColorSecondary, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.leaderboard,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Lihat peringkat pemain teratas',
                          style: TextStyle(fontSize: 12, color: kColorTextLight),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right),
                ],
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: kColorTextLight,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.play_arrow, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
