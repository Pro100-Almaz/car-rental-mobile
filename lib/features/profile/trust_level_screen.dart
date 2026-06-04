import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/user.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/app_localizations.dart';

class TrustLevelScreen extends ConsumerWidget {
  const TrustLevelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final userLevel = ref.watch(currentUserProvider)?.trustLevel ??
        TrustLevel.newUser;

    final tiers = [
      _TierData(
        level: TrustLevel.newUser,
        icon: Icons.person_outline,
        name: l10n.trustNew,
        description: l10n.trustNewDesc,
        color: AppColors.neutral500,
      ),
      _TierData(
        level: TrustLevel.verified,
        icon: Icons.verified_outlined,
        name: l10n.trustVerified,
        description: l10n.trustVerifiedDesc,
        color: AppColors.info,
      ),
      _TierData(
        level: TrustLevel.trusted,
        icon: Icons.star_outline_rounded,
        name: l10n.trustTrusted,
        description: l10n.trustTrustedDesc,
        color: AppColors.warning,
      ),
      _TierData(
        level: TrustLevel.vip,
        icon: Icons.workspace_premium_outlined,
        name: l10n.trustVip,
        description: l10n.trustVipDesc,
        color: AppColors.secondary,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.neutral900),
        title: Text(
          l10n.trustLevelTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          MediaQuery.paddingOf(context).bottom + AppSpacing.xl,
        ),
        children: tiers
            .map((tier) =>
                _TierCard(tier: tier, isCurrent: tier.level == userLevel))
            .toList(),
      ),
    );
  }
}

class _TierData {
  const _TierData({
    required this.level,
    required this.icon,
    required this.name,
    required this.description,
    required this.color,
  });

  final TrustLevel level;
  final IconData icon;
  final String name;
  final String description;
  final Color color;
}

class _TierCard extends StatelessWidget {
  const _TierCard({required this.tier, required this.isCurrent});

  final _TierData tier;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: isCurrent
            ? Border.all(color: tier.color, width: 2)
            : Border.all(color: AppColors.neutral200),
        boxShadow: AppColors.elevation1,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tier.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(tier.icon, color: tier.color, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      tier.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isCurrent ? tier.color : AppColors.neutral900,
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: tier.color,
                          borderRadius:
                              BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          l10n.trustYourLevel,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  tier.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.neutral700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
