import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/primary_button.dart';
import '../../l10n/app_localizations.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xxl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Branding(subtitle: l10n.loginSubtitle),
                  const SizedBox(height: AppSpacing.xxxl),
                  _LoginCard(),
                  const SizedBox(height: AppSpacing.xxl),
                  _SignupPrompt(onTap: () => context.push('/register')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Branding extends StatelessWidget {
  const _Branding({required this.subtitle});
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: const Icon(
            Icons.directions_car_rounded,
            color: AppColors.primary,
            size: 32,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          AppL10n.of(context).appName,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.neutral500,
            fontWeight: FontWeight.w400,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class _LoginCard extends StatefulWidget {
  @override
  State<_LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<_LoginCard> {
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: AppColors.elevation1,
      ),
      child: Column(
        children: [
          _Field(
            label: l10n.commonPhone,
            controller: _phoneCtrl,
            hint: l10n.commonPhoneHint,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: AppSpacing.lg),
          _Field(
            label: l10n.commonPassword,
            controller: _passwordCtrl,
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            obscure: true,
            trailing: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l10n.loginForgot,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: l10n.loginButton,
            onPressed: () => context.go('/home'),
          ),
          const SizedBox(height: AppSpacing.xl),
          _Divider(label: l10n.loginDivider),
          const SizedBox(height: AppSpacing.xl),
          SecondaryButton(
            label: l10n.commonContinueWithGoogle,
            icon: Container(
              width: 20,
              height: 20,
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
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.trailing,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral700,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.sm),
              child: Icon(icon, color: AppColors.neutral500, size: 20),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.neutral200)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.neutral500,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.neutral200)),
      ],
    );
  }
}

class _SignupPrompt extends StatelessWidget {
  const _SignupPrompt({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.loginNoAccount,
          style: const TextStyle(
            color: AppColors.neutral500,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        GestureDetector(
          onTap: onTap,
          child: Text(
            l10n.loginSignup,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
