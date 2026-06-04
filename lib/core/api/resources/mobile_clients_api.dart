import 'package:dio/dio.dart';

import '../../models/fine.dart';
import '../../models/outstanding.dart';
import '../../models/payment_record.dart';
import '../../models/user.dart';
import '../api_endpoints.dart';
import '../error_mapper.dart';

// ---------------------------------------------------------------------------
// DTOs
// ---------------------------------------------------------------------------

/// Response from GET /mobile/clients/me/verification
/// Field name: verification_status (not 'status') per OpenAPI ClientQm.
class VerificationStatusResponse {
  const VerificationStatusResponse({
    required this.status,
    this.rejectionReason,
    this.updatedAt,
  });

  final VerificationStatus status;
  final String? rejectionReason;
  final DateTime? updatedAt;

  factory VerificationStatusResponse.fromJson(Map<String, dynamic> json) {
    // Backend field is 'verification_status'; fall back to 'status' for compat.
    final rawStatus =
        (json['verification_status'] ?? json['status'] ?? 'not_started')
            as String;
    final status = switch (rawStatus.toLowerCase()) {
      'pending' => VerificationStatus.pending,
      'verified' => VerificationStatus.verified,
      'rejected' => VerificationStatus.rejected,
      _ => VerificationStatus.notStarted,
    };
    final updatedRaw = json['updated_at'] as String?;
    return VerificationStatusResponse(
      status: status,
      rejectionReason: json['rejection_reason'] as String?,
      updatedAt: updatedRaw != null ? DateTime.tryParse(updatedRaw) : null,
    );
  }
}

// DocumentUploadResult removed — uploadDocument now returns void.
// Backend stores the URL supplied by the mobile client (2-step: S3 then API).

// ---------------------------------------------------------------------------
// API resource
// ---------------------------------------------------------------------------

/// Client-profile resource: /mobile/clients/me and sub-paths.
class MobileClientsApi {
  MobileClientsApi(this._dio);
  final Dio _dio;

  // -------------------------------------------------------------------------
  // Profile
  // -------------------------------------------------------------------------

