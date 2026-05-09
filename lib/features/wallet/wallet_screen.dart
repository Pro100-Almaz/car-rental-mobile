import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../l10n/app_localizations.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  AppNavDestination _nav = AppNavDestination.wallet;

  void _onNav(AppNavDestination d) {
    if (d == _nav) return;
    setState(() => _nav = d);
    switch (d) {
      case AppNavDestination.home:
        context.go('/home');
      case AppNavDestination.bookings:
        context.go('/bookings');
      case AppNavDestination.profile:
        context.go('/profile');
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      appBar: const GlassAppBar(),
      bottomNavigationBar: AppBottomNav(current: _nav, onSelect: _onNav),
      body: ListView(
        padding: EdgeInsets.only(
          top: AppSpacing.lg,
          bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.xl,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              l10n.walletTitle,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.walletBalance,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    '₸ 15,000',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Expanded(
                        child: _WalletAction(
                          icon: Icons.add_rounded,
                          label: l10n.walletTopUp,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _WalletAction(
                          icon: Icons.history_rounded,
                          label: l10n.walletHistory,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              l10n.walletPaymentMethods,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _PaymentMethodTile(
            icon: Icons.account_balance_wallet_rounded,
            title: 'Kaspi Pay',
            subtitle: '•••• 4821',
            isDefault: true,
          ),
          _PaymentMethodTile(
            icon: Icons.credit_card_rounded,
            title: l10n.walletBankCard,
            subtitle: 'Visa •••• 3156',
            isDefault: false,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: Text(l10n.walletAddMethod),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.neutral300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              l10n.walletRecentTransactions,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _TransactionTile(
            title: 'Toyota Camry',
            subtitle: '12 – 15 Oct',
            amount: '-₸ 24,000',
            isDebit: true,
          ),
          _TransactionTile(
            title: l10n.walletTopUp,
            subtitle: '10 Oct',
            amount: '+₸ 30,000',
            isDebit: false,
          ),
          _TransactionTile(
            title: l10n.walletDepositRefund,
            subtitle: '8 Oct',
            amount: '+₸ 10,000',
            isDebit: false,
          ),
        ],
      ),
    );
  }
}

class _WalletAction extends StatelessWidget {
  const _WalletAction({
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
      color: AppColors.white.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.white, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDefault,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDefault;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.neutral500)),
      trailing: isDefault
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Text(
                'Default',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            )
          : null,
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isDebit,
  });

  final String title;
  final String subtitle;
  final String amount;
  final bool isDebit;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (isDebit ? AppColors.error : AppColors.success).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(
          isDebit ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
          color: isDebit ? AppColors.error : AppColors.success,
          size: 20,
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.neutral500)),
      trailing: Text(
        amount,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: isDebit ? AppColors.neutral900 : AppColors.success,
        ),
      ),
    );
  }
}
