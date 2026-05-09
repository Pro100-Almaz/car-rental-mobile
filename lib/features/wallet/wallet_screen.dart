import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/wallet_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../l10n/app_localizations.dart';

String _formatPrice(int amount) {
  final s = amount.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
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

  void _showTopUpSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      builder: (_) => _TopUpSheet(
        onConfirm: (amount) {
          ref.read(walletProvider.notifier).topUp(amount);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('₸ ${_formatPrice(amount)} added to wallet'),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }

  void _showAddMethodDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Payment Method'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AddMethodOption(
              icon: Icons.account_balance_wallet_rounded,
              title: 'Kaspi Pay',
              onTap: () {
                Navigator.of(ctx).pop();
                final id = 'pm${DateTime.now().millisecondsSinceEpoch}';
                ref.read(walletProvider.notifier).addPaymentMethod(
                  PaymentMethod(
                    id: id,
                    type: 'kaspi',
                    title: 'Kaspi Pay',
                    subtitle: '•••• ${(1000 + DateTime.now().millisecondsSinceEpoch % 9000)}',
                    icon: Icons.account_balance_wallet_rounded,
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            _AddMethodOption(
              icon: Icons.credit_card_rounded,
              title: 'Bank Card',
              onTap: () {
                Navigator.of(ctx).pop();
                final id = 'pm${DateTime.now().millisecondsSinceEpoch}';
                ref.read(walletProvider.notifier).addPaymentMethod(
                  PaymentMethod(
                    id: id,
                    type: 'card',
                    title: 'Bank Card',
                    subtitle: 'Visa •••• ${(1000 + DateTime.now().millisecondsSinceEpoch % 9000)}',
                    icon: Icons.credit_card_rounded,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final wallet = ref.watch(walletProvider);

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
                  Text(
                    '₸ ${_formatPrice(wallet.balance)}',
                    style: const TextStyle(
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
                          onTap: _showTopUpSheet,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _WalletAction(
                          icon: Icons.history_rounded,
                          label: l10n.walletHistory,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Coming soon')),
                            );
                          },
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
          ...wallet.paymentMethods.map(
            (method) => _PaymentMethodTile(
              icon: method.icon,
              title: method.title,
              subtitle: method.subtitle,
              isDefault: method.isDefault,
              onTap: () =>
                  ref.read(walletProvider.notifier).setDefaultPaymentMethod(method.id),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: OutlinedButton.icon(
              onPressed: _showAddMethodDialog,
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
          ...wallet.transactions.map(
            (tx) => _TransactionTile(
              title: tx.title,
              subtitle: tx.subtitle,
              amount:
                  '${tx.isDebit ? '-' : '+'}₸ ${_formatPrice(tx.amount)}',
              isDebit: tx.isDebit,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top-Up Bottom Sheet
// ---------------------------------------------------------------------------

class _TopUpSheet extends StatefulWidget {
  const _TopUpSheet({required this.onConfirm});
  final ValueChanged<int> onConfirm;

  @override
  State<_TopUpSheet> createState() => _TopUpSheetState();
}

class _TopUpSheetState extends State<_TopUpSheet> {
  static const _presets = [5000, 10000, 20000, 50000];
  int? _selected;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  int? get _effectiveAmount {
    if (_controller.text.isNotEmpty) {
      return int.tryParse(_controller.text.replaceAll(',', ''));
    }
    return _selected;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.lg + bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Top Up Wallet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 3.2,
            children: _presets.map((preset) {
              final isSelected = _selected == preset && _controller.text.isEmpty;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selected = preset;
                    _controller.clear();
                  });
                  _focusNode.unfocus();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.neutral100,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '₸ ${_formatPrice(preset)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.white : AppColors.neutral900,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: 'Custom amount',
              prefixText: '₸  ',
              filled: true,
              fillColor: AppColors.neutral100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
            onChanged: (_) => setState(() => _selected = null),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: _effectiveAmount != null && _effectiveAmount! > 0
                ? () => widget.onConfirm(_effectiveAmount!)
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: const Text(
              'Confirm Top Up',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add Method Option
// ---------------------------------------------------------------------------

class _AddMethodOption extends StatelessWidget {
  const _AddMethodOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: BorderRadius.circular(AppRadius.md),
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
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable sub-widgets
// ---------------------------------------------------------------------------

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
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDefault;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      onTap: onTap,
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
      subtitle:
          Text(subtitle, style: const TextStyle(color: AppColors.neutral500)),
      trailing: isDefault
          ? Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          color:
              (isDebit ? AppColors.error : AppColors.success).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(
          isDebit ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
          color: isDebit ? AppColors.error : AppColors.success,
          size: 20,
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle:
          Text(subtitle, style: const TextStyle(color: AppColors.neutral500)),
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
