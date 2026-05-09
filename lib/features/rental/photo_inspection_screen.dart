import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/models/booking.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class PhotoInspectionScreen extends ConsumerStatefulWidget {
  const PhotoInspectionScreen({
    super.key,
    required this.bookingId,
    required this.isCheckIn,
  });

  final String bookingId;
  final bool isCheckIn;

  @override
  ConsumerState<PhotoInspectionScreen> createState() =>
      _PhotoInspectionScreenState();
}

class _PhotoInspectionScreenState
    extends ConsumerState<PhotoInspectionScreen> {
  static const _angles = [
    ('Front', Icons.directions_car),
    ('Right Side', Icons.arrow_forward),
    ('Rear', Icons.directions_car),
    ('Left Side', Icons.arrow_back),
    ('Dashboard', Icons.dashboard),
    ('Back Seat', Icons.airline_seat_recline_normal),
    ('Trunk', Icons.inventory_2),
    ('Odometer', Icons.speed),
  ];

  int _currentIndex = 0;

  Future<void> _capturePhoto() async {
    final picker = ImagePicker();
    XFile? file;

    try {
      file = await picker.pickImage(source: ImageSource.camera);
    } catch (_) {
      // Camera unavailable (e.g. simulator) — fall back to gallery
      file = await picker.pickImage(source: ImageSource.gallery);
    }

    if (file == null) return;

    ref
        .read(inspectionPhotosProvider.notifier)
        .setPhoto(_currentIndex, file.path);
  }

  void _acceptPhoto() {
    final photos = ref.read(inspectionPhotosProvider);
    final notifier = ref.read(inspectionPhotosProvider.notifier);

    if (notifier.isComplete) {
      _finishInspection();
      return;
    }

    // Advance to next un-captured angle, or first incomplete one
    if (_currentIndex < _angles.length - 1) {
      setState(() => _currentIndex = _currentIndex + 1);
    } else {
      // Find first null slot
      final firstNull = photos.indexWhere((p) => p == null);
      if (firstNull == -1) {
        _finishInspection();
      } else {
        setState(() => _currentIndex = firstNull);
      }
    }
  }


  void _finishInspection() {
    if (widget.isCheckIn) {
      ref.read(bookingsProvider.notifier).startRental(
            widget.bookingId,
            fuelLevel: 0.85,
            mileage: 45230,
          );
      context.go('/rental/active/${widget.bookingId}');
    } else {
      ref
          .read(bookingsProvider.notifier)
          .updateStatus(widget.bookingId, BookingStatus.completed);
      context.go('/bookings');
    }
  }

  @override
  Widget build(BuildContext context) {
    final photos = ref.watch(inspectionPhotosProvider);
    final notifier = ref.read(inspectionPhotosProvider.notifier);
    final currentPhoto = photos[_currentIndex];
    final hasCaptured = currentPhoto != null && currentPhoto.isNotEmpty;
    final (angleName, angleIcon) = _angles[_currentIndex];
    final allComplete = notifier.isComplete;

    return Scaffold(
      backgroundColor: AppColors.neutral900,
      appBar: _InspectionAppBar(
        currentStep: _currentIndex + 1,
        total: _angles.length,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Camera / photo preview area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  0,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: hasCaptured
                      ? _PhotoPreview(path: currentPhoto)
                      : _AnglePlaceholder(
                          name: angleName,
                          icon: angleIcon,
                        ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Guide text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                'Align the $angleName of the car',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: hasCaptured
                  ? _AcceptRetakeRow(
                      onAccept: allComplete ? _finishInspection : _acceptPhoto,
                      onRetake: () async {
                        // Clear current photo then re-capture
                        ref
                            .read(inspectionPhotosProvider.notifier)
                            .setPhoto(_currentIndex, '');
                        await _capturePhoto();
                      },
                      isLast: allComplete,
                    )
                  : _CaptureButton(onTap: _capturePhoto),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Progress dots
            _ProgressDots(
              photos: photos,
              currentIndex: _currentIndex,
              onDotTap: (i) => setState(() => _currentIndex = i),
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// App bar
// ---------------------------------------------------------------------------

class _InspectionAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _InspectionAppBar({required this.currentStep, required this.total});

  final int currentStep;
  final int total;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.neutral900,
      foregroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'Vehicle Inspection',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          child: Center(
            child: Text(
              'Photo $currentStep/$total',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.neutral500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Placeholder shown before capture
// ---------------------------------------------------------------------------

class _AnglePlaceholder extends StatelessWidget {
  const _AnglePlaceholder({required this.name, required this.icon});

  final String name;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.neutral100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: AppColors.elevation2,
            ),
            child: Icon(icon, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Tap the button below to take a photo',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.neutral500,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Photo preview after capture
// ---------------------------------------------------------------------------

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(File(path), fit: BoxFit.cover),
        Positioned(
          top: AppSpacing.md,
          right: AppSpacing.md,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_rounded, size: 14, color: AppColors.white),
                SizedBox(width: 4),
                Text(
                  'Captured',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Capture button (before photo taken)
// ---------------------------------------------------------------------------

class _CaptureButton extends StatelessWidget {
  const _CaptureButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: AppColors.elevation3,
          ),
          child: const Icon(
            Icons.camera_alt_rounded,
            size: 32,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Accept / Retake row (after photo taken)
// ---------------------------------------------------------------------------

class _AcceptRetakeRow extends StatelessWidget {
  const _AcceptRetakeRow({
    required this.onAccept,
    required this.onRetake,
    required this.isLast,
  });

  final VoidCallback onAccept;
  final VoidCallback onRetake;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onRetake,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.white,
              side: const BorderSide(color: AppColors.neutral500),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: const Text(
              'Retake',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          flex: 2,
          child: FilledButton(
            onPressed: onAccept,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: Text(
              isLast ? 'Complete Inspection' : 'Accept',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Progress dots
// ---------------------------------------------------------------------------

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({
    required this.photos,
    required this.currentIndex,
    required this.onDotTap,
  });

  final List<String?> photos;
  final int currentIndex;
  final ValueChanged<int> onDotTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(photos.length, (i) {
        final isCompleted = photos[i] != null && photos[i]!.isNotEmpty;
        final isCurrent = i == currentIndex;

        return GestureDetector(
          onTap: () => onDotTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            width: isCurrent ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.success
                  : isCurrent
                      ? AppColors.primary
                      : AppColors.neutral500,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
        );
      }),
    );
  }
}
