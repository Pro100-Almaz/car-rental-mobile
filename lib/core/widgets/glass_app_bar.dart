import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

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
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surface,
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
      ),
      height: 56 + MediaQuery.paddingOf(context).top,
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
          GestureDetector(
            onTap: onProfileTap,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.neutral300, width: 1.5),
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
                  : const Icon(Icons.person, color: AppColors.neutral500, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
