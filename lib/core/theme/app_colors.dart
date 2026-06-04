import 'package:flutter/material.dart';

/// AutoFleet design system color tokens.
class AppColors {
  AppColors._();

  // Primary — Blue (trust, technology, professional)
  static const Color primary = Color(0xFF1A73E8);
  static const Color primaryDark = Color(0xFF1557B0);
  static const Color primaryLight = Color(0xFFE8F0FE);

  // Secondary — Teal (growth, freshness, action)
  static const Color secondary = Color(0xFF00BFA5);
  static const Color secondaryDark = Color(0xFF00897B);
  static const Color secondaryLight = Color(0xFFE0F7FA);

  // Neutrals
  static const Color neutral900 = Color(0xFF1A1A2E);
  static const Color neutral700 = Color(0xFF4A4A68);
  // neutral600: #52525B — WCAG 4.5:1 on white, used for body/hint text instead
  // of neutral500 (#8E8EA0) which fails contrast on white backgrounds.
  static const Color neutral600 = Color(0xFF52525B);
  static const Color neutral500 = Color(0xFF8E8EA0);
  static const Color neutral300 = Color(0xFFD1D1DB);
  static const Color neutral200 = Color(0xFFE8E8EE);
  static const Color neutral100 = Color(0xFFF4F4F8);
  static const Color neutral50 = Color(0xFFFAFAFE);
  static const Color white = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFEAB308);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);

  // Vehicle status
  static const Color statusAvailable = Color(0xFF16A34A);
  static const Color statusReserved = Color(0xFF7C3AED);
  static const Color statusRented = Color(0xFF2563EB);
  static const Color statusReturning = Color(0xFFEAB308);
  static const Color statusInService = Color(0xFFF97316);
  static const Color statusInWash = Color(0xFF06B6D4);
  static const Color statusDecommissioned = Color(0xFF6B7280);

  // Neutral 400 (between 300 and 500)
  static const Color neutral400 = Color(0xFFB0B0C0);

  // Star / rating
  static const Color star = Color(0xFFEAB308);

  // Dark mode
  static const Color darkBackground = Color(0xFF0F0F1A);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkSurfaceAlt = Color(0xFF242444);
  static const Color darkBorder = Color(0xFF2D2D4A);
  static const Color darkTextPrimary = Color(0xFFE8E8F0);
  static const Color darkTextSecondary = Color(0xFF8E8EA0);

  // Semantic aliases for easy migration
  static const Color onPrimary = white;
  static const Color surface = neutral100;
  static const Color onSurface = neutral900;
  static const Color onSurfaceVariant = neutral700;
  static const Color outline = neutral500;
  static const Color outlineVariant = neutral300;

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  // Elevation shadows (from spec)
  static const List<BoxShadow> elevation1 = [
    BoxShadow(color: Color(0x14000000), blurRadius: 3, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> elevation2 = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> elevation3 = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 24, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> elevation4 = [
    BoxShadow(color: Color(0x29000000), blurRadius: 48, offset: Offset(0, 16)),
  ];
}
