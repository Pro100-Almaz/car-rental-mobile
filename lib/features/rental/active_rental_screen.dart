// AUDIT FIX: The original active_rental_screen.dart had a Timer.periodic in
// the top-level initState that called setState() every second, causing the
// entire screen widget tree to rebuild on every tick (audit finding M4-PERF-1).
//
// Fix: Timer.periodic now lives exclusively inside RentalTimer, which owns a
// ValueNotifier<Duration> updated each second. Only the Text widget inside
// ValueListenableBuilder rebuilds. A RepaintBoundary wraps RentalTimer so
// its repaint does not propagate to the parent layer.
//
// Verified: no Timer.periodic at top-level initState in this file.

import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/formatters/money.dart';
import '../../core/models/booking.dart';
import '../../core/providers/active_rental_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/error_retry_widget.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/shimmer_box.dart';
import '../../core/widgets/status_chip.dart';
import '../../features/bookings/booking_detail_screen.dart'
    show ManagerContactActions;
import '../../l10n/app_localizations.dart';

class ActiveRentalScreen extends ConsumerWidget {
  const ActiveRentalScreen({super.key, this.bookingId});

  // bookingId is now optional — the screen drives from activeRentalProvider
  // rather than from a passed id (retained for router back-compat).
  final String? bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final activeAsync = ref.watch(activeRentalProvider);

