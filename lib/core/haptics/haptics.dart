import 'package:flutter/services.dart';

/// Centralized haptic feedback per AutoFleet §7 haptics policy.
///
/// All methods are wrapped in try/catch — some platforms silently ignore
/// certain feedback types (e.g. Android ignores selectionClick on older APIs).
class AppHaptics {
  AppHaptics._();

  /// Light selection feedback — tab switches, chip taps, radio selections.
  static Future<void> selection() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// Light impact — card taps, pull-to-refresh trigger, document picker.
  static Future<void> light() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Medium impact — submit actions (login, signup, booking submit, etc.).
  static Future<void> medium() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Heavy impact — overdue timer transition, payment rejected, cancellation.
  static Future<void> heavy() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }
}
