import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/api/api_exception.dart';
import '../../core/api/api_client.dart';
import '../../core/models/car.dart';
import '../../core/models/user.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/primary_button.dart';

// ---------------------------------------------------------------------------
// Submit booking provider (ephemeral StateNotifier)
// ---------------------------------------------------------------------------

class _SubmitState {
  const _SubmitState({
    this.loading = false,
    this.errorMessage,
  });
  final bool loading;
  final String? errorMessage;
}

class _SubmitNotifier extends StateNotifier<_SubmitState> {
  _SubmitNotifier(this._ref) : super(const _SubmitState());
  final Ref _ref;

  Future<String?> submit({
    required String vehicleId,
    required DateTime start,
    required DateTime end,
    required List<String> serviceIds,
    String? pickupNotes,
  }) async {
    state = const _SubmitState(loading: true);
    try {
      final api = _ref.read(mobileRentalsApiProvider);
      final booking = await api.create(
        vehicleId: vehicleId,
        scheduledStart: start,
        scheduledEnd: end,
        additionalServiceIds: serviceIds,
        pickupNotes: pickupNotes,
      );
      state = const _SubmitState();
      return booking.id;
    } on ConflictException {
      state = const _SubmitState(
          errorMessage:
              'These dates are no longer available. Please choose other dates.');
      return null;
    } on ApiException catch (e) {
      state = _SubmitState(
          errorMessage: e.serverMessage ?? 'Submission failed. Please try again.');
      return null;
    } catch (_) {
      state = const _SubmitState(
          errorMessage: 'Something went wrong. Please try again.');
      return null;
    }
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = const _SubmitState();
    }
  }
}

final _submitProvider =
    StateNotifierProvider.autoDispose<_SubmitNotifier, _SubmitState>((ref) {
  return _SubmitNotifier(ref);
});

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class BookingRequestScreen extends ConsumerStatefulWidget {
  const BookingRequestScreen({
    super.key,
    required this.car,
    required this.startDate,
    required this.endDate,
  });

  final CarListing car;
  final DateTime startDate;
  final DateTime endDate;

  @override
  ConsumerState<BookingRequestScreen> createState() =>
      _BookingRequestScreenState();
}

class _BookingRequestScreenState extends ConsumerState<BookingRequestScreen> {
  final _pickupNotesController = TextEditingController();
  final Set<String> _selectedServiceIds = {};

  @override
  void dispose() {
    _pickupNotesController.dispose();
    super.dispose();
  }

  int get _days =>
      widget.endDate.difference(widget.startDate).inDays.clamp(1, 30);

  int get _subtotal => widget.car.dailyRate * _days;

  int get _servicesTotal => kStubAdditionalServices
      .where((s) => _selectedServiceIds.contains(s.id))
      .fold(0, (sum, s) => sum + s.totalFor(_days));

  int get _deposit => (widget.car.dailyRate * 0.3).round();

  int get _estimatedTotal => _subtotal + _servicesTotal;

  String _fmt(num amount) => NumberFormat('#,##0', 'ru').format(amount.truncate());

  Future<void> _handleSubmit() async {
    final notifier = ref.read(_submitProvider.notifier);
    final bookingId = await notifier.submit(
      vehicleId: widget.car.id,
      start: widget.startDate,
      end: widget.endDate,
      serviceIds: _selectedServiceIds.toList(),
      pickupNotes: _pickupNotesController.text.trim(),
    );

    if (!mounted) return;

    if (bookingId != null) {
      context.pushReplacement(
        '/cars/${widget.car.id}/book/confirm',
        extra: {
          'car': widget.car,
          'bookingId': bookingId,
          'startDate': widget.startDate,
          'endDate': widget.endDate,
          'estimatedTotal': _estimatedTotal,
        },
      );
    } else {
      // Error is shown in UI via submitState
      final err = ref.read(_submitProvider).errorMessage;
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(_submitProvider);
    final user = ref.watch(currentUserProvider);

    // Pre-submit guard banners
    String? blockReason;
    if (user != null) {
      if (user.verificationStatus != VerificationStatus.verified) {
        blockReason = 'Complete document verification first';
      } else if (user.isBlacklisted) {
        blockReason = 'Account suspended. Contact support.';
      } else if (user.debtBalance > 0) {
        blockReason =
            'Pay outstanding ₸${_fmt(user.debtBalance)} before booking';
      }
    }

    final canSubmit = blockReason == null && !submitState.loading;

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.neutral900),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Book your car',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0.5),
          child: Divider(height: 0.5, color: AppColors.neutral200),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Block reason banner
                if (blockReason != null) ...[
                  _BlockBanner(message: blockReason),
                  const SizedBox(height: AppSpacing.md),
                ],

                // Car summary card
                _CarSummaryCard(car: widget.car),
                const SizedBox(height: AppSpacing.lg),

                // Dates summary card
                _DatesSummaryCard(
                  startDate: widget.startDate,
                  endDate: widget.endDate,
                  days: _days,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Pricing breakdown
                _PricingCard(
                  car: widget.car,
                  days: _days,
                  subtotal: _subtotal,
                  deposit: _deposit,
                  estimatedTotal: _estimatedTotal,
                  selectedServiceIds: _selectedServiceIds,
                  onServiceToggle: (id) {
                    setState(() {
                      if (_selectedServiceIds.contains(id)) {
                        _selectedServiceIds.remove(id);
                      } else {
                        _selectedServiceIds.add(id);
                      }
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Pickup notes
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pickup notes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: _pickupNotesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText:
                              'Where would you like to pick up the car?',
                          hintStyle: TextStyle(
                              fontSize: 14, color: AppColors.neutral400),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8)),
                            borderSide:
                                BorderSide(color: AppColors.neutral200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8)),
                            borderSide:
                                BorderSide(color: AppColors.neutral200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8)),
                            borderSide:
                                BorderSide(color: AppColors.primary),
                          ),
                          contentPadding: EdgeInsets.all(AppSpacing.md),
                          isDense: true,
                        ),
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.neutral900),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Loading overlay
          if (submitState.loading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),

      // Sticky bottom CTA
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(
              top: BorderSide(color: AppColors.neutral200, width: 0.5)),
        ),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          MediaQuery.paddingOf(context).bottom + AppSpacing.md,
        ),
        child: PrimaryButton(
          label: 'Submit request',
          isLoading: submitState.loading,
          onPressed: canSubmit ? _handleSubmit : null,
          icon: Icons.check_rounded,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _BlockBanner extends StatelessWidget {
  const _BlockBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.block_rounded, size: 18, color: AppColors.error),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 13, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarSummaryCard extends StatelessWidget {
  const _CarSummaryCard({required this.car});
  final CarListing car;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppRadius.md),
              bottomLeft: Radius.circular(AppRadius.md),
            ),
            child: car.primaryPhoto.isNotEmpty
                ? Image.network(
                    car.primaryPhoto,
                    width: 100,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, trace) => Container(
                      width: 100,
                      height: 80,
                      color: AppColors.neutral200,
                      child: const Icon(Icons.directions_car_outlined,
                          color: AppColors.neutral500),
                    ),
                  )
                : Container(
                    width: 100,
                    height: 80,
                    color: AppColors.neutral200,
                    child: const Icon(Icons.directions_car_outlined,
                        color: AppColors.neutral500),
                  ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.displayTitle,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    car.displaySubtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.neutral500),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(Icons.attach_money_rounded,
                          size: 14, color: AppColors.primary),
                      Text(
                        '₸${NumberFormat('#,##0', 'ru').format(car.dailyRate)}/day',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
        ],
      ),
    );
  }
}

