import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  Future<void> _upload(
    BuildContext context,
    WidgetRef ref, {
    required bool isLicense,
  }) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    ref.read(currentUserProvider.notifier).setDocumentStatus(
          driverLicense: isLicense ? true : null,
          idDocument: isLicense ? null : true,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final hasLicense = user?.hasDriverLicense ?? false;
    final hasId = user?.hasIdDocument ?? false;
    final bothUploaded = hasLicense && hasId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _DocumentCard(
              icon: Icons.credit_card_outlined,
              title: "Driver's License",
              subtitle: 'Front & back photos',
              uploaded: hasLicense,
              onUpload: () => _upload(context, ref, isLicense: true),
            ),
            const SizedBox(height: AppSpacing.lg),
            _DocumentCard(
              icon: Icons.badge_outlined,
              title: 'ID Card / Passport',
              subtitle: 'Front & back photos',
              uploaded: hasId,
              onUpload: () => _upload(context, ref, isLicense: false),
            ),
            if (bothUploaded) ...[
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info, size: 20),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Verification in progress. We\'ll notify you once reviewed.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.info,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.uploaded,
    required this.onUpload,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool uploaded;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: AppColors.elevation1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(uploaded: uploaded),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: uploaded ? null : onUpload,
              icon: Icon(
                uploaded ? Icons.check_circle_outline : Icons.upload_outlined,
                size: 18,
              ),
              label: Text(uploaded ? 'Uploaded' : 'Upload Photos'),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    uploaded ? AppColors.success : AppColors.primary,
                side: BorderSide(
                  color: uploaded ? AppColors.success : AppColors.primary,
                ),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.uploaded});

  final bool uploaded;

  @override
  Widget build(BuildContext context) {
    final color = uploaded ? AppColors.success : AppColors.warning;
    final label = uploaded ? 'Uploaded' : 'Pending';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
