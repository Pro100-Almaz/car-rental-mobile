import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/api/api_exception.dart';
import '../../core/models/car.dart';
import '../../core/models/user.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/cars_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/availability_calendar.dart';
import '../../core/widgets/error_retry_widget.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/price_text.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/shimmer_box.dart';
import '../../core/widgets/status_chip.dart';

class CarDetailsScreen extends ConsumerStatefulWidget {
  const CarDetailsScreen({super.key, required this.carId});

  final String carId;

  @override
  ConsumerState<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends ConsumerState<CarDetailsScreen> {
  DateTimeRange? _selectedRange;
  int _photoPage = 0;
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final carAsync = ref.watch(carDetailProvider(widget.carId));

    return carAsync.when(
      loading: () => const _CarDetailSkeleton(),
      error: (e, _) => _CarDetailError(
        error: e,
        onRetry: () => ref.invalidate(carDetailProvider(widget.carId)),
      ),
      data: (car) => _CarDetailBody(
        car: car,
        selectedRange: _selectedRange,
        photoPage: _photoPage,
        pageController: _pageController,
        onRangeChanged: (range) => setState(() => _selectedRange = range),
        onPhotoPageChanged: (p) => setState(() => _photoPage = p),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Main body (loaded state)
// ---------------------------------------------------------------------------

class _CarDetailBody extends ConsumerWidget {
  const _CarDetailBody({
    required this.car,
    required this.selectedRange,
    required this.photoPage,
    required this.pageController,
    required this.onRangeChanged,
    required this.onPhotoPageChanged,
  });

  final CarListing car;
  final DateTimeRange? selectedRange;
  final int photoPage;
  final PageController pageController;
  final void Function(DateTimeRange?) onRangeChanged;
  final void Function(int) onPhotoPageChanged;

  bool get _isUnavailable =>
      car.status == CarStatus.inService ||
      car.status == CarStatus.decommissioned;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final days = selectedRange != null
        ? selectedRange!.end.difference(selectedRange!.start).inDays.clamp(1, 30)
        : 0;
    final estimatedTotal = days * car.dailyRate;

    // Booking blocked reasons
    String? blockReason;
    if (user != null) {
      if (user.verificationStatus != VerificationStatus.verified) {
        blockReason = 'Complete document verification first';
      } else if (user.isBlacklisted) {
        blockReason = 'Account suspended. Contact support.';
      } else if (user.debtBalance > 0) {
        blockReason =
            'Pay outstanding ₸${_fmt(user.debtBalance)} before booking';
      }
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ---- Pinned photo carousel app bar ----
          SliverAppBar(
            pinned: true,
            expandedHeight: 320,
            leading: _CircleButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => context.pop(),
            ),
            title: Text(
              car.displayTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Photo carousel — M6.F Hero tag on first image matches
                  // the list screen tag 'car-photo-$carId'
                  car.photos.isNotEmpty
                      ? PageView.builder(
                          controller: pageController,
                          onPageChanged: onPhotoPageChanged,
                          itemCount: car.photos.length,
                          itemBuilder: (_, i) {
                            final image = CachedNetworkImage(
                              imageUrl: car.photos[i],
                              fit: BoxFit.cover,
                              placeholder: (ctx, ph) =>
                                  const ShimmerBox(height: double.infinity),
                              errorWidget: (ctx, err, trace) => Container(
                                color: AppColors.neutral200,
                                child: const Icon(
                                  Icons.directions_car_outlined,
                                  size: 80,
                                  color: AppColors.neutral400,
                                ),
                              ),
                            );
                            // Only first photo participates in Hero transition
                            return i == 0
                                ? Hero(tag: 'car-photo-${car.id}', child: image)
                                : image;
                          },
                        )
                      : Container(
                          color: AppColors.neutral200,
                          child: const Icon(
                            Icons.directions_car_outlined,
                            size: 80,
                            color: AppColors.neutral400,
                          ),
                        ),
                  // Page dots at bottom
                  if (car.photos.length > 1)
                    Positioned(
                      bottom: AppSpacing.md,
                      left: 0,
                      right: 0,
                      child: _PhotoDots(
                          count: car.photos.length, current: photoPage),
                    ),
                ],
              ),
            ),
          ),

          // ---- Content ----
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.xl,
                AppSpacing.lg, AppSpacing.xl + 80,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Unavailable banner
                  if (_isUnavailable)
                    _Banner(
                      message: 'This vehicle is currently unavailable.',
                      color: AppColors.warning,
                    ),

                  // Blocked booking banner
                  if (blockReason != null)
                    _Banner(message: blockReason, color: AppColors.error),

                  // Title + plate + category
                  _TitleSection(car: car),
                  const SizedBox(height: AppSpacing.xl),

                  // Specs grid
                  _SpecsGrid(car: car),
                  const SizedBox(height: AppSpacing.xl),

                  // Features
                  if (car.features.isNotEmpty) ...[
                    _SectionLabel(text: 'Features'),
                    const SizedBox(height: AppSpacing.sm),
                    _FeatureWrap(features: car.features),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  // Daily rate card
                  GlassCard(
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Daily rate',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral700,
                            ),
                          ),
                        ),
                        PriceText(
                          amount: car.dailyRate,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const Text(
                          '/day',
                          style: TextStyle(
                              fontSize: 14, color: AppColors.neutral500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Availability calendar
                  _SectionLabel(text: 'Pick your dates'),
                  const SizedBox(height: AppSpacing.md),
                  GlassCard(
                    child: AvailabilityCalendar(
                      vehicleId: car.id,
                      selectedStart: null,
                      selectedEnd: null,
                      onRangeChanged: onRangeChanged,
                    ),
                  ),

                  // Selected range preview
                  if (selectedRange != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    _RangePreview(
                      range: selectedRange!,
                      dailyRate: car.dailyRate,
                      estimatedTotal: estimatedTotal,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),

      // ---- Sticky bottom CTA ----
      bottomNavigationBar: _BottomBar(
        car: car,
        selectedRange: selectedRange,
        estimatedTotal: estimatedTotal,
        isUnavailable: _isUnavailable,
        blockReason: blockReason,
      ),
    );
  }

  String _fmt(num amount) {
    final f = NumberFormat('#,##0', 'ru');
    return f.format(amount);
  }
}

// ---------------------------------------------------------------------------
// Title section
// ---------------------------------------------------------------------------

class _TitleSection extends StatelessWidget {
  const _TitleSection({required this.car});
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
                car.displayTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                    ),
              ),
            ),
            StatusChip(
              label: _categoryLabel(car.category),
              color: AppColors.primary,
              dot: false,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Text(
              '${car.make} ${car.model} · ${car.year}',
              style: const TextStyle(
                  fontSize: 14, color: AppColors.neutral500),
            ),
            const SizedBox(width: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.neutral200),
              ),
              child: Text(
                car.maskedPlate,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral700,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _categoryLabel(VehicleCategory c) {
    switch (c) {
      case VehicleCategory.economy:
        return 'Economy';
      case VehicleCategory.comfort:
        return 'Comfort';
      case VehicleCategory.business:
        return 'Business';
      case VehicleCategory.suv:
        return 'SUV';
      case VehicleCategory.minivan:
        return 'Minivan';
    }
  }
}

// ---------------------------------------------------------------------------
// Specs grid
// ---------------------------------------------------------------------------

class _SpecsGrid extends StatelessWidget {
  const _SpecsGrid({required this.car});
  final CarListing car;

