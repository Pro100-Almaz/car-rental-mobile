import 'package:flutter/material.dart';

/// Editorial Fluidity palette (Stitch CarShare design system).
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF00685F);
  static const Color primaryContainer = Color(0xFF008378);
  static const Color primaryFixedDim = Color(0xFF66D9CA);
  static const Color primaryFixed = Color(0xFF84F6E6);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFF4FFFC);

  static const Color secondary = Color(0xFFAC331D);
  static const Color secondaryContainer = Color(0xFFFE6E52);
  static const Color onSecondary = Color(0xFFFFFFFF);

  static const Color tertiary = Color(0xFF934626);

  static const Color error = Color(0xFFBA1A1A);

  static const Color surface = Color(0xFFF8F9FA);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F4F5);
  static const Color surfaceContainer = Color(0xFFEDEEEF);
  static const Color surfaceContainerHigh = Color(0xFFE7E8E9);
  static const Color surfaceContainerHighest = Color(0xFFE1E3E4);
  static const Color surfaceVariant = Color(0xFFE1E3E4);

  static const Color onSurface = Color(0xFF191C1D);
  static const Color onSurfaceVariant = Color(0xFF3D4947);
  static const Color outline = Color(0xFF6D7A77);
  static const Color outlineVariant = Color(0xFFBCC9C6);

  static const Color star = Color(0xFFFFB400);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryContainer],
  );

  static const List<BoxShadow> cloudShadow = [
    BoxShadow(
      color: Color(0x0F191C1D),
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
  ];

  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x08191C1D),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];
}
