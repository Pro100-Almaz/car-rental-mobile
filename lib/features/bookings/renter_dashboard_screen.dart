import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/models/booking.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/primary_button.dart';
import '../../l10n/app_localizations.dart';

class RenterDashboardScreen extends ConsumerStatefulWidget {
  const RenterDashboardScreen({super.key});

  @override
  ConsumerState<RenterDashboardScreen> createState() =>
      _RenterDashboardScreenState();
}

class _RenterDashboardScreenState extends ConsumerState<RenterDashboardScreen> {
  int _tab = 0;
  AppNavDestination _nav = AppNavDestination.bookings;

  static const _tabStatuses = [
    BookingStatus.confirmed,
    BookingStatus.active,
    BookingStatus.completed,
    BookingStatus.cancelled,
  ];

  void _onNav(AppNavDestination d) {
    if (d == _nav) return;
    setState(() => _nav = d);
    switch (d) {
      case AppNavDestination.home:
        context.go('/home');
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
    final allBookings = ref.watch(bookingsProvider);
    final filteredBookings =
        allBookings.where((b) => b.status == _tabStatuses[_tab]).toList();

    final List<String> tabs = [
      l10n.bookingsTabUpcoming,
      l10n.bookingsTabActive,
      l10n.bookingsTabCompleted,
      l10n.bookingsTabCancelled,
    ];

    return Scaffold(
      appBar: const GlassAppBar(),
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
              l10n.bookingsGreeting,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              l10n.bookingsSubtitle,
              style: const TextStyle(fontSize: 15, color: AppColors.neutral500),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: tabs.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (_, i) => _TabChip(
                label: tabs[i],
                selected: i == _tab,
                onTap: () => setState(() => _tab = i),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (filteredBookings.isEmpty)
            _EmptyState(tab: tabs[_tab])
          else
            ...filteredBookings.map(
              (b) => Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md,
                ),
                child: _BookingCard(booking: b),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _NextRideCta(),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.tab});
  final String tab;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xxl,
      ),
      child: Column(
        children: [
          Icon(Icons.calendar_today_outlined,
              size: 48, color: AppColors.neutral300),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No $tab bookings',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral500,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Your bookings will appear here.',
            style: TextStyle(fontSize: 14, color: AppColors.neutral500),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: selected ? null : Border.all(color: AppColors.neutral300),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.white : AppColors.neutral700,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM');
    final dateRange = '${fmt.format(booking.startDate)} – ${fmt.format(booking.endDate)}';
    final statusColor = bookingStatusColor(booking.status);
    final statusLabel = bookingStatusLabel(booking.status);

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.md),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 160,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: booking.carImageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(color: AppColors.neutral200),
                ),
                Positioned(
                  top: AppSpacing.sm,
                  left: AppSpacing.sm,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      statusLabel,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        booking.carName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral900,
                        ),
                      ),
                    ),
                    Text(
                      '₸ ${_formatPrice(booking.total)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 14, color: AppColors.neutral500),
                    const SizedBox(width: 6),
                    Text(
                      dateRange,
                      style:
                          const TextStyle(fontSize: 13, color: AppColors.neutral500),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.neutral100,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        booking.category[0].toUpperCase() +
                            booking.category.substring(1),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.neutral700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _BookingActions(booking: booking),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingActions extends ConsumerWidget {
  const _BookingActions({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (booking.status) {
      case BookingStatus.confirmed:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ref
                      .read(bookingsProvider.notifier)
                      .updateStatus(booking.id, BookingStatus.cancelled);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.push(
                    '/rental/inspect/${booking.id}',
                    extra: {'isCheckIn': true},
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: const Text('Start Rental'),
              ),
            ),
          ],
        );
      case BookingStatus.active:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () =>
                context.push('/rental/active/${booking.id}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: const Text('View Active Rental'),
          ),
        );
      case BookingStatus.completed:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.push('/car/${booking.carId}'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.neutral700,
              side: const BorderSide(color: AppColors.neutral300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: const Text('Book Again'),
          ),
        );
      case BookingStatus.cancelled:
      case BookingStatus.pending:
        return const SizedBox.shrink();
    }
  }
}

class _NextRideCta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.bookingsNextRideTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.bookingsNextRideSubtitle,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: AppColors.neutral700,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: l10n.bookingsFindCar,
            icon: Icons.search_rounded,
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
    );
  }
}

String _formatPrice(int value) {
  final str = value.toString();
  final buf = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buf.write(',');
    buf.write(str[i]);
  }
  return buf.toString();
}
