import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.neutral100,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        onSecondary: AppColors.white,
        secondaryContainer: AppColors.secondaryLight,
        surface: AppColors.neutral50,
        onSurface: AppColors.neutral900,
        error: AppColors.error,
        onError: AppColors.white,
        outline: AppColors.neutral500,
        outlineVariant: AppColors.neutral300,
        surfaceContainerLowest: AppColors.white,
        surfaceContainerLow: AppColors.neutral50,
        surfaceContainer: AppColors.neutral100,
        surfaceContainerHigh: AppColors.neutral200,
        surfaceContainerHighest: AppColors.neutral300,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 28, fontWeight: FontWeight.w600,
          height: 34 / 28, color: AppColors.neutral900,
        ),
        headlineLarge: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w600,
          height: 28 / 22, color: AppColors.neutral900,
        ),
        headlineMedium: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600,
          height: 24 / 18, color: AppColors.neutral900,
        ),
        bodyLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w400,
          height: 22 / 16, color: AppColors.neutral900,
        ),
        bodyMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w400,
          height: 20 / 14, color: AppColors.neutral700,
        ),
        labelLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600,
          color: AppColors.neutral900,
        ),
        labelSmall: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600,
          letterSpacing: 0.5, color: AppColors.neutral500,
        ),
        bodySmall: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w400,
          height: 18 / 13, color: AppColors.neutral700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.neutral50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(
          color: AppColors.neutral500,
          fontWeight: FontWeight.w400,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.neutral300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.neutral300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.white,
        primaryContainer: AppColors.primaryDark,
        secondary: AppColors.secondary,
        onSecondary: AppColors.white,
        secondaryContainer: AppColors.secondaryDark,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.error,
        onError: AppColors.white,
        outline: AppColors.darkBorder,
        outlineVariant: AppColors.darkBorder,
        surfaceContainerLowest: AppColors.darkBackground,
        surfaceContainerLow: AppColors.darkSurface,
        surfaceContainer: AppColors.darkSurfaceAlt,
        surfaceContainerHigh: AppColors.darkSurfaceAlt,
        surfaceContainerHighest: AppColors.darkBorder,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 28, fontWeight: FontWeight.w600,
          height: 34 / 28, color: AppColors.darkTextPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w600,
          height: 28 / 22, color: AppColors.darkTextPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600,
          height: 24 / 18, color: AppColors.darkTextPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w400,
          height: 22 / 16, color: AppColors.darkTextPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w400,
          height: 20 / 14, color: AppColors.darkTextSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
        labelSmall: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600,
          letterSpacing: 0.5, color: AppColors.darkTextSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w400,
          height: 18 / 13, color: AppColors.darkTextSecondary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(
          color: AppColors.darkTextSecondary,
          fontWeight: FontWeight.w400,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }
}
