import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Standard white card with rounded corners, neutral border, and elevation-1 shadow.
///
/// Use this for the common white/neutral card pattern.
/// Do NOT use for gradient cards or cards with unusual shapes.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.elevation,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    // M6.D: use colorScheme.surface as default so card is theme-aware in dark mode
    final effectiveColor = color ?? Theme.of(context).colorScheme.surface;
    return Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: elevation == null || elevation! > 0
            ? AppColors.elevation1
            : null,
      ),
      child: child,
    );
  }
}
