import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/booking.dart';
import '../../core/api/api_client.dart';
import '../../core/providers/bookings_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/status_chip.dart';
import '../../l10n/app_localizations.dart';

class BookingDetailScreen extends ConsumerWidget {
  const BookingDetailScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingDetailProvider(bookingId));

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: bookingAsync.when(
        loading: () => const Scaffold(
          backgroundColor: AppColors.neutral50,
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(
          backgroundColor: AppColors.neutral50,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.neutral900),
              onPressed: () => context.pop(),
            ),
          ),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 48, color: AppColors.neutral300),
                const SizedBox(height: AppSpacing.md),
                const Text('Could not load booking',
                    style: TextStyle(color: AppColors.neutral500)),
                const SizedBox(height: AppSpacing.lg),
                TextButton(
                  onPressed: () =>
                      ref.invalidate(bookingDetailProvider(bookingId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (booking) => _BookingDetailBody(booking: booking),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Main body (scrollable)
// ---------------------------------------------------------------------------

class _BookingDetailBody extends ConsumerWidget {
  const _BookingDetailBody({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final statusColor = bookingStatusColor(booking.status);
    final statusLabel = _statusLabel(l10n, booking.status);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.neutral900),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.bookingDetailTitle(booking.shortRef),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: StatusChip(
              label: statusLabel,
              color: statusColor,
              dot: true,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          120, // leave room for sticky actions
        ),
        children: [
          // 1. Timeline
          _TimelineCard(booking: booking),
          const SizedBox(height: AppSpacing.md),

          // 2. Car snapshot
          _CarSnapshotCard(booking: booking),
          const SizedBox(height: AppSpacing.md),

          // 3. Dates
          _DatesCard(booking: booking),
          const SizedBox(height: AppSpacing.md),

          // 4. Pricing
          _PricingCard(booking: booking),
          const SizedBox(height: AppSpacing.md),

          // 5. Pickup info (confirmed/active only)
          if (booking.status == BookingStatus.confirmed ||
              booking.status == BookingStatus.active ||
              booking.status == BookingStatus.returning)
            _PickupInfoCard(booking: booking),

          // 6. Cancellation reason
          if (booking.status == BookingStatus.cancelled &&
              booking.cancellationReason != null) ...[
            const SizedBox(height: AppSpacing.md),
            _CancellationReasonCard(booking: booking),
          ],
        ],
      ),
      bottomNavigationBar: _StickyActions(booking: booking),
    );
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
// Timeline card
// ---------------------------------------------------------------------------

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final isCancelled = booking.status == BookingStatus.cancelled;

    final stages = [
      (BookingStatus.pending, l10n.bookingTimelineRequested),
      (BookingStatus.confirmed, l10n.bookingTimelineConfirmed),
      (BookingStatus.active, l10n.bookingTimelineActive),
      (BookingStatus.completed, l10n.bookingTimelineCompleted),
    ];

    // Determine which stages are "past" based on statusHistory or current status
    bool isStagePast(BookingStatus stageStatus) {
      if (booking.statusHistory.isNotEmpty) {
        return booking.statusHistory
            .any((e) => e.status == stageStatus);
      }
      // Fallback: derive from current status order
      final order = [
        BookingStatus.pending,
        BookingStatus.confirmed,
        BookingStatus.active,
        BookingStatus.completed,
      ];
      final currentIdx = order.indexOf(booking.status);
      final stageIdx = order.indexOf(stageStatus);
      return stageIdx <= currentIdx;
    }

    DateTime? timestampFor(BookingStatus stageStatus) {
      try {
        return booking.statusHistory
            .firstWhere((e) => e.status == stageStatus)
            .timestamp;
      } catch (_) {
        return null;
      }
    }

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCancelled)
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.bookingTimelineCancelled,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                for (var i = 0; i < stages.length; i++) ...[
                  _TimelineDot(
                    label: stages[i].$2,
                    timestamp: timestampFor(stages[i].$1),
                    isPast: isStagePast(stages[i].$1),
                    isCurrent: booking.status == stages[i].$1,
                  ),
                  if (i < stages.length - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: isStagePast(stages[i + 1].$1)
                            ? AppColors.primary
                            : AppColors.neutral200,
                      ),
                    ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _TimelineDot extends StatelessWidget {
  const _TimelineDot({
    required this.label,
    required this.isPast,
    required this.isCurrent,
    this.timestamp,
  });

  final String label;
  final bool isPast;
  final bool isCurrent;
  final DateTime? timestamp;

  @override
  Widget build(BuildContext context) {
    final color = isPast ? AppColors.primary : AppColors.neutral300;
    final fmt = DateFormat('dd.MM');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: isPast ? AppColors.primary : AppColors.white,
            border: Border.all(color: color, width: 2),
            shape: BoxShape.circle,
          ),
          child: isCurrent
              ? const Center(
                  child: SizedBox(
                    width: 6,
                    height: 6,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: isPast ? AppColors.primary : AppColors.neutral400,
          ),
        ),
        if (timestamp != null)
          Text(
            fmt.format(timestamp!),
            style: const TextStyle(fontSize: 9, color: AppColors.neutral400),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Car snapshot card
// ---------------------------------------------------------------------------

class _CarSnapshotCard extends StatelessWidget {
  const _CarSnapshotCard({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final plate = booking.displayPlate;

    return _SectionCard(
      title: l10n.bookingCarSection,
      child: Row(
        children: [
          // M6.F: Hero tag matches booking card thumbnail in dashboard
          Hero(
            tag: 'booking-thumb-${booking.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: CachedNetworkImage(
                imageUrl: booking.carImageUrl,
                width: 80,
                height: 60,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                    width: 80, height: 60, color: AppColors.neutral200),
                errorWidget: (_, _, _) => Container(
                  width: 80,
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
                Text(
                  booking.carName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.neutral100,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: AppColors.neutral200),
                      ),
                      child: Text(
                        plate,
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
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dates card
// ---------------------------------------------------------------------------

class _DatesCard extends StatelessWidget {
  const _DatesCard({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final fmt = DateFormat('dd.MM.yyyy HH:mm');

    return _SectionCard(
      title: l10n.bookingDatesSection,
      child: Column(
        children: [
          _DateRow(
            label: 'Scheduled start',
            value: fmt.format(booking.startDate),
          ),
          _DateRow(
            label: 'Scheduled end',
            value: fmt.format(booking.endDate),
          ),
          if (booking.actualStart != null)
            _DateRow(
              label: 'Actual start',
              value: fmt.format(booking.actualStart!),
            ),
          if (booking.actualEnd != null)
            _DateRow(
              label: 'Actual end',
              value: fmt.format(booking.actualEnd!),
            ),
          _DateRow(
            label: 'Total days',
            value: l10n.bookingPricingDays(booking.days),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.neutral500)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral900)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pricing card
// ---------------------------------------------------------------------------

class _PricingCard extends StatelessWidget {
  const _PricingCard({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final isFinal = booking.status == BookingStatus.completed;
    final totalLabel =
        isFinal ? l10n.bookingPricingFinalTotal : l10n.bookingPricingEstimatedTotal;
    final displayTotal = isFinal
        ? (booking.actualTotal ?? booking.total)
        : (booking.estimatedTotal ?? booking.total);

    return _SectionCard(
      title: l10n.bookingPricingSection,
      child: Column(
        children: [
          // Daily rate line
          _PriceRow(
            label:
                '${l10n.bookingPricingDailyRate} × ${l10n.bookingPricingDays(booking.days)}',
            amount: booking.pricePerDay * booking.days,
          ),
          // Additional services
          for (final svc in booking.additionalServices)
            _PriceRow(label: svc.name, amount: svc.price),
          // Deposit
          if (booking.deposit > 0)
            _PriceRow(
                label: l10n.bookingPricingDeposit, amount: booking.deposit),
          // Fees breakdown
          if (booking.fees != null && booking.fees!.total > 0) ...[
            const Divider(height: AppSpacing.lg, color: AppColors.neutral200),
            if (booking.fees!.fuel > 0)
              _PriceRow(label: 'Fuel fee', amount: booking.fees!.fuel),
            if (booking.fees!.mileage > 0)
              _PriceRow(
                  label: 'Mileage fee', amount: booking.fees!.mileage),
            if (booking.fees!.damage > 0)
              _PriceRow(
                  label: 'Damage fee', amount: booking.fees!.damage),
            if (booking.fees!.fines > 0)
              _PriceRow(
                  label: 'Fines', amount: booking.fees!.fines),
          ],
          const Divider(height: AppSpacing.lg, color: AppColors.neutral200),
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                totalLabel,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                ),
              ),
              Text(
                '₸${_fmt(displayTotal)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(int amount) {
    final s = amount.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.amount});
  final String label;
  final int amount;

  @override
  Widget build(BuildContext context) {
    final s = amount.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.neutral700)),
          ),
          Text('₸$buf',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral900)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pickup info card
// ---------------------------------------------------------------------------

class _PickupInfoCard extends ConsumerWidget {
  const _PickupInfoCard({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);

    return _SectionCard(
      title: l10n.bookingPickupSection,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (booking.pickupLocation != null) ...[
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 16, color: AppColors.neutral500),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    booking.pickupLocation!,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.neutral700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (booking.pickupNotes != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.notes_outlined,
                    size: 16, color: AppColors.neutral500),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    booking.pickupNotes!,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.neutral700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (booking.managerPhone != null) ...[
            const SizedBox(height: AppSpacing.xs),
            ManagerContactActions(
                managerPhone: booking.managerPhone!),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Cancellation reason card
// ---------------------------------------------------------------------------

class _CancellationReasonCard extends StatelessWidget {
  const _CancellationReasonCard({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return _SectionCard(
      title: l10n.bookingCancellationReason,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Text(
          booking.cancellationReason!,
          style: const TextStyle(fontSize: 13, color: AppColors.neutral700),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sticky bottom actions
// ---------------------------------------------------------------------------

class _StickyActions extends ConsumerWidget {
  const _StickyActions({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final status = booking.status;

    // No actions for completed (no debt), cancelled
    if (status == BookingStatus.cancelled ||
        status == BookingStatus.completed) {
      // Show "Mark as paid" if completed with outstanding balance
      final hasDebt = booking.actualTotal != null &&
          (booking.estimatedTotal ?? booking.total) <
              (booking.actualTotal ?? 0);
      if (!hasDebt) return const SizedBox.shrink();
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border:
            Border(top: BorderSide(color: AppColors.neutral200, width: 0.5)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        MediaQuery.paddingOf(context).bottom + AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == BookingStatus.pending)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => showCancelBookingSheet(context, ref, booking),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  minimumSize: const Size(0, 48),
                ),
                child: Text(l10n.bookingActionCancelRequest),
              ),
            ),
          if (status == BookingStatus.confirmed) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => showCancelBookingSheet(context, ref, booking),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  minimumSize: const Size(0, 48),
                ),
                child: Text(l10n.bookingActionCancel),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            PrimaryButton(
              label: l10n.bookingActionContactManager,
              onPressed: booking.managerPhone != null
                  ? () => _showContactSheet(context, booking.managerPhone!)
                  : null,
            ),
          ],
          if (status == BookingStatus.active ||
              status == BookingStatus.returning) ...[
            PrimaryButton(
              label: l10n.bookingActionContactManager,
              onPressed: booking.managerPhone != null
                  ? () => _showContactSheet(context, booking.managerPhone!)
                  : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showReturnInstructions(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.neutral700,
                  side: const BorderSide(color: AppColors.neutral300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  minimumSize: const Size(0, 48),
                ),
                child: Text(l10n.bookingActionReturnInstructions),
              ),
            ),
          ],
          if (status == BookingStatus.completed)
            PrimaryButton(
              label: l10n.bookingActionMarkAsPaid,
              onPressed: () => context
                  .push('/record-payment?rentalId=${booking.id}'),
            ),
        ],
      ),
    );
  }

  void _showContactSheet(BuildContext context, String phone) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) => _ContactSheet(phone: phone),
    );
  }

  void _showReturnInstructions(BuildContext context) {
    final l10n = AppL10n.of(context);
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          MediaQuery.paddingOf(ctx).bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.bookingReturnInstructionsTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.bookingReturnInstructionsBody,
              style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.neutral700),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: const Text('OK'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Manager contact actions widget (shared by detail + active rental screens)
// ---------------------------------------------------------------------------

class ManagerContactActions extends StatelessWidget {
  const ManagerContactActions({super.key, required this.managerPhone});

  final String managerPhone;

  Future<void> _launch(BuildContext context, Uri uri) async {
    final l10n = AppL10n.of(context);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.contactCannotLaunch)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    // Normalize phone: strip everything except digits and leading +
    final digits = managerPhone.replaceAll(RegExp(r'[^\d+]'), '');

    return Row(
      children: [
        Expanded(
          child: Material(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: InkWell(
              onTap: () => _launch(context, Uri.parse('tel:$digits')),
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.call_outlined,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      l10n.contactCall,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Material(
            color: const Color(0xFFE7F7EE),
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: InkWell(
              onTap: () => _launch(
                context,
                Uri.parse('https://wa.me/$digits'),
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.chat_outlined,
                        size: 18, color: Color(0xFF25D366)),
                    const SizedBox(width: 6),
                    Text(
                      l10n.contactWhatsapp,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF25D366),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Contact bottom sheet (used from sticky actions "Contact manager")
// ---------------------------------------------------------------------------

class _ContactSheet extends StatelessWidget {
  const _ContactSheet({required this.phone});
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        MediaQuery.paddingOf(context).bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact manager',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            phone,
            style: const TextStyle(fontSize: 15, color: AppColors.neutral500),
          ),
          const SizedBox(height: AppSpacing.lg),
          ManagerContactActions(managerPhone: phone),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Cancel booking bottom sheet
// ---------------------------------------------------------------------------

Future<void> showCancelBookingSheet(
  BuildContext context,
  WidgetRef ref,
  Booking booking,
) async {
  // Guard: only pending/confirmed can be cancelled
  if (booking.status != BookingStatus.pending &&
      booking.status != BookingStatus.confirmed) {
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (ctx) => _CancelBookingSheet(booking: booking),
  );

  // After sheet closes, refresh providers
  ref.invalidate(bookingsListProvider);
  ref.invalidate(bookingDetailProvider(booking.id));
}

class _CancelBookingSheet extends ConsumerStatefulWidget {
  const _CancelBookingSheet({required this.booking});
  final Booking booking;

  @override
  ConsumerState<_CancelBookingSheet> createState() =>
      _CancelBookingSheetState();
}

class _CancelBookingSheetState extends ConsumerState<_CancelBookingSheet> {
  final _reasonController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final l10n = AppL10n.of(context);
    final reason = _reasonController.text.trim();

    if (reason.length < 5) {
      setState(() => _error = 'Please enter at least 5 characters');
      return;
    }

    // Extra confirmation dialog for confirmed bookings
    if (widget.booking.status == BookingStatus.confirmed) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.cancelBookingConfirmed),
          content: Text(l10n.cancelBookingConfirmedWarning),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.cancelBookingKeepCta),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style:
                  TextButton.styleFrom(foregroundColor: AppColors.error),
              child: Text(l10n.cancelBookingConfirmCta),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Import via api_client provider
      final api = ref.read(mobileRentalsApiProvider);
      await api.cancel(widget.booking.id, reason: reason);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.cancelBookingSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final isConfirmed = widget.booking.status == BookingStatus.confirmed;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        MediaQuery.viewInsetsOf(context).bottom +
            MediaQuery.paddingOf(context).bottom +
            AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.cancelBookingTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isConfirmed
                  ? AppColors.error.withValues(alpha: 0.06)
                  : AppColors.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              isConfirmed
                  ? l10n.cancelBookingConfirmedWarning
                  : l10n.cancelBookingPendingWarning,
              style: TextStyle(
                fontSize: 13,
                color: isConfirmed
                    ? AppColors.error
                    : AppColors.neutral700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _reasonController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: l10n.cancelBookingReasonHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.neutral300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              contentPadding: const EdgeInsets.all(AppSpacing.md),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(_error!,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.error)),
          ],
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _confirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
                elevation: 0,
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.white),
                      ),
                    )
                  : Text(l10n.cancelBookingConfirmCta),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancelBookingKeepCta,
                  style:
                      const TextStyle(color: AppColors.neutral500)),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared section card wrapper
// ---------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child, this.title});

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: AppColors.elevation1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: AppColors.neutral500,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          child,
        ],
      ),
    );
  }
}
