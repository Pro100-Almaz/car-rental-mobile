enum UserRole { client, bookingManager, financialManager, technician, admin }

/// Document / identity verification status for the router gate.
enum VerificationStatus { notStarted, pending, verified, rejected }

enum TrustLevel { newUser, verified, trusted, vip }

String trustLevelLabel(TrustLevel level) => switch (level) {
      TrustLevel.newUser => 'New',
      TrustLevel.verified => 'Verified',
      TrustLevel.trusted => 'Trusted',
      TrustLevel.vip => 'VIP',
    };

/// Trip / spend statistics embedded in the client profile.
class ClientStatistics {
  const ClientStatistics({
    required this.tripCount,
    required this.totalSpent,
    required this.onTimeRate,
  });

  final int tripCount;

  /// Total spend in KZT (integer).
  final int totalSpent;

  /// On-time return rate, 0.0 – 1.0.
  final double onTimeRate;

  factory ClientStatistics.fromJson(Map<String, dynamic> json) {
    return ClientStatistics(
      tripCount: (json['trip_count'] ?? json['tripCount'] ?? 0) as int,
      totalSpent: (json['total_spent'] ?? json['totalSpent'] ?? 0) as int,
      onTimeRate: ((json['on_time_rate'] ?? json['onTimeRate'] ?? 0.0) as num)
          .toDouble(),
    );
  }

  static const empty = ClientStatistics(
    tripCount: 0,
    totalSpent: 0,
    onTimeRate: 1.0,
  );
}

/// Notification preference flags.  Critical alerts are always on (not stored).
class NotificationPreferences {
  const NotificationPreferences({
    this.bookings = true,
    this.fines = true,
    this.promotions = false,
  });

  final bool bookings;
  final bool fines;
  final bool promotions;

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      bookings: (json['bookings'] as bool?) ?? true,
      fines: (json['fines'] as bool?) ?? true,
      promotions: (json['promotions'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'bookings': bookings,
        'fines': fines,
        'promotions': promotions,
      };

  NotificationPreferences copyWith({
    bool? bookings,
    bool? fines,
    bool? promotions,
  }) =>
      NotificationPreferences(
        bookings: bookings ?? this.bookings,
        fines: fines ?? this.fines,
        promotions: promotions ?? this.promotions,
      );
}

class AppUser {
  const AppUser({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    this.avatarUrl,
    this.isVerified = false,
    this.emailVerified = false,
    this.trustLevel = TrustLevel.newUser,
    this.hasDriverLicense = false,
    this.hasIdDocument = false,
    this.roles = const [UserRole.client],
    this.organizationId,
    this.verificationStatus = VerificationStatus.notStarted,
    this.isBlacklisted = false,
    this.blacklistReason,
    this.debtBalance = 0.0,
    this.walletBalance = 0.0,
    this.trustScore = 0,
    this.statistics,
    this.notificationPreferences,
    // Document URLs — 3 fields matching ClientQm (id_back removed)
    this.idDocumentUrl,
    this.licenseFrontUrl,
    this.licenseBackUrl,
  });

  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final String? avatarUrl;

  /// Overall account verified flag (documents reviewed + approved).
  final bool isVerified;

  /// Sourced from ClientQm.email_verified (added by backend 2026-05-23).
  final bool emailVerified;

  final TrustLevel trustLevel;

  /// True when license_front_url + license_back_url are non-empty.
  final bool hasDriverLicense;

  /// True when id_document_url is non-empty.
  final bool hasIdDocument;

  final List<UserRole> roles;
  final String? organizationId;

  /// Document submission / review status for the verification gate.
  final VerificationStatus verificationStatus;

  final bool isBlacklisted;
  final String? blacklistReason;

  /// Backend returns wallet_balance as a decimal string — stored as double.
  final double debtBalance;

  /// Backend returns debt_balance as a decimal string — stored as double.
  final double walletBalance;

  /// Numeric trust score from ClientQm.trust_score.
  final int trustScore;

  /// Document URLs — ClientQm exposes exactly 3 (no id_back).
  final String? idDocumentUrl;
  final String? licenseFrontUrl;
  final String? licenseBackUrl;

  /// Trip statistics shown on the profile header.
  final ClientStatistics? statistics;

  /// Notification toggle preferences.
  final NotificationPreferences? notificationPreferences;

  // Keep isClient; manager role is out of scope per spec §7.
  bool get isClient => roles.contains(UserRole.client);

  /// Whether this user can create new bookings.
  bool get canBook =>
      verificationStatus == VerificationStatus.verified &&
      !isBlacklisted &&
      debtBalance <= 0;

  AppUser copyWith({
    String? fullName,
    String? phone,
    String? email,
    String? avatarUrl,
    bool? isVerified,
    bool? emailVerified,
    TrustLevel? trustLevel,
    bool? hasDriverLicense,
    bool? hasIdDocument,
    List<UserRole>? roles,
    String? organizationId,
    VerificationStatus? verificationStatus,
    bool? isBlacklisted,
    String? blacklistReason,
    double? debtBalance,
    double? walletBalance,
    int? trustScore,
    String? idDocumentUrl,
    String? licenseFrontUrl,
    String? licenseBackUrl,
    ClientStatistics? statistics,
    NotificationPreferences? notificationPreferences,
  }) {
    return AppUser(
      id: id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      emailVerified: emailVerified ?? this.emailVerified,
      trustLevel: trustLevel ?? this.trustLevel,
      hasDriverLicense: hasDriverLicense ?? this.hasDriverLicense,
      hasIdDocument: hasIdDocument ?? this.hasIdDocument,
      roles: roles ?? this.roles,
      organizationId: organizationId ?? this.organizationId,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      isBlacklisted: isBlacklisted ?? this.isBlacklisted,
      blacklistReason: blacklistReason ?? this.blacklistReason,
      debtBalance: debtBalance ?? this.debtBalance,
      walletBalance: walletBalance ?? this.walletBalance,
      trustScore: trustScore ?? this.trustScore,
      idDocumentUrl: idDocumentUrl ?? this.idDocumentUrl,
      licenseFrontUrl: licenseFrontUrl ?? this.licenseFrontUrl,
      licenseBackUrl: licenseBackUrl ?? this.licenseBackUrl,
      statistics: statistics ?? this.statistics,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
    );
  }
}