  @override
  Widget build(BuildContext context) {
    final specs = [
      (Icons.local_gas_station_outlined, _fuelLabel(car.fuelType)),
      (Icons.settings_outlined, _transmissionLabel(car.transmission)),
      (Icons.speed_outlined, '${car.currentMileage} km'),
      (Icons.palette_outlined, car.color),
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: specs
          .map((s) => _SpecChip(icon: s.$1, label: s.$2))
          .toList(),
    );
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
        return 'Automatic';
      case Transmission.manual:
        return 'Manual';
    }
  }
}

class _SpecChip extends StatelessWidget {
  const _SpecChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.neutral700),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.neutral700),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Feature wrap
// ---------------------------------------------------------------------------

class _FeatureWrap extends StatelessWidget {
  const _FeatureWrap({required this.features});
  final Map<String, dynamic> features;

  @override
  Widget build(BuildContext context) {
    final items = features.entries.map((e) {
      final key = e.key
          .replaceAll('_', ' ')
          .split(' ')
          .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
          .join(' ');
      return '$key: ${e.value}';
    }).toList();

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: items
          .map(
            (f) => Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.secondaryLight,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(f,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.secondaryDark)),
            ),
          )
          .toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Range preview
// ---------------------------------------------------------------------------

class _RangePreview extends StatelessWidget {
  const _RangePreview({
    required this.range,
    required this.dailyRate,
    required this.estimatedTotal,
  });

