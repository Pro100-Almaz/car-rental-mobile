import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/providers/notification_provider.dart';
import '../../core/providers/providers.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/category_chip.dart';
import '../../core/widgets/app_top_bar.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/section_header.dart';
import '../../l10n/app_localizations.dart';
import 'data/sample_cars.dart';
import 'widgets/car_card.dart';

const _kMockLocations = [
  'Almaty Center',
  'Dostyk Plaza',
  'Almaty Airport',
  'Railway Station',
  'Mega Center',
];

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

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  AppNavDestination _nav = AppNavDestination.home;
  String? _selectedLocation;
  DateTimeRange? _selectedDateRange;

  void _onNav(AppNavDestination d) {
    if (d == _nav) return;
    setState(() => _nav = d);
    switch (d) {
      case AppNavDestination.bookings:
        context.go('/bookings');
      case AppNavDestination.wallet:
        context.go('/wallet');
      case AppNavDestination.profile:
        context.go('/profile');
      default:
        break;
    }
  }

  Future<void> _showLocationSheet() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => const _LocationSheet(),
    );
    if (result != null) {
      setState(() => _selectedLocation = result);
    }
  }

  Future<void> _showDateRangePicker() async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: AppColors.white,
            onSurface: AppColors.neutral900,
          ),
        ),
        child: child!,
      ),
    );
    if (result != null) {
      setState(() => _selectedDateRange = result);
    }
  }

  String _formatDateRange(DateTimeRange range) {
    final fmt = DateFormat('MMM d');
    return '${fmt.format(range.start)} – ${fmt.format(range.end)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final filteredCars = ref.watch(filteredCarsProvider);
    final nearbyCars = ref.watch(nearbyCarsProvider);
    final topRated = ref.watch(topRatedCarsProvider);

    final showFiltered = selectedCategory != 'all';

    return Scaffold(
      appBar: AppTopBar(
        avatarUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBxmcWrd2jPGzuah_fpGZ23pCaYfvQE_NSG2iturHwMmVrgEZRk4InsvS28fVL8oOulzlhb224tTHb3AXtmGf1n3_nSIcs0mH2wT1D_SoFZNkibTfH9sAP3d8z92wZrtIWiTfvfRtIClwdpFAAzLcjqD9I7K1DYGTM9IAWZ9DCsy4_jQE5oINByoD4N74HSOYFBByqcWzJRiLUeR1BIJicJ37pECJJCFCLu4B-_CF_0NiREO_W5PEl-t6ACXpqkhJ-ZbsjdXsCgxTR9',
        notificationCount: ref.watch(unreadCountProvider),
        onNotificationTap: () => context.push('/notifications'),
      ),
      bottomNavigationBar: AppBottomNav(current: _nav, onSelect: _onNav),
      body: ListView(
        padding: EdgeInsets.only(
          top: AppSpacing.lg,
          bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.xl,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              l10n.homeHeadline,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1.2,
                color: AppColors.neutral900,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _SearchBar(
              whereHint: l10n.homeSearchWhere,
              whenHint: l10n.homeSearchWhen,
              selectedLocation: _selectedLocation,
              selectedDateRange: _selectedDateRange != null
                  ? _formatDateRange(_selectedDateRange!)
                  : null,
              onWhereTap: _showLocationSheet,
              onWhenTap: _showDateRangePicker,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: kCarCategories.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (_, i) {
                final c = kCarCategories[i];
                return CategoryChip(
                  label: _categoryLabel(l10n, c.id),
                  selected: c.id == selectedCategory,
                  onTap: () =>
                      ref.read(selectedCategoryProvider.notifier).state = c.id,
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (showFiltered) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                '${_categoryLabel(l10n, selectedCategory)} (${filteredCars.length})',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (filteredCars.isEmpty)
              EmptyStateView(
                icon: Icons.directions_car_outlined,
                title: 'No cars in this category',
              )
            else
              ...filteredCars.map(
                (c) => Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md,
                  ),
                  child: CarListTile(
                    car: c,
                    onTap: () => context.push('/car/${c.id}'),
                  ),
                ),
              ),
          ] else ...[
            SectionHeader(title: l10n.homeNearby),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 280,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: nearbyCars.length,
                separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
                itemBuilder: (_, i) => CarFeatureCard(
                  car: nearbyCars[i],
                  onTap: () => context.push('/car/${nearbyCars[i].id}'),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                l10n.homeTopRated,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...topRated.map(
              (c) => Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md,
                ),
                child: CarListTile(
                  car: c,
                  onTap: () => context.push('/car/${c.id}'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.whereHint,
    required this.whenHint,
    required this.onWhereTap,
    required this.onWhenTap,
    this.selectedLocation,
    this.selectedDateRange,
  });

  final String whereHint;
  final String whenHint;
  final VoidCallback onWhereTap;
  final VoidCallback onWhenTap;
  final String? selectedLocation;
  final String? selectedDateRange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.neutral300),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onWhereTap,
              child: _SearchField(
                icon: Icons.location_on_outlined,
                hint: whereHint,
                value: selectedLocation,
              ),
            ),
          ),
          Container(width: 1, height: 28, color: AppColors.neutral200),
          Expanded(
            child: GestureDetector(
              onTap: onWhenTap,
              child: _SearchField(
                icon: Icons.calendar_today_outlined,
                hint: whenHint,
                value: selectedDateRange,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // Category filtering is already reactive via selectedCategoryProvider.
              // Tapping search simply confirms the current selection — no extra action needed.
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                  Icons.search_rounded, color: AppColors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.icon,
    required this.hint,
    this.value,
  });

  final IconData icon;
  final String hint;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 18,
              color: hasValue ? AppColors.primary : AppColors.neutral500),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              hasValue ? value! : hint,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: hasValue ? AppColors.neutral900 : AppColors.neutral500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationSheet extends StatefulWidget {
  const _LocationSheet();

  @override
  State<_LocationSheet> createState() => _LocationSheetState();
}

class _LocationSheetState extends State<_LocationSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _kMockLocations
        .where((l) => l.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.md),
            child: Text(
              'Select Location',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: TextField(
              autofocus: true,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search location...',
                hintStyle: const TextStyle(
                    color: AppColors.neutral500, fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.neutral500, size: 20),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                filled: true,
                fillColor: AppColors.neutral100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...filtered.map(
            (loc) => ListTile(
              leading: const Icon(Icons.location_on_outlined,
                  color: AppColors.primary, size: 20),
              title: Text(
                loc,
                style: const TextStyle(
                    fontSize: 15, color: AppColors.neutral900),
              ),
              onTap: () => Navigator.of(context).pop(loc),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

