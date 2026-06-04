import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/models/booking.dart';
import '../../core/providers/active_rental_provider.dart';
import '../../core/providers/bookings_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/error_retry_widget.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/shimmer_box.dart';
import '../../core/widgets/status_chip.dart';
import '../../l10n/app_localizations.dart';

class RenterDashboardScreen extends ConsumerWidget {
  const RenterDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final bookingsAsync = ref.watch(bookingsListProvider);
    final activeAsync = ref.watch(activeRentalProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: SafeArea(
        child: bookingsAsync.when(
          loading: () => const _BookingsLoadingSkeleton(),
          error: (e, _) => _BookingsError(onRetry: () => ref.refresh(bookingsListProvider.future)),
          data: (bookings) {
            final activeRental = activeAsync.valueOrNull;

            // Group bookings into sections
            final now = DateTime.now();
            final upcoming = bookings
                .where((b) =>
                    b.status == BookingStatus.confirmed &&
                    b.startDate.isAfter(now))
                .toList()
              ..sort((a, b) => a.startDate.compareTo(b.startDate));
            final pending = bookings
                .where((b) => b.status == BookingStatus.pending)
                .toList()
              ..sort((a, b) => b.startDate.compareTo(a.startDate));
            final history = bookings
                .where((b) =>
                    b.status == BookingStatus.completed ||
                    b.status == BookingStatus.cancelled)
                .toList()
              ..sort((a, b) => b.endDate.compareTo(a.endDate));

            final hasAny = activeRental != null ||
                upcoming.isNotEmpty ||
                pending.isNotEmpty ||
                history.isNotEmpty;

            return RefreshIndicator(
              onRefresh: () => ref.refresh(bookingsListProvider.future),
              color: AppColors.primary,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.sm,
                      ),
                      child: Text(
                        l10n.bookingsGreeting,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutral900,
                        ),
                      ),
                    ),
                  ),
                  if (!hasAny)
                    SliverFillRemaining(
                      child: EmptyStateView(
                        icon: Icons.calendar_today_outlined,
                        title: l10n.bookingsEmpty,
                        action: SizedBox(
                          width: 180,
                          child: PrimaryButton(
                            label: l10n.bookingsBrowseCars,
                            onPressed: () => context.go('/cars'),
                          ),
                        ),
                      ),
                    )
                  else ...[
                    // ── Active rental (pinned at top)
                    if (activeRental != null) ...[
                      _SectionHeader(title: l10n.bookingsSectionActive),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg),
                        sliver: SliverToBoxAdapter(
                          child: _ActiveRentalCard(booking: activeRental),
                        ),
                      ),
                    ],

                    // ── Upcoming
                    if (upcoming.isNotEmpty) ...[
                      _SectionHeader(
                          title:
                              '${l10n.bookingsSectionUpcoming} (${upcoming.length})'),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.md),
                              child: _BookingCard(booking: upcoming[i]),
                            ),
                            childCount: upcoming.length,
                          ),
                        ),
                      ),
                    ],

                    // ── Pending
                    if (pending.isNotEmpty) ...[
                      _SectionHeader(
                          title:
                              '${l10n.bookingsSectionPending} (${pending.length})'),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.md),
                              child: _BookingCard(booking: pending[i]),
                            ),
                            childCount: pending.length,
                          ),
                        ),
                      ),
                    ],

                    // ── History
                    if (history.isNotEmpty) ...[
                      _SectionHeader(title: l10n.bookingsSectionHistory),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.md),
                              child: _BookingCard(booking: history[i]),
                            ),
                            childCount: history.length,
                          ),
                        ),
                      ),
                    ],

                    const SliverPadding(
                        padding: EdgeInsets.only(bottom: AppSpacing.xl)),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Active rental card — visually distinct (gradient accent border)
// ---------------------------------------------------------------------------

