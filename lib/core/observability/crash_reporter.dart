import 'package:flutter/foundation.dart';

import 'observability_config.dart';

/// Crash reporting interface — stubbed for pre-Firebase provisioning.
///
/// When [kEnableCrashlytics] = true and `firebase_crashlytics` is added to
/// pubspec.yaml, replace the stub body of each method with:
///   FirebaseCrashlytics.instance.recordError(error, stack, fatal: fatal);
///   FirebaseCrashlytics.instance.setUserIdentifier(userId);
class CrashReporter {
  CrashReporter._();

  static final CrashReporter instance = CrashReporter._();

  /// Call once in main() after Firebase.initializeApp().
  Future<void> init() async {
    if (!kEnableCrashlytics) return;
    // TODO: FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  }

  /// Record a Dart/Flutter framework error (from FlutterError.onError).
  void recordFlutterError(FlutterErrorDetails details) {
    if (!kEnableCrashlytics) return;
    // TODO: FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    debugPrint('[CrashReporter] Flutter error: ${details.exceptionAsString()}');
  }

  /// Record an arbitrary error with stack trace.
  void recordError(Object error, StackTrace? stack, {bool fatal = false}) {
    if (!kEnableCrashlytics) return;
    // TODO: FirebaseCrashlytics.instance.recordError(error, stack, fatal: fatal);
    debugPrint('[CrashReporter] Error: $error');
  }

  /// Associate subsequent reports with the authenticated user.
  void setUserContext(String userId) {
    if (!kEnableCrashlytics) return;
    // TODO: FirebaseCrashlytics.instance.setUserIdentifier(userId);
  }
}
