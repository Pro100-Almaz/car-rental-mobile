import 'package:dio/dio.dart';

import '../api_endpoints.dart';
import '../error_mapper.dart';

// AuthTokens DTO has been removed — login returns 204 No Content + cookie.
// No /account/refresh/ endpoint exists in the FastAPI backend v1.

/// Auth endpoints: /account/*
class MobileAuthApi {
  const MobileAuthApi(this._dio);
  final Dio _dio;

  // -------------------------------------------------------------------------
  // Login — 204 No Content + Set-Cookie: auth_token=...
  // -------------------------------------------------------------------------

  /// POST /account/login/
  /// Request:  { email, password }
  /// Response: 204 No Content — cookie set automatically by CookieManager.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  // -------------------------------------------------------------------------
  // Sign up — 204 on success
  // -------------------------------------------------------------------------

  /// POST /account/signup/
  /// Required: email, password, first_name, last_name
  /// Optional: phone, organization_id, invite_token, role
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
  /// Logged-in change-password. Body: { current_password, new_password }
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
  // Forgot password (added by backend 2026-05-23)
  // -------------------------------------------------------------------------

  /// POST /account/forgot-password/ — Body: { email }
  /// Sends a reset code to the user's email.
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

  /// DELETE /account/logout/ — clears the auth_token cookie server-side.
  Future<void> logout() async {
    try {
      await _dio.delete(ApiEndpoints.logout);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
