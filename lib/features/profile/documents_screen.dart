import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/uploads/document_upload_service.dart';
import '../../core/widgets/primary_button.dart';
import '../../l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Document types — 3 photos matching ClientQm (id_back removed)
// ---------------------------------------------------------------------------

enum _DocType {
  /// ID document front — stored in ClientQm.id_document_url
  idFront,

  /// Driver's license front — stored in ClientQm.license_front_url
  licenseFront,

  /// Driver's license back — stored in ClientQm.license_back_url
  licenseBack;

  /// Wire value sent to POST /mobile/clients/me/documents as document_type.
  /// TODO(backend): confirm these exact string values with the backend team.
  String get apiKey => switch (this) {
        _DocType.idFront => 'id_front',
        _DocType.licenseFront => 'license_front',
        _DocType.licenseBack => 'license_back',
      };

  String label(AppL10n l10n) => switch (this) {
        _DocType.idFront => l10n.documentIdFront,
        _DocType.licenseFront => l10n.documentLicenseFront,
        _DocType.licenseBack => l10n.documentLicenseBack,
      };
}

// ---------------------------------------------------------------------------
// Per-document card state
// ---------------------------------------------------------------------------

enum _CardState { empty, uploading, uploaded, failed }

class _DocCardState {
  _DocCardState({
    this.state = _CardState.empty,
    this.localFile,
    this.serverUrl,
    this.error,
  });

  final _CardState state;
  final File? localFile;
  final String? serverUrl;
  final String? error;

  _DocCardState copyWith({
    _CardState? state,
    File? localFile,
    String? serverUrl,
    String? error,
  }) =>
      _DocCardState(
        state: state ?? this.state,
        localFile: localFile ?? this.localFile,
        serverUrl: serverUrl ?? this.serverUrl,
        error: error ?? this.error,
      );
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

class _DocumentsNotifier extends StateNotifier<Map<_DocType, _DocCardState>> {
  _DocumentsNotifier(this._clientsApi, this._uploadService)
      : super({for (final t in _DocType.values) t: _DocCardState()});

  final dynamic _clientsApi; // MobileClientsApi
  final DocumentUploadService _uploadService;

  Future<void> pick(
    _DocType type, {
    required ImageSource source,
    required AppL10n l10n,
  }) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 2400,
      imageQuality: 85,
    );
    if (picked == null) return;

    final file = File(picked.path);

    // Validate extension
    final ext = picked.path.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png'].contains(ext)) {
      state = {
        ...state,
        type: _DocCardState(
          state: _CardState.failed,
          error: l10n.documentUnsupportedFormat,
        ),
      };
      return;
    }

    // Validate size (5 MB)
    final bytes = await file.length();
    if (bytes > 5 * 1024 * 1024) {
      state = {
        ...state,
        type: _DocCardState(
          state: _CardState.failed,
          error: l10n.documentFileTooLarge,
        ),
      };
      return;
    }

    // Show picked thumbnail, start upload
    state = {
      ...state,
      type: _DocCardState(state: _CardState.uploading, localFile: file),
    };

    try {
      // Step 1: Upload file to S3 (stub returns placeholder URL in dev).
      final url = await _uploadService.upload(
        file,
        documentType: type.apiKey,
      );

      // Step 2: Register URL with backend.
      await _clientsApi.uploadDocument(
        documentType: type.apiKey,
        documentUrl: url,
      );

      state = {
        ...state,
        type: _DocCardState(
          state: _CardState.uploaded,
          localFile: file,
          serverUrl: url,
        ),
      };
    } on ApiException catch (e) {
      state = {
        ...state,
        type: _DocCardState(
          state: _CardState.failed,
          localFile: file,
          error: e.serverMessage ?? l10n.documentUploadFailed,
        ),
      };
    } catch (_) {
      state = {
        ...state,
        type: _DocCardState(
          state: _CardState.failed,
          localFile: file,
          error: l10n.documentUploadFailed,
        ),
      };
    }
  }

  bool get allUploaded =>
      state.values.every((s) => s.state == _CardState.uploaded);
}

