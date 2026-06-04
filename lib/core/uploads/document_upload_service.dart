import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Abstraction for uploading a document file to remote storage and returning
/// the public URL. The URL is then passed to POST /mobile/clients/me/documents.
///
/// Swap [StubDocumentUploadService] for a real S3 implementation once the
/// bucket + access credentials are provided.
abstract class DocumentUploadService {
  /// Uploads [file] to remote storage and returns the public URL.
  ///
  /// [documentType] is one of: "id_front", "license_front", "license_back".
  Future<String> upload(File file, {required String documentType});
}

/// Stub implementation — returns a placeholder URL with a warning log.
///
/// TODO(s3): Replace with a real S3 PUT implementation when the following are
/// provided by the backend/infra team:
///   - S3 bucket name
///   - AWS region
///   - Access key ID + secret (or IAM role / presigned-URL endpoint)
///   - Allowed MIME types and max file size
///
/// WARNING: Documents uploaded via this stub are NOT persisted to real storage.
/// The placeholder URL will be stored in the database but will return 404 when
/// accessed. This is intentional dev scaffolding.
class StubDocumentUploadService implements DocumentUploadService {
  const StubDocumentUploadService();

  @override
  Future<String> upload(File file, {required String documentType}) async {
    // Simulate a short network delay so the UI loading state is visible.
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final placeholderUrl =
        'https://placeholder.autofleet.kz/dev-uploads/'
        '$documentType-${DateTime.now().millisecondsSinceEpoch}.jpg';

    debugPrint(
      '[DocumentUploadService] WARNING: StubDocumentUploadService is active. '
      'File "${file.path}" was NOT uploaded to S3. '
      'Returning placeholder URL: $placeholderUrl',
    );

    return placeholderUrl;
  }
}

/// Riverpod provider. Replace [StubDocumentUploadService] with the real
/// implementation once S3 credentials are configured.
final documentUploadServiceProvider = Provider<DocumentUploadService>((ref) {
  // TODO(s3): swap to RealS3DocumentUploadService(bucket: ..., region: ...)
  return const StubDocumentUploadService();
});
