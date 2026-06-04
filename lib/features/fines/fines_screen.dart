import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/formatters/money.dart';
import '../../core/providers/fine_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/error_retry_widget.dart';
import '../../core/widgets/shimmer_box.dart';
import '../../core/widgets/status_chip.dart';
import '../../l10n/app_localizations.dart';

class FinesScreen extends ConsumerWidget {
  const FinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final finesAsync = ref.watch(finesProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.neutral900),
        title: Text(
          l10n.finesTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
        centerTitle: false,
      ),
      body: finesAsync.when(
        loading: () => const _FinesLoadingSkeleton(),
        error: (e, _) => ErrorRetryWidget(
          message: 'Could not load fines. Please try again.',
          onRetry: () => ref.invalidate(finesProvider),
        ),
        data: (fines) => RefreshIndicator(
          onRefresh: () =>
              ref.read(finesProvider.notifier).refresh(),
          child: _FinesList(fines: fines),
        ),
      ),
    );
  }
}

class _FinesList extends StatelessWidget {
  const _FinesList({required this.fines});
  final List<Fine> fines;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    final unpaid = fines
        .where((f) =>
            f.status == FineStatus.chargedToClient ||
            f.status == FineStatus.paidPending)
        .toList();
    final paid =
        fines.where((f) => f.status == FineStatus.paidConfirmed).toList();
    final disputed =
        fines.where((f) => f.status == FineStatus.disputed).toList();

    if (fines.isEmpty) {
      return ListView(
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.25),
          EmptyStateView(
            icon: Icons.check_circle_outline_rounded,
            title: l10n.finesEmpty,
          ),
        ],
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        MediaQuery.paddingOf(context).bottom + AppSpacing.xl,
      ),
      children: [
        if (unpaid.isNotEmpty) ...[
          _SectionHeader(l10n.finesUnpaid),
          ...unpaid.map((f) => _FineCard(fine: f)),
        ],
        if (paid.isNotEmpty) ...[
          _SectionHeader(l10n.finesPaid),
          ...paid.map((f) => _FineCard(fine: f)),
        ],
        if (disputed.isNotEmpty) ...[
          _SectionHeader(l10n.finesDisputed),
          ...disputed.map((f) => _FineCard(fine: f)),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Loading skeleton (M6.A)
// ---------------------------------------------------------------------------

class _FinesLoadingSkeleton extends StatelessWidget {
  const _FinesLoadingSkeleton();

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ShimmerBox(
                      height: 22,
                      width: 80,
                      borderRadius: BorderRadius.circular(11)),
                  const Spacer(),
                  ShimmerBox(
                      height: 12,
                      width: 70,
                      borderRadius: BorderRadius.circular(4)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ShimmerBox(
                  height: 15,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(4)),
              const SizedBox(height: AppSpacing.sm),
              ShimmerBox(
                  height: 15,
                  width: 180,
                  borderRadius: BorderRadius.circular(4)),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  ShimmerBox(
                      height: 20,
                      width: 100,
                      borderRadius: BorderRadius.circular(4)),
                  const Spacer(),
                  ShimmerBox(
                      height: 32,
                      width: 100,
                      borderRadius: BorderRadius.circular(AppRadius.md)),
                ],
              ),
            ],
          ),
        ),
      ),
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

class _FineCard extends StatelessWidget {
  const _FineCard({required this.fine});
  final Fine fine;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final dateStr = DateFormat('dd.MM.yyyy').format(fine.createdAt);

    final (chipLabel, chipColor) = switch (fine.status) {
      FineStatus.chargedToClient => (
          l10n.fineStatusChargedToClient,
          AppColors.error
        ),
      FineStatus.paidPending => (l10n.fineStatusPaidPending, AppColors.warning),
      FineStatus.paidConfirmed => (
          l10n.fineStatusPaidConfirmed,
          AppColors.success
        ),
      FineStatus.disputed => (l10n.fineStatusDisputed, AppColors.neutral500),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppColors.elevation1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              StatusChip(label: chipLabel, color: chipColor, dot: true),
              const Spacer(),
              Text(
                dateStr,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.neutral500),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            fine.description,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.neutral200, height: 1),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(
                formatKzt(fine.amount),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                ),
              ),
              const Spacer(),
              if (fine.isUnpaid)
                FilledButton(
                  onPressed: () {
                    final params = <String, String>{
                      'amount': '${fine.amount}',
                      'fineId': fine.id,
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
                        horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
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
        ],
      ),
    );
  }
}
