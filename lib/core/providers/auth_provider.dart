import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../api/resources/mobile_auth_api.dart';
import '../api/resources/mobile_clients_api.dart';
import '../api/storage/secure_token_storage.dart';
import '../models/user.dart';
import '../push/push_config.dart';
import '../push/push_service.dart';

// ---------------------------------------------------------------------------
// Auth state sealed class
// ---------------------------------------------------------------------------

sealed class AuthState {
  const AuthState();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthAuthenticating extends AuthState {
  const AuthAuthenticating();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final AppUser user;
}

class AuthError extends AuthState {
  const AuthError(this.message, {this.code});
  final String message;
  final String? code;
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final currentUserProvider =
    StateNotifierProvider<AuthNotifier, AppUser?>((ref) {
  return AuthNotifier(ref);
});

/// Derived sealed-state provider for screens that want typed auth state.
final authStateProvider = Provider<AuthState>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null ? AuthAuthenticated(user) : const AuthUnauthenticated();
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

final themeModeProvider = StateProvider<ThemeMode>((_) => ThemeMode.system);
final localeProvider = StateProvider<Locale?>((_) => null);

// ---------------------------------------------------------------------------
// AuthNotifier
// ---------------------------------------------------------------------------

class AuthNotifier extends StateNotifier<AppUser?> {
  AuthNotifier(this._ref) : super(null);

  final Ref _ref;

  MobileAuthApi get _authApi => _ref.read(mobileAuthApiProvider);
  MobileClientsApi get _clientsApi => _ref.read(mobileClientsApiProvider);
  SecureTokenStorage get _storage => _ref.read(secureTokenStorageProvider);

  // -------------------------------------------------------------------------
  // Bootstrap — call on app start to hydrate from persisted JWT
  // -------------------------------------------------------------------------

  /// Checks SecureTokenStorage for a stored access token. If present,
  /// calls GET /mobile/clients/me. A 401 means the token (and refresh) have
  /// expired — the AuthInterceptor already cleared storage.
  Future<void> bootstrap() async {
    final token = await _storage.accessToken;
    if (token == null) {
      state = null;
      return;
    }
    try {
      final user = await _clientsApi.me();
      state = user;
    } on UnauthorizedException {
      await _clearTokens();
      state = null;
    } on NetworkException {
      // Offline — keep tokens, leave state null. App retries next launch.
      state = null;
    } on ApiException {
      await _clearTokens();
      state = null;
    }
  }

  // -------------------------------------------------------------------------
  // Login
  // -------------------------------------------------------------------------

  /// Returns 'ok' on success, 'unverified' on 403, 'invalid_credentials' on
  /// 401, or an error message string.
  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      final tokens = await _authApi.login(email: email, password: password);
      await _storage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
    } on ForbiddenException {
      return 'unverified';
    } on UnauthorizedException {
      return 'invalid_credentials';
    } on ApiException catch (e) {
      return e.serverMessage ?? e.code;
    }

    // Tokens saved — hydrate the user profile.
    try {
      final user = await _clientsApi.me();
      state = user;
      if (kEnablePush) await _ref.read(pushServiceProvider).register(_ref);
      return 'ok';
    } catch (e) {
      await _clearTokens();
      return 'no_client_profile';
    }
  }

  // -------------------------------------------------------------------------
  // Sign up
  // -------------------------------------------------------------------------

  /// Returns one of:
  ///   - 'ok'                 — 204; user created, code emailed
  ///   - 'email_send_failed'  — 503; user IS created but SMTP failed
  ///   - 'conflict'           — 409 email already registered
  ///   - 'org_required'       — 400 OrganizationIdRequiredError
  ///   - server message string — other ApiException
  Future<String> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    String? organizationId,
  }) async {
    await _clearTokens();
    state = null;
    try {
      await _authApi.signup(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        organizationId: organizationId,
      );
      return 'ok';
    } on ConflictException {
      return 'conflict';
    } on ServerException catch (e) {
      if (e.statusCode == 503) return 'email_send_failed';
      return e.serverMessage ?? 'error';
    } on ApiException catch (e) {
      if (e.code == 'org_required' ||
          (e.serverMessage ?? '').toLowerCase().contains('organization id')) {
        return 'org_required';
      }
      return e.serverMessage ?? 'error';
    }
  }

  // -------------------------------------------------------------------------
  // Email verification
  // -------------------------------------------------------------------------

  /// Returns 'ok', 'invalid', 'already_verified', or 'error'.
  Future<String> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      await _authApi.verifyEmail(email: email, code: code);
      await refreshCurrentUser();
      return 'ok';
    } on ConflictException {
      return 'already_verified';
    } on ValidationException {
      return 'invalid';
    } on ApiException {
      return 'error';
    }
  }

  // -------------------------------------------------------------------------
  // Resend verification
  // -------------------------------------------------------------------------

  /// Returns 'ok', 'rate_limited', 'already_verified', or 'error'.
  Future<String> resendVerification({required String email}) async {
    try {
      await _authApi.resendVerification(email: email);
      return 'ok';
    } on RateLimitedException {
      return 'rate_limited';
    } on ConflictException {
      return 'already_verified';
    } on ApiException {
      return 'error';
    }
  }

  // -------------------------------------------------------------------------
  // Forgot / reset password
  // -------------------------------------------------------------------------

  /// Returns 'ok', 'not_found', 'rate_limited', 'email_send_failed', or 'error'.
  Future<String> forgotPassword({required String email}) async {
    try {
      await _authApi.forgotPassword(email: email);
      return 'ok';
    } on NotFoundException {
      return 'not_found';
    } on RateLimitedException {
      return 'rate_limited';
    } on ServerException catch (e) {
      if (e.statusCode == 503) return 'email_send_failed';
      return 'error';
    } on ApiException {
      return 'error';
    }
  }

  /// Returns 'ok', 'invalid_code', 'weak_password', or 'error'.
  Future<String> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _authApi.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );
      return 'ok';
    } on ValidationException {
      return 'weak_password';
    } on ApiException catch (e) {
      final msg = (e.serverMessage ?? '').toLowerCase();
      if (msg.contains('code') || msg.contains('invalid')) return 'invalid_code';
      return 'error';
    }
  }

  // -------------------------------------------------------------------------
  // Refresh current user
  // -------------------------------------------------------------------------

  Future<void> refreshCurrentUser() async {
    try {
      final user = await _clientsApi.me();
      state = user;
    } on ApiException {
      // Silently fail — stale state is acceptable here.
    }
  }

  // -------------------------------------------------------------------------
  // Profile update (local optimistic)
  // -------------------------------------------------------------------------

  void updateProfile({String? fullName, String? email, String? phone}) {
    if (state == null) return;
    state = state!.copyWith(
      fullName: fullName,
      email: email,
      phone: phone,
    );
  }

  // -------------------------------------------------------------------------
  // Logout
  // -------------------------------------------------------------------------

  Future<void> logout() async {
    if (kEnablePush) await _ref.read(pushServiceProvider).deregister(_ref);
    try {
      await _authApi.logout();
    } catch (_) {
      // Best-effort server logout — always clear local session.
    }
    await _clearTokens();
    state = null;
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  Future<void> _clearTokens() async {
    try {
      await _storage.clearTokens();
    } catch (_) {
      // Ignore storage errors on logout.
    }
  }
}
