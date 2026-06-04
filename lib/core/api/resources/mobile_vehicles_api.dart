import 'package:dio/dio.dart';

import '../../models/car.dart';
import '../api_exception.dart';
import '../error_mapper.dart';

/// Vehicle browsing resource: GET /mobile/vehicles/*
class MobileVehiclesApi {
  MobileVehiclesApi(this._dio);

  final Dio _dio;

  // ---------------------------------------------------------------------------
  // List vehicles with filters + pagination
  // GET /mobile/vehicles/?page=&category=&fuel=&transmission=&min_price=&max_price=&search=
  // ---------------------------------------------------------------------------

  Future<PaginatedResponse<CarListing>> list({
    int page = 1,
    int pageSize = 20,
    String? search,
    Set<VehicleCategory>? categories,
    Set<FuelType>? fuelTypes,
    Set<Transmission>? transmissions,
    int? minPrice,
    int? maxPrice,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (categories != null && categories.isNotEmpty) {
        queryParams['category'] =
            categories.map(vehicleCategoryToString).join(',');
      }
      if (fuelTypes != null && fuelTypes.isNotEmpty) {
        queryParams['fuel'] = fuelTypes.map(fuelTypeToString).join(',');
      }
      if (transmissions != null && transmissions.isNotEmpty) {
        queryParams['transmission'] =
            transmissions.map(transmissionToString).join(',');
      }
      if (minPrice != null) queryParams['min_price'] = minPrice;
      if (maxPrice != null) queryParams['max_price'] = maxPrice;

      final response = await _dio.get<Map<String, dynamic>>(
        '/mobile/vehicles/',
        queryParameters: queryParams,
      );

      final data = response.data ?? {};
      return PaginatedResponse.fromJson(data,
          currentPage: page, pageSize: pageSize);
    } on DioException catch (e) {
      throw mapDioError(e);
    } catch (e) {
      throw UnknownException(serverMessage: e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // Get single vehicle
  // GET /mobile/vehicles/{id}
  // ---------------------------------------------------------------------------

  Future<CarListing> get(String vehicleId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/mobile/vehicles/$vehicleId',
      );
      final data = response.data;
      if (data == null) {
        throw const NotFoundException(serverMessage: 'Vehicle not found');
      }
      return CarListing.fromJson(data);
    } on DioException catch (e) {
      throw mapDioError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(serverMessage: e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // Get availability map for a vehicle and month
  // GET /mobile/vehicles/{id}/availability?month=YYYY-MM
  // Response: { month: "2026-06", days: { "2026-06-01": "available", ... } }
  // ---------------------------------------------------------------------------

  Future<Map<DateTime, DayAvailability>> availability(
    String vehicleId,
    DateTime month,
  ) async {
    final monthStr =
        '${month.year}-${month.month.toString().padLeft(2, '0')}';
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/mobile/vehicles/$vehicleId/availability',
        queryParameters: {'month': monthStr},
      );

      final data = response.data ?? {};
      final daysRaw = data['days'] as Map<String, dynamic>? ?? {};
      final result = <DateTime, DayAvailability>{};

      for (final entry in daysRaw.entries) {
        final date = DateTime.tryParse(entry.key);
        if (date != null) {
          result[DateTime(date.year, date.month, date.day)] =
              dayAvailabilityFromString(entry.value as String? ?? 'available');
        }
      }

      return result;
    } on DioException catch (e) {
      throw mapDioError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(serverMessage: e.toString());
    }
  }
}
