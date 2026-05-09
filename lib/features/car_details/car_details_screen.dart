import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/category_chip.dart';
import '../../core/widgets/primary_button.dart';
import '../../l10n/app_localizations.dart';
import '../home/data/sample_cars.dart';

class CarDetailsScreen extends StatelessWidget {
  const CarDetailsScreen({super.key, required this.carId});

  final String carId;

  CarListing get _car => [...kNearbyCars, ...kTopRated].firstWhere(
        (c) => c.id == carId,
        orElse: () => kNearbyCars.first,
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final CarListing car = _car;
    final int dailyTotal = car.pricePerDay * 3;
    const int insurance = 3000;
    const int serviceFee = 1500;
    final int total = dailyTotal + insurance + serviceFee;

    return Scaffold(
      bottomNavigationBar: _BookNowBar(
        label: l10n.detailsBookNow,
        onBook: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.detailsBookedToast(car.name))),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          _Hero(car: car, onBack: () => context.pop()),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
              ),
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
                  const _AvailabilityCard(),
                  const SizedBox(height: AppSpacing.xl),
                  _PaymentCard(
                    pricePerDay: car.pricePerDay,
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
                  _CircleButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: onBack,
                  ),
                  _CircleButton(
                    icon: Icons.favorite_outline_rounded,
                    onTap: () {},
                  ),
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

class _AvailabilityCard extends StatelessWidget {
  const _AvailabilityCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final List<String> dayLabels = [
      l10n.dayMon, l10n.dayTue, l10n.dayWed,
      l10n.dayThu, l10n.dayFri, l10n.daySat, l10n.daySun,
    ];
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
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.detailsAvailability,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral900,
                  ),
                ),
              ),
              Text(
                l10n.detailsCalendarMonth,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 20),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: dayLabels
                .map(
                  (l) => Expanded(
                    child: Text(
                      l,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral500,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.sm),
          _CalendarGrid(),
        ],
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  static const List<int> _days = [
    28, 29, 30, 1, 2, 3, 4,
    5, 6, 7, 8, 9, 10, 11,
  ];

  static const Set<int> _selected = {7, 8, 9};

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int row = 0; row < 2; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              children: List.generate(7, (i) {
                final int idx = row * 7 + i;
                final int day = _days[idx];
                final bool placeholder = day > 25 && row == 0 && i < 3;
                final bool isSelected = _selected.contains(day);
                return Expanded(
                  child: Container(
                    height: 36,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryLight
                          : Colors.transparent,
                      borderRadius: BorderRadius.horizontal(
                        left: isSelected && day == _selected.first
                            ? const Radius.circular(AppRadius.md)
                            : Radius.zero,
                        right: isSelected && day == _selected.last
                            ? const Radius.circular(AppRadius.md)
                            : Radius.zero,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                        color: placeholder
                            ? AppColors.neutral300
                            : isSelected
                                ? AppColors.primary
                                : AppColors.neutral900,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.pricePerDay,
    required this.dailyTotal,
    required this.insurance,
    required this.serviceFee,
    required this.total,
  });

  final int pricePerDay;
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
          _Line(label: l10n.detailsDailyLine('$pricePerDay', 3), value: dailyTotal),
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
        border: Border(
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