  /// GET /mobile/clients/me
  /// Parses ClientQm: snake_case, balances as decimal strings.
  Future<AppUser> me() async {
    try {
      final response = await _dio.get(ApiEndpoints.clientMe);
      final data = response.data as Map<String, dynamic>;
      return _parseUser(data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// PATCH /mobile/clients/me
  Future<AppUser> updateMe({
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (firstName != null) body['first_name'] = firstName;
      if (lastName != null) body['last_name'] = lastName;
      if (phone != null) body['phone'] = phone;

      final response = await _dio.patch(ApiEndpoints.clientMe, data: body);
      return _parseUser(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  // -------------------------------------------------------------------------
  // Verification status
  // -------------------------------------------------------------------------

  /// GET /mobile/clients/me/verification
  Future<VerificationStatusResponse> verification() async {
    try {
      final response = await _dio.get(ApiEndpoints.clientVerification);
      final data = response.data as Map<String, dynamic>;
      return VerificationStatusResponse.fromJson(data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  // -------------------------------------------------------------------------
  // Document upload (2-step: mobile uploads to S3 first, then sends URL here)
  // -------------------------------------------------------------------------

  /// POST /mobile/clients/me/documents
  /// Body: { document_type: "id_front|license_front|license_back", document_url: "https://..." }
  ///
  /// Mobile must upload the file to S3 first via [DocumentUploadService],
  /// then pass the resulting URL here. This endpoint stores the URL only.
  ///
  /// document_type wire values:
  ///   "id_front"      → stored in ClientQm.id_document_url
  ///   "license_front" → stored in ClientQm.license_front_url
  ///   "license_back"  → stored in ClientQm.license_back_url
  ///
  /// TODO(backend): confirm exact document_type string values with backend team.
  Future<void> uploadDocument({
    required String documentType,
    required String documentUrl,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.clientDocuments,
        data: {
          'document_type': documentType,
          'document_url': documentUrl,
        },
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  // -------------------------------------------------------------------------
  // Fines
  // -------------------------------------------------------------------------

  /// GET /mobile/clients/me/fines
  Future<List<Fine>> getFines() async {
    try {
      final response = await _dio.get(ApiEndpoints.clientFines);
      return _parseList<Fine>(response.data, Fine.fromJson);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  // -------------------------------------------------------------------------
  // Payments
  // -------------------------------------------------------------------------

  /// GET /mobile/clients/me/payments
  Future<List<PaymentRecord>> getPayments() async {
    try {
      final response = await _dio.get(ApiEndpoints.clientPayments);
      return _parseList<PaymentRecord>(response.data, PaymentRecord.fromJson);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  // -------------------------------------------------------------------------
  // Outstanding
  // -------------------------------------------------------------------------

  /// GET /mobile/clients/me/outstanding
  Future<OutstandingResponse> getOutstanding() async {
    try {
      final response = await _dio.get(ApiEndpoints.clientOutstanding);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return OutstandingResponse.fromJson(data);
      }
      return OutstandingResponse.empty;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  // -------------------------------------------------------------------------
  // Notification preferences
  // -------------------------------------------------------------------------

  /// PATCH /mobile/clients/me/notification-preferences
  Future<void> updateNotificationPreferences(
      NotificationPreferences prefs) async {
    try {
      await _dio.patch(
        ApiEndpoints.clientNotificationPrefs,
        data: prefs.toJson(),
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  List<T> _parseList<T>(
    dynamic data,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    List<dynamic> items;
    if (data is List) {
      items = data;
    } else if (data is Map<String, dynamic> && data['results'] is List) {
      items = data['results'] as List;
    } else {
      return const [];
    }
    return items.whereType<Map<String, dynamic>>().map(fromJson).toList();
  }

  /// Parses ClientQm (all snake_case from FastAPI).
  /// wallet_balance and debt_balance are decimal strings — parsed to double.
  /// email_verified added by backend 2026-05-23.
  AppUser _parseUser(Map<String, dynamic> data) {
    final id = (data['id'] ?? data['user_id'] ?? '').toString();
    final email = data['email'] as String?;
    final firstName = (data['first_name'] ?? '') as String;
    final lastName = (data['last_name'] ?? '') as String;
    final fullName = '$firstName $lastName'.trim();
    final phone = (data['phone'] ?? '') as String;
    final avatarUrl = data['avatar_url'] as String?;
    final organizationId = data['organization_id']?.toString();

    // verification_status
    final rawVs =
        (data['verification_status'] as String? ?? 'not_started').toLowerCase();
    final verificationStatus = switch (rawVs) {
      'pending' => VerificationStatus.pending,
      'verified' => VerificationStatus.verified,
      'rejected' => VerificationStatus.rejected,
      _ => VerificationStatus.notStarted,
    };

    // trust_level
    final rawTrust =
        (data['trust_level'] as String? ?? 'new').toLowerCase();
    final trustLevel = switch (rawTrust) {
      'verified' => TrustLevel.verified,
      'trusted' => TrustLevel.trusted,
      'vip' => TrustLevel.vip,
      _ => TrustLevel.newUser,
    };

    // trust_score (int)
    final trustScore = (data['trust_score'] as num? ?? 0).toInt();

    // wallet_balance + debt_balance are decimal strings per ClientQm schema.
    final walletBalance = _parseDecimalString(data['wallet_balance']);
    final debtBalance = _parseDecimalString(data['debt_balance']);

    // Document URLs — exactly 3 (id_back removed from ClientQm)
    final idDocumentUrl = data['id_document_url'] as String?;
    final licenseFrontUrl = data['license_front_url'] as String?;
    final licenseBackUrl = data['license_back_url'] as String?;

    // Derive hasIdDocument / hasDriverLicense from URL presence
    final hasIdDocument =
        idDocumentUrl != null && idDocumentUrl.isNotEmpty;
    final hasDriverLicense = (licenseFrontUrl != null &&
            licenseFrontUrl.isNotEmpty) &&
        (licenseBackUrl != null && licenseBackUrl.isNotEmpty);

    // blacklisted
    final isBlacklisted =
        (data['is_blacklisted'] ?? false) as bool;
    final blacklistReason = data['blacklist_reason'] as String?;

    // email_verified (added by backend 2026-05-23)
    final emailVerified = (data['email_verified'] ?? false) as bool;

    // statistics (optional nested object)
    final statsRaw = data['statistics'];
    final statistics = statsRaw is Map<String, dynamic>
        ? ClientStatistics.fromJson(statsRaw)
        : null;

    // notification preferences
    final prefsRaw = data['notification_preferences'];
    final notificationPreferences = prefsRaw is Map<String, dynamic>
        ? NotificationPreferences.fromJson(prefsRaw)
        : null;

    return AppUser(
      id: id,
      fullName: fullName.isEmpty ? (email ?? 'User') : fullName,
      phone: phone,
      email: email,
      avatarUrl: avatarUrl,
      isVerified: verificationStatus == VerificationStatus.verified,
      emailVerified: emailVerified,
      trustLevel: trustLevel,
      trustScore: trustScore,
      hasDriverLicense: hasDriverLicense,
      hasIdDocument: hasIdDocument,
      organizationId: organizationId,
      verificationStatus: verificationStatus,
      isBlacklisted: isBlacklisted,
      blacklistReason: blacklistReason,
      walletBalance: walletBalance,
      debtBalance: debtBalance,
      idDocumentUrl: idDocumentUrl,
      licenseFrontUrl: licenseFrontUrl,
      licenseBackUrl: licenseBackUrl,
      statistics: statistics,
      notificationPreferences: notificationPreferences,
      roles: const [UserRole.client],
    );
  }

  /// Safely parses a value that may be a decimal string ("123.45"),
  /// a num, or null. Returns 0.0 on parse failure.
  static double _parseDecimalString(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}
