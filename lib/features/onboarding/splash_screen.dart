import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/primary_button.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F9B8E), AppColors.surface],
          ),
        ),
        child: Stack(
          children: [
            const _DecorativeBlurs(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.xl,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    _BrandHeader(),
                    _HeroImage(),
                    _ActionStack(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecorativeBlurs extends StatelessWidget {
  const _DecorativeBlurs();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -120,
          right: -120,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.10),
            ),
          ),
        ),
        Positioned(
          top: 200,
          left: -80,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryContainer.withValues(alpha: 0.10),
            ),
          ),
        ),
      ],
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xxl),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: const Icon(
                Icons.directions_car_rounded,
                size: 36,
                color: AppColors.onPrimaryContainer,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text(
          'CarShare',
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
            color: AppColors.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          "Your car. Someone's journey.",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.rotate(
              angle: 0.05,
              child: Transform.scale(
                scale: 0.94,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: CachedNetworkImage(
                imageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBXnWfeiE6X4-i4TvJrQcK10iMZdqqknQYetNa9bUg0oXem84cAb6hi0qB3inCOBMc2u22gf5r2xOakRiR8pqNDTKjdZKeeOyjzh4e1z-yC0pU4o8SltBV4lEVwKexrl3i1VsBzn9M2rWB2xFliLtGXXRqFphAd-Ph9y1I3M9HnpP1GVDdHIh2dmFqjR4SM8Eh3KnzSxJYjMnm9AlF_3k1868v-71_-VjARJjFs3xQ0eHNfbbVzo18nWs8VFkgwXydTbjcN4wTR_cRC',
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  color: AppColors.surfaceContainerHigh,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionStack extends StatelessWidget {
  const _ActionStack();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PrimaryButton(
          label: 'Find a car',
          onPressed: () => context.go('/login'),
        ),
        const SizedBox(height: AppSpacing.md),
        Material(
          color: Colors.white.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            side: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: InkWell(
            onTap: () => context.push('/register'),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: const SizedBox(
              height: 56,
              child: Center(
                child: Text(
                  'List your car',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        GestureDetector(
          onTap: () => context.push('/login'),
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
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          width: 120,
          height: 5,
          decoration: BoxDecoration(
            color: AppColors.onSurface.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
      ],
    );
  }
}
