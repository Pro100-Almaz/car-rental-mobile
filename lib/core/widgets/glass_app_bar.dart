import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Frosted-glass sliver app bar used across the main marketplace screens.
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassAppBar({
    super.key,
    this.avatarUrl,
    this.onMenuTap,
    this.onProfileTap,
  });

  final String? avatarUrl;
  final VoidCallback? onMenuTap;
  final VoidCallback? onProfileTap;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: AppColors.surface.withValues(alpha: 0.8),
          padding: EdgeInsets.only(
            top: MediaQuery.paddingOf(context).top,
            left: AppSpacing.xl,
            right: AppSpacing.xl,
          ),
          height: 72 + MediaQuery.paddingOf(context).top,
          child: Row(
            children: [
              IconButton(
                onPressed: onMenuTap,
                icon: const Icon(Icons.menu_rounded, color: AppColors.primaryContainer),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                'CarShare',
                style: TextStyle(
                  color: AppColors.primaryContainer,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onProfileTap,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 2,
                    ),
                    color: AppColors.surfaceContainerHigh,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: avatarUrl != null
                      ? CachedNetworkImage(
                          imageUrl: avatarUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => const Icon(
                            Icons.person,
                            color: AppColors.onSurfaceVariant,
                          ),
                        )
                      : const Icon(Icons.person, color: AppColors.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
