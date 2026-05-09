import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/app_localizations.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, Color(0xFF0F3D91)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.xl,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - AppSpacing.xl * 2,
                  ),
                  child: const IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _BrandHeader(),
                        _HeroCarousel(),
                        _ActionStack(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xxl),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: const Icon(
            Icons.directions_car_rounded,
            size: 36,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.appName,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.brandTagline,
          style: TextStyle(
            color: AppColors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class _HeroCarousel extends StatefulWidget {
  const _HeroCarousel();

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  late final PageController _controller;
  int _page = 0;

  static const List<String> _images = [
    'assets/images/welcome/slide_1.png',
    'assets/images/welcome/slide_2.png',
    'assets/images/welcome/slide_3.png',
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final slides = <_SlideData>[
      _SlideData(
        image: _images[0],
        title: l10n.welcomeSlide1Title,
        subtitle: l10n.welcomeSlide1Subtitle,
      ),
      _SlideData(
        image: _images[1],
        title: l10n.welcomeSlide2Title,
        subtitle: l10n.welcomeSlide2Subtitle,
      ),
      _SlideData(
        image: _images[2],
        title: l10n.welcomeSlide3Title,
        subtitle: l10n.welcomeSlide3Subtitle,
      ),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: PageView.builder(
              controller: _controller,
              itemCount: slides.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, index) => _HeroSlide(data: slides[index]),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _PageDots(count: slides.length, active: _page),
        ],
      ),
    );
  }
}

class _SlideData {
  const _SlideData({
    required this.image,
    required this.title,
    required this.subtitle,
  });

  final String image;
  final String title;
  final String subtitle;
}

class _HeroSlide extends StatelessWidget {
  const _HeroSlide({required this.data});

  final _SlideData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Image.asset(
                data.image,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: const Icon(
                    Icons.directions_car,
                    color: AppColors.white,
                    size: 64,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.75),
              fontWeight: FontWeight.w400,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.white
                : AppColors.white.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        );
      }),
    );
  }
}

class _ActionStack extends StatelessWidget {
  const _ActionStack();

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => context.go('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            child: Text(l10n.commonLogin),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => context.push('/register'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.white,
              side: BorderSide(color: AppColors.white.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            child: Text(l10n.loginSignup),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
