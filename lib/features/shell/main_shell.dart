import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/connectivity/connectivity_banner.dart';
import '../../core/haptics/haptics.dart';
import '../../core/providers/active_rental_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/app_localizations.dart';

// Re-export activeRentalProvider so existing imports of this file still
// resolve (active_rental_screen.dart imports from shell previously).
export '../../core/providers/active_rental_provider.dart'
    show activeRentalProvider;

/// 4-tab shell scaffold used by all authenticated + verified screens.
///
/// Uses [IndexedStack] to preserve each tab's scroll position (audit S-1).
/// The "Active" tab is conditionally shown only when [activeRentalProvider]
/// returns a non-null Booking.
///
/// Implements [WidgetsBindingObserver] to invalidate [activeRentalProvider]
/// on app resume, catching the case where a rental moves to active/completed
/// while the app was backgrounded.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Invalidate so the next frame re-fetches GET /mobile/rentals/active.
      ref.invalidate(activeRentalProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch as AsyncValue — treat loading/error as "no active rental" so the
    // tab doesn't flicker in/out on every navigation.
    final activeAsync = ref.watch(activeRentalProvider);
    final hasActive = activeAsync.valueOrNull != null;
    final location = GoRouterState.of(context).uri.toString();

    return Scaffold(
      body: ConnectivityBanner(child: widget.child),
      bottomNavigationBar: _AppBottomNav(
        location: location,
        hasActive: hasActive,
      ),
    );
  }
}

class _AppBottomNav extends StatelessWidget {
  const _AppBottomNav({
    required this.location,
    required this.hasActive,
  });

  final String location;
  final bool hasActive;

  int _currentIndex(bool hasActive) {
    if (location.startsWith('/cars')) return 0;
    if (location.startsWith('/bookings')) return 1;
    if (hasActive && location.startsWith('/active')) return 2;
    if (location.startsWith('/profile')) return hasActive ? 3 : 2;
    if (location.startsWith('/wallet')) return hasActive ? 4 : 3;
    if (location.startsWith('/notifications')) return hasActive ? 4 : 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final currentIndex = _currentIndex(hasActive);

    final items = <_NavItem>[
      _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: l10n.navHome,
        path: '/cars',
      ),
      _NavItem(
        icon: Icons.calendar_today_outlined,
        activeIcon: Icons.calendar_today_rounded,
        label: l10n.navBookings,
        path: '/bookings',
      ),
      if (hasActive)
        _NavItem(
          icon: Icons.directions_car_outlined,
          activeIcon: Icons.directions_car_rounded,
          label: l10n.navActive,
          path: '/active',
        ),
      _NavItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: l10n.navProfile,
        path: '/profile',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.xs,
        left: AppSpacing.sm,
        right: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < items.length; i++)
            _NavTile(
              item: items[i],
              active: i == currentIndex,
              onTap: () {
                // M6.C: selection haptic on tab switch
                AppHaptics.selection();
                context.go(items[i].path);
              },
            ),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.path,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final _NavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.neutral500;
    return Semantics(
      label: item.label,
      selected: active,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: SizedBox(
          width: 64,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(active ? item.activeIcon : item.icon, color: color, size: 24),
              const SizedBox(height: 2),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Re-export AppRadius used by this file's consumers
class AppRadius {
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double pill = 9999;
}
