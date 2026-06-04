import 'package:flutter/material.dart';

import '../models/app_notification.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'notification_router.dart';

/// In-app notification banner shown at the top of the screen when a push
/// arrives while the app is in the foreground.
///
/// Usage (from PushService._handleForeground):
/// ```dart
/// InAppBanner.show(context: context, notification: n);
/// ```
class InAppBanner extends StatelessWidget {
  const InAppBanner({
    super.key,
    required this.notification,
    required this.onDismiss,
  });

  final AppNotification notification;
  final VoidCallback onDismiss;

  /// Shows the banner as an overlay entry that auto-dismisses after 4 seconds.
  static void show({
    required BuildContext context,
    required AppNotification notification,
  }) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _BannerOverlay(
        notification: notification,
        onDismiss: () => entry.remove(),
      ),
    );
    Overlay.of(context).insert(entry);
    Future.delayed(const Duration(seconds: 4), () {
      if (entry.mounted) entry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(notification.category);
    final icon = categoryIcon(notification.category);

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppColors.elevation3,
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    notification.body,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.neutral700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close,
                  size: 18, color: AppColors.neutral500),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerOverlay extends StatelessWidget {
  const _BannerOverlay({
    required this.notification,
    required this.onDismiss,
  });

  final AppNotification notification;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    return Positioned(
      top: topPad + AppSpacing.sm,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () {
          onDismiss();
          routeNotification(context, notification);
        },
        child: InAppBanner(
          notification: notification,
          onDismiss: onDismiss,
        ),
      ),
    );
  }
}
