import 'package:flutter/material.dart';

import '../formatters/money.dart';
import '../theme/app_colors.dart';

/// Renders a KZT price using the canonical [formatKzt] formatter.
///
/// [showSymbol] controls whether the ₸ prefix is shown.
class PriceText extends StatelessWidget {
  const PriceText({
    super.key,
    required this.amount,
    this.style,
    this.showSymbol = true,
  });

  final int amount;
  final TextStyle? style;
  final bool showSymbol;

  @override
  Widget build(BuildContext context) {
    return Text(
      formatKzt(amount, symbol: showSymbol),
      style: style ??
          const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
    );
  }
}
