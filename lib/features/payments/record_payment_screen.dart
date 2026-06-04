import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import '../../core/providers/fine_provider.dart';
import '../../core/providers/payments_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/primary_button.dart';
import '../../l10n/app_localizations.dart';

class RecordPaymentScreen extends ConsumerStatefulWidget {
  const RecordPaymentScreen({super.key});

  @override
  ConsumerState<RecordPaymentScreen> createState() =>
      _RecordPaymentScreenState();
}

class _RecordPaymentScreenState
    extends ConsumerState<RecordPaymentScreen> {
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;

  PaymentMethodType _method = PaymentMethodType.kaspi;
  bool _loading = false;
  String? _error;
  bool _success = false;

  String? _rentalId;
  String? _fineId;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController();
    _noteCtrl = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Read query params from route — safe to call in didChangeDependencies.
    final state = GoRouterState.of(context);
    final params = state.uri.queryParameters;
    _rentalId = params['rentalId'];
    _fineId = params['fineId'];
    final amountStr = params['amount'] ?? '';
    if (_amountCtrl.text.isEmpty && amountStr.isNotEmpty) {
      _amountCtrl.text = amountStr;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amountInt = int.tryParse(_amountCtrl.text.trim());
    if (amountInt == null || amountInt <= 0) {
      setState(() => _error = 'Please enter a valid amount');
      return;
    }
    if (_rentalId == null && _fineId == null) {
      setState(() => _error = 'No rental or fine ID provided');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final api = ref.read(mobilePaymentsApiProvider);
      await api.record(
        rentalId: _rentalId,
        fineId: _fineId,
        amount: amountInt,
        method: _method,
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      );
      // Invalidate providers so lists refresh.
      ref.invalidate(paymentsProvider);
      ref.invalidate(finesProvider);
      setState(() => _success = true);
    } on ApiException catch (e) {
      setState(() => _error = e.serverMessage ?? e.code);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    if (_success) return _SuccessScreen();

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.neutral900),
        title: Text(
          l10n.recordPaymentTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Explanation banner
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.25)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppColors.info, size: 18),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        l10n.recordPaymentExplanation,
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
              const SizedBox(height: AppSpacing.xl),
              // Amount
              _Label(l10n.recordPaymentAmount),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.neutral200),
                  boxShadow: AppColors.elevation1,
                ),
                child: TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: '0',
                    prefixText: '₸ ',
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.all(AppSpacing.md),
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Payment method chips
              _Label(l10n.recordPaymentMethod),
              _MethodChips(
                selected: _method,
                onSelected: (m) => setState(() => _method = m),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Note
              _Label(l10n.recordPaymentNote),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.neutral200),
                  boxShadow: AppColors.elevation1,
                ),
                child: TextField(
                  controller: _noteCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Optional note…',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(AppSpacing.md),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.error),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: l10n.recordPaymentSubmit,
                onPressed: _loading ? null : _submit,
                isLoading: _loading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral700,
        ),
      ),
    );
  }
}

class _MethodChips extends StatelessWidget {
  const _MethodChips({required this.selected, required this.onSelected});
  final PaymentMethodType selected;
  final ValueChanged<PaymentMethodType> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final methods = [
      (PaymentMethodType.kaspi, l10n.paymentMethodKaspi),
      (PaymentMethodType.cash, l10n.paymentMethodCash),
      (PaymentMethodType.card, l10n.paymentMethodCard),
      (PaymentMethodType.bankTransfer, l10n.paymentMethodBankTransfer),
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      children: methods.map((entry) {
        final (method, label) = entry;
        final isSelected = method == selected;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onSelected(method),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.neutral300,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.white
                      : AppColors.neutral700,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Success screen shown after successful submission
// ---------------------------------------------------------------------------

class _SuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: AppColors.success, size: 44),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                l10n.recordPaymentSuccessTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.recordPaymentSuccessBody,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.neutral700,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              PrimaryButton(
                label: l10n.recordPaymentSuccessDone,
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/profile');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
