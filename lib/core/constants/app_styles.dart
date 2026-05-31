import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppStyles {
  AppStyles._();

  // ── Border Radius ────────────────────────────────────────────────────
  static const radiusS = 8.0;
  static const radiusM = 12.0;
  static const radiusL = 16.0;
  static const radiusXL = 24.0;

  // ── Text Styles ──────────────────────────────────────────────────────
  static const heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: kColorText,
  );

  static const heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: kColorText,
  );

  static const heading3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: kColorText,
  );

  static const bodyText = TextStyle(
    fontSize: 14,
    height: 1.6,
    color: kColorText,
  );

  static const caption = TextStyle(
    fontSize: 12,
    color: kColorTextLight,
  );

  static const captionSmall = TextStyle(
    fontSize: 11,
    color: kColorTextLight,
  );

  static const label = TextStyle(
    fontSize: 13,
    color: kColorTextLight,
  );

  static const brandTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: kColorPrimary,
    fontFamily: 'CinzelDecorative',
  );

  // ── Box Decorations ──────────────────────────────────────────────────
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: kColorSurface,
        borderRadius: BorderRadius.circular(radiusM),
        border: Border.all(color: kColorSecondary.withValues(alpha: 0.3)),
      );

  static BoxDecoration get sectionDecoration => BoxDecoration(
        color: kColorSurface,
        borderRadius: BorderRadius.circular(radiusL),
        border: Border.all(color: kColorSecondary.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );

  static BoxDecoration get gradientBanner => BoxDecoration(
        gradient: const LinearGradient(
          colors: [kColorPrimary, Color(0xFFB22222)],
        ),
        borderRadius: BorderRadius.circular(radiusL),
      );

  static BoxDecoration tagDecoration(Color color) => BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(radiusL),
      );

  static BoxDecoration statusDecoration(Color color) => BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(radiusM),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      );
}
