import 'package:dio/dio.dart';

import '../../models/device.dart';
import '../api_endpoints.dart';
import '../error_mapper.dart';

/// Device token registration: /mobile/devices/
class MobileDevicesApi {
  const MobileDevicesApi(this._dio);
  final Dio _dio;

  /// POST /mobile/devices/register
  Future<void> register({
    required String token,
    required DevicePlatform platform,
  }) async {
    try {
      await _dio.post(
        '/mobile/devices/register',
        data: {
          'token': token,
          'platform': devicePlatformToWire(platform),
        },
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// DELETE /mobile/devices/{token}
  Future<void> unregister(String token) async {
    try {
      await _dio.delete(ApiEndpoints.deviceToken(token));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
