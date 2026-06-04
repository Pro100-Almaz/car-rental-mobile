import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Feature flag — disable glass blur on low-end Android devices if needed.
const bool kEnableGlassBlur = true;

// Renamed from GlassAppBar → AppTopBar (M1.C rename).
// M6.F: Real BackdropFilter glass effect added with RepaintBoundary for perf.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    this.avatarUrl,
    this.onMenuTap,
    this.onProfileTap,
    this.notificationCount = 0,
    this.onNotificationTap,
  });

  final String? avatarUrl;
  final VoidCallback? onMenuTap;
  final VoidCallback? onProfileTap;
  final int notificationCount;
  final VoidCallback? onNotificationTap;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final topPad = MediaQuery.paddingOf(context).top;
    final totalHeight = 56 + topPad;

    return RepaintBoundary(
      child: SizedBox(
        height: totalHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Glass blur layer (M6.F)
            if (kEnableGlassBlur)
              ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    color: cs.surface.withValues(alpha: 0.7),
                  ),
                ),
              )
            else
              Container(color: cs.surface),

            // Content
            Padding(
              padding: EdgeInsets.only(
                top: topPad,
                left: AppSpacing.lg,
                right: AppSpacing.lg,
              ),
              child: Row(
                children: [
                  const Text(
                    'AutoFleet',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  if (onNotificationTap != null) ...[
                    // M6.E: Semantics label on icon-only button
                    Semantics(
                      label: notificationCount > 0
                          ? 'Notifications, $notificationCount unread'
                          : 'Notifications',
                      button: true,
                      child: GestureDetector(
                        onTap: onNotificationTap,
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: Center(
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Icon(Icons.notifications_outlined,
                                    color: cs.onSurface.withValues(alpha: 0.7),
                                    size: 24),
                                if (notificationCount > 0)
                                  Positioned(
                                    top: -4,
                                    right: -4,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppColors.error,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(
                                          minWidth: 16, minHeight: 16),
                                      child: Text(
                                        '$notificationCount',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  // M6.E: Semantics on profile avatar
                  Semantics(
                    label: 'Profile',
                    button: true,
                    child: GestureDetector(
                      onTap: onProfileTap,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: AppColors.neutral300, width: 1.5),
                          color: AppColors.neutral200,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: avatarUrl != null
                            ? CachedNetworkImage(
                                imageUrl: avatarUrl!,
                                fit: BoxFit.cover,
                                errorWidget: (_, _, _) => const Icon(
                                  Icons.person,
                                  color: AppColors.neutral500,
                                  size: 20,
                                ),
                              )
                            : const Icon(Icons.person,
                                color: AppColors.neutral500, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