class _ActiveRentalCard extends StatelessWidget {
  const _ActiveRentalCard({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd.MM.yyyy');
    final days = booking.days;
    final dateRange =
        '${fmt.format(booking.startDate)} — ${fmt.format(booking.endDate)}, $days d';

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => context.go('/active'),
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: CachedNetworkImage(
                    imageUrl: booking.carImageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(
                      width: 60,
                      height: 60,
                      color: AppColors.white.withValues(alpha: 0.2),
                    ),
                    errorWidget: (_, _, _) => Container(
                      width: 60,
                      height: 60,
                      color: AppColors.white.withValues(alpha: 0.2),
                      child: const Icon(Icons.directions_car_outlined,
                          color: AppColors.white),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.carName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateRange,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 16, color: Colors.white70),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Regular booking card
// ---------------------------------------------------------------------------

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final fmt = DateFormat('dd.MM.yyyy');
    final days = booking.days;
    final dateRange =
        '${fmt.format(booking.startDate)} — ${fmt.format(booking.endDate)}, $days d';
    final statusColor = bookingStatusColor(booking.status);
    final statusLabel = _statusLabel(l10n, booking.status);

    // Show "Estimated" prefix for pending/confirmed; none for completed
    final isEstimated = booking.status == BookingStatus.pending ||
        booking.status == BookingStatus.confirmed;
    final totalAmount = booking.estimatedTotal ?? booking.total;

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/bookings/${booking.id}'),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.neutral200),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // M6.F: Hero tag for booking-detail transition
              Hero(
                tag: 'booking-thumb-${booking.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: CachedNetworkImage(
                    imageUrl: booking.carImageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(
                      width: 60,
                      height: 60,
                      color: AppColors.neutral200,
                    ),
                    errorWidget: (_, _, _) => Container(
                      width: 60,
                      height: 60,
                      color: AppColors.neutral200,
                      child: const Icon(Icons.directions_car_outlined,
                          color: AppColors.neutral500),
                    ),
                  ),
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
                            booking.carName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        StatusChip(label: statusLabel, color: statusColor),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateRange,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.neutral500),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (booking.category.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.neutral100,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              booking.category,
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.neutral700),
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        Text(
                          '${isEstimated ? '~' : ''}₸${_formatAmount(totalAmount)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.neutral400, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAmount(int amount) {
    if (amount == 0) return '0';
    final s = amount.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  String _statusLabel(AppL10n l10n, BookingStatus status) =>
      switch (status) {
        BookingStatus.pending => l10n.bookingStatusPending,
        BookingStatus.confirmed => l10n.bookingStatusConfirmed,
        BookingStatus.active => l10n.bookingStatusActive,
        BookingStatus.returning => l10n.bookingStatusReturning,
        BookingStatus.completed => l10n.bookingStatusCompleted,
        BookingStatus.cancelled => l10n.bookingStatusCancelled,
      };
}

// ---------------------------------------------------------------------------
// Loading skeleton — uses ShimmerBox (M6.A)
// ---------------------------------------------------------------------------

class _BookingsLoadingSkeleton extends StatelessWidget {
  const _BookingsLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        ShimmerBox(
          height: 28,
          width: 160,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        const SizedBox(height: AppSpacing.xl),
        ...List.generate(
          3,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: _BookingCardSkeleton(),
          ),
        ),
      ],
    );
  }
}

class _BookingCardSkeleton extends StatelessWidget {
  const _BookingCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        children: [
          ShimmerBox(
            width: 60,
            height: 60,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(
                  height: 15,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: AppSpacing.sm),
                ShimmerBox(
                  height: 12,
                  width: 140,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: AppSpacing.sm),
                ShimmerBox(
                  height: 12,
                  width: 80,
                  borderRadius: BorderRadius.circular(4),
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
// Error widget — uses ErrorRetryWidget (M6.B)
// ---------------------------------------------------------------------------

class _BookingsError extends StatelessWidget {
  const _BookingsError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ErrorRetryWidget(
      message: 'Could not load bookings. Please try again.',
      onRetry: onRetry,
    );
  }
}
