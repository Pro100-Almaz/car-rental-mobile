import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_client.dart';
import '../../core/api/resources/mobile_clients_api.dart';
import '../../core/models/user.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/primary_button.dart';
import '../../l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final verificationStatusProvider =
    FutureProvider.autoDispose<VerificationStatusResponse>((ref) async {
  final api = ref.watch(mobileClientsApiProvider);
  return api.verification();
});

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class VerificationGateScreen extends ConsumerStatefulWidget {
  const VerificationGateScreen({super.key});

  @override
  ConsumerState<VerificationGateScreen> createState() =>
      _VerificationGateScreenState();
}

class _VerificationGateScreenState
    extends ConsumerState<VerificationGateScreen>
    with WidgetsBindingObserver {
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startPollingIfPending();
    } else if (state == AppLifecycleState.paused) {
      _stopPolling();
    }
  }

  void _startPollingIfPending() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      ref.invalidate(verificationStatusProvider);
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(verificationStatusProvider);

    return Scaffold(
      body: SafeArea(
        child: statusAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (e, _) => _ErrorView(
            onRetry: () => ref.invalidate(verificationStatusProvider),
          ),
          data: (response) {
            // Side-effect: start/stop polling and navigate on verified
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              if (response.status == VerificationStatus.pending) {
                _startPollingIfPending();
              } else {
                _stopPolling();
              }
              if (response.status == VerificationStatus.verified) {
                // Update cached user verification status
                ref.read(currentUserProvider.notifier).refreshCurrentUser();
                final router = GoRouter.of(context);
                Future.delayed(const Duration(milliseconds: 1500), () {
                  if (mounted) router.go('/cars');
                });
              }
            });

            return _StatusView(response: response);
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status view — 4 states
// ---------------------------------------------------------------------------

class _StatusView extends StatelessWidget {
  const _StatusView({required this.response});
  final VerificationStatusResponse response;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return switch (response.status) {
      VerificationStatus.notStarted => _StateLayout(
          icon: Icons.upload_file_outlined,
          iconColor: AppColors.primary,
          title: l10n.verificationNotStartedTitle,
          subtitle: l10n.verificationNotStartedSubtitle,
          child: PrimaryButton(
            label: l10n.verificationNotStartedCta,
            icon: Icons.arrow_forward_rounded,
            onPressed: () => context.push('/profile/documents'),
          ),
        ),
      VerificationStatus.pending => _StateLayout(
          icon: Icons.hourglass_top_rounded,
          iconColor: AppColors.warning,
          title: l10n.verificationPendingTitle,
          subtitle: l10n.verificationPendingSubtitle,
          child: OutlinedButton.icon(
            onPressed: () => context.push('/profile/support'),
            icon: const Icon(Icons.support_agent_outlined),
            label: Text(l10n.verificationContactSupport),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
        ),
      VerificationStatus.verified => _StateLayout(
          icon: Icons.check_circle_rounded,
          iconColor: AppColors.success,
          title: l10n.verificationVerifiedTitle,
          subtitle: null,
          child: Consumer(
            builder: (context, ref, _) => PrimaryButton(
              label: l10n.verificationContinue,
              icon: Icons.arrow_forward_rounded,
              onPressed: () {
                ref
                    .read(currentUserProvider.notifier)
                    .refreshCurrentUser();
                context.go('/cars');
              },
            ),
          ),
        ),
      VerificationStatus.rejected => _StateLayout(
          icon: Icons.error_outline_rounded,
          iconColor: AppColors.error,
          title: l10n.verificationRejectedTitle,
          subtitle: response.rejectionReason ?? l10n.verificationRejectedFallback,
          child: PrimaryButton(
            label: l10n.verificationReupload,
            icon: Icons.upload_file_outlined,
            onPressed: () => context.push('/profile/documents'),
          ),
        ),
    };
  }
}

// ---------------------------------------------------------------------------
// Shared layout widget
// ---------------------------------------------------------------------------

class _StateLayout extends StatelessWidget {
  const _StateLayout({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.xxl,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 48),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.neutral500,
                    height: 1.5,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xxxl),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error view
// ---------------------------------------------------------------------------

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                color: AppColors.neutral500, size: 48),
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.errorNetworkOffline,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.neutral700, fontSize: 15),
            ),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
