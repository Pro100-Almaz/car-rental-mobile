import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../models/booking.dart';

// ---------------------------------------------------------------------------
// Active rental provider
// GET /mobile/rentals/active → Booking? (null = no active rental)
//
// autoDispose so it re-fetches when the shell re-subscribes (e.g. on resume).
// The shell wraps itself in a WidgetsBindingObserver to invalidate on resume.
// ---------------------------------------------------------------------------

final activeRentalProvider =
    FutureProvider.autoDispose<Booking?>((ref) async {
  final api = ref.read(mobileRentalsApiProvider);
  return api.active();
});
