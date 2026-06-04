import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/formatters/money.dart';
import '../../core/providers/payments_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/error_retry_widget.dart';
import '../../core/widgets/shimmer_box.dart';
import '../../core/widgets/status_chip.dart';
import '../../l10n/app_localizations.dart';

class PaymentsHistoryScreen extends ConsumerWidget {
  const PaymentsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final paymentsAsync = ref.watch(paymentsProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.neutral900),
        title: Text(
          l10n.paymentsHistoryTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
        centerTitle: false,
      ),
      body: paymentsAsync.when(
        loading: () => const _PaymentsLoadingSkeleton(),
        error: (e, _) => ErrorRetryWidget(
          message: 'Could not load payments. Please try again.',
          onRetry: () => ref.invalidate(paymentsProvider),
        ),
        data: (payments) => RefreshIndicator(
          onRefresh: () =>
              ref.read(paymentsProvider.notifier).refresh(),
          child: payments.isEmpty
              ? ListView(children: [
                  SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.25),
                  EmptyStateView(
                    icon: Icons.receipt_long_outlined,
                    title: l10n.paymentsEmpty,
                  ),
                ])
              : _PaymentsList(payments: payments),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading skeleton (M6.A)
// ---------------------------------------------------------------------------

class _PaymentsLoadingSkeleton extends StatelessWidget {
  const _PaymentsLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        ShimmerBox(
            height: 14,
            width: 80,
            borderRadius: BorderRadius.circular(4)),
        const SizedBox(height: AppSpacing.sm),
        ...List.generate(
          4,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              children: [
                ShimmerBox(
                    width: 40,
                    height: 40,
                    borderRadius: BorderRadius.circular(AppRadius.md)),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(
                          height: 14,
                          width: 100,
                          borderRadius: BorderRadius.circular(4)),
                      const SizedBox(height: 6),
                      ShimmerBox(
                          height: 12,
                          width: 140,
                          borderRadius: BorderRadius.circular(4)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ShimmerBox(
                        height: 14,
                        width: 70,
                        borderRadius: BorderRadius.circular(4)),
                    const SizedBox(height: 6),
                    ShimmerBox(
                        height: 22,
                        width: 60,
                        borderRadius: BorderRadius.circular(11)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Date-grouping helpers
// ---------------------------------------------------------------------------

bool _isToday(DateTime d) {
  final now = DateTime.now();
  return d.year == now.year && d.month == now.month && d.day == now.day;
}

bool _isThisWeek(DateTime d) {
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  return d.isAfter(startOfWeek.subtract(const Duration(days: 1)));
}

bool _isThisMonth(DateTime d) {
  final now = DateTime.now();
  return d.year == now.year && d.month == now.month;
}

class _PaymentsList extends StatelessWidget {
  const _PaymentsList({required this.payments});
  final List<PaymentRecord> payments;

  @override
  Widget build(BuildContext context) {
    final today =
        payments.where((p) => _isToday(p.createdAt)).toList();
    final thisWeek = payments
        .where((p) => !_isToday(p.createdAt) && _isThisWeek(p.createdAt))
        .toList();
    final thisMonth = payments
        .where((p) =>
            !_isToday(p.createdAt) &&
            !_isThisWeek(p.createdAt) &&
            _isThisMonth(p.createdAt))
        .toList();
    final earlier = payments
        .where((p) => !_isThisMonth(p.createdAt))
        .toList();

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        MediaQuery.paddingOf(context).bottom + AppSpacing.xl,
      ),
      children: [
        if (today.isNotEmpty) ...[
          _GroupHeader('Today'),
          ...today.map((p) => _PaymentRow(payment: p)),
        ],
        if (thisWeek.isNotEmpty) ...[
          _GroupHeader('This Week'),
          ...thisWeek.map((p) => _PaymentRow(payment: p)),
        ],
        if (thisMonth.isNotEmpty) ...[
          _GroupHeader('This Month'),
          ...thisMonth.map((p) => _PaymentRow(payment: p)),
        ],
        if (earlier.isNotEmpty) ...[
          _GroupHeader('Earlier'),
          ...earlier.map((p) => _PaymentRow(payment: p)),
        ],
      ],
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          bottom: AppSpacing.sm, top: AppSpacing.md),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.neutral500,
        ),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.payment});
  final PaymentRecord payment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final dateStr =
        DateFormat('dd.MM.yyyy HH:mm').format(payment.createdAt);

    final methodLabel = switch (payment.method) {
      PaymentMethodType.kaspi => l10n.paymentMethodKaspi,
      PaymentMethodType.cash => l10n.paymentMethodCash,
      PaymentMethodType.card => l10n.paymentMethodCard,
      PaymentMethodType.bankTransfer => l10n.paymentMethodBankTransfer,
    };

    final (statusLabel, statusColor) = switch (payment.status) {
      PaymentRecordStatus.pending => (
          l10n.paymentStatusPending,
          AppColors.warning
        ),
      PaymentRecordStatus.completed => (
          l10n.paymentStatusCompleted,
          AppColors.success
        ),
      PaymentRecordStatus.rejected => (
          l10n.paymentStatusRejected,
          AppColors.error
        ),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () => _showDetails(context, l10n, methodLabel, statusLabel,
            statusColor, dateStr),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppColors.elevation1,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.payment_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      methodLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral900,
                      ),
                    ),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatKzt(payment.amount),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                    ),
                  ),
                  StatusChip(label: statusLabel, color: statusColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetails(
    BuildContext context,
    AppL10n l10n,
    String method,
    String status,
    Color statusColor,
    String date,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.xl,
          MediaQuery.paddingOf(context).bottom + AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatKzt(payment.amount),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _DetailRow('Method', method),
            _DetailRow('Status', status,
                valueColor: statusColor),
            _DetailRow('Date', date),
            if (payment.note != null && payment.note!.isNotEmpty)
              _DetailRow('Note', payment.note!),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value, {this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.neutral500)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.neutral900,
            ),
          ),
        ],
      ),
    );
  }
}