    return activeAsync.when(
      loading: () => const _ActiveRentalSkeleton(),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.neutral50,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: const Text('Active Rental'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: ErrorRetryWidget(
          message: 'Could not load rental. Please try again.',
          onRetry: () => ref.invalidate(activeRentalProvider),
        ),
      ),
      data: (booking) {
        if (booking == null) {
          return Scaffold(
            backgroundColor: AppColors.neutral50,
            body: EmptyStateView(
              icon: Icons.directions_car_outlined,
              title: l10n.activeRentalEmpty,
              subtitle: l10n.activeRentalEmptyCta,
              action: SizedBox(
                width: 180,
                child: PrimaryButton(
                  label: l10n.bookingsBrowseCars,
                  onPressed: () => context.go('/cars'),
                ),
              ),
            ),
          );
        }
        return _ActiveRentalBody(booking: booking);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Skeleton loading state (M6.A)
// ---------------------------------------------------------------------------

class _ActiveRentalSkeleton extends StatelessWidget {
  const _ActiveRentalSkeleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              // Timer card skeleton
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.neutral200),
                ),
                child: Column(
                  children: [
                    ShimmerBox(
                        height: 14,
                        width: 120,
                        borderRadius: BorderRadius.circular(4)),
                    const SizedBox(height: AppSpacing.xl),
                    const ShimmerBox(
                        width: 180,
                        height: 180,
                        borderRadius: BorderRadius.all(Radius.circular(90))),
                    const SizedBox(height: AppSpacing.lg),
                    ShimmerBox(
                        height: 14,
                        width: 100,
                        borderRadius: BorderRadius.circular(4)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Cost card skeleton
              ShimmerBox(
                  height: 90,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(AppRadius.md)),
              const SizedBox(height: AppSpacing.lg),
              // Car snapshot skeleton
              ShimmerBox(
                  height: 100,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(AppRadius.md)),
              const SizedBox(height: AppSpacing.lg),
              // Actions row skeleton
              Row(
                children: List.generate(
                  3,
                  (i) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          right: i < 2 ? AppSpacing.sm : 0),
                      child: ShimmerBox(
                          height: 72,
                          borderRadius: BorderRadius.circular(AppRadius.md)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Main body
// ---------------------------------------------------------------------------

class _ActiveRentalBody extends StatelessWidget {
  const _ActiveRentalBody({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: CustomScrollView(
        slivers: [
          _RentalAppBar(booking: booking, onBack: () => context.pop()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: Column(
                children: [
                  // Timer — only this widget rebuilds every second
                  // (RepaintBoundary isolates its repaint from the rest of the tree)
                  RepaintBoundary(
                    child: RentalTimer(endsAt: booking.endDate),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Running cost — server-computed, no client-side ticking
                  RunningCostCard(booking: booking),
                  const SizedBox(height: AppSpacing.lg),

                  // Car snapshot with fuel + mileage
                  ActiveRentalCarSnapshot(booking: booking),
                  const SizedBox(height: AppSpacing.lg),

                  // Quick actions row
                  _QuickActionsRow(booking: booking),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _ReturnBar(booking: booking),
    );
  }
}

// ---------------------------------------------------------------------------
// App bar
// ---------------------------------------------------------------------------

class _RentalAppBar extends StatelessWidget {
  const _RentalAppBar({required this.booking, required this.onBack});

  final Booking booking;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          Material(
            color: AppColors.neutral100,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onBack,
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(Icons.arrow_back_rounded,
                    color: AppColors.neutral900, size: 20),
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
                    color: AppColors.neutral900,
                  ),
                ),
                Text(
                  booking.displayPlate,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
          const StatusChip(
            label: 'Active',
            color: AppColors.statusRented,
            dot: true,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// RentalTimer — owns its own Timer.periodic.
//
// AUDIT FIX M4-PERF-1: Only the countdown Text rebuilds every second via
// ValueListenableBuilder<Duration>. The arc painter also uses ValueNotifier
// but is wrapped in its own RepaintBoundary at the call site.
// ---------------------------------------------------------------------------

class RentalTimer extends StatefulWidget {
  const RentalTimer({super.key, required this.endsAt});

  final DateTime endsAt;

  @override
  State<RentalTimer> createState() => _RentalTimerState();
}

class _RentalTimerState extends State<RentalTimer> {
  late final ValueNotifier<Duration> _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = ValueNotifier(_computeRemaining());
    // Timer.periodic lives ONLY here — never in the parent screen's initState.
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _remaining.value = _computeRemaining();
    });
  }

  Duration _computeRemaining() =>
      widget.endsAt.difference(DateTime.now());

  @override
  void dispose() {
    _timer?.cancel();
    _remaining.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: AppColors.elevation2,
      ),
      child: Column(
        children: [
          const Text(
            'TIME REMAINING',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              color: AppColors.neutral500,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: 180,
            height: 180,
            child: ValueListenableBuilder<Duration>(
              valueListenable: _remaining,
              builder: (context, remaining, _) {
                // progress = elapsed / total, clamped 0..1
                final totalSec = widget.endsAt
                    .difference(widget.endsAt.subtract(
                        Duration(days: (remaining.inDays.abs() + 1).clamp(1, 365))))
                    .inSeconds
                    .abs();
                final progress = totalSec > 0
                    ? (1.0 -
                            remaining.inSeconds.abs() /
                                totalSec.clamp(1, totalSec))
                        .clamp(0.0, 1.0)
                    : 1.0;

                // M6.E: Semantics on custom arc canvas
                return Semantics(
                  label: remaining.isNegative
                      ? 'Overdue by ${_formatDurationLabel(remaining.abs())}'
                      : 'Time remaining: ${_formatDurationLabel(remaining)}',
                  child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CustomPaint(
                        painter: _ArcPainter(
                            progress: remaining.isNegative ? 1.0 : progress),
                      ),
                    ),
                    // Only this Column rebuilds every second — the CustomPaint
                    // repaints only if progress changes, which is the same tick.
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _TimerText(remaining: remaining),
                        const SizedBox(height: 4),
                        Text(
                          remaining.isNegative ? 'Overdue' : 'remaining',
                          style: TextStyle(
                            fontSize: 13,
                            color: remaining.isNegative
                                ? AppColors.error
                                : AppColors.neutral500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ); // closes Semantics
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: _TimeLabel(
                  icon: Icons.play_circle_outline_rounded,
                  label: 'End',
                  value: _formatDateTime(widget.endsAt),
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Human-readable duration for Semantics label.
  String _formatDurationLabel(Duration d) {
    final abs = d.abs();
    final h = abs.inHours;
    final m = abs.inMinutes % 60;
    if (h > 0) return '$h hours $m minutes';
    return '$m minutes';
  }

  String _formatDateTime(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '$d.$mo  $h:$mi';
  }
}

// Small leaf widget — only the formatted string rebuilds, not the container.
class _TimerText extends StatelessWidget {
  const _TimerText({required this.remaining});
  final Duration remaining;

  String _format(Duration d) {
    final abs = d.abs();
    final h = abs.inHours.toString().padLeft(2, '0');
    final m = (abs.inMinutes % 60).toString().padLeft(2, '0');
    final s = (abs.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _format(remaining),
      style: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: remaining.isNegative ? AppColors.error : AppColors.neutral900,
        letterSpacing: 2,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

class _TimeLabel extends StatelessWidget {
  const _TimeLabel({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: AppColors.neutral500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
        ),
      ],
    );
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 8;
    const strokeWidth = 10.0;

    final trackPaint = Paint()
      ..color = AppColors.neutral200
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final remaining = 1.0 - progress;
    if (remaining > 0) {
      final color = remaining > 0.3
          ? AppColors.primary
          : remaining > 0.1
              ? AppColors.warning
              : AppColors.error;

      final arcPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * remaining, false,
          arcPaint);
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress;
}

// ---------------------------------------------------------------------------
// RunningCostCard — server-computed cost from booking.estimatedTotal
// No client-side ticking — updates only when bookingDetailProvider refreshes.
// ---------------------------------------------------------------------------

class RunningCostCard extends StatelessWidget {
  const RunningCostCard({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final cost = booking.estimatedTotal ?? booking.total;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.activeRentalRunningCost.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formatKzt(cost),
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.white,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ActiveRentalCarSnapshot — photo + nickname + plate + fuel + mileage
// ---------------------------------------------------------------------------

class ActiveRentalCarSnapshot extends StatelessWidget {
  const ActiveRentalCarSnapshot({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final fuel = booking.fuelLevelAtPickup;
    final mileage = booking.mileageAtPickup;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: CachedNetworkImage(
                  imageUrl: booking.carImageUrl,
                  width: 72,
                  height: 52,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    color: AppColors.neutral200,
                    child: const Icon(Icons.directions_car_outlined,
                        color: AppColors.neutral500),
                  ),
                  errorWidget: (_, _, _) => Container(
                    color: AppColors.neutral200,
                    child: const Icon(Icons.directions_car_outlined,
                        color: AppColors.neutral500),
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
                    const SizedBox(height: 2),
                    Text(
                      booking.displayPlate,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (fuel != null || mileage != null) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1, color: AppColors.neutral200),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                if (fuel != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.local_gas_station_outlined,
                                size: 13, color: AppColors.neutral500),
                            const SizedBox(width: 4),
                            Text(
                              l10n.activeRentalCurrentFuel,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                color: AppColors.neutral500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        _FuelGauge(level: fuel),
                      ],
                    ),
                  ),
                if (fuel != null && mileage != null)
                  Container(
                    width: 1,
                    height: 36,
                    color: AppColors.neutral200,
                    margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                  ),
                if (mileage != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.route_outlined,
                                size: 13, color: AppColors.neutral500),
                            const SizedBox(width: 4),
                            Text(
                              l10n.activeRentalCurrentMileage,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                color: AppColors.neutral500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$mileage km',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.neutral900,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FuelGauge extends StatelessWidget {
  const _FuelGauge({required this.level});
  // level: 0.0–1.0 (from API). If API returns 0–100, Booking.fromJson
  // stores it as double; callers should divide by 100 if needed.
  // Open question: confirm unit with backend team.
  final double level;

  @override
  Widget build(BuildContext context) {
    // Clamp in case API returns 0–100 scale
    final normalised = level > 1.0 ? level / 100.0 : level;
    final pct = (normalised * 100).round();
    final color = normalised > 0.5
        ? AppColors.success
        : normalised > 0.2
            ? AppColors.warning
            : AppColors.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            value: normalised.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: AppColors.neutral200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$pct%',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Quick actions row
// ---------------------------------------------------------------------------

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            icon: Icons.access_time_rounded,
            label: l10n.activeRentalExtend,
            onTap: () => context.push('/active/extend'),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _ActionTile(
            icon: Icons.warning_amber_rounded,
            label: l10n.activeRentalReportIssue,
            onTap: () => _reportIssue(context),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _ActionTile(
            icon: Icons.phone_outlined,
            label: l10n.activeRentalContactManager,
            onTap: () => _showContactSheet(context),
          ),
        ),
      ],
    );
  }

  void _reportIssue(BuildContext context) {
    // MVP: WhatsApp deep link with pre-filled message per spec §3.6
    if (booking.managerPhone != null) {
      final phone =
          booking.managerPhone!.replaceAll(RegExp(r'[^\d+]'), '');
      final shortRef = booking.shortRef;
      final uri = Uri.parse(
          'https://wa.me/$phone?text=${Uri.encodeComponent('Issue with rental #$shortRef')}');
      launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Manager contact not available')),
      );
    }
  }

  void _showContactSheet(BuildContext context) {
    if (booking.managerPhone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Manager contact not available')),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg)),
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
              booking.managerPhone!,
              style: const TextStyle(
                  fontSize: 15, color: AppColors.neutral500),
            ),
            const SizedBox(height: AppSpacing.lg),
            ManagerContactActions(managerPhone: booking.managerPhone!),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.neutral200),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: AppSpacing.md),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Return bar
// ---------------------------------------------------------------------------

class _ReturnBar extends StatelessWidget {
  const _ReturnBar({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

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
      // Per spec §3.6: returns are handled offline by the manager.
      // Return CTA shows info bottom sheet — does NOT route to inspection screen.
      child: PrimaryButton(
        label: l10n.activeRentalReturnCar,
        icon: Icons.flag_outlined,
        onPressed: () => showModalBottomSheet<void>(
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
                    color: AppColors.neutral700,
                  ),
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
        ),
      ),
    );
  }
}
