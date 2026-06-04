import 'package:flutter/foundation.dart';

import 'observability_config.dart';

/// Analytics interface — stubbed for pre-Firebase provisioning.
///
/// When [kEnableAnalytics] = true and `firebase_analytics` is added to
/// pubspec.yaml, replace the stub body with:
///   FirebaseAnalytics.instance.logEvent(name: event, parameters: params);
class Analytics {
  Analytics._();

  static final Analytics instance = Analytics._();

  /// Track a named event with optional parameters.
  ///
  /// All event names are defined as constants below to prevent typos.
  void track(String event, {Map<String, dynamic>? params}) {
    if (!kEnableAnalytics) return;
    // TODO: FirebaseAnalytics.instance.logEvent(name: event, parameters: params);
    debugPrint('[Analytics] $event ${params ?? ''}');
  }
}

// ---------------------------------------------------------------------------
// Event name constants — prevents string typos across call sites
// ---------------------------------------------------------------------------

/// Auth / onboarding events
const String kEvtSignupStarted = 'signup_started';
const String kEvtSignupCompleted = 'signup_completed';
const String kEvtEmailVerificationSubmitted = 'email_verification_submitted';
const String kEvtEmailVerificationSucceeded = 'email_verification_succeeded';
const String kEvtDocumentsSubmitted = 'documents_submitted';
const String kEvtVerificationStatusChanged = 'verification_status_changed';

/// Booking / rental events
const String kEvtBookingRequested = 'booking_requested';
const String kEvtBookingCancelled = 'booking_cancelled';
const String kEvtRentalStarted = 'rental_started';
const String kEvtRentalCompleted = 'rental_completed';
const String kEvtExtensionRequested = 'extension_requested';

/// Payment events
const String kEvtPaymentRecorded = 'payment_recorded';

/// Notification events
const String kEvtNotificationOpened = 'notification_opened';
