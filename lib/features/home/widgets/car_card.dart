import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../data/sample_cars.dart';

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
                      imageUrl: car.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(color: AppColors.neutral200),
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
                            car.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral900,
                            ),
                          ),
                        ),
                        Text(
                          '₸${car.pricePerHour}${l10n.carPerHour}',
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
                          car.plateNumber,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.neutral500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Icon(Icons.location_on_outlined,
                            size: 14, color: AppColors.neutral500),
                        const SizedBox(width: 2),
                        Text(
                          l10n.carMetersAway('${car.distanceMeters}'),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.neutral500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        _InfoChip(
                          icon: Icons.local_gas_station_outlined,
                          label: '${(car.fuelLevel * 100).toInt()}%',
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _InfoChip(
                          icon: Icons.settings_outlined,
                          label: car.transmission,
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
                  imageUrl: car.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
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
                            car.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral900,
                            ),
                          ),
                        ),
                        Text(
                          '₸${car.pricePerHour}${l10n.carPerHour}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${car.plateNumber} • ${_categoryLabel(l10n, car.category)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.neutral500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.star, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          l10n.carReviewsPlus(
                            car.rating.toStringAsFixed(1),
                            car.reviewCount,
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral900,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Icon(Icons.local_gas_station_outlined,
                            size: 14, color: AppColors.neutral500),
                        const SizedBox(width: 2),
                        Text(
                          '${(car.fuelLevel * 100).toInt()}%',
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

String _categoryLabel(AppL10n l10n, String id) {
  switch (id) {
    case 'economy':
      return l10n.categoryEconomy;
    case 'comfort':
      return l10n.categoryComfort;
    case 'business':
      return l10n.categoryBusiness;
    case 'suv':
      return l10n.categorySuv;
    default:
      return l10n.categoryAll;
  }
}
