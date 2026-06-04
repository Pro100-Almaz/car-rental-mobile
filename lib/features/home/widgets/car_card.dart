import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/models/car.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';

class CarFeatureCard extends StatelessWidget {
  const CarFeatureCard({super.key, required this.car, this.onTap});

  final CarListing car;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return SizedBox(
      width: 260,
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 160,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: car.primaryPhoto,
                      fit: BoxFit.cover,
                      placeholder: (ctx, ph) =>
                          Container(color: AppColors.neutral200),
                      errorWidget: (ctx, err, trace) =>
                          Container(color: AppColors.neutral200),
                    ),
                    Positioned(
                      top: AppSpacing.sm,
                      left: AppSpacing.sm,
                      child: _StatusBadge(status: car.status),
                    ),
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: _RatingBadge(rating: car.rating),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            car.displayTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral900,
                            ),
                          ),
                        ),
                        Text(
                          '₸${car.dailyRate}${l10n.carPerDay}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          car.maskedPlate,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.neutral500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        _InfoChip(
                          icon: Icons.local_gas_station_outlined,
                          label: _fuelLabel(car.fuelType),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _InfoChip(
                          icon: Icons.settings_outlined,
                          label: _transmissionLabel(car.transmission),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _InfoChip(
                          icon: Icons.event_seat_outlined,
                          label: '${car.seats}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final CarStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: carStatusColor(status),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            carStatusLabel(status),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: AppColors.elevation1,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.star, size: 14),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.neutral500),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.neutral700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class CarListTile extends StatelessWidget {
  const CarListTile({super.key, required this.car, this.onTap});

  final CarListing car;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: CachedNetworkImage(
                  imageUrl: car.primaryPhoto,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorWidget: (ctx, err, trace) =>
                      Container(color: AppColors.neutral200),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            car.displayTitle,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral900,
                            ),
                          ),
                        ),
                        Text(
                          '₸${car.dailyRate}${l10n.carPerDay}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${car.maskedPlate} • ${_categoryLabel(l10n, car.category)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.neutral500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        const Icon(Icons.local_gas_station_outlined,
                            size: 14, color: AppColors.neutral500),
                        const SizedBox(width: 2),
                        Text(
                          _fuelLabel(car.fuelType),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.neutral500,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        const Icon(Icons.settings_outlined,
                            size: 14, color: AppColors.neutral500),
                        const SizedBox(width: 2),
                        Text(
                          _transmissionLabel(car.transmission),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.neutral500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _categoryLabel(AppL10n l10n, VehicleCategory category) {
  switch (category) {
    case VehicleCategory.economy:
      return l10n.categoryEconomy;
    case VehicleCategory.comfort:
      return l10n.categoryComfort;
    case VehicleCategory.business:
      return l10n.categoryBusiness;
    case VehicleCategory.suv:
      return l10n.categorySuv;
    case VehicleCategory.minivan:
      return 'Minivan';
  }
}

String _fuelLabel(FuelType f) {
  switch (f) {
    case FuelType.petrol:
      return 'Petrol';
    case FuelType.diesel:
      return 'Diesel';
    case FuelType.hybrid:
      return 'Hybrid';
    case FuelType.electric:
      return 'Electric';
  }
}

String _transmissionLabel(Transmission t) {
  switch (t) {
    case Transmission.automatic:
      return 'Auto';
    case Transmission.manual:
      return 'Manual';
  }
}
