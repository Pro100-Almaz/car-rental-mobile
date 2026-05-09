import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/providers/providers.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/category_chip.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../l10n/app_localizations.dart';
import 'data/sample_cars.dart';
import 'widgets/car_card.dart';

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final filteredCars = ref.watch(filteredCarsProvider);
    final nearbyCars = ref.watch(nearbyCarsProvider);
    final topRated = ref.watch(topRatedCarsProvider);

    final showFiltered = selectedCategory != 'all';

    return Scaffold(
      appBar: const GlassAppBar(
        avatarUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBxmcWrd2jPGzuah_fpGZ23pCaYfvQE_NSG2iturHwMmVrgEZRk4InsvS28fVL8oOulzlhb224tTHb3AXtmGf1n3_nSIcs0mH2wT1D_SoFZNkibTfH9sAP3d8z92wZrtIWiTfvfRtIClwdpFAAzLcjqD9I7K1DYGTM9IAWZ9DCsy4_jQE5oINByoD4N74HSOYFBByqcWzJRiLUeR1BIJicJ37pECJJCFCLu4B-_CF_0NiREO_W5PEl-t6ACXpqkhJ-ZbsjdXsCgxTR9',
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
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  children: [
                    Icon(Icons.directions_car_outlined,
                        size: 48, color: AppColors.neutral300),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No cars in this category',
                      style: TextStyle(
                        color: AppColors.neutral500,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
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
            _SectionHeader(title: l10n.homeNearby),
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
  const _SearchBar({required this.whereHint, required this.whenHint});

  final String whereHint;
  final String whenHint;

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
            child: _SearchField(icon: Icons.location_on_outlined, hint: whereHint),
          ),
          Container(width: 1, height: 28, color: AppColors.neutral200),
          Expanded(
            child: _SearchField(icon: Icons.calendar_today_outlined, hint: whenHint),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(Icons.search_rounded, color: AppColors.white, size: 20),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.icon, required this.hint});

  final IconData icon;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.neutral500),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              hint,
              style: const TextStyle(fontSize: 14, color: AppColors.neutral500),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.neutral900,
        ),
      ),
    );
  }
}