  final DateTimeRange range;
  final int dailyRate;
  final int estimatedTotal;

  @override
  Widget build(BuildContext context) {
    final days =
        range.end.difference(range.start).inDays.clamp(1, 30);
    final fmt = DateFormat('d MMM');
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined,
              size: 16, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '${fmt.format(range.start)} – ${fmt.format(range.end)} · $days ${days == 1 ? 'day' : 'days'}',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary),
            ),
          ),
          PriceText(
            amount: estimatedTotal,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sticky bottom CTA
// ---------------------------------------------------------------------------

class _BottomBar extends ConsumerWidget {
  const _BottomBar({
    required this.car,
    required this.selectedRange,
    required this.estimatedTotal,
    required this.isUnavailable,
    required this.blockReason,
  });

  final CarListing car;
  final DateTimeRange? selectedRange;
  final int estimatedTotal;
  final bool isUnavailable;
  final String? blockReason;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnabled =
        selectedRange != null && !isUnavailable && blockReason == null;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: const Border(
          top: BorderSide(color: AppColors.neutral200, width: 0.5),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        MediaQuery.paddingOf(context).bottom + AppSpacing.md,
      ),
      child: PrimaryButton(
        label: selectedRange != null
            ? 'Request booking'
            : 'Select dates to book',
        onPressed: isEnabled
            ? () => context.push(
                  '/cars/${car.id}/book',
                  extra: {
                    'car': car,
                    'startDate': selectedRange!.start,
                    'endDate': selectedRange!.end,
                  },
                )
            : null,
        icon: isEnabled ? Icons.arrow_forward_rounded : null,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Banner widget (unavailable / blocked)
// ---------------------------------------------------------------------------

class _Banner extends StatelessWidget {
  const _Banner({required this.message, required this.color});
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Photo page dots
// ---------------------------------------------------------------------------

class _PhotoDots extends StatelessWidget {
  const _PhotoDots({required this.count, required this.current});
  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: i == current ? 16 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: i == current
                ? AppColors.white
                : AppColors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Circle back button
// ---------------------------------------------------------------------------

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Material(
        color: AppColors.white.withValues(alpha: 0.9),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: const SizedBox(
            width: 36,
            height: 36,
            child: Icon(Icons.arrow_back_rounded,
                color: AppColors.neutral900, size: 20),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section label
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: AppColors.neutral500,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Skeleton + error states
// ---------------------------------------------------------------------------

class _CarDetailSkeleton extends StatelessWidget {
  const _CarDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const ShimmerBox(height: 320),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(
                    height: 24,
                    width: 200,
                    borderRadius: BorderRadius.circular(4)),
                const SizedBox(height: AppSpacing.sm),
                ShimmerBox(
                    height: 14,
                    width: 150,
                    borderRadius: BorderRadius.circular(4)),
                const SizedBox(height: AppSpacing.xl),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: List.generate(
                      4,
                      (_) => ShimmerBox(
                          height: 36,
                          width: 80,
                          borderRadius: BorderRadius.circular(8))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CarDetailError extends StatelessWidget {
  const _CarDetailError({required this.error, required this.onRetry});
  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isNotFound = error is NotFoundException;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isNotFound
                    ? Icons.search_off_rounded
                    : Icons.error_outline_rounded,
                size: 56,
                color: AppColors.neutral300,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                isNotFound ? 'Car not found' : 'Failed to load car details',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral700,
                ),
              ),
              if (isNotFound) ...[
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'This vehicle is no longer available.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14, color: AppColors.neutral500),
                ),
                const SizedBox(height: AppSpacing.lg),
                OutlinedButton(
                  onPressed: () => context.go('/cars'),
                  child: const Text('Back to cars'),
                ),
              ] else ...[
                const SizedBox(height: AppSpacing.lg),
                ErrorRetryWidget(
                  message: 'Something went wrong. Please try again.',
                  onRetry: onRetry,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

