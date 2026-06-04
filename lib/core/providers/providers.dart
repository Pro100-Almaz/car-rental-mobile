// Car providers use sample data (M3 wired to real API via mobile_vehicles_api).
// Booking providers wired to real API in M4 via mobile_rentals_api.
// This file is a stub keeping screens compiling; new providers live in
// bookings_provider.dart and active_rental_provider.dart.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking.dart';
import '../../features/home/data/sample_cars.dart'; // re-exports car.dart + seed data

// --- Car providers ---

final allCarsProvider = Provider<List<CarListing>>((ref) {
  return [...kNearbyCars, ...kTopRated];
});

final nearbyCarsProvider = Provider<List<CarListing>>((ref) {
  return List.of(kNearbyCars);
});

final topRatedCarsProvider = Provider<List<CarListing>>((ref) {
  return List.of(kTopRated);
});

// 'all' sentinel means no category filter
final selectedCategoryProvider = StateProvider<String>((_) => 'all');

final filteredCarsProvider = Provider<List<CarListing>>((ref) {
  final category = ref.watch(selectedCategoryProvider);
  final all = ref.watch(allCarsProvider);
  if (category == 'all') return all;
  return all.where((c) => c.category.name == category).toList();
});

final carByIdProvider = Provider.family<CarListing?, String>((ref, id) {
  final all = ref.watch(allCarsProvider);
  try {
    return all.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
});

// --- Booking providers (legacy stub — screens still reference bookingsProvider) ---
// M4: new async providers are in bookings_provider.dart + active_rental_provider.dart.

final bookingsProvider =
    StateNotifierProvider<BookingsNotifier, List<Booking>>((_) => BookingsNotifier());

final bookingsByStatusProvider =
    Provider.family<List<Booking>, BookingStatus>((ref, status) {
  return ref.watch(bookingsProvider).where((b) => b.status == status).toList();
});

final activeBookingProvider = Provider<Booking?>((ref) {
  final bookings = ref.watch(bookingsProvider);
  try {
    return bookings.firstWhere((b) => b.status == BookingStatus.active);
  } catch (_) {
    return null;
  }
});

// --- Booking date selection ---
final bookingStartDateProvider = StateProvider<DateTime?>((ref) => null);
final bookingEndDateProvider = StateProvider<DateTime?>((ref) => null);

class BookingsNotifier extends StateNotifier<List<Booking>> {
  BookingsNotifier() : super(const []);

  void updateStatus(String id, BookingStatus status) {
    state = [
      for (final b in state)
        if (b.id == id) b.copyWith(status: status) else b,
    ];
  }
}
