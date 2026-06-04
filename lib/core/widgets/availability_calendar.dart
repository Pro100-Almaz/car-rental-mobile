import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/car.dart';
import '../providers/cars_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'shimmer_box.dart';

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

class AvailabilityCalendar extends ConsumerStatefulWidget {
  const AvailabilityCalendar({
    super.key,
    required this.vehicleId,
    required this.onRangeChanged,
    this.selectedStart,
    this.selectedEnd,
    this.overrideAvailability,
  });

  final String vehicleId;
  final DateTime? selectedStart;
  final DateTime? selectedEnd;
  final void Function(DateTimeRange?) onRangeChanged;

  /// For testing/preview — bypasses API fetch.
  final Map<DateTime, DayAvailability>? overrideAvailability;

  @override
  ConsumerState<AvailabilityCalendar> createState() =>
      _AvailabilityCalendarState();
}

// ---------------------------------------------------------------------------
// State machine
// Selection states:
//   - nothing selected         → tap sets start
//   - start set, no end        → tap sets end (if >= start)
//   - both set                 → tap resets (new start)
// Conflict: if range spans booked/pending → error, reset to start only.
// Month navigation: capped at current month + 3.
// ---------------------------------------------------------------------------

class _AvailabilityCalendarState extends ConsumerState<AvailabilityCalendar> {
  late DateTime _visibleMonth;
  DateTime? _start;
  DateTime? _end;
  String? _conflictMsg;

