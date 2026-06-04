import 'package:dio/dio.dart';

import 'api_exception.dart';

/// Converts a raw [DioException] into a typed [ApiException].
ApiException mapDioError(DioException e) {
  // Connection / timeout errors
  if (e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout) {
    return const NetworkException();
  }

  final response = e.response;
  if (response == null) {
    return NetworkException(serverMessage: e.message);
  }

  final status = response.statusCode ?? 0;
  final body = response.data;
  final serverMsg = _extractMessage(body);
  final fieldErrors = _extractFieldErrors(body);

  return switch (status) {
    401 => UnauthorizedException(serverMessage: serverMsg),
    403 => ForbiddenException(serverMessage: serverMsg),
    404 => NotFoundException(serverMessage: serverMsg),
    409 => ConflictException(serverMessage: serverMsg),
    422 => ValidationException(
        statusCode: 422,
        serverMessage: serverMsg,
        fieldErrors: fieldErrors,
      ),
    400 => ValidationException(
        serverMessage: serverMsg,
        fieldErrors: fieldErrors,
      ),
    429 => RateLimitedException(serverMessage: serverMsg),
    >= 500 => ServerException(statusCode: status, serverMessage: serverMsg),
    _ => UnknownException(serverMessage: serverMsg),
  };
}

/// Extracts a human-readable message from FastAPI error envelopes:
///   SimpleErrorResponseModel: { "error": "string" }
///   HTTPValidationError:      { "detail": [...] }
///   Legacy DRF:               { "detail": "string" } or { "message": "..." }
String? _extractMessage(dynamic body) {
  if (body is! Map) return null;

  // FastAPI SimpleErrorResponseModel: { "error": "string" }
  if (body['error'] is String) return body['error'] as String;

  // HTTPValidationError: { "detail": [...] } — join first few messages
  if (body['detail'] is List) {
    final detail = (body['detail'] as List).whereType<Map>();
    final msgs = detail
        .map((e) => e['msg']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .take(2)
        .join('; ');
    return msgs.isNotEmpty ? msgs : null;
  }

  // Legacy DRF / fallback
  if (body['detail'] is String) return body['detail'] as String;
  if (body['message'] is String) return body['message'] as String;
  final nfe = body['non_field_errors'];
  if (nfe is List && nfe.isNotEmpty) return nfe.first.toString();

  return null;
}

/// Extracts per-field errors from:
///   HTTPValidationError: { "detail": [{ "loc": [..., "field"], "msg": "..." }] }
///   Legacy DRF field errors: { "field": ["msg"] }
Map<String, List<String>> _extractFieldErrors(dynamic body) {
  if (body is! Map) return const {};
  final result = <String, List<String>>{};

  // HTTPValidationError (422)
  if (body['detail'] is List) {
    for (final e in (body['detail'] as List).whereType<Map>()) {
      final loc = e['loc'];
      final fieldName =
          (loc is List && loc.isNotEmpty ? loc.last : '_')?.toString() ?? '_';
      final msg = e['msg']?.toString() ?? '';
      result.putIfAbsent(fieldName, () => []).add(msg);
    }
    return result;
  }

  // Legacy field map
  for (final entry in body.entries) {
    final key = entry.key.toString();
    if (key == 'detail' || key == 'non_field_errors' ||
        key == 'error' || key == 'message') {
      continue;
    }
    final value = entry.value;
    if (value is List) {
      result[key] = value.map((e) => e.toString()).toList();
    } else if (value is String) {
      result[key] = [value];
    }
  }
  return result;
}
