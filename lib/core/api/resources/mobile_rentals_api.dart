import 'package:dio/dio.dart';

import '../../models/booking.dart';
import '../api_exception.dart';
import '../error_mapper.dart';

/// Rental resource: /mobile/rentals/*
class MobileRentalsApi {
  MobileRentalsApi(this._dio);

  final Dio _dio;

  // ---------------------------------------------------------------------------
  // List rentals — GET /mobile/rentals/?status=<optional>
  // Response: array of Booking objects (or paginated envelope)
  // ---------------------------------------------------------------------------

  Future<List<Booking>> list({BookingStatus? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) {
        queryParams['status'] = bookingStatusToString(status);
      }

      final response = await _dio.get<dynamic>(
        '/mobile/rentals/',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final data = response.data;
      // Defensive: handle both paginated { results: [...] } and raw array
      List<dynamic> items;
      if (data is List) {
        items = data;
      } else if (data is Map && data['results'] is List) {
        items = data['results'] as List<dynamic>;
      } else {
        items = const [];
      }

      return items
          .whereType<Map<String, dynamic>>()
          .map(Booking.fromJson)
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(serverMessage: e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // Get single rental — GET /mobile/rentals/{id}
  // ---------------------------------------------------------------------------

  Future<Booking> get(String rentalId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/mobile/rentals/$rentalId',
      );
      final data = response.data;
      if (data == null) {
        throw const UnknownException(serverMessage: 'Empty response from server');
      }
      return Booking.fromJson(data);
    } on DioException catch (e) {
      throw mapDioError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(serverMessage: e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // Get active rental — GET /mobile/rentals/active
  // 404 → returns null (no active rental)
  // 200 → returns Booking
  // ---------------------------------------------------------------------------

  Future<Booking?> active() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/mobile/rentals/active',
      );
      final data = response.data;
      if (data == null) return null;
      return Booking.fromJson(data);
    } on DioException catch (e) {
      final mapped = mapDioError(e);
      if (mapped is NotFoundException) return null;
      throw mapped;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(serverMessage: e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // Cancel rental — POST /mobile/rentals/{id}/cancel
  // Body: { "reason": "..." }
  // Only valid for pending and confirmed statuses.
  // ---------------------------------------------------------------------------

  Future<void> cancel(String rentalId, {required String reason}) async {
    try {
      await _dio.post<dynamic>(
        '/mobile/rentals/$rentalId/cancel',
        data: {'reason': reason},
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(serverMessage: e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // Extend request — POST /mobile/rentals/{id}/extend-request
  // Body: { "new_end_date": "2026-06-10T10:00:00Z" }
  // ---------------------------------------------------------------------------

  Future<void> extendRequest(
    String rentalId, {
    required DateTime newEndDate,
  }) async {
    try {
      await _dio.post<dynamic>(
        '/mobile/rentals/$rentalId/extend-request',
        data: {'new_end_date': newEndDate.toUtc().toIso8601String()},
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(serverMessage: e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // Create rental — POST /mobile/rentals/
  // Request: { vehicle_id, scheduled_start, scheduled_end,
  //            additional_services[], pickup_notes }
  // Response: Rental (status=pending)
  // ---------------------------------------------------------------------------

  Future<BookingResponse> create({
    required String vehicleId,
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
    required List<String> additionalServiceIds,
    String? pickupNotes,
  }) async {
    try {
      final body = <String, dynamic>{
        'vehicle_id': vehicleId,
        'scheduled_start': scheduledStart.toUtc().toIso8601String(),
        'scheduled_end': scheduledEnd.toUtc().toIso8601String(),
        'additional_services': additionalServiceIds,
        if (pickupNotes != null && pickupNotes.isNotEmpty)
          'pickup_notes': pickupNotes,
      };

      final response = await _dio.post<Map<String, dynamic>>(
        '/mobile/rentals/',
        data: body,
      );

      final data = response.data;
      if (data == null) {
        throw const UnknownException(
            serverMessage: 'Empty response from server');
      }
      return BookingResponse.fromJson(data);
    } on DioException catch (e) {
      throw mapDioError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(serverMessage: e.toString());
    }
  }
}
