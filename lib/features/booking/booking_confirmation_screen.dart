import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/models/car.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/primary_button.dart';

/// Post-submit success screen shown after a booking request is created.
/// Route: /cars/:id/book/confirm
class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({
    super.key,
    required this.carId,
    required this.bookingId,
    required this.startDate,
    required this.endDate,
    this.car,
    this.estimatedTotal,
  });

  final String carId;
  final String bookingId;
  final DateTime startDate;
  final DateTime endDate;

  /// Optional — passed via route extra when available
  final CarListing? car;
  final int? estimatedTotal;

  @override
  Widget build(BuildContext context) {
    final days =
        endDate.difference(startDate).inDays.clamp(1, 30);
    final fmt = DateFormat('d MMM yyyy');

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Spacer(),

              // Success icon
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 56,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Headline
              const Text(
                'Booking request submitted!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Subtitle
              const Text(
                'A manager will review your request and contact you to confirm. You will receive a notification.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.neutral500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Booking summary card
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.neutral200),
                ),
                child: Column(
                  children: [
                    if (car != null) ...[
                      _SummaryRow(
                        label: 'Vehicle',
                        value: car!.displayTitle,
                        bold: true,
                      ),
                      const Divider(height: AppSpacing.xl),
                    ],
                    _SummaryRow(
                      label: 'Start date',
                      value: fmt.format(startDate),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _SummaryRow(
                      label: 'End date',
                      value: fmt.format(endDate),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _SummaryRow(
                      label: 'Duration',
                      value: '$days ${days == 1 ? 'day' : 'days'}',
                    ),
                    if (estimatedTotal != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _SummaryRow(
                        label: 'Estimated total',
                        value:
                            '₸${NumberFormat('#,##0', 'ru').format(estimatedTotal)}',
                        bold: true,
                        valueColor: AppColors.primary,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    _SummaryRow(
                      label: 'Status',
                      value: 'Pending review',
                      valueColor: const Color(0xFFD97706),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // CTAs
              PrimaryButton(
                label: 'View booking',
                onPressed: () => context.go('/bookings/$bookingId'),
                icon: Icons.arrow_forward_rounded,
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => context.go('/cars'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.neutral700,
                    side: const BorderSide(color: AppColors.neutral300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Back to cars',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
                fontSize: 13, color: AppColors.neutral500),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: valueColor ?? AppColors.neutral900,
          ),
        ),
      ],
    );
  }
}
