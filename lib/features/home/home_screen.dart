import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/category_chip.dart';
import '../../core/widgets/glass_app_bar.dart';
import 'data/sample_cars.dart';
import 'widgets/car_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'all';
  AppNavDestination _nav = AppNavDestination.home;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: const GlassAppBar(
        avatarUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBxmcWrd2jPGzuah_fpGZ23pCaYfvQE_NSG2iturHwMmVrgEZRk4InsvS28fVL8oOulzlhb224tTHb3AXtmGf1n3_nSIcs0mH2wT1D_SoFZNkibTfH9sAP3d8z92wZrtIWiTfvfRtIClwdpFAAzLcjqD9I7K1DYGTM9IAWZ9DCsy4_jQE5oINByoD4N74HSOYFBByqcWzJRiLUeR1BIJicJ37pECJJCFCLu4B-_CF_0NiREO_W5PEl-t6ACXpqkhJ-ZbsjdXsCgxTR9',
      ),
      bottomNavigationBar: AppBottomNav(
        current: _nav,
        onSelect: (d) {
          setState(() => _nav = d);
          switch (d) {
            case AppNavDestination.bookings:
              context.push('/bookings');
              break;
            case AppNavDestination.profile:
              context.push('/owner');
              break;
            default:
              break;
          }
        },
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          0,
          MediaQuery.paddingOf(context).top + 84,
          0,
          MediaQuery.paddingOf(context).bottom + 120,
        ),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              'Find the perfect ride\nfor your next adventure.',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                height: 1.15,
                letterSpacing: -0.5,
                color: AppColors.onSurface,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: _SearchBar(),
          ),
          const SizedBox(height: AppSpacing.xxl),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              itemCount: kCarCategories.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (_, i) {
                final c = kCarCategories[i];
                return CategoryChip(
                  label: c.label,
                  selected: c.id == _selectedCategory,
                  onTap: () => setState(() => _selectedCategory = c.id),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _SectionHeader(
            eyebrow: 'AVAILABLE NOW',
            title: 'Nearby cars',
            onAction: () {},
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 304,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              itemCount: kNearbyCars.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xl),
              itemBuilder: (_, i) => CarFeatureCard(
                car: kNearbyCars[i],
                onTap: () => context.push('/car/${kNearbyCars[i].id}'),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              'Top rated',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...kTopRated.map(
            (c) => Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.md,
              ),
              child: CarListTile(
                car: c,
                onTap: () => context.push('/car/${c.id}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: AppColors.cloudShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: _SearchField(
              icon: Icons.location_on_rounded,
              hint: 'Where to?',
            ),
          ),
          Container(
            width: 1,
            height: 28,
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _SearchField(
              icon: Icons.calendar_today_rounded,
              hint: 'When?',
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_rounded, color: AppColors.onPrimary, size: 22),
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: hint,
                isDense: true,
                filled: false,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    this.eyebrow,
    required this.title,
    this.onAction,
  });

  final String? eyebrow;
  final String title;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null)
                  Text(
                    eyebrow!,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.secondary,
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          if (onAction != null)
            TextButton(
              onPressed: onAction,
              child: const Text(
                'View all',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
