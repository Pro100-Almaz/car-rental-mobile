import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatters/money.dart';
import '../../core/models/user.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/fine_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/status_chip.dart';
import '../../l10n/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final user = ref.watch(currentUserProvider);
    final unpaidCount = ref.watch(unpaidFinesCountProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          l10n.profileTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(currentUserProvider.notifier).refreshCurrentUser();
          ref.invalidate(finesProvider);
        },
        child: ListView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.xl,
          ),
          children: [
            // 1. Header card
            _HeaderCard(user: user),
            const SizedBox(height: AppSpacing.md),
            // 2. Statistics row
            _StatisticsRow(stats: user?.statistics),
            const SizedBox(height: AppSpacing.md),
            // 3. Trust + finance card
            _TrustFinanceCard(user: user),
            const SizedBox(height: AppSpacing.md),
            // 4. Navigation list
            _NavSection(
              items: [
                _NavItem(
                  icon: Icons.person_outline,
                  label: l10n.profileSectionPersonal,
                  onTap: () => context.push('/profile/edit'),
                ),
                _NavItem(
                  icon: Icons.badge_outlined,
                  label: l10n.profileSectionDocuments,
                  trailing: user?.verificationStatus ==
                          VerificationStatus.verified
                      ? StatusChip(
                          label: l10n.profileVerified,
                          color: AppColors.success,
                        )
                      : null,
                  onTap: () => context.push('/profile/documents'),
                ),
                _NavItem(
                  icon: Icons.receipt_long_outlined,
                  label: l10n.profileSectionFines,
                  trailing: unpaidCount > 0
                      ? _Badge(count: unpaidCount)
                      : null,
                  onTap: () => context.push('/profile/fines'),
                ),
                _NavItem(
                  icon: Icons.payment_outlined,
                  label: l10n.profileSectionPayments,
                  onTap: () => context.push('/profile/payments'),
                ),
                _NavItem(
                  icon: Icons.notifications_outlined,
                  label: l10n.profileSectionNotifications,
                  onTap: () =>
                      context.push('/profile/notifications-settings'),
                ),
                _NavItem(
                  icon: Icons.language_outlined,
                  label: l10n.profileSectionLanguage,
                  onTap: () => context.push('/profile/language'),
                ),
                _NavItem(
                  icon: Icons.help_outline,
                  label: l10n.profileSectionSupport,
                  onTap: () => context.push('/profile/support'),
                ),
                _NavItem(
                  icon: Icons.info_outline,
                  label: l10n.profileSectionAbout,
                  onTap: () => context.push('/profile/about'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            // 5. Sign out
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _SignOutButton(),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header card
// ---------------------------------------------------------------------------

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.user});
  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final name = user?.fullName ?? '';
    final avatarUrl = user?.avatarUrl;
    final isVerified =
        user?.verificationStatus == VerificationStatus.verified;

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryLight,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: avatarUrl != null
                ? Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context2, err, stack) => const Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: 40,
                    ),
                  )
                : const Icon(Icons.person, color: AppColors.primary, size: 40),
          ),
          const SizedBox(height: AppSpacing.md),
          // Name
          Text(
            name.isEmpty ? '—' : name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
          if (user?.email != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              user!.email!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.neutral500,
              ),
            ),
          ],
          if (isVerified) ...[
            const SizedBox(height: AppSpacing.sm),
            StatusChip(
              label: l10n.profileVerified,
              color: AppColors.success,
              dot: true,
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Statistics row
// ---------------------------------------------------------------------------

class _StatisticsRow extends StatelessWidget {
  const _StatisticsRow({required this.stats});
  final ClientStatistics? stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final s = stats ?? ClientStatistics.empty;
    final onTimePct =
        '${(s.onTimeRate * 100).toStringAsFixed(0)}%';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: l10n.profileStatsTrips,
              value: '${s.tripCount}',
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _StatCard(
              label: l10n.profileStatsSpent,
              value: formatKzt(s.totalSpent),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _StatCard(
              label: l10n.profileStatsOnTime,
              value: onTimePct,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppColors.elevation1,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.neutral500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Trust + finance card
// ---------------------------------------------------------------------------

class _TrustFinanceCard extends ConsumerWidget {
  const _TrustFinanceCard({required this.user});
  final AppUser? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final trustLevel = user?.trustLevel ?? TrustLevel.newUser;
    final walletBalance = user?.walletBalance ?? 0;
    final debtBalance = user?.debtBalance ?? 0;

    final trustLabel = switch (trustLevel) {
      TrustLevel.newUser => l10n.trustNew,
      TrustLevel.verified => l10n.trustVerified,
      TrustLevel.trusted => l10n.trustTrusted,
      TrustLevel.vip => l10n.trustVip,
    };

    final trustStars = switch (trustLevel) {
      TrustLevel.newUser => '⭐',
      TrustLevel.verified => '⭐⭐',
      TrustLevel.trusted => '⭐⭐⭐',
      TrustLevel.vip => '⭐⭐⭐⭐',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppColors.elevation1,
        ),
        child: Column(
          children: [
            // Trust level row — tappable
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push('/profile/trust'),
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.warning, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.profileTrustLevel,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.neutral500,
                            ),
                          ),
                          Text(
                            '$trustStars $trustLabel',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral900,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right,
                          color: AppColors.neutral400, size: 20),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(color: AppColors.neutral200, height: AppSpacing.xl),
            // Wallet balance
            Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.profileWalletBalance,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.neutral500,
                      ),
                    ),
                    Text(
                      formatKzt(walletBalance),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (debtBalance > 0) ...[
              const Divider(
                  color: AppColors.neutral200, height: AppSpacing.xl),
              // Outstanding debt — tappable
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.push('/profile/outstanding'),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: AppColors.error, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.profileOutstandingDebt,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.neutral500,
                              ),
                            ),
                            Text(
                              formatKzt(debtBalance),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(Icons.chevron_right,
                            color: AppColors.neutral400, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Nav section + item
// ---------------------------------------------------------------------------

class _NavSection extends StatelessWidget {
  const _NavSection({required this.items});
  final List<_NavItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppColors.elevation1,
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1)
              const Divider(
                height: 1,
                indent: AppSpacing.lg,
                endIndent: AppSpacing.lg,
                color: AppColors.neutral200,
              ),
          ],
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.neutral700, size: 20),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutral900,
                  ),
                ),
              ),
              trailing ??
                  const Icon(Icons.chevron_right,
                      color: AppColors.neutral400, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sign out button
// ---------------------------------------------------------------------------

class _SignOutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    return TextButton(
      onPressed: () => _confirmSignOut(context, ref),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.error,
        minimumSize: const Size(double.infinity, 48),
      ),
      child: Text(l10n.profileSectionSignOut),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.profileSignOutTitle),
        content: Text(l10n.profileSignOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonBack),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.profileSectionSignOut),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && context.mounted) {
        ref.read(currentUserProvider.notifier).logout();
      }
    });
  }
}
