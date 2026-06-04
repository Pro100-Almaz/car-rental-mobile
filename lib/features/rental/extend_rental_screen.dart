import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/api/api_client.dart';
import '../../core/providers/active_rental_provider.dart';
import '../../core/providers/bookings_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/primary_button.dart';
import '../../l10n/app_localizations.dart';

class ExtendRentalScreen extends ConsumerStatefulWidget {
  const ExtendRentalScreen({super.key});

  @override
  ConsumerState<ExtendRentalScreen> createState() =>
      _ExtendRentalScreenState();
}

class _ExtendRentalScreenState extends ConsumerState<ExtendRentalScreen> {
  DateTime? _newEndDate;
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final activeAsync = ref.watch(activeRentalProvider);

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
          l10n.extendRentalTitle,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
      ),
      body: activeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Could not load rental',
              style: const TextStyle(color: AppColors.neutral500)),
        ),
        data: (booking) {
          if (booking == null) {
            return Center(
              child: Text(l10n.activeRentalEmpty,
                  style: const TextStyle(color: AppColors.neutral500)),
            );
          }

          final fmt = DateFormat('dd.MM.yyyy');
          final currentEnd = booking.endDate;
          // Max: 30 days from scheduledStart per spec §3.4 MVP cap
          final maxEnd =
              booking.startDate.add(const Duration(days: 30));

          // Additional cost estimation
          int? additionalCost;
          if (_newEndDate != null) {
            final newDays =
                _newEndDate!.difference(booking.startDate).inDays.clamp(1, 30);
            final currentDays = booking.days;
            final extraDays = (newDays - currentDays).clamp(0, 30);
            additionalCost = extraDays * booking.pricePerDay;
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              // Current end date
              _InfoRow(
                label: l10n.extendCurrentEnd,
                value: fmt.format(currentEnd),
              ),
              const SizedBox(height: AppSpacing.md),

              // New end date picker
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.neutral200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.extendNewEnd,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Material(
                      color: AppColors.neutral50,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: InkWell(
                        onTap: () => _pickDate(
                            context, currentEnd, maxEnd),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(AppRadius.md),
                            border:
                                Border.all(color: AppColors.neutral200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  size: 18, color: AppColors.neutral500),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  _newEndDate != null
                                      ? fmt.format(_newEndDate!)
                                      : 'Select new end date',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: _newEndDate != null
                                        ? AppColors.neutral900
                                        : AppColors.neutral500,
                                  ),
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down_rounded,
                                  color: AppColors.neutral500),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Estimated additional cost
              if (additionalCost != null)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.extendAdditionalCost,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral900,
                        ),
                      ),
                      Text(
                        '~₸${_fmt(additionalCost)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.md),

              // Disclaimer
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 16, color: AppColors.warning),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        l10n.extendDisclaimer,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.neutral700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(_error!,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.error)),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              PrimaryButton(
                label: l10n.extendSubmit,
                isLoading: _isLoading,
                onPressed: (_newEndDate != null && !_isLoading)
                    ? () => _submit(context, booking.id)
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    DateTime currentEnd,
    DateTime maxEnd,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentEnd.add(const Duration(days: 1)),
      firstDate: currentEnd.add(const Duration(days: 1)),
      lastDate: maxEnd,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.primary,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _newEndDate = picked;
        _error = null;
      });
    }
  }

  Future<void> _submit(BuildContext context, String rentalId) async {
    if (_newEndDate == null) return;
    // Capture context-dependent objects before the async gap.
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final successMsg = AppL10n.of(context).extendSuccess;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ref.read(mobileRentalsApiProvider);
      await api.extendRequest(rentalId, newEndDate: _newEndDate!);

      // Invalidate providers so the screen refreshes
      ref.invalidate(activeRentalProvider);
      ref.invalidate(bookingsListProvider);

      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(successMsg)));
        router.pop();
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.neutral500)),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral900)),
        ],
      ),
    );
  }
}
