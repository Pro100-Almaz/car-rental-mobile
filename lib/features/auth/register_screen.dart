import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/haptics/haptics.dart';
import '../../core/observability/analytics.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/primary_button.dart';
import '../../l10n/app_localizations.dart';

/// Password must be ≥8 chars, contain at least 1 letter and 1 digit.
final _passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  // Single-page form (spec §3.1: "single-step email + password + first/last name + phone")
  final _emailCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreed = false;
  bool _loading = false;

  String? _emailError;
  String? _firstNameError;
  String? _lastNameError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _phoneError;
  String? _termsError;
  String? _generalError;

  // organization_id is assigned server-side by default (backend update 2026-05-23).
  // Mobile no longer needs to send it.

  @override
  void dispose() {
    _emailCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  bool _validate(AppL10n l10n) {
    final email = _emailCtrl.text.trim();
    final firstName = _firstNameCtrl.text.trim();
    final lastName = _lastNameCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirmPassword = _confirmPasswordCtrl.text;
    final phone = _phoneCtrl.text.trim();

    String? emailErr;
    String? firstNameErr;
    String? lastNameErr;
    String? passwordErr;
    String? confirmErr;
    String? phoneErr;
    String? termsErr;

    if (email.isEmpty || !email.contains('@')) {
      emailErr = l10n.commonEmail;
    }
    if (firstName.isEmpty) firstNameErr = l10n.authFirstNameRequired;
    if (lastName.isEmpty) lastNameErr = l10n.authLastNameRequired;
    if (!_passwordRegex.hasMatch(password)) {
      passwordErr = l10n.authPasswordRule;
    }
    if (password != confirmPassword) {
      confirmErr = l10n.authPasswordsDoNotMatch;
    }
    if (phone.isEmpty) phoneErr = l10n.authPhoneRequired;
    if (!_agreed) termsErr = 'You must agree to the terms';

    setState(() {
      _emailError = emailErr;
      _firstNameError = firstNameErr;
      _lastNameError = lastNameErr;
      _passwordError = passwordErr;
      _confirmPasswordError = confirmErr;
      _phoneError = phoneErr;
      _termsError = termsErr;
      _generalError = null;
    });

    return emailErr == null &&
        firstNameErr == null &&
        lastNameErr == null &&
        passwordErr == null &&
        confirmErr == null &&
        phoneErr == null &&
        termsErr == null;
  }

  Future<void> _onSubmit() async {
    final l10n = AppL10n.of(context);
    if (!_validate(l10n)) return;

    // M6.C: medium haptic on signup submit
    await AppHaptics.medium();
    Analytics.instance.track(kEvtSignupStarted);

    setState(() => _loading = true);

    final result = await ref.read(currentUserProvider.notifier).signup(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          firstName: _firstNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
        );

    if (!mounted) return;
    setState(() => _loading = false);

    switch (result) {
      case 'ok':
        Analytics.instance.track(kEvtSignupCompleted);
        context.push('/verify-email', extra: {'email': _emailCtrl.text.trim()});
      case 'conflict':
        setState(() => _generalError = l10n.authEmailTaken);
      default:
        setState(() => _generalError =
            result == 'error' ? l10n.errorUnknown : result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onBack: () => context.pop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.xl),
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

                    // Email
                    _FormField(
                      label: l10n.commonEmail,
                      controller: _emailCtrl,
                      hint: l10n.commonEmailHint,
                      keyboardType: TextInputType.emailAddress,
                      error: _emailError,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // First name
                    _FormField(
                      label: l10n.registerFirstName,
                      controller: _firstNameCtrl,
                      hint: l10n.registerFirstNameHint,
                      error: _firstNameError,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Last name
                    _FormField(
                      label: l10n.registerLastName,
                      controller: _lastNameCtrl,
                      hint: l10n.registerLastNameHint,
                      error: _lastNameError,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Phone
                    _FormField(
                      label: l10n.commonPhone,
                      controller: _phoneCtrl,
                      hint: l10n.commonPhoneHint,
                      keyboardType: TextInputType.phone,
                      error: _phoneError,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Password
                    _FormField(
                      label: l10n.commonPassword,
                      controller: _passwordCtrl,
                      hint: '••••••••',
                      obscure: _obscurePassword,
                      error: _passwordError,
                      suffix: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                          child: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.neutral500,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Confirm password
                    _FormField(
                      label: 'Confirm password',
                      controller: _confirmPasswordCtrl,
                      hint: '••••••••',
                      obscure: _obscureConfirm,
                      error: _confirmPasswordError,
                      suffix: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => setState(
                              () => _obscureConfirm = !_obscureConfirm),
                          child: Icon(
                            _obscureConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.neutral500,
                            size: 20,
                          ),
                        ),
                      ),
                    ),

                    if (_generalError != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          _generalError!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xl),

                    // Terms checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _agreed,
                            onChanged: (v) =>
                                setState(() => _agreed = v ?? false),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            activeColor: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () =>
                                  setState(() => _agreed = !_agreed),
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
                        ),
                      ],
                    ),
                    if (_termsError != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _termsError!,
                        style: const TextStyle(
                            color: AppColors.error, fontSize: 12),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xxl),

                    // Already have account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.splashAlreadyHaveAccount,
                          style: const TextStyle(
                            color: AppColors.neutral500,
                            fontSize: 14,
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              context.pop();
                              context.push('/login');
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: Text(
                              l10n.commonLogin,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
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
              child: PrimaryButton(
                label: l10n.registerSubmit,
                icon: Icons.check_rounded,
                isLoading: _loading,
                onPressed: _loading ? null : _onSubmit,
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
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded,
                color: AppColors.neutral900),
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

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
    this.error,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final String? error;

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
            suffixIcon: suffix != null
                ? Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: suffix,
                  )
                : null,
            suffixIconConstraints:
                const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 4),
          Text(
            error!,
            style: const TextStyle(color: AppColors.error, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
