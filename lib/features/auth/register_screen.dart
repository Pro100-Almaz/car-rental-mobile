import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/primary_button.dart';

enum RegisterRole { renter, owner, fleet }

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _step = 0;
  RegisterRole _role = RegisterRole.renter;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  bool _obscure = true;
  bool _agreed = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  void _onPrimary() {
    if (_step == 0) {
      setState(() => _step = 1);
      return;
    }
    context.go(_role == RegisterRole.renter ? '/home' : '/owner');
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
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onBack: _onBack),
            _ProgressDots(step: _step),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _step == 0
                    ? _RoleStep(
                        key: const ValueKey('role'),
                        selected: _role,
                        onSelect: (r) => setState(() => _role = r),
                      )
                    : _DetailsStep(
                        key: const ValueKey('details'),
                        nameCtrl: _nameCtrl,
                        emailCtrl: _emailCtrl,
                        phoneCtrl: _phoneCtrl,
                        passwordCtrl: _passwordCtrl,
                        dobCtrl: _dobCtrl,
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
                AppSpacing.xxl,
                AppSpacing.lg,
                AppSpacing.xxl,
                AppSpacing.xl,
              ),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: _canContinue ? 1 : 0.55,
                child: PrimaryButton(
                  label: _step == 0 ? 'Continue' : 'Create account',
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
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.primaryContainer,
            ),
          ),
          const Spacer(),
          const Text(
            'CarShare',
            style: TextStyle(
              color: AppColors.primaryContainer,
              fontWeight: FontWeight.w800,
              fontSize: 20,
              letterSpacing: -0.5,
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
    Color colorAt(int i) {
      if (i < step) return AppColors.primary.withValues(alpha: 0.4);
      if (i == step) return AppColors.primary;
      return AppColors.surfaceContainerHighest;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: i == step ? 40 : 16,
            height: 6,
            decoration: BoxDecoration(
              color: colorAt(i),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
        );
      }),
    );
  }
}

class _RoleStep extends StatelessWidget {
  const _RoleStep({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final RegisterRole selected;
  final ValueChanged<RegisterRole> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How will you use CarShare?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              color: AppColors.onSurface,
              height: 1.15,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'You can switch roles later in your profile.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _RoleCard(
            icon: Icons.vpn_key_rounded,
            title: 'Rent a car',
            subtitle: 'Search and book from thousands of cars near you.',
            selected: selected == RegisterRole.renter,
            onTap: () => onSelect(RegisterRole.renter),
          ),
          const SizedBox(height: AppSpacing.md),
          _RoleCard(
            icon: Icons.directions_car_rounded,
            title: 'List my car',
            subtitle: "Earn from your car when you're not driving it.",
            selected: selected == RegisterRole.owner,
            onTap: () => onSelect(RegisterRole.owner),
          ),
          const SizedBox(height: AppSpacing.md),
          _RoleCard(
            icon: Icons.apartment_rounded,
            title: 'Rental company',
            subtitle: 'Manage your fleet and reach more customers.',
            selected: selected == RegisterRole.fleet,
            onTap: () => onSelect(RegisterRole.fleet),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected
            ? AppColors.surfaceContainerLowest
            : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: selected
              ? AppColors.primary
              : AppColors.outlineVariant.withValues(alpha: 0.0),
          width: 2,
        ),
        boxShadow: selected ? AppColors.cloudShadow : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : AppColors.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: selected ? AppColors.onPrimary : AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : AppColors.outlineVariant.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppColors.onPrimary,
                          size: 16,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailsStep extends StatelessWidget {
  const _DetailsStep({
    super.key,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.passwordCtrl,
    required this.dobCtrl,
    required this.obscure,
    required this.agreed,
    required this.onToggleObscure,
    required this.onToggleAgreed,
    required this.onLogin,
  });

  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController dobCtrl;
  final bool obscure;
  final bool agreed;
  final VoidCallback onToggleObscure;
  final ValueChanged<bool?> onToggleAgreed;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Create your account',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              color: AppColors.onSurface,
              height: 1.15,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Join our community and start your journey today.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _Field(
            label: 'Full name',
            controller: nameCtrl,
            hint: 'Temirlan Doe',
          ),
          const SizedBox(height: AppSpacing.lg),
          _Field(
            label: 'Email address',
            controller: emailCtrl,
            hint: 'john@example.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.lg),
          _Field(
            label: 'Phone number',
            controller: phoneCtrl,
            hint: '+1 (555) 000-0000',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: AppSpacing.lg),
          _Field(
            label: 'Password',
            controller: passwordCtrl,
            hint: '••••••••',
            obscure: obscure,
            suffix: IconButton(
              onPressed: onToggleObscure,
              icon: Icon(
                obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Field(
            label: 'Date of birth',
            controller: dobCtrl,
            hint: 'MM / DD / YYYY',
            readOnly: true,
            onTap: () async {
              final now = DateTime.now();
              final d = await showDatePicker(
                context: context,
                firstDate: DateTime(now.year - 100),
                lastDate: now,
                initialDate: DateTime(now.year - 25),
              );
              if (d != null) {
                dobCtrl.text =
                    '${d.month.toString().padLeft(2, '0')} / ${d.day.toString().padLeft(2, '0')} / ${d.year}';
              }
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.translate(
                offset: const Offset(0, -2),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: agreed,
                    onChanged: onToggleAgreed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm / 2),
                    ),
                    activeColor: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: GestureDetector(
                  onTap: () => onToggleAgreed(!agreed),
                  child: const Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(text: 'I agree to the '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
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
              Expanded(
                child: Divider(
                  color: AppColors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text(
                  'OR CONTINUE WITH',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                    color: AppColors.outline,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: AppColors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          SecondaryButton(
            label: 'Continue with Google',
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
            child: const Text.rich(
              TextSpan(
                text: 'Already have an account? ',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                children: [
                  TextSpan(
                    text: 'Log in',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            behavior: HitTestBehavior.opaque,
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
    this.readOnly = false,
    this.onTap,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
