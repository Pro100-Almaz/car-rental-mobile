import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum AppNavDestination { home, bookings, active, wallet, profile }

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.current,
    required this.onSelect,
  });

  final AppNavDestination current;
  final ValueChanged<AppNavDestination> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
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
          _NavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: l10n.navHome,
            active: current == AppNavDestination.home,
            onTap: () => onSelect(AppNavDestination.home),
          ),
          _NavItem(
            icon: Icons.calendar_today_outlined,
            activeIcon: Icons.calendar_today_rounded,
            label: l10n.navBookings,
            active: current == AppNavDestination.bookings,
            onTap: () => onSelect(AppNavDestination.bookings),
          ),
          _NavItem(
            icon: Icons.directions_car_outlined,
            activeIcon: Icons.directions_car_rounded,
            label: l10n.navActive,
            active: current == AppNavDestination.active,
            onTap: () => onSelect(AppNavDestination.active),
          ),
          _NavItem(
            icon: Icons.account_balance_wallet_outlined,
            activeIcon: Icons.account_balance_wallet_rounded,
            label: l10n.navWallet,
            active: current == AppNavDestination.wallet,
            onTap: () => onSelect(AppNavDestination.wallet),
          ),
          _NavItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: l10n.navProfile,
            active: current == AppNavDestination.profile,
            onTap: () => onSelect(AppNavDestination.profile),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = active ? AppColors.primary : AppColors.neutral500;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(active ? activeIcon : icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
