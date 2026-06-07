import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'resources/mobile_auth_api.dart';
import 'resources/mobile_clients_api.dart';
import 'resources/mobile_devices_api.dart';
import 'resources/mobile_notifications_api.dart';
import 'resources/mobile_payments_api.dart';
import 'resources/mobile_rentals_api.dart';
import 'resources/mobile_vehicles_api.dart';
import 'storage/secure_token_storage.dart';

const _baseUrl = 'https://e762-85-159-25-41.ngrok-free.app/api/v1';

// ---------------------------------------------------------------------------
// Dio singleton — JWT Bearer auth
// ---------------------------------------------------------------------------

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureTokenStorageProvider);
  final logoutController = ref.watch(logoutControllerProvider);

  final dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Content-Type': 'application/json',
      // Skip ngrok browser-warning interstitial in dev builds.
      if (kDebugMode) 'ngrok-skip-browser-warning': 'true',
    },
    followRedirects: true,
    maxRedirects: 3,
  ));

  dio.interceptors.add(
    AuthInterceptor(
      storage: storage,
      dio: dio,
      logoutController: logoutController,
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(LoggingInterceptor());
  }

  return dio;
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
// Legacy ApiClient — kept so any remaining callsites compile.
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

  Future<Response<dynamic>> logout() => _dio.post('/account/logout/');

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

  static final logoutStream = logoutControllerProvider;
}
