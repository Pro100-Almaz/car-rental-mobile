import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'resources/mobile_auth_api.dart';
import 'resources/mobile_clients_api.dart';
import 'resources/mobile_devices_api.dart';
import 'resources/mobile_notifications_api.dart';
import 'resources/mobile_payments_api.dart';
import 'resources/mobile_rentals_api.dart';
import 'resources/mobile_vehicles_api.dart';

const _baseUrl = 'http://127.0.0.1:8000/api/v1';

// ---------------------------------------------------------------------------
// Cookie jar — persists auth_token across app launches
// ---------------------------------------------------------------------------

/// Async provider that resolves a [PersistCookieJar] backed by the app's
/// documents directory. Cookies (including auth_token) survive app restarts.
final cookieJarProvider = FutureProvider<PersistCookieJar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  final cookiePath = '${dir.path}/.cookies/';
  return PersistCookieJar(
    storage: FileStorage(cookiePath),
    ignoreExpires: false,
  );
});

// ---------------------------------------------------------------------------
// Dio singleton — cookie-based auth, no Bearer interceptor
// ---------------------------------------------------------------------------

final dioProvider = Provider<Dio>((ref) {
  final cookieJarAsync = ref.watch(cookieJarProvider);

  final dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json'},
    // Follow FastAPI's strict-slashes 307 redirects automatically.
    followRedirects: true,
    maxRedirects: 3,
  ));

  // Attach cookie jar when it's available. Falls back gracefully (no cookies)
  // on the very first frame before the future resolves — bootstrap() handles
  // the auth check after the jar is ready.
  cookieJarAsync.whenData((jar) {
    dio.interceptors.add(CookieManager(jar));
  });

  if (kDebugMode) {
    dio.interceptors.add(LoggingInterceptor());
  }

  return dio;
});

/// Provides the resolved cookie jar for operations like deleteAll() on logout.
/// Callers must handle the loading/error states (typically via AsyncValue).
final resolvedCookieJarProvider = Provider<PersistCookieJar?>((ref) {
  return ref.watch(cookieJarProvider).valueOrNull;
});

// ---------------------------------------------------------------------------
// Per-resource providers
// ---------------------------------------------------------------------------

final mobileAuthApiProvider = Provider<MobileAuthApi>((ref) {
  return MobileAuthApi(ref.watch(dioProvider));
});

final mobileClientsApiProvider = Provider<MobileClientsApi>((ref) {
  return MobileClientsApi(ref.watch(dioProvider));
});

final mobileVehiclesApiProvider = Provider<MobileVehiclesApi>((ref) {
  return MobileVehiclesApi(ref.watch(dioProvider));
});

final mobileRentalsApiProvider = Provider<MobileRentalsApi>((ref) {
  return MobileRentalsApi(ref.watch(dioProvider));
});

final mobilePaymentsApiProvider = Provider<MobilePaymentsApi>((ref) {
  return MobilePaymentsApi(ref.watch(dioProvider));
});

final mobileNotificationsApiProvider = Provider<MobileNotificationsApi>((ref) {
  return MobileNotificationsApi(ref.watch(dioProvider));
});

final mobileDevicesApiProvider = Provider<MobileDevicesApi>((ref) {
  return MobileDevicesApi(ref.watch(dioProvider));
});

// ---------------------------------------------------------------------------
// Legacy ApiClient — thin wrapper kept so any remaining callsites compile.
// New code should use per-resource providers directly.
// ---------------------------------------------------------------------------

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});

class ApiClient {
  ApiClient(this._dio);
  final Dio _dio;

  Future<Response<dynamic>> login({
    required String email,
    required String password,
  }) =>
      _dio.post('/account/login/', data: {
        'email': email,
        'password': password,
      });

  Future<Response<dynamic>> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    String? organizationId,
  }) {
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
    return _dio.post('/account/signup/', data: data);
  }

  Future<Response<dynamic>> logout() => _dio.delete('/account/logout/');

  Future<Response<dynamic>> verifyEmail({
    required String email,
    required String code,
  }) =>
      _dio.post('/account/verify-email/', data: {
        'email': email,
        'code': code,
      });

  Future<Response<dynamic>> resendVerification({required String email}) =>
      _dio.post('/account/resend-verification/', data: {'email': email});

  // Expose logoutControllerProvider so auth_provider can still listen.
  static final logoutStream = logoutControllerProvider;
}
