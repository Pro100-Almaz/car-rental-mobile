class AppUser {
  const AppUser({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    this.avatarUrl,
    this.isVerified = false,
    this.trustLevel = TrustLevel.newUser,
    this.hasDriverLicense = false,
    this.hasIdDocument = false,
  });

  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final String? avatarUrl;
  final bool isVerified;
  final TrustLevel trustLevel;
  final bool hasDriverLicense;
  final bool hasIdDocument;

  AppUser copyWith({
    String? fullName,
    String? phone,
    String? email,
    String? avatarUrl,
    bool? isVerified,
    TrustLevel? trustLevel,
    bool? hasDriverLicense,
    bool? hasIdDocument,
  }) {
    return AppUser(
      id: id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      trustLevel: trustLevel ?? this.trustLevel,
      hasDriverLicense: hasDriverLicense ?? this.hasDriverLicense,
      hasIdDocument: hasIdDocument ?? this.hasIdDocument,
    );
  }
}

enum TrustLevel { newUser, verified, trusted, vip }

String trustLevelLabel(TrustLevel level) => switch (level) {
  TrustLevel.newUser => 'New',
  TrustLevel.verified => 'Verified',
  TrustLevel.trusted => 'Trusted',
  TrustLevel.vip => 'VIP',
};
