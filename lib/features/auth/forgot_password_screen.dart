import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/primary_button.dart';
import '../../l10n/app_localizations.dart';

/// Password must be ≥8 chars, contain at least 1 letter and 1 digit.
final _passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  int _step = 0; // 0=email, 1=code, 2=new password

  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;

  // Stored between steps.
  String _submittedEmail = '';
  String _submittedCode = '';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Step 1 — request reset code via POST /account/forgot-password/
  // -------------------------------------------------------------------------

  Future<void> _onSubmitEmail() async {
    final l10n = AppL10n.of(context);
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = l10n.authEmailInvalid);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await ref
        .read(currentUserProvider.notifier)
        .forgotPassword(email: email);
    if (!mounted) return;
    setState(() => _loading = false);
    switch (result) {
      case 'ok':
        _submittedEmail = email;
        setState(() {
          _error = null;
          _step = 1;
        });
      case 'not_found':
        setState(() => _error = l10n.authForgotEmailNotFound);
      case 'rate_limited':
        setState(() => _error = l10n.authVerifyRateLimited);
      case 'email_send_failed':
        // Backend created/queued the reset but SMTP failed. Still allow the
        // user to advance — they can grab the code from server logs in dev.
        _submittedEmail = email;
        setState(() {
          _error = null;
          _step = 1;
        });
      default:
        setState(() => _error = l10n.errorGenericFallback);
    }
  }

  // -------------------------------------------------------------------------
  // Step 2 — validate code format then advance
  // -------------------------------------------------------------------------

  void _onSubmitCode() {
    final code = _codeCtrl.text.trim();
    if (code.length != 6 || int.tryParse(code) == null) {
      setState(
          () => _error = AppL10n.of(context).authVerifyInvalidCode);
      return;
    }
    _submittedCode = code;
    setState(() {
      _error = null;
      _step = 2;
    });
  }

  // -------------------------------------------------------------------------
  // Step 3 — confirm reset
  // -------------------------------------------------------------------------

  Future<void> _onSubmitPassword() async {
    final l10n = AppL10n.of(context);
    final newPassword = _newPasswordCtrl.text;
    final confirmPassword = _confirmPasswordCtrl.text;

    if (!_passwordRegex.hasMatch(newPassword)) {
      setState(() => _error = l10n.authPasswordRule);
      return;
    }
    if (newPassword != confirmPassword) {
      setState(() => _error = l10n.authPasswordsDoNotMatch);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await ref.read(currentUserProvider.notifier).resetPassword(
          email: _submittedEmail,
          code: _submittedCode,
          newPassword: newPassword,
        );
    if (!mounted) return;
    setState(() => _loading = false);
    switch (result) {
      case 'ok':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.authForgotSuccess)),
        );
        context.go('/login');
      case 'invalid_code':
        // Bounce back to step 2.
        setState(() {
          _step = 1;
          _error = l10n.authForgotInvalidCode;
        });
      case 'weak_password':
        setState(() => _error = l10n.authPasswordRule);
      default:
        setState(() => _error = l10n.errorGenericFallback);
    }
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Back nav
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (_step > 0) {
                        setState(() {
                          _step--;
                          _error = null;
                        });
                      } else {
                        context.pop();
                      }
                    },
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: AppColors.neutral900),
                  ),
                  const Spacer(),
                  // Step indicator
                  Row(
                    children: List.generate(3, (i) {
                      return Container(
                        width: 8,
                        height: 8,
                        margin:
                            const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i <= _step
                              ? AppColors.primary
                              : AppColors.neutral200,
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius:
                            BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Icon(
                        _step == 0
                            ? Icons.lock_reset_rounded
                            : _step == 1
                                ? Icons.pin_outlined
                                : Icons.lock_outline_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      _step == 0
                          ? l10n.authForgotStep1Title
                          : _step == 1
                              ? l10n.authForgotStep2Title
                              : l10n.authForgotStep3Title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    if (_step == 0) _buildEmailStep(l10n),
                    if (_step == 1) _buildCodeStep(l10n),
                    if (_step == 2) _buildPasswordStep(l10n),
                    if (_error != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color:
                              AppColors.error.withValues(alpha: 0.08),
                          borderRadius:
                              BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                              color: AppColors.error
                                  .withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xxl),
                    PrimaryButton(
                      label: _step == 2
                          ? l10n.authForgotStep3Title
                          : l10n.commonContinue,
                      isLoading: _loading,
                      onPressed: _loading
                          ? null
                          : _step == 0
                              ? _onSubmitEmail
                              : _step == 1
                                  ? _onSubmitCode
                                  : _onSubmitPassword,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailStep(AppL10n l10n) {
    return _StepField(
      label: l10n.commonEmail,
      controller: _emailCtrl,
      hint: l10n.commonEmailHint,
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildCodeStep(AppL10n l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'We sent a code to $_submittedEmail',
          style: const TextStyle(
              fontSize: 14, color: AppColors.neutral500),
        ),
        const SizedBox(height: AppSpacing.lg),
        _StepField(
          label: l10n.authVerifyEmailHint,
          controller: _codeCtrl,
          hint: '000000',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordStep(AppL10n l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepField(
          label: l10n.commonPassword,
          controller: _newPasswordCtrl,
          hint: '••••••••',
          obscure: _obscureNew,
          suffix: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () =>
                  setState(() => _obscureNew = !_obscureNew),
              child: Icon(
                _obscureNew
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.neutral500,
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _StepField(
          label: 'Confirm password',
          controller: _confirmPasswordCtrl,
          hint: '••••••••',
          obscure: _obscureConfirm,
          suffix: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
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
      ],
    );
  }
}

class _StepField extends StatelessWidget {
  const _StepField({
    required this.label,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final List<TextInputFormatter>? inputFormatters;

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
          inputFormatters: inputFormatters,
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
      ],
    );
  }
}
