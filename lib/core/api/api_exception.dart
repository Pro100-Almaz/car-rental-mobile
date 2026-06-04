/// Typed exception hierarchy for the API layer.
/// Screens interact with these types — never with raw DioException.
sealed class ApiException implements Exception {
  const ApiException({required this.code, this.serverMessage});

  /// Machine-readable code:
  /// network_offline, unauthorized, forbidden, not_found, conflict,
  /// validation, rate_limited, server, unknown
  final String code;
  final String? serverMessage;

  @override
  String toString() => 'ApiException($code): $serverMessage';
}

/// Device has no connectivity or request timed out.
class NetworkException extends ApiException {
  const NetworkException({super.serverMessage})
      : super(code: 'network_offline');
}

/// HTTP 401 — cookie expired or missing.
class UnauthorizedException extends ApiException {
  const UnauthorizedException({super.serverMessage})
      : super(code: 'unauthorized');
}

/// HTTP 403 — authenticated but not permitted (e.g. email not verified).
class ForbiddenException extends ApiException {
  const ForbiddenException({super.serverMessage})
      : super(code: 'forbidden');
}

/// HTTP 404 — resource not found.
class NotFoundException extends ApiException {
  const NotFoundException({super.serverMessage})
      : super(code: 'not_found');
}

/// HTTP 409 — conflict (e.g. email already registered).
class ConflictException extends ApiException {
  const ConflictException({super.serverMessage})
      : super(code: 'conflict');
}

/// HTTP 422 / 400 — validation error.
/// [fieldErrors]: keys are field names; values are lists of error messages.
/// [statusCode]: raw HTTP status (400 or 422) for callers that need to distinguish.
class ValidationException extends ApiException {
  const ValidationException({
    super.serverMessage,
    this.fieldErrors = const {},
    this.statusCode,
  }) : super(code: 'validation');

  final Map<String, List<String>> fieldErrors;

  /// Raw HTTP status code — 400 or 422.
  final int? statusCode;
}

/// HTTP 429 — too many requests.
class RateLimitedException extends ApiException {
  const RateLimitedException({super.serverMessage})
      : super(code: 'rate_limited');
}

/// HTTP 5xx — server error.
class ServerException extends ApiException {
  const ServerException({super.serverMessage, this.statusCode})
      : super(code: 'server');
  final int? statusCode;
}

/// Catch-all for unexpected errors.
class UnknownException extends ApiException {
  const UnknownException({super.serverMessage})
      : super(code: 'unknown');
}
