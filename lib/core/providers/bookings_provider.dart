import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../models/booking.dart';

// ---------------------------------------------------------------------------
// Bookings list provider
// Fetches all rentals for the current user from GET /mobile/rentals/
// ---------------------------------------------------------------------------

final bookingsListProvider =
    AsyncNotifierProvider<BookingsListNotifier, List<Booking>>(
  BookingsListNotifier.new,
);

class BookingsListNotifier extends AsyncNotifier<List<Booking>> {
  @override
  Future<List<Booking>> build() async {
    return _fetch();
  }

  Future<List<Booking>> _fetch() async {
    final api = ref.read(mobileRentalsApiProvider);
    return api.list();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

// ---------------------------------------------------------------------------
// Booking detail provider — FutureProvider.family
// Fetches a single rental by id from GET /mobile/rentals/{id}
// ---------------------------------------------------------------------------

final bookingDetailProvider =
    FutureProvider.autoDispose.family<Booking, String>((ref, bookingId) async {
  final api = ref.read(mobileRentalsApiProvider);
  return api.get(bookingId);
});
