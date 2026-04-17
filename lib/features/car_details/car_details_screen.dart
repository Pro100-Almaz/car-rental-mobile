import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/category_chip.dart';
import '../../core/widgets/primary_button.dart';
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
    final CarListing car = _car;
    final double dailyTotal = car.pricePerDay * 3;
    final double insurance = 30;
    final double serviceFee = 15;
    final double total = dailyTotal + insurance + serviceFee;

    return Scaffold(
      backgroundColor: AppColors.surface,
      bottomNavigationBar: _BookNowBar(
        onBook: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booked ${car.name}!')),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          _Hero(car: car, onBack: () => context.pop()),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -48),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
                ),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xxl,
                  AppSpacing.xl,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TitleRow(car: car),
                    const SizedBox(height: AppSpacing.xxl),
                    _Specs(car: car),
                    const SizedBox(height: AppSpacing.xxl),
                    const _SectionLabel('ABOUT THIS VEHICLE'),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      car.description,
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    const _AvailabilityCard(),
                    const SizedBox(height: AppSpacing.xxl),
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
      backgroundColor: AppColors.surface,
      expandedHeight: 397,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(imageUrl: car.imageUrl, fit: BoxFit.cover),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 128,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, AppColors.surface],
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.paddingOf(context).top + AppSpacing.md,
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: onBack,
                    color: AppColors.onSurface,
                  ),
                  _CircleButton(
                    icon: Icons.favorite_rounded,
                    onTap: () {},
                    color: AppColors.secondary,
                    background: AppColors.secondaryContainer.withValues(alpha: 0.18),
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
  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.color,
    this.background,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Material(
          color: background ?? AppColors.surface.withValues(alpha: 0.7),
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Icon(icon, color: color, size: 22),
            ),
          ),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                car.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: AppColors.secondary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    car.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '(${car.reviewCount} reviews)',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surfaceContainerLowest, width: 2),
                boxShadow: AppColors.softShadow,
              ),
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                imageUrl: car.ownerAvatarUrl,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surfaceContainerLowest, width: 2),
                ),
                child: const Icon(Icons.verified_rounded, size: 10, color: Colors.white),
              ),
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
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          SpecChip(icon: Icons.event_seat_rounded, label: '${car.seats} Seats'),
          const SizedBox(width: AppSpacing.md),
          SpecChip(
            icon: car.category == 'electric'
                ? Icons.electric_car_rounded
                : Icons.local_gas_station_rounded,
            label: car.category == 'electric' ? 'Electric' : 'Petrol',
          ),
          const SizedBox(width: AppSpacing.md),
          SpecChip(icon: Icons.settings_rounded, label: car.transmission),
          const SizedBox(width: AppSpacing.md),
          SpecChip(icon: Icons.calendar_today_rounded, label: '${car.year}'),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}

class _AvailabilityCard extends StatelessWidget {
  const _AvailabilityCard();

  static const List<String> _dayLabels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Availability',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              const Text(
                'September 2024',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: _dayLabels
                .map(
                  (l) => Expanded(
                    child: Text(
                      l.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.md),
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
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: List.generate(7, (i) {
                final int idx = row * 7 + i;
                final int day = _days[idx];
                final bool placeholder = day > 25 && row == 0 && i < 3;
                final bool isSelected = _selected.contains(day);
                return Expanded(
                  child: Container(
                    height: 32,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryContainer.withValues(alpha: 0.18)
                          : Colors.transparent,
                      borderRadius: BorderRadius.horizontal(
                        left: isSelected && day == _selected.first
                            ? const Radius.circular(AppRadius.pill)
                            : Radius.zero,
                        right: isSelected && day == _selected.last
                            ? const Radius.circular(AppRadius.pill)
                            : Radius.zero,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                        color: placeholder
                            ? AppColors.onSurfaceVariant.withValues(alpha: 0.3)
                            : isSelected
                                ? AppColors.primary
                                : AppColors.onSurface,
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

  final double pricePerDay;
  final double dailyTotal;
  final double insurance;
  final double serviceFee;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PAYMENT SUMMARY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _Line(
            label: '\$${pricePerDay.toStringAsFixed(0)}/day x 3 days',
            value: dailyTotal,
          ),
          const SizedBox(height: AppSpacing.md),
          _Line(label: 'Insurance', value: insurance),
          const SizedBox(height: AppSpacing.md),
          _Line(label: 'Service Fee', value: serviceFee),
          const SizedBox(height: AppSpacing.lg),
          Divider(color: AppColors.surfaceVariant.withValues(alpha: 0.6)),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
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
  final double value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.onSurfaceVariant),
          ),
        ),
        Text(
          '\$${value.toStringAsFixed(0)}',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _BookNowBar extends StatelessWidget {
  const _BookNowBar({required this.onBook});
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          color: AppColors.surface.withValues(alpha: 0.85),
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            MediaQuery.paddingOf(context).bottom + AppSpacing.lg,
          ),
          child: PrimaryButton(
            label: 'Book Now',
            icon: Icons.bolt_rounded,
            onPressed: onBook,
          ),
        ),
      ),
    );
  }
}
