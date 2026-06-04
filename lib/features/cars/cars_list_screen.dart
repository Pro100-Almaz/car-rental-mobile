import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/haptics/haptics.dart';
import '../../core/models/car.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/cars_provider.dart';
import '../../core/providers/notification_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_top_bar.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/error_retry_widget.dart';
import '../../core/widgets/price_text.dart';
import '../../core/widgets/shimmer_box.dart';
import '../../core/widgets/status_chip.dart';

class CarsListScreen extends ConsumerStatefulWidget {
  const CarsListScreen({super.key});

  @override
  ConsumerState<CarsListScreen> createState() => _CarsListScreenState();
}

class _CarsListScreenState extends ConsumerState<CarsListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    // Fire 200px before bottom
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      ref.read(carsListProvider.notifier).loadNextPage();
    }
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      builder: (ctx) => _FilterSheet(
        currentFilter: ref.read(carsListProvider).filter,
        onApply: (f) {
          ref.read(carsListProvider.notifier).applyFilter(f);
          Navigator.of(ctx).pop();
        },
        onReset: () {
          ref.read(carsListProvider.notifier).applyFilter(
                CarsFilter(search: ref.read(carsListProvider).filter.search),
              );
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final notifCount = ref.watch(unreadCountProvider);
    final state = ref.watch(carsListProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: SafeArea(
        child: Column(
          children: [
            // ---- Top bar ----
            AppTopBar(
              avatarUrl: user?.avatarUrl,
              notificationCount: notifCount,
              onNotificationTap: () => context.push('/notifications'),
              onProfileTap: () => context.push('/profile'),
            ),
            // ---- Search + filter row ----
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _SearchField(
                      controller: _searchController,
                      onChanged: (q) =>
                          ref.read(carsListProvider.notifier).search(q),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _FilterButton(
                    hasActiveFilters: !state.filter.isEmpty,
                    onTap: _openFilterSheet,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // ---- Car list ----
            Expanded(
              child: _buildBody(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(CarsListState state) {
    // First-load skeleton
    if (state.loading && state.items.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: 6,
        itemBuilder: (ctx, idx) => const _CarCardSkeleton(),
      );
    }

    // Error on first load
    if (state.hasError && state.items.isEmpty) {
      return ErrorRetryWidget(
        message: _errorMessage(state.errorCode),
        onRetry: () =>
            ref.read(carsListProvider.notifier).loadFirstPage(),
      );
    }

    // Empty state
    if (state.isEmpty) {
      return EmptyStateView(
        icon: Icons.directions_car_outlined,
        title: 'No cars match your filters',
        subtitle: 'Try adjusting or resetting your filters.',
        action: TextButton(
          onPressed: () {
            ref.read(carsListProvider.notifier).resetFilter();
          },
          child: const Text('Reset filters'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(carsListProvider.notifier).refresh(),
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        itemCount: state.items.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.items.length) {
            // Next-page loader
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          }
          final car = state.items[index];
          return _CarCard(
            car: car,
            onTap: () => context.push('/cars/${car.id}'),
          );
        },
      ),
    );
  }

  String _errorMessage(String? code) {
    switch (code) {
      case 'network_offline':
        return 'No internet connection. Please check your network.';
      case 'server':
        return 'Server error. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}

// ---------------------------------------------------------------------------
// Search field
// ---------------------------------------------------------------------------

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: const InputDecoration(
          hintText: 'Search cars…',
          hintStyle: TextStyle(fontSize: 14, color: AppColors.neutral500),
          prefixIcon: Icon(Icons.search_rounded,
              color: AppColors.neutral500, size: 20),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(vertical: 12, horizontal: AppSpacing.sm),
          isDense: true,
        ),
        style: const TextStyle(fontSize: 14, color: AppColors.neutral900),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter button
// ---------------------------------------------------------------------------

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.hasActiveFilters,
    required this.onTap,
  });

  final bool hasActiveFilters;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color:
              hasActiveFilters ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: hasActiveFilters
                ? AppColors.primary
                : AppColors.neutral200,
          ),
        ),
        child: Icon(
          Icons.tune_rounded,
          size: 20,
          color: hasActiveFilters ? AppColors.white : AppColors.neutral700,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Car card
// ---------------------------------------------------------------------------

class _CarCard extends StatelessWidget {
  const _CarCard({required this.car, required this.onTap});

  final CarListing car;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppHaptics.light(); // M6.C: light haptic on card tap
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.neutral200),
          boxShadow: AppColors.elevation1,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo — M6.F Hero tag for car-detail transition
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Hero(
                tag: 'car-photo-${car.id}',
                child: car.primaryPhoto.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: car.primaryPhoto,
                        fit: BoxFit.cover,
                        placeholder: (ctx, ph) =>
                            const ShimmerBox(height: double.infinity),
                        errorWidget: (ctx, err, trace) => Container(
                          color: AppColors.neutral200,
                          child: const Icon(Icons.directions_car_outlined,
                              size: 48, color: AppColors.neutral400),
                        ),
                      )
                    : Container(
                        color: AppColors.neutral200,
                        child: const Icon(Icons.directions_car_outlined,
                            size: 48, color: AppColors.neutral400),
                      ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          car.displayTitle,
                          style: const TextStyle(
                            fontSize: 16,
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
                  const SizedBox(height: AppSpacing.xs),
                  // Subtitle
                  Text(
                    car.displaySubtitle,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.neutral500),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Specs row
                  Row(
                    children: [
                      _SpecIcon(
                        icon: Icons.local_gas_station_outlined,
                        label: _fuelLabel(car.fuelType),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _SpecIcon(
                        icon: Icons.settings_outlined,
                        label: _transmissionLabel(car.transmission),
                      ),
                      const Spacer(),
                      PriceText(
                        amount: car.dailyRate,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const Text(
                        '/day',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.neutral500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
}

class _SpecIcon extends StatelessWidget {
  const _SpecIcon({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.neutral500),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: AppColors.neutral500)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Car card skeleton
// ---------------------------------------------------------------------------

class _CarCardSkeleton extends StatelessWidget {
  const _CarCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.neutral200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(height: 180),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(
                  height: 18,
                  width: MediaQuery.sizeOf(context).width * 0.5,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: AppSpacing.sm),
                ShimmerBox(
                  height: 14,
                  width: MediaQuery.sizeOf(context).width * 0.35,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    ShimmerBox(
                        height: 14,
                        width: 60,
                        borderRadius: BorderRadius.circular(4)),
                    const SizedBox(width: AppSpacing.md),
                    ShimmerBox(
                        height: 14,
                        width: 60,
                        borderRadius: BorderRadius.circular(4)),
                    const Spacer(),
                    ShimmerBox(
                        height: 20,
                        width: 80,
                        borderRadius: BorderRadius.circular(4)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter bottom sheet
// ---------------------------------------------------------------------------

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.currentFilter,
    required this.onApply,
    required this.onReset,
  });

  final CarsFilter currentFilter;
  final void Function(CarsFilter) onApply;
  final VoidCallback onReset;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late Set<VehicleCategory> _categories;
  late Set<FuelType> _fuels;
  late Set<Transmission> _transmissions;
  late RangeValues _priceRange;

  static const double _maxPrice = 100000;

  @override
  void initState() {
    super.initState();
    _categories = Set.of(widget.currentFilter.categories);
    _fuels = Set.of(widget.currentFilter.fuelTypes);
    _transmissions = Set.of(widget.currentFilter.transmissions);
    _priceRange = RangeValues(
      (widget.currentFilter.minPrice ?? 0).toDouble(),
      (widget.currentFilter.maxPrice ?? _maxPrice).toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Scaffold(
          backgroundColor: AppColors.white,
          body: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: AppSpacing.md),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.neutral300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                child: Row(
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: widget.onReset,
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Category'),
                      const SizedBox(height: AppSpacing.sm),
                      _ChipGroup<VehicleCategory>(
                        items: VehicleCategory.values,
                        selected: _categories,
                        label: _categoryLabel,
                        onToggle: (v) => setState(() {
                          if (_categories.contains(v)) {
                            _categories.remove(v);
                          } else {
                            _categories.add(v);
                          }
                        }),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _sectionTitle('Fuel type'),
                      const SizedBox(height: AppSpacing.sm),
                      _ChipGroup<FuelType>(
                        items: FuelType.values,
                        selected: _fuels,
                        label: _fuelLabel,
                        onToggle: (v) => setState(() {
                          if (_fuels.contains(v)) {
                            _fuels.remove(v);
                          } else {
                            _fuels.add(v);
                          }
                        }),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _sectionTitle('Transmission'),
                      const SizedBox(height: AppSpacing.sm),
                      _ChipGroup<Transmission>(
                        items: Transmission.values,
                        selected: _transmissions,
                        label: _transmissionLabel,
                        onToggle: (v) => setState(() {
                          if (_transmissions.contains(v)) {
                            _transmissions.remove(v);
                          } else {
                            _transmissions.add(v);
                          }
                        }),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _sectionTitle(
                          'Price range (₸/day)'),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₸${_priceRange.start.round()}',
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.neutral700),
                          ),
                          Text(
                            '₸${_priceRange.end.round()}',
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.neutral700),
                          ),
                        ],
                      ),
                      RangeSlider(
                        values: _priceRange,
                        min: 0,
                        max: _maxPrice,
                        divisions: 100,
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.neutral200,
                        onChanged: (v) => setState(() => _priceRange = v),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  MediaQuery.paddingOf(context).bottom + AppSpacing.md,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(CarsFilter(
                        search: widget.currentFilter.search,
                        categories: _categories,
                        fuelTypes: _fuels,
                        transmissions: _transmissions,
                        minPrice: _priceRange.start.round() > 0
                            ? _priceRange.start.round()
                            : null,
                        maxPrice: _priceRange.end.round() < _maxPrice
                            ? _priceRange.end.round()
                            : null,
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: const Text(
                      'Apply filters',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.neutral700,
      ),
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

class _ChipGroup<T> extends StatelessWidget {
  const _ChipGroup({
    required this.items,
    required this.selected,
    required this.label,
    required this.onToggle,
  });

  final List<T> items;
  final Set<T> selected;
  final String Function(T) label;
  final void Function(T) onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: items.map((item) {
        final isSelected = selected.contains(item);
        return GestureDetector(
          onTap: () {
            AppHaptics.selection(); // M6.C: selection haptic on chip tap
            onToggle(item);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color:
                  isSelected ? AppColors.primary : AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.neutral300,
              ),
            ),
            child: Text(
              label(item),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? AppColors.white
                    : AppColors.neutral700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// Re-use AppRadius constant
class AppRadius {
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double pill = 9999;
}

