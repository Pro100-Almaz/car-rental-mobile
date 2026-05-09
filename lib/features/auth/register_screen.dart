import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/primary_button.dart';
import '../../l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _step = 0;

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _agreed = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _onPrimary() {
    if (_step == 0) {
      setState(() => _step = 1);
      return;
    }
    context.go('/home');
  }

  bool get _canContinue {
    if (_step == 0) return true;
    return _agreed;
  }

  void _onBack() {
    if (_step > 0) {
      setState(() => _step -= 1);
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onBack: _onBack),
            _ProgressDots(step: _step),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _step == 0
                    ? _PhoneStep(
                        key: const ValueKey('phone'),
                        phoneCtrl: _phoneCtrl,
                      )
                    : _DetailsStep(
                        key: const ValueKey('details'),
                        nameCtrl: _nameCtrl,
                        passwordCtrl: _passwordCtrl,
                        obscure: _obscure,
                        agreed: _agreed,
                        onToggleObscure: () => setState(() => _obscure = !_obscure),
                        onToggleAgreed: (v) => setState(() => _agreed = v ?? false),
                        onLogin: () {
                          context.pop();
                          context.push('/login');
                        },
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: _canContinue ? 1 : 0.5,
                child: PrimaryButton(
                  label: _step == 0
                      ? l10n.commonContinue
                      : l10n.registerSubmit,
                  icon: _step == 0
                      ? Icons.arrow_forward_rounded
                      : Icons.check_rounded,
                  onPressed: _canContinue ? _onPrimary : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm, AppSpacing.sm, AppSpacing.sm, AppSpacing.sm,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.neutral900),
          ),
          const Spacer(),
          Text(
            AppL10n.of(context).appName,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: List.generate(2, (i) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 4,
              decoration: BoxDecoration(
                color: i <= step ? AppColors.primary : AppColors.neutral200,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _PhoneStep extends StatelessWidget {
  const _PhoneStep({super.key, required this.phoneCtrl});

  final TextEditingController phoneCtrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.registerStepPhoneTitle,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.registerStepPhoneSubtitle,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.neutral500,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _Field(
            label: l10n.commonPhone,
            controller: phoneCtrl,
            hint: l10n.commonPhoneHint,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }
}

class _DetailsStep extends StatelessWidget {
  const _DetailsStep({
    super.key,
    required this.nameCtrl,
    required this.passwordCtrl,
    required this.obscure,
    required this.agreed,
    required this.onToggleObscure,
    required this.onToggleAgreed,
    required this.onLogin,
  });

  final TextEditingController nameCtrl;
  final TextEditingController passwordCtrl;
  final bool obscure;
  final bool agreed;
  final VoidCallback onToggleObscure;
  final ValueChanged<bool?> onToggleAgreed;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.registerStepDetailsTitle,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.registerStepDetailsSubtitle,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.neutral500,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _Field(
            label: l10n.commonFullName,
            controller: nameCtrl,
            hint: l10n.commonNameHint,
          ),
          const SizedBox(height: AppSpacing.lg),
          _Field(
            label: l10n.commonPassword,
            controller: passwordCtrl,
            hint: '••••••••',
            obscure: obscure,
            suffix: IconButton(
              onPressed: onToggleObscure,
              icon: Icon(
                obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                color: AppColors.neutral500,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: agreed,
                  onChanged: onToggleAgreed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  activeColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: GestureDetector(
                  onTap: () => onToggleAgreed(!agreed),
                  child: Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.neutral700,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(text: l10n.registerAgreePrefix),
                        TextSpan(
                          text: l10n.registerAgreeTerms,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: l10n.registerAgreeAnd),
                        TextSpan(
                          text: l10n.registerAgreePrivacy,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            children: [
              const Expanded(child: Divider(color: AppColors.neutral200)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text(
                  l10n.commonOrContinueWith,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutral500,
                  ),
                ),
              ),
              const Expanded(child: Divider(color: AppColors.neutral200)),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          SecondaryButton(
            label: l10n.commonContinueWithGoogle,
            icon: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    Color(0xFFEA4335),
                    Color(0xFFFBBC05),
                    Color(0xFF34A853),
                    Color(0xFF4285F4),
                    Color(0xFFEA4335),
                  ],
                ),
              ),
              child: const Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            onPressed: () {},
          ),
          const SizedBox(height: AppSpacing.xl),
          GestureDetector(
            onTap: onLogin,
            behavior: HitTestBehavior.opaque,
            child: Text.rich(
              TextSpan(
                text: l10n.splashAlreadyHaveAccount,
                style: const TextStyle(
                  color: AppColors.neutral500,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: l10n.commonLogin,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral700,
            ),
          ),
        ),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
