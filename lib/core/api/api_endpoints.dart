/// Canonical path constants for all /mobile/* endpoints.
/// Source of truth: AutoFleet FastAPI OpenAPI spec.
/// Base URL: see api_client.dart _baseUrl
class ApiEndpoints {
  ApiEndpoints._();

  // Auth — /account/
  static const String login = '/account/login/';
  static const String signup = '/account/signup/';
  static const String logout = '/account/logout/';
  static const String verifyEmail = '/account/verify-email/';
  static const String resendVerification = '/account/resend-verification/';

  /// PUT /account/password/ — logged-in change-password only.
  /// Body: { current_password, new_password }
  static const String changePassword = '/account/password/';

  /// POST /account/forgot-password/ — Body: { email }
  static const String forgotPassword = '/account/forgot-password/';

  /// POST /account/reset-password/ — Body: { email, code, new_password }
  static const String resetPassword = '/account/reset-password/';

  /// POST /account/refresh/ — Body: { refresh_token }
  static const String refreshToken = '/account/refresh/';

  // Client profile — /mobile/clients/me (no trailing slash per OpenAPI)
  static const String clientMe = '/mobile/clients/me';
  static const String clientDocuments = '/mobile/clients/me/documents';
  static const String clientVerification = '/mobile/clients/me/verification';
  static const String clientFines = '/mobile/clients/me/fines';
  static const String clientPayments = '/mobile/clients/me/payments';
  static const String clientOutstanding = '/mobile/clients/me/outstanding';
  static const String clientNotificationPrefs =
      '/mobile/clients/me/notification-preferences';

  // Vehicles — /mobile/vehicles (no trailing slash per OpenAPI)
  static const String vehicles = '/mobile/vehicles';
  static String vehicleById(String id) => '/mobile/vehicles/$id';
  static String vehicleAvailability(String id) =>
      '/mobile/vehicles/$id/availability';

  // Rentals — /mobile/rentals (no trailing slash per OpenAPI)
  static const String rentals = '/mobile/rentals';
  static String rentalById(String id) => '/mobile/rentals/$id';
  static const String activeRental = '/mobile/rentals/active';
  static String cancelRental(String id) => '/mobile/rentals/$id/cancel';

  /// POST /mobile/rentals/{rental_id}/extend-request (fixed by backend 2026-05-23)
  static String extendRentalRequest(String id) =>
      '/mobile/rentals/$id/extend-request';

  // Payments — /mobile/payments/
  static const String recordPayment = '/mobile/payments/record';

  // Notifications — /mobile/notifications/
  static const String notifications = '/mobile/notifications/';
  static String readNotification(String id) =>
      '/mobile/notifications/$id/read';

  // Devices — /mobile/devices/
  static const String deviceRegister = '/mobile/devices/register';
  static String deviceToken(String token) => '/mobile/devices/$token';
}
