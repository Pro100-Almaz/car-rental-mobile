import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'connectivity_provider.dart';

/// Slides in from the top when offline, slides out when back online.
/// Dismissible but re-appears on the next offline transition.
class ConnectivityBanner extends ConsumerStatefulWidget {
  const ConnectivityBanner({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ConnectivityBanner> createState() =>
      _ConnectivityBannerState();
}

class _ConnectivityBannerState extends ConsumerState<ConnectivityBanner> {
  bool _dismissed = false;
  ConnectivityStatus? _lastStatus;

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(connectivityStatusProvider);

    final status = statusAsync.valueOrNull ?? ConnectivityStatus.online;

    // Re-show banner if we transition back to offline after being dismissed
    if (_lastStatus != status) {
      if (status == ConnectivityStatus.offline) {
        _dismissed = false;
      }
      _lastStatus = status;
    }

    final showBanner = status == ConnectivityStatus.offline && !_dismissed;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: showBanner ? null : 0,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(),
          child: showBanner ? _BannerContent(onDismiss: () {
            setState(() => _dismissed = true);
          }) : const SizedBox.shrink(),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}

class _BannerContent extends StatelessWidget {
  const _BannerContent({required this.onDismiss});
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.neutral900,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        MediaQuery.paddingOf(context).top + AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded,
              color: AppColors.white, size: 16),
          const SizedBox(width: AppSpacing.sm),
          const Expanded(
            child: Text(
              'No internet connection · Showing cached data',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded,
                color: AppColors.white, size: 18),
            onPressed: onDismiss,
            padding: const EdgeInsets.all(AppSpacing.xs),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}
