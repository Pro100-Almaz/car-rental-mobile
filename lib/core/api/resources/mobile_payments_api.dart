import 'package:dio/dio.dart';

import '../../models/payment_record.dart';
import '../api_endpoints.dart';
import '../error_mapper.dart';

/// Payment recording resource: POST /mobile/payments/record
class MobilePaymentsApi {
  const MobilePaymentsApi(this._dio);
  final Dio _dio;

  /// POST /mobile/payments/record
  ///
  /// One of [rentalId] or [fineId] is required.
  /// Returns the created [PaymentRecord] with status: pending.
  Future<PaymentRecord> record({
    String? rentalId,
    String? fineId,
    required int amount,
    required PaymentMethodType method,
    String? note,
  }) async {
    assert(rentalId != null || fineId != null,
        'Either rentalId or fineId must be provided');

    try {
      final body = <String, dynamic>{
        'amount': amount,
        'method': paymentMethodToWire(method),
      };
      if (rentalId != null) body['rental_id'] = rentalId;
      if (fineId != null) body['fine_id'] = fineId;
      if (note != null && note.isNotEmpty) body['note'] = note;

      final response =
          await _dio.post(ApiEndpoints.recordPayment, data: body);
      return PaymentRecord.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