class _DatesSummaryCard extends StatelessWidget {
  const _DatesSummaryCard({
    required this.startDate,
    required this.endDate,
    required this.days,
  });

  final DateTime startDate;
  final DateTime endDate;
  final int days;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('EEE, d MMM yyyy');
    return GlassCard(
      child: Row(
        children: [
          Expanded(
            child: _DateCol(
              label: 'PICK-UP',
              date: fmt.format(startDate),
            ),
          ),
          Column(
            children: [
              Container(
                width: 32,
                height: 1.5,
                color: AppColors.neutral300,
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  '$days ${days == 1 ? 'day' : 'days'}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: _DateCol(
              label: 'RETURN',
              date: fmt.format(endDate),
              align: CrossAxisAlignment.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateCol extends StatelessWidget {
  const _DateCol({
    required this.label,
    required this.date,
    this.align = CrossAxisAlignment.start,
  });
  final String label;
  final String date;
  final CrossAxisAlignment align;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: AppColors.neutral500)),
        const SizedBox(height: 4),
        Text(date,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900)),
      ],
    );
  }
}

class _PricingCard extends StatelessWidget {
  const _PricingCard({
    required this.car,
    required this.days,
    required this.subtotal,
    required this.deposit,
    required this.estimatedTotal,
    required this.selectedServiceIds,
    required this.onServiceToggle,
  });

  final CarListing car;
  final int days;
  final int subtotal;
  final int deposit;
  final int estimatedTotal;
  final Set<String> selectedServiceIds;
  final void Function(String) onServiceToggle;

  String _fmt(int n) => NumberFormat('#,##0', 'ru').format(n);

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PRICING BREAKDOWN',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.neutral500,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _PriceLine(
              label:
                  '₸${_fmt(car.dailyRate)} × $days ${days == 1 ? 'day' : 'days'}',
              value: subtotal),
          const SizedBox(height: AppSpacing.sm),

          // Additional services
          ...kStubAdditionalServices.map((s) {
            final isSelected = selectedServiceIds.contains(s.id);
            final cost = s.totalFor(days);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: isSelected,
                      activeColor: AppColors.primary,
                      onChanged: (_) => onServiceToggle(s.id),
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '${s.name}${s.perDay ? ' (per day)' : ''}',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.neutral700),
                    ),
                  ),
                  Text(
                    '₸${_fmt(cost)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? AppColors.neutral900
                          : AppColors.neutral400,
                    ),
                  ),
                ],
              ),
            );
          }),

          const Divider(color: AppColors.neutral200),
          const SizedBox(height: AppSpacing.sm),

          // Deposit info
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Deposit (estimated)',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.neutral500),
                ),
              ),
              Text(
                '₸${_fmt(deposit)}',
                style: const TextStyle(
                    fontSize: 13, color: AppColors.neutral500),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.neutral200),
          const SizedBox(height: AppSpacing.md),

          // Estimated total
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Estimated total',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                ),
              ),
              Text(
                '₸${_fmt(estimatedTotal)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            '* Deposit collected separately at pickup.',
            style: TextStyle(fontSize: 11, color: AppColors.neutral400),
          ),
        ],
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  const _PriceLine({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.neutral700)),
        ),
        Text(
          '₸${NumberFormat('#,##0', 'ru').format(value)}',
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.neutral900),
        ),
      ],
    );
  }
}

// Local AppRadius constants (mirrors app_spacing.dart AppRadius)
class AppRadius {
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double pill = 9999;
}
