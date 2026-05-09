import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/user.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../l10n/app_localizations.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  AppNavDestination _nav = AppNavDestination.profile;

  void _onNav(AppNavDestination d) {
    if (d == _nav) return;
    setState(() => _nav = d);
    switch (d) {
      case AppNavDestination.home:
        context.go('/home');
      case AppNavDestination.bookings:
        context.go('/bookings');
      case AppNavDestination.wallet:
        context.go('/wallet');
      default:
        break;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showTrustSheet(AppUser? user) {
    final level = user?.trustLevel ?? TrustLevel.newUser;
    final label = trustLevelLabel(level);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trust Score',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Icon(Icons.star, color: AppColors.warning, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Level: $label',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: _trustProgress(level),
                minHeight: 8,
                backgroundColor: AppColors.neutral200,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _trustDescription(level),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.neutral500,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  double _trustProgress(TrustLevel level) => switch (level) {
        TrustLevel.newUser => 0.1,
        TrustLevel.verified => 0.4,
        TrustLevel.trusted => 0.7,
        TrustLevel.vip => 1.0,
      };

  String _trustDescription(TrustLevel level) => switch (level) {
        TrustLevel.newUser =>
          'Complete your profile and upload documents to increase your trust score.',
        TrustLevel.verified =>
          'Your identity is verified. Book more trips to reach Trusted status.',
        TrustLevel.trusted =>
          'You\'re a trusted renter. Keep up the great track record!',
        TrustLevel.vip => 'VIP status — you enjoy the highest tier of trust.',
      };

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Choose Theme'),
        children: [
          SimpleDialogOption(
            child: const Text('System'),
            onPressed: () {
              ref.read(themeModeProvider.notifier).state = ThemeMode.system;
              Navigator.of(context).pop();
            },
          ),
          SimpleDialogOption(
            child: const Text('Light'),
            onPressed: () {
              ref.read(themeModeProvider.notifier).state = ThemeMode.light;
              Navigator.of(context).pop();
            },
          ),
          SimpleDialogOption(
            child: const Text('Dark'),
            onPressed: () {
              ref.read(themeModeProvider.notifier).state = ThemeMode.dark;
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final user = ref.watch(currentUserProvider);
    final name = user?.fullName ?? 'Guest';
    final phone = user?.phone ?? '';
    final isVerified = user?.isVerified ?? false;

    return Scaffold(
      appBar: const GlassAppBar(),
      bottomNavigationBar: AppBottomNav(current: _nav, onSelect: _onNav),
      body: ListView(
        padding: EdgeInsets.only(
          top: AppSpacing.lg,
          bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.xl,
        ),
        children: [
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryLight,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: const Icon(Icons.person,
                      color: AppColors.primary, size: 40),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  phone,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.neutral500,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified,
                            color: AppColors.success, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          l10n.profileVerified,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _ProfileSection(
            title: l10n.profileAccountSection,
            items: [
              _ProfileItem(
                icon: Icons.person_outline,
                label: l10n.profilePersonalInfo,
                onTap: () => context.push('/profile/edit'),
              ),
              _ProfileItem(
                icon: Icons.badge_outlined,
                label: l10n.profileDocuments,
                onTap: () => context.push('/profile/documents'),
              ),
              _ProfileItem(
                icon: Icons.star_outline,
                label: l10n.profileTrustScore,
                trailing: Text(
                  '★ ${trustLevelLabel(user?.trustLevel ?? TrustLevel.newUser)}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                onTap: () => _showTrustSheet(user),
              ),
            ],
          ),
          _ProfileSection(
            title: l10n.profileSettingsSection,
            items: [
              _ProfileItem(
                icon: Icons.notifications_outlined,
                label: l10n.profileNotifications,
                onTap: () => _showSnackBar('Coming soon'),
              ),
              _ProfileItem(
                icon: Icons.dark_mode_outlined,
                label: l10n.profileTheme,
                onTap: _showThemeDialog,
              ),
            ],
          ),
          _ProfileSection(
            title: l10n.profileSupportSection,
            items: [
              _ProfileItem(
                icon: Icons.help_outline,
                label: l10n.profileHelp,
                onTap: () => _showSnackBar('Coming soon'),
              ),
              _ProfileItem(
                icon: Icons.description_outlined,
                label: l10n.profileTerms,
                onTap: () => _showSnackBar('Coming soon'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: TextButton(
              onPressed: () {
                ref.read(currentUserProvider.notifier).logout();
                context.go('/');
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(l10n.profileLogout),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.items});

  final String title;
  final List<_ProfileItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: AppColors.neutral500,
            ),
          ),
        ),
        ...items,
      ],
    );
  }
}

class _ProfileItem extends StatelessWidget {
  const _ProfileItem({
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
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      leading: Icon(icon, color: AppColors.neutral700, size: 22),
      title: Text(
        label,
        style:
            const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing: trailing ??
          const Icon(Icons.chevron_right,
              color: AppColors.neutral500, size: 20),
      onTap: onTap,
      visualDensity: VisualDensity.compact,
    );
  }
}
