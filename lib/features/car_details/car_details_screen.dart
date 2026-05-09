import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/providers/providers.dart';
import '../../core/widgets/category_chip.dart';
import '../../core/widgets/primary_button.dart';
import '../../l10n/app_localizations.dart';
import '../home/data/sample_cars.dart';

class CarDetailsScreen extends ConsumerWidget {
  const CarDetailsScreen({super.key, required this.carId});

  final String carId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final car = ref.watch(carByIdProvider(carId));
    if (car == null) {
      return Scaffold(
        body: Center(child: Text('Car not found')),
      );
    }

    final startDate = ref.watch(bookingStartDateProvider);
    final endDate = ref.watch(bookingEndDateProvider);
    final days = (startDate != null && endDate != null)
        ? endDate.difference(startDate).inDays.clamp(1, 365)
        : 3;
    final dailyTotal = car.pricePerDay * days;
    final insurance = (car.pricePerDay * 0.15).round();
    final serviceFee = (car.pricePerDay * 0.08).round();
    final total = dailyTotal + insurance + serviceFee;

    return Scaffold(
      bottomNavigationBar: _BookNowBar(
        label: l10n.detailsBookNow,
        onBook: () {
          final s = startDate ?? DateTime.now().add(const Duration(days: 1));
          final e = endDate ?? s.add(const Duration(days: 3));
          ref.read(bookingStartDateProvider.notifier).state = s;
          ref.read(bookingEndDateProvider.notifier).state = e;
          context.push('/booking/confirm/$carId', extra: {
            'startDate': s,
            'endDate': e,
          });
        },
      ),
      body: CustomScrollView(
        slivers: [
          _Hero(car: car, onBack: () => context.pop()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TitleRow(car: car),
                  const SizedBox(height: AppSpacing.xl),
                  _Specs(car: car),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    l10n.detailsAbout,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: AppColors.neutral500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    car.description,
                    style: const TextStyle(
                      color: AppColors.neutral700,
                      height: 1.5,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _DatePickerCard(carId: carId),
                  const SizedBox(height: AppSpacing.xl),
                  _PaymentCard(
                    pricePerDay: car.pricePerDay,
                    days: days,
                    dailyTotal: dailyTotal,
                    insurance: insurance,
                    serviceFee: serviceFee,
                    total: total,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.car, required this.onBack});

  final CarListing car;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: false,
      automaticallyImplyLeading: false,
      expandedHeight: 300,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(imageUrl: car.imageUrl, fit: BoxFit.cover),
            Positioned(
              top: MediaQuery.paddingOf(context).top + AppSpacing.sm,
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleButton(icon: Icons.arrow_back_rounded, onTap: onBack),
                  _CircleButton(icon: Icons.favorite_outline_rounded, onTap: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white.withValues(alpha: 0.9),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: AppColors.neutral900, size: 22),
        ),
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.car});
  final CarListing car;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                car.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: carStatusColor(car.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: carStatusColor(car.status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    carStatusLabel(car.status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: carStatusColor(car.status),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Text(
              car.plateNumber,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.neutral500,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            const Icon(Icons.star_rounded, color: AppColors.star, size: 16),
            const SizedBox(width: 4),
            Text(
              car.rating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              AppL10n.of(context).carReviewsParen(car.reviewCount),
              style: const TextStyle(fontSize: 13, color: AppColors.neutral500),
            ),
          ],
        ),
      ],
    );
  }
}

class _Specs extends StatelessWidget {
  const _Specs({required this.car});
  final CarListing car;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        SpecChip(icon: Icons.event_seat_outlined, label: l10n.carSeats(car.seats)),
        SpecChip(
          icon: Icons.local_gas_station_outlined,
          label: '${(car.fuelLevel * 100).toInt()}%',
        ),
        SpecChip(icon: Icons.settings_outlined, label: car.transmission),
        SpecChip(icon: Icons.calendar_today_outlined, label: '${car.year}'),
      ],
    );
  }
}

class _DatePickerCard extends ConsumerWidget {
  const _DatePickerCard({required this.carId});
  final String carId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final startDate = ref.watch(bookingStartDateProvider);
    final endDate = ref.watch(bookingEndDateProvider);
    final fmt = DateFormat('dd MMM yyyy');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.detailsAvailability,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _DateField(
                  label: 'Pick-up',
                  value: startDate != null ? fmt.format(startDate) : 'Select date',
                  icon: Icons.calendar_today_outlined,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (picked != null) {
                      ref.read(bookingStartDateProvider.notifier).state = picked;
                      final end = ref.read(bookingEndDateProvider);
                      if (end == null || end.isBefore(picked.add(const Duration(days: 1)))) {
                        ref.read(bookingEndDateProvider.notifier).state =
                            picked.add(const Duration(days: 1));
                      }
                    }
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _DateField(
                  label: 'Return',
                  value: endDate != null ? fmt.format(endDate) : 'Select date',
                  icon: Icons.calendar_today_outlined,
                  onTap: () async {
                    final start = ref.read(bookingStartDateProvider) ??
                        DateTime.now().add(const Duration(days: 1));
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? start.add(const Duration(days: 1)),
                      firstDate: start.add(const Duration(days: 1)),
                      lastDate: start.add(const Duration(days: 90)),
                    );
                    if (picked != null) {
                      ref.read(bookingEndDateProvider.notifier).state = picked;
                    }
                  },
                ),
              ),
            ],
          ),
          if (startDate != null && endDate != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${endDate.difference(startDate).inDays} day${endDate.difference(startDate).inDays != 1 ? 's' : ''} rental',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.neutral50,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.neutral300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral500,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral900,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.pricePerDay,
    required this.days,
    required this.dailyTotal,
    required this.insurance,
    required this.serviceFee,
    required this.total,
  });

  final int pricePerDay;
  final int days;
  final int dailyTotal;
  final int insurance;
  final int serviceFee;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: AppColors.elevation1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.detailsPaymentSummary,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: AppColors.neutral500,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Line(label: l10n.detailsDailyLine('$pricePerDay', days), value: dailyTotal),
          const SizedBox(height: AppSpacing.sm),
          _Line(label: l10n.detailsInsurance, value: insurance),
          const SizedBox(height: AppSpacing.sm),
          _Line(label: l10n.detailsServiceFee, value: serviceFee),
          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.neutral200),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.detailsTotal,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                ),
              ),
              Text(
                '₸ ${_formatPrice(total)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: AppColors.neutral700)),
        ),
        Text(
          '₸ ${_formatPrice(value)}',
          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.neutral900),
        ),
      ],
    );
  }
}

String _formatPrice(int value) {
  final str = value.toString();
  final buf = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buf.write(',');
    buf.write(str[i]);
  }
  return buf.toString();
}

class _BookNowBar extends StatelessWidget {
  const _BookNowBar({required this.onBook, required this.label});
  final VoidCallback onBook;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: const Border(
          top: BorderSide(color: AppColors.neutral200, width: 0.5),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.md, AppSpacing.lg,
        MediaQuery.paddingOf(context).bottom + AppSpacing.md,
      ),
      child: PrimaryButton(label: label, onPressed: onBook),
    );
  }
}