final _documentsProvider = StateNotifierProvider.autoDispose<
    _DocumentsNotifier, Map<_DocType, _DocCardState>>((ref) {
  return _DocumentsNotifier(
    ref.read(mobileClientsApiProvider),
    ref.read(documentUploadServiceProvider),
  );
});

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  bool _submitting = false;
  bool _submitted = false;

  Future<void> _submit() async {
    setState(() => _submitting = true);
    // All 3 docs already uploaded individually. A brief delay lets the server
    // process the uploads before we navigate to the gate screen.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _submitted = true;
    });
    context.go('/verification-gate');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final docsState = ref.watch(_documentsProvider);
    final notifier = ref.read(_documentsProvider.notifier);
    final allUploaded = notifier.allUploaded;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileDocuments),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          // Debug-only banner: warns that S3 uploads are stubbed.
          if (kDebugMode)
            Container(
              width: double.infinity,
              color: Colors.amber.shade100,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      size: 16, color: Colors.orange),
                  const SizedBox(width: AppSpacing.sm),
                  const Expanded(
                    child: Text(
                      'Dev mode: documents are not actually uploaded to S3 yet. '
                      'Placeholder URLs will be stored.',
                      style: TextStyle(fontSize: 11, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                for (final type in _DocType.values) ...[
                  _DocCard(
                    type: type,
                    cardState: docsState[type]!,
                    onPick: (source) => notifier.pick(
                      type,
                      source: source,
                      l10n: l10n,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ],
            ),
          ),

          // Bottom CTA
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: _submitted
                ? Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                          color: AppColors.info.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: AppColors.info, size: 20),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            l10n.documentSubmittedBadge,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.info,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : PrimaryButton(
                    label: l10n.documentSubmitForReview,
                    isLoading: _submitting,
                    onPressed:
                        (allUploaded && !_submitting) ? _submit : null,
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Document card
// ---------------------------------------------------------------------------

class _DocCard extends StatelessWidget {
  const _DocCard({
    required this.type,
    required this.cardState,
    required this.onPick,
  });

  final _DocType type;
  final _DocCardState cardState;
  final Future<void> Function(ImageSource) onPick;

  void _showSourceSheet(BuildContext context, AppL10n l10n) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.md),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.documentChooseSource,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(ctx).pop();
                  onPick(ImageSource.camera);
                },
                child: ListTile(
                  leading: const Icon(Icons.camera_alt_outlined,
                      color: AppColors.primary),
                  title: Text(l10n.documentTakePhoto),
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(ctx).pop();
                  onPick(ImageSource.gallery);
                },
                child: ListTile(
                  leading: const Icon(Icons.photo_library_outlined,
                      color: AppColors.primary),
                  title: Text(l10n.documentChooseFromGallery),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final uploaded = cardState.state == _CardState.uploaded;
    final uploading = cardState.state == _CardState.uploading;
    final failed = cardState.state == _CardState.failed;
    final hasFile =
        cardState.localFile != null || cardState.serverUrl != null;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: failed
              ? AppColors.error.withValues(alpha: 0.5)
              : uploaded
                  ? AppColors.success.withValues(alpha: 0.4)
                  : AppColors.neutral200,
          width: failed || uploaded ? 1.5 : 1.0,
        ),
        boxShadow: AppColors.elevation1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  type.label(l10n),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral900,
                  ),
                ),
              ),
              if (uploaded)
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 20),
              if (failed)
                const Icon(Icons.error_outline_rounded,
                    color: AppColors.error, size: 20),
            ],
          ),

          if (hasFile) ...[
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: cardState.localFile != null
                  ? Image.file(
                      cardState.localFile!,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 140,
                      color: AppColors.neutral100,
                      child: const Center(
                        child: Icon(Icons.image_outlined,
                            color: AppColors.neutral500, size: 40),
                      ),
                    ),
            ),
          ],

          if (uploading) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.documentUploading,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ),
          ],

          if (failed && cardState.error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              cardState.error!,
              style: const TextStyle(
                  color: AppColors.error, fontSize: 12),
            ),
          ],

          const SizedBox(height: AppSpacing.md),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: uploading
                  ? null
                  : () => _showSourceSheet(context, l10n),
              icon: Icon(
                uploaded
                    ? Icons.swap_horiz_rounded
                    : failed
                        ? Icons.refresh_rounded
                        : Icons.upload_outlined,
                size: 18,
              ),
              label: Text(
                uploaded
                    ? l10n.documentReplace
                    : failed
                        ? l10n.documentRetry
                        : l10n.documentUpload,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: failed ? AppColors.error : AppColors.primary,
                side: BorderSide(
                  color: failed ? AppColors.error : AppColors.primary,
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
