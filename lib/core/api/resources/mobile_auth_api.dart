import 'package:dio/dio.dart';

import '../api_endpoints.dart';
import '../error_mapper.dart';

// ---------------------------------------------------------------------------
// AuthTokens DTO — returned by login and refresh endpoints.
// ---------------------------------------------------------------------------

class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.refreshExpiresIn,
  });

  final String accessToken;
  final String refreshToken;

  /// Seconds until access token expires.
  final int expiresIn;

  /// Seconds until refresh token expires.
  final int refreshExpiresIn;

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn: (json['expires_in'] as num).toInt(),
      refreshExpiresIn: (json['refresh_expires_in'] as num).toInt(),
    );
  }
}

// ---------------------------------------------------------------------------
// Auth API resource: /account/*
// ---------------------------------------------------------------------------

class MobileAuthApi {
  const MobileAuthApi(this._dio);
  final Dio _dio;

  // -------------------------------------------------------------------------
  // Login — 200 + { access_token, refresh_token, ... }
  // -------------------------------------------------------------------------

  /// POST /account/login/
  /// Request:  { email, password }
  /// Response: 200 AuthTokens
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      return AuthTokens.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  // -------------------------------------------------------------------------
  // Refresh — 200 + { access_token, refresh_token, ... }
  // -------------------------------------------------------------------------

  /// POST /account/refresh/
  /// Request:  { refresh_token }
  /// Response: 200 AuthTokens
  Future<AuthTokens> refreshToken({required String refreshToken}) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
      );
      return AuthTokens.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  // -------------------------------------------------------------------------
  // Sign up — 204 on success
  // -------------------------------------------------------------------------

  /// POST /account/signup/
  /// Required: email, password, first_name, last_name
  /// Optional: phone, organization_id
  /// Response: 204 No Content
  Future<void> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    String? organizationId,
  }) async {
    try {
      final data = <String, dynamic>{
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
      };
      if (phone != null && phone.isNotEmpty) data['phone'] = phone;
      if (organizationId != null && organizationId.isNotEmpty) {
        data['organization_id'] = organizationId;
      }
      await _dio.post(ApiEndpoints.signup, data: data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  // -------------------------------------------------------------------------
  // Email verification
  // -------------------------------------------------------------------------

  /// POST /account/verify-email/
  /// Request:  { email, code }
  /// Response: 204 No Content
  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.verifyEmail,
        data: {'email': email, 'code': code},
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// POST /account/resend-verification/
  /// Request:  { email }
  /// Response: 204 / 429
  Future<void> resendVerification({required String email}) async {
    try {
      await _dio.post(
        ApiEndpoints.resendVerification,
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  // -------------------------------------------------------------------------
  // Change password (logged-in users only)
  // -------------------------------------------------------------------------

  /// PUT /account/password/
  /// Body: { current_password, new_password }
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.put(
        ApiEndpoints.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  // -------------------------------------------------------------------------
  // Forgot / reset password
  // -------------------------------------------------------------------------

  /// POST /account/forgot-password/ — Body: { email }
  Future<void> forgotPassword({required String email}) async {
    try {
      await _dio.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// POST /account/reset-password/ — Body: { email, code, new_password }
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.resetPassword,
        data: {
          'email': email,
          'code': code,
          'new_password': newPassword,
        },
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  // -------------------------------------------------------------------------
  // Logout
  // -------------------------------------------------------------------------

  /// POST /account/logout/
  Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoints.logout);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
