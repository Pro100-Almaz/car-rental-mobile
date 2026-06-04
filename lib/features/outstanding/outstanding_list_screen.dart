import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatters/money.dart';
import '../../core/providers/outstanding_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/error_retry_widget.dart';
import '../../core/widgets/shimmer_box.dart';
import '../../l10n/app_localizations.dart';

class OutstandingListScreen extends ConsumerWidget {
  const OutstandingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final outstandingAsync = ref.watch(outstandingProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.neutral900),
        title: Text(
          l10n.outstandingTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
        centerTitle: false,
      ),
      body: outstandingAsync.when(
        loading: () => const _OutstandingLoadingSkeleton(),
        error: (e, _) => ErrorRetryWidget(
          message: 'Could not load outstanding items. Please try again.',
          onRetry: () => ref.invalidate(outstandingProvider),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () =>
              ref.read(outstandingProvider.notifier).refresh(),
          child: _OutstandingBody(data: data),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading skeleton (M6.A)
// ---------------------------------------------------------------------------

class _OutstandingLoadingSkeleton extends StatelessWidget {
  const _OutstandingLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: List.generate(
        4,
        (_) => Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(
                        height: 14,
                        width: 160,
                        borderRadius: BorderRadius.circular(4)),
                    const SizedBox(height: 6),
                    ShimmerBox(
                        height: 18,
                        width: 100,
                        borderRadius: BorderRadius.circular(4)),
                  ],
                ),
              ),
              ShimmerBox(
                  height: 36,
                  width: 100,
                  borderRadius: BorderRadius.circular(AppRadius.md)),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutstandingBody extends StatelessWidget {
  const _OutstandingBody({required this.data});
  final OutstandingResponse data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    if (data.isEmpty) {
      return ListView(
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.25),
          EmptyStateView(
            icon: Icons.check_circle_outline_rounded,
            title: l10n.outstandingAllClear,
            subtitle: l10n.outstandingEmpty,
          ),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            children: [
              if (data.rentals.isNotEmpty) ...[
                _SectionHeader(l10n.outstandingRentals),
                ...data.rentals.map((item) => _OutstandingCard(item: item)),
              ],
              if (data.fines.isNotEmpty) ...[
                _SectionHeader(l10n.outstandingFines),
                ...data.fines.map((item) => _OutstandingCard(item: item)),
              ],
              if (data.debts.isNotEmpty) ...[
                _SectionHeader(l10n.outstandingDebts),
                ...data.debts.map((item) => _OutstandingCard(item: item)),
              ],
            ],
          ),
        ),
        // Sticky footer total
        _TotalFooter(total: data.total),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);
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

class _OutstandingCard extends StatelessWidget {
  const _OutstandingCard({required this.item});
  final OutstandingItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppColors.elevation1,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatKzt(item.amount),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          FilledButton(
            onPressed: () {
              final params = <String, String>{
                'amount': '${item.amount}',
                if (item.rentalId != null) 'rentalId': item.rentalId!,
                if (item.fineId != null) 'fineId': item.fineId!,
              };
              context.push(
                Uri(
                  path: '/record-payment',
                  queryParameters: params,
                ).toString(),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: Text(l10n.finesMarkAsPaid,
                style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _TotalFooter extends StatelessWidget {
  const _TotalFooter({required this.total});
  final int total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        MediaQuery.paddingOf(context).bottom + AppSpacing.md,
      ),
      child: Row(
        children: [
          Text(
            l10n.outstandingTotal,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral700,
            ),
          ),
          const Spacer(),
          Text(
            formatKzt(total),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
