// ignore_for_file: deprecated_member_use_from_same_package
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kAccessToken = 'access_token';
const _kRefreshToken = 'refresh_token';

@Deprecated(
  'JWT token storage is no longer used. '
  'Auth is cookie-based (auth_token cookie set by FastAPI). '
  'This class is kept only as a reference stub. Do not use in new code.',
)
final secureTokenStorageProvider = Provider<SecureTokenStorage>((_) {
  return SecureTokenStorage(const FlutterSecureStorage());
});

/// @Deprecated — JWT access + refresh token storage.
/// Cookie-based auth replaced this in the FastAPI pivot (2026-05-23).
/// Retained so IDEs show the deprecation rather than a missing-symbol error
/// during any lingering callsites that have not yet been cleaned up.
@Deprecated(
  'Use cookie-based auth via CookieManager/PersistCookieJar instead.',
)
class SecureTokenStorage {
  const SecureTokenStorage(this._storage);
  final FlutterSecureStorage _storage;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _kAccessToken, value: accessToken),
      _storage.write(key: _kRefreshToken, value: refreshToken),
    ]);
  }

  Future<String?> get accessToken => _storage.read(key: _kAccessToken);
  Future<String?> get refreshToken => _storage.read(key: _kRefreshToken);

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _kAccessToken, value: token);

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _kAccessToken),
      _storage.delete(key: _kRefreshToken),
    ]);
  }
}
