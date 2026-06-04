import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../models/device.dart';
import 'push_config.dart';

/// Singleton push-notification service.
///
/// All methods are guarded by [kEnablePush].  When the flag is false every
/// method returns immediately so the app runs without Firebase configured.
///
/// Wiring points:
/// - [main.dart]          : `if (kEnablePush) await PushService.instance.init();`
/// - [auth_provider.dart] : after login  → `pushServiceProvider.register(...)`
/// - [auth_provider.dart] : before logout → `pushServiceProvider.deregister()`
class PushService {
  PushService._();

  static final PushService instance = PushService._();

  String? _token;

  /// Initialise Firebase + request permissions.
  ///
  /// Must be called from [main()] before [runApp].
  /// No-op when [kEnablePush] is false.
  Future<void> init() async {
    if (!kEnablePush) return;

    // -----------------------------------------------------------------------
    // FCM initialisation — requires:
    //   android/app/google-services.json
    //   ios/Runner/GoogleService-Info.plist
    //   APNs certificate in Firebase project
    //
    // Uncomment after backend team provisions Firebase:
    // -----------------------------------------------------------------------
    //
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );
    //
    // final messaging = FirebaseMessaging.instance;
    // await messaging.requestPermission(alert: true, badge: true, sound: true);
    //
    // if (Platform.isIOS) {
    //   await messaging.getAPNSToken();
    // }
    // _token = await messaging.getToken();
    //
    // FirebaseMessaging.onMessage.listen(_handleForeground);
    // FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);
    // -----------------------------------------------------------------------
  }

  /// Returns the current FCM token (null when push is disabled).
  Future<String?> currentToken() async {
    if (!kEnablePush) return null;
    return _token;
  }

  /// Called after successful login.  Registers the FCM token with the backend.
  Future<void> register(Ref ref) async {
    if (!kEnablePush) return;
    final token = await currentToken();
    if (token == null) return;
    try {
      await ref.read(mobileDevicesApiProvider).register(
            token: token,
            platform: Platform.isIOS ? DevicePlatform.ios : DevicePlatform.android,
          );
    } catch (_) {
      // Best-effort — push registration failure must not block login.
    }
  }

  /// Called before logout.  Unregisters the FCM token from the backend.
  Future<void> deregister(Ref ref) async {
    if (!kEnablePush) return;
    final token = _token;
    if (token == null) return;
    try {
      await ref.read(mobileDevicesApiProvider).unregister(token);
    } catch (_) {
      // Best-effort.
    }
  }

  // Foreground push handler — shows in-app banner overlay.
  // ignore: unused_element
  void _handleForeground(dynamic message) {
    // TODO(FCM): parse RemoteMessage → AppNotification, show InAppBanner
  }

  // Background-tap handler — routes to the correct screen.
  // ignore: unused_element
  void _handleTap(dynamic message) {
    // TODO(FCM): parse RemoteMessage → AppNotification, call routeNotification
  }
}

/// Riverpod provider so widgets can access the push service.
final pushServiceProvider = Provider<PushService>((_) => PushService.instance);