  static const int _maxMonthsAhead = 3;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
    _start = widget.selectedStart;
    _end = widget.selectedEnd;
    // Pre-fetch next month for snappier UX
    _prefetchNext();
  }

  void _prefetchNext() {
    final next = _nextMonth(_visibleMonth);
    ref.read(availabilityProvider(availKey(widget.vehicleId, next)));
  }

  DateTime _nextMonth(DateTime m) => DateTime(m.year, m.month + 1);

  DateTime _prevMonth(DateTime m) => DateTime(m.year, m.month - 1);

  DateTime get _maxMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month + _maxMonthsAhead);
  }

  bool get _canGoBack {
    final now = DateTime.now();
    return _visibleMonth.isAfter(DateTime(now.year, now.month));
  }

  bool get _canGoForward => _visibleMonth.isBefore(_maxMonth);

  void _goBack() {
    if (!_canGoBack) return;
    setState(() {
      _visibleMonth = _prevMonth(_visibleMonth);
      _conflictMsg = null;
    });
  }

  void _goForward() {
    if (!_canGoForward) return;
    setState(() {
      _visibleMonth = _nextMonth(_visibleMonth);
      _conflictMsg = null;
    });
    _prefetchNext();
  }

  void _onDayTap(DateTime day, Map<DateTime, DayAvailability> avail) {
    final key = DateTime(day.year, day.month, day.day);
    final dayAvail = avail[key] ?? DayAvailability.available;

    // Past dates and non-free days are not tappable
    if (_isPast(day) ||
        dayAvail == DayAvailability.booked ||
        dayAvail == DayAvailability.pending) {
      return;
    }

    setState(() => _conflictMsg = null);

    // State machine
    if (_start == null || (_start != null && _end != null)) {
      // Fresh start
      setState(() {
        _start = key;
        _end = null;
      });
      widget.onRangeChanged(null);
      return;
    }

    // We have a start but no end — set end
    if (key.isBefore(_start!)) {
      // Tapped before start — make it the new start
      setState(() {
        _start = key;
        _end = null;
      });
      widget.onRangeChanged(null);
      return;
    }

    if (key == _start) {
      // Same day — reset
      setState(() {
        _start = null;
        _end = null;
      });
      widget.onRangeChanged(null);
      return;
    }

    // Validate range: no booked/pending days in between
    final conflict = _rangeHasConflict(_start!, key, avail);
    if (conflict) {
      setState(() {
        _conflictMsg =
            'Selected dates conflict with an existing booking. Please choose other dates.';
        _end = null;
      });
      widget.onRangeChanged(null);
      return;
    }

    // Valid range
    setState(() {
      _end = key;
      _conflictMsg = null;
    });
    widget.onRangeChanged(DateTimeRange(start: _start!, end: _end!));
  }

  bool _rangeHasConflict(
      DateTime start, DateTime end, Map<DateTime, DayAvailability> avail) {
    var cursor = start.add(const Duration(days: 1));
    while (!cursor.isAfter(end)) {
      final k = DateTime(cursor.year, cursor.month, cursor.day);
      final a = avail[k];
      if (a == DayAvailability.booked || a == DayAvailability.pending) {
        return true;
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    return false;
  }

  bool _isPast(DateTime day) {
    final today = DateTime.now();
    return day.isBefore(DateTime(today.year, today.month, today.day));
  }

  bool _isInRange(DateTime day) {
    if (_start == null || _end == null) return false;
    return day.isAfter(_start!) && day.isBefore(_end!);
  }

  bool _isStart(DateTime day) =>
      _start != null &&
      day == DateTime(_start!.year, _start!.month, _start!.day);

  bool _isEnd(DateTime day) =>
      _end != null && day == DateTime(_end!.year, _end!.month, _end!.day);

  @override
  Widget build(BuildContext context) {
    final provKey = widget.overrideAvailability != null
        ? null
        : availKey(widget.vehicleId, _visibleMonth);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CalendarHeader(
          visibleMonth: _visibleMonth,
          canGoBack: _canGoBack,
          canGoForward: _canGoForward,
          onBack: _goBack,
          onForward: _goForward,
        ),
        const SizedBox(height: AppSpacing.sm),
        const _WeekdayHeader(),
        const SizedBox(height: AppSpacing.xs),
        if (widget.overrideAvailability != null)
          _CalendarGrid(
            month: _visibleMonth,
            availability: widget.overrideAvailability!,
            onDayTap: _onDayTap,
            isStart: _isStart,
            isEnd: _isEnd,
            isInRange: _isInRange,
            isPast: _isPast,
          )
        else
          Consumer(
            builder: (context, ref, _) {
              final asyncAvail = ref.watch(availabilityProvider(provKey!));
              return asyncAvail.when(
                loading: () => const _CalendarShimmer(),
                error: (e, st) => _CalendarError(
                  onRetry: () =>
                      ref.invalidate(availabilityProvider(provKey)),
                ),
                data: (avail) => _CalendarGrid(
                  month: _visibleMonth,
                  availability: avail,
                  onDayTap: _onDayTap,
                  isStart: _isStart,
                  isEnd: _isEnd,
                  isInRange: _isInRange,
                  isPast: _isPast,
                ),
              );
            },
          ),
        if (_conflictMsg != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _ConflictChip(message: _conflictMsg!),
        ],
        const SizedBox(height: AppSpacing.sm),
        const _CalendarLegend(),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Calendar header
// ---------------------------------------------------------------------------

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.visibleMonth,
    required this.canGoBack,
    required this.canGoForward,
    required this.onBack,
    required this.onForward,
  });

  final DateTime visibleMonth;
  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback onBack;
  final VoidCallback onForward;

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    final label =
        '${_months[visibleMonth.month - 1]} ${visibleMonth.year}';
    return Row(
      children: [
        IconButton(
          onPressed: canGoBack ? onBack : null,
          icon: const Icon(Icons.chevron_left_rounded),
          color: canGoBack ? AppColors.neutral900 : AppColors.neutral300,
          iconSize: 24,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
          ),
        ),
        IconButton(
          onPressed: canGoForward ? onForward : null,
          icon: const Icon(Icons.chevron_right_rounded),
          color: canGoForward ? AppColors.neutral900 : AppColors.neutral300,
          iconSize: 24,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Weekday header (Mon-first, Kazakhstan convention)
// ---------------------------------------------------------------------------

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  static const _labels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _labels
          .map(
            (d) => Expanded(
              child: Text(
                d,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral500,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Calendar grid
// ---------------------------------------------------------------------------

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.month,
    required this.availability,
    required this.onDayTap,
    required this.isStart,
    required this.isEnd,
    required this.isInRange,
    required this.isPast,
  });

  final DateTime month;
  final Map<DateTime, DayAvailability> availability;
  final void Function(DateTime, Map<DateTime, DayAvailability>) onDayTap;
  final bool Function(DateTime) isStart;
  final bool Function(DateTime) isEnd;
  final bool Function(DateTime) isInRange;
  final bool Function(DateTime) isPast;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);
    // weekday: 1=Mon, 7=Sun
    final leadingBlanks = firstDay.weekday - 1;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    final cells = <Widget>[];

    for (var i = 0; i < leadingBlanks; i++) {
      cells.add(const SizedBox.shrink());
    }

    for (var d = 1; d <= daysInMonth; d++) {
      final day = DateTime(month.year, month.month, d);
      cells.add(_DayCell(
        day: day,
        availability: availability[day] ?? DayAvailability.available,
        isPast: isPast(day),
        isStart: isStart(day),
        isEnd: isEnd(day),
        isInRange: isInRange(day),
        onTap: () => onDayTap(day, availability),
      ));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.0,
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      children: cells,
    );
  }
}

// ---------------------------------------------------------------------------
// Individual day cell
// ---------------------------------------------------------------------------

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.availability,
    required this.isPast,
    required this.isStart,
    required this.isEnd,
    required this.isInRange,
    required this.onTap,
  });

  final DateTime day;
  final DayAvailability availability;
  final bool isPast;
  final bool isStart;
  final bool isEnd;
  final bool isInRange;
  final VoidCallback onTap;

  bool get _isToday {
    final now = DateTime.now();
    return day.year == now.year &&
        day.month == now.month &&
        day.day == now.day;
  }

  bool get _isSelectable =>
      !isPast &&
      availability != DayAvailability.booked &&
      availability != DayAvailability.pending;

  @override
  Widget build(BuildContext context) {
    Color? bg;
    Color textColor = AppColors.neutral900;
    bool strikeThrough = false;

    if (isPast) {
      textColor = AppColors.neutral300;
    } else if (isStart || isEnd) {
      bg = AppColors.primary;
      textColor = AppColors.white;
    } else if (isInRange) {
      bg = AppColors.primaryLight;
      textColor = AppColors.primary;
    } else {
      switch (availability) {
        case DayAvailability.available:
          bg = const Color(0xFFDCFCE7);
        case DayAvailability.booked:
          bg = const Color(0xFFFEE2E2);
          textColor = AppColors.error;
          strikeThrough = true;
        case DayAvailability.pending:
          bg = const Color(0xFFFEF9C3);
          textColor = const Color(0xFF92400E);
        case DayAvailability.past:
          textColor = AppColors.neutral300;
      }
    }

    final isEndpoint = isStart || isEnd;

    return GestureDetector(
      onTap: _isSelectable ? onTap : null,
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: bg,
          shape: isEndpoint ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isEndpoint
              ? null
              : BorderRadius.circular(isInRange ? 0 : 6),
          border: _isToday && !isEndpoint
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
        ),
        child: Center(
          child: Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 13,
              fontWeight:
                  isEndpoint || _isToday ? FontWeight.w700 : FontWeight.w400,
              color: textColor,
              decoration: strikeThrough
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              decorationColor: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Conflict chip
// ---------------------------------------------------------------------------

class _ConflictChip extends StatelessWidget {
  const _ConflictChip({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              size: 16, color: AppColors.error),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Legend
// ---------------------------------------------------------------------------

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.sm,
      children: [
        _LegendItem(color: Color(0xFFDCFCE7), label: 'Available'),
        _LegendItem(color: Color(0xFFFEE2E2), label: 'Booked'),
        _LegendItem(color: Color(0xFFFEF9C3), label: 'Pending'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: AppColors.neutral300),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style:
              const TextStyle(fontSize: 12, color: AppColors.neutral500),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shimmer placeholder while loading
// ---------------------------------------------------------------------------

class _CalendarShimmer extends StatelessWidget {
  const _CalendarShimmer();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.0,
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      children: List.generate(
        35,
        (_) => Padding(
          padding: const EdgeInsets.all(2),
          child: ShimmerBox(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Inline error
// ---------------------------------------------------------------------------

class _CalendarError extends StatelessWidget {
  const _CalendarError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 16, color: AppColors.error),
          const SizedBox(width: AppSpacing.sm),
          const Text(
            'Failed to load availability',
            style: TextStyle(fontSize: 13, color: AppColors.neutral500),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: onRetry,
            child: const Text(
              'Retry',
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
