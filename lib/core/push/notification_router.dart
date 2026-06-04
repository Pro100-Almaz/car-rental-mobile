import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/app_notification.dart';

/// Maps an [AppNotification] to its destination route and navigates there.
///
/// Call from:
/// - notification list row tap
/// - FCM foreground banner tap
/// - FCM background push tap (onMessageOpenedApp)
void routeNotification(BuildContext context, AppNotification n) {
  switch (n.type) {
    case 'document_approved':
    case 'document_rejected':
      context.go('/verification-gate');

    case 'booking_confirmed':
    case 'booking_cancelled_by_manager':
    case 'pickup_reminder':
    case 'return_reminder':
    case 'overdue_alert':
    case 'rental_completed':
      final id = n.data['booking_id'] as String?;
      if (id != null) {
        context.go('/bookings/$id');
      } else {
        context.go('/bookings');
      }

    case 'fine_added':
      context.go('/profile/fines');

    case 'payment_confirmed':
    case 'payment_rejected':
      context.go('/profile/payments');

    default:
      context.go('/notifications');
  }
}
