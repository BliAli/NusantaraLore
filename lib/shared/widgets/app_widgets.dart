import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';

// ── Empty State ──────────────────────────────────────────────────────────
class NEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final Widget? action;

  const NEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: kColorTextLight.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: kColorTextLight),
            ),
            if (action != null) ...[
              const SizedBox(height: 16),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

// ── Async View (loading / empty / content) ───────────────────────────────
class NAsyncView extends StatelessWidget {
  final bool isLoading;
  final bool isEmpty;
  final Widget emptyState;
  final Widget child;

  const NAsyncView({
    super.key,
    required this.isLoading,
    this.isEmpty = false,
    required this.emptyState,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (isEmpty) return emptyState;
    return child;
  }
}

// ── Loading Button ───────────────────────────────────────────────────────
class NLoadingButton extends StatelessWidget {
  final bool isLoading;
  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final IconData? icon;

  const NLoadingButton({
    super.key,
    required this.isLoading,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Text(label);

    final style = backgroundColor != null
        ? ElevatedButton.styleFrom(backgroundColor: backgroundColor)
        : null;

    if (icon != null && !isLoading) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: isLoading ? null : onPressed,
          icon: Icon(icon),
          label: Text(label),
          style: style,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: style,
        child: child,
      ),
    );
  }
}

// ── Section Card ─────────────────────────────────────────────────────────
class NSectionCard extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final Widget child;
  final EdgeInsets padding;

  const NSectionCard({
    super.key,
    this.title,
    this.icon,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: AppStyles.sectionDecoration,
      child: title != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (icon != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kColorPrimary.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppStyles.radiusS + 2),
                        ),
                        child: Icon(icon, color: kColorPrimary, size: 20),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Text(title!, style: AppStyles.heading3),
                  ],
                ),
                const SizedBox(height: 20),
                child,
              ],
            )
          : child,
    );
  }
}

// ── Gradient Header Banner ───────────────────────────────────────────────
class NGradientBanner extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const NGradientBanner({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: AppStyles.gradientBanner,
      child: child,
    );
  }
}

// ── Budaya Card ──────────────────────────────────────────────────────────
class NBudayaCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imageAsset;
  final String? trailing;
  final VoidCallback? onTap;
  final double imageSize;

  const NBudayaCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.imageAsset,
    this.trailing,
    this.onTap,
    this.imageSize = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: _buildImage(),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: trailing != null
            ? Text(trailing!, style: AppStyles.caption)
            : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      width: imageSize,
      height: imageSize,
      decoration: BoxDecoration(
        color: kColorPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppStyles.radiusS),
      ),
      child: _imageOrFallback(),
    );
  }

  Widget _imageOrFallback() {
    if (imageAsset != null && imageAsset!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppStyles.radiusS),
        child: Image.asset(
          imageAsset!,
          width: imageSize,
          height: imageSize,
          fit: BoxFit.cover,
          errorBuilder: (_, error, stackTrace) =>
              const Icon(Icons.auto_stories, color: kColorPrimary),
        ),
      );
    }
    return const Icon(Icons.auto_stories, color: kColorPrimary);
  }
}

// ── Stat Card ────────────────────────────────────────────────────────────
class NStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const NStatCard({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: AppStyles.cardDecoration,
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: valueColor ?? kColorPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: AppStyles.caption),
          ],
        ),
      ),
    );
  }
}

// ── Menu Item Tile ───────────────────────────────────────────────────────
class NMenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  const NMenuTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? kColorPrimary),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

// ── Quick Action Button ──────────────────────────────────────────────────
class NQuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const NQuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: AppStyles.cardDecoration,
          child: Column(
            children: [
              Icon(icon, color: kColorPrimary, size: 28),
              const SizedBox(height: 4),
              Text(label, style: AppStyles.caption),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Snackbar Helpers ─────────────────────────────────────────────────────
void showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: kColorSuccess),
  );
}

void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: kColorError),
  );
}
