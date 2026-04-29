import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class WayangIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;

  const WayangIcon({
    super.key,
    required this.icon,
    this.size = 24,
    this.color = kColorPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Icon(icon, size: size, color: color),
    );
  }
}
