import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../api/resources/mobile_auth_api.dart';
import '../api/resources/mobile_clients_api.dart';
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

  // -------------------------------------------------------------------------
  // Bootstrap — call on app start to hydrate from persisted cookie
  // -------------------------------------------------------------------------

  /// Calls GET /mobile/clients/me. If cookies are valid the server returns the
  /// user. A 401 means the cookie has expired — clear cookie jar and emit null.
  Future<void> bootstrap() async {
    // Wait for the cookie jar to be ready before attempting the auth check.
    await _ref.read(cookieJarProvider.future);
    try {
      final user = await _clientsApi.me();
      state = user;
    } on UnauthorizedException {
      await _clearCookies();
      state = null;
    } on NetworkException {
      // Offline — keep cookies, leave state null. App will retry next launch.
      state = null;
    } on ApiException {
      // Server responded with 5xx/4xx (e.g., 500 "no client profile" for an
      // admin/seed account). Clear cookies so the user can re-auth as a client.
      await _clearCookies();
      state = null;
    }
  }

  // -------------------------------------------------------------------------
  // Login
  // -------------------------------------------------------------------------

  /// Returns 'ok' on success, 'unverified' on 403, 'invalid_credentials' on
  /// 401, or an error message string.
  ///
  /// Cookie auth flow:
  ///   1. POST /account/login/ → 204 + Set-Cookie: auth_token=...
  ///      CookieManager persists the cookie automatically.
  ///   2. GET /mobile/clients/me → hydrates AppUser.
  ///   3. Login success implies email is verified (backend rejects unverified
  ///      accounts — Option A per contract discovery 2026-05-23).
  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      await _authApi.login(email: email, password: password);
    } on ForbiddenException {
      // Backend may 403 on unverified email — send user to verify-email screen.
      return 'unverified';
    } on UnauthorizedException {
      return 'invalid_credentials';
    } on ApiException catch (e) {
      return e.serverMessage ?? e.code;
    }
    // Login succeeded — the auth_token cookie is set. Hydrate the user.
    // If hydration fails, the account exists but has no client profile (admin /
    // seed accounts). Clear the cookie so subsequent bootstraps don't loop.
    try {
      final user = await _clientsApi.me();
      state = user;
      if (kEnablePush) await _ref.read(pushServiceProvider).register(_ref);
      return 'ok';
    } catch (e) {
      final jar = await _ref.read(cookieJarProvider.future);
      await jar.deleteAll();
      return 'no_client_profile';
    }
  }

  // -------------------------------------------------------------------------
  // Sign up
  // -------------------------------------------------------------------------

  /// Returns one of:
  ///   - 'ok'                 — 204; user created, code emailed
  ///   - 'email_send_failed'  — 503 EmailSendError; user IS created but SMTP
  ///                            failed. UI should still push /verify-email and
  ///                            offer Resend.
  ///   - 'conflict'           — 409 email already registered
  ///   - 'org_required'       — 400 OrganizationIdRequiredError
  ///   - server message string — other ApiException
  /// Does NOT auto-login — user must verify email first.
  Future<String> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    String? organizationId,
  }) async {
    // Backend rejects signup with 403 if the caller is already authenticated.
    // Clear any lingering cookies before proceeding.
    await _clearCookies();
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
      // Backend B1 (signup 500) is fixed. SMTP failures now return 503
      // EmailSendError — the account is created but the verification email
      // could not be delivered. Surface as 'email_send_failed' so the UI can
      // still push to /verify-email and offer Resend.
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
      // After verification the user needs to login — refreshCurrentUser
      // will succeed only if a session cookie exists.
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
  // Forgot / reset password (backend endpoints added 2026-05-23)
  // -------------------------------------------------------------------------

  /// POST /account/forgot-password/ — Body: { email }
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

  /// POST /account/reset-password/ — Body: { email, code, new_password }
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
    await _clearCookies();
    state = null;
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  Future<void> _clearCookies() async {
    try {
      final jar = _ref.read(resolvedCookieJarProvider);
      await jar?.deleteAll();
    } catch (_) {
      // Ignore cookie-jar errors on logout.
    }
  }
}
