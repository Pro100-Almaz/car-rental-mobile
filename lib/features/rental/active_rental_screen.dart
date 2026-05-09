import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/booking.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/primary_button.dart';

class ActiveRentalScreen extends ConsumerStatefulWidget {
  const ActiveRentalScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  ConsumerState<ActiveRentalScreen> createState() => _ActiveRentalScreenState();
}

class _ActiveRentalScreenState extends ConsumerState<ActiveRentalScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(bookingsProvider);
    final Booking booking;
    try {
      booking = bookings.firstWhere((b) => b.id == widget.bookingId);
    } catch (_) {
      return const Scaffold(
        body: Center(child: Text('Booking not found')),
      );
    }

    final car = ref.watch(carByIdProvider(booking.carId));
    final now = DateTime.now();
    final remaining = booking.endDate.difference(now);
    final elapsed = now.difference(booking.startDate);
    final totalDuration = booking.endDate.difference(booking.startDate);
    final progress = totalDuration.inSeconds > 0
        ? (elapsed.inSeconds / totalDuration.inSeconds).clamp(0.0, 1.0)
        : 0.0;

    final int currentCost;
    if (car != null && elapsed.inHours < 3) {
      currentCost = elapsed.inHours.ceil().clamp(1, 999) * car.pricePerHour;
    } else {
      final days = (elapsed.inHours / 24).ceil().clamp(1, 999);
      currentCost = days * booking.pricePerDay;
    }

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: CustomScrollView(
        slivers: [
          _RentalAppBar(booking: booking, onBack: () => context.pop()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.xl,
              ),
              child: Column(
                children: [
                  _TimerCard(
                    remaining: remaining,
                    progress: progress,
                    startDate: booking.startDate,
                    endDate: booking.endDate,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _CostCard(currentCost: currentCost),
                  const SizedBox(height: AppSpacing.lg),
                  _CarInfoRow(booking: booking),
                  const SizedBox(height: AppSpacing.lg),
                  _ActionGrid(bookingId: widget.bookingId),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _ReturnBar(bookingId: widget.bookingId),
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
                  booking.plateNumber,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
          _StatusBadge(),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.statusRented.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: AppColors.statusRented.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.statusRented,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          const Text(
            'Active',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.statusRented,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Timer card
// ---------------------------------------------------------------------------

class _TimerCard extends StatelessWidget {
  const _TimerCard({
    required this.remaining,
    required this.progress,
    required this.startDate,
    required this.endDate,
  });

  final Duration remaining;
  final double progress;
  final DateTime startDate;
  final DateTime endDate;

  String _formatDuration(Duration d) {
    if (d.isNegative) return '00:00:00';
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _formatDateTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    return '$day.$month  $h:$m';
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
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CustomPaint(
                    painter: _ArcPainter(progress: progress),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatDuration(remaining),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                        letterSpacing: 2,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
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
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: _TimeLabel(
                  icon: Icons.play_circle_outline_rounded,
                  label: 'Start',
                  value: _formatDateTime(startDate),
                  color: AppColors.success,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: AppColors.neutral200,
              ),
              Expanded(
                child: _TimeLabel(
                  icon: Icons.stop_circle_outlined,
                  label: 'End',
                  value: _formatDateTime(endDate),
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ],
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

    // Background track
    final trackPaint = Paint()
      ..color = AppColors.neutral200
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc (remaining = 1 - progress)
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
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * remaining,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress;
}

// ---------------------------------------------------------------------------
// Cost card
// ---------------------------------------------------------------------------

class _CostCard extends StatelessWidget {
  const _CostCard({required this.currentCost});

  final int currentCost;

  @override
  Widget build(BuildContext context) {
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
                const Text(
                  'RUNNING COST',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '₸ ${_formatPrice(currentCost)}',
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
// Car info row
// ---------------------------------------------------------------------------

class _CarInfoRow extends StatelessWidget {
  const _CarInfoRow({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
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
                  booking.plateNumber,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              booking.category,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.neutral700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action grid
// ---------------------------------------------------------------------------

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 2.2,
      children: [
        _ActionTile(
          icon: Icons.access_time_rounded,
          label: 'Extend Rental',
          onTap: () => _showExtendDialog(context),
        ),
        _ActionTile(
          icon: Icons.warning_amber_rounded,
          label: 'Report Issue',
          onTap: () => _showReportSheet(context),
        ),
        _ActionTile(
          icon: Icons.chat_bubble_outline_rounded,
          label: 'Support Chat',
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Coming soon')),
          ),
        ),
        _ActionTile(
          icon: Icons.navigation_rounded,
          label: 'Navigation',
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Coming soon')),
          ),
        ),
      ],
    );
  }

  void _showExtendDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: const Text(
          'Extend Rental',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select how long you want to extend:',
              style: TextStyle(color: AppColors.neutral700),
            ),
            const SizedBox(height: AppSpacing.lg),
            ...[
              ('+1 Hour', 1),
              ('+3 Hours', 3),
              ('+1 Day', 24),
            ].map(
              (opt) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(Icons.access_time_rounded,
                      color: AppColors.primary, size: 20),
                ),
                title: Text(
                  opt.$1,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral900,
                  ),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Extended by ${opt.$1}')),
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.neutral500)),
          ),
        ],
      ),
    );
  }

  void _showReportSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
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
              'Report an Issue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...[
              (Icons.car_crash_outlined, 'Accident or Damage'),
              (Icons.local_gas_station_outlined, 'Fuel Problem'),
              (Icons.build_outlined, 'Mechanical Issue'),
              (Icons.lock_outline_rounded, 'Lock / Key Problem'),
              (Icons.more_horiz_rounded, 'Other'),
            ].map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(item.$1, color: AppColors.neutral700),
                title: Text(
                  item.$2,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutral900,
                  ),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item.$2} reported')),
                  );
                },
              ),
            ),
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
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
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
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral900,
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
// Return bar
// ---------------------------------------------------------------------------

class _ReturnBar extends StatelessWidget {
  const _ReturnBar({required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.neutral200, width: 0.5)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        MediaQuery.paddingOf(context).bottom + AppSpacing.md,
      ),
      child: PrimaryButton(
        label: 'Return Car',
        icon: Icons.flag_outlined,
        onPressed: () => context.push('/rental/inspect/$bookingId'),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _formatPrice(int value) {
  final str = value.toString();
  final buf = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buf.write(',');
    buf.write(str[i]);
  }
  return buf.toString();
}
