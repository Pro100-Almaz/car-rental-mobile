import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking.dart';
import '../repositories/car_repository.dart';
import '../repositories/booking_repository.dart';
import '../../features/home/data/sample_cars.dart';

// --- Repositories ---
final carRepositoryProvider = Provider<CarRepository>((_) => MockCarRepository());
final bookingRepositoryProvider = Provider<BookingRepository>((_) => MockBookingRepository());

// --- Car providers ---
final allCarsProvider = Provider<List<CarListing>>((ref) {
  return ref.watch(carRepositoryProvider).getAllCars();
});

final nearbyCarsProvider = Provider<List<CarListing>>((ref) {
  return ref.watch(carRepositoryProvider).getNearbyCars();
});

final topRatedCarsProvider = Provider<List<CarListing>>((ref) {
  return ref.watch(carRepositoryProvider).getTopRated();
});

final selectedCategoryProvider = StateProvider<String>((_) => 'all');

final filteredCarsProvider = Provider<List<CarListing>>((ref) {
  final category = ref.watch(selectedCategoryProvider);
  return ref.watch(carRepositoryProvider).getCarsByCategory(category);
});

final carByIdProvider = Provider.family<CarListing?, String>((ref, id) {
  return ref.watch(carRepositoryProvider).getCarById(id);
});

// --- Booking providers ---
final bookingsProvider = StateNotifierProvider<BookingsNotifier, List<Booking>>((ref) {
  return BookingsNotifier(ref.watch(bookingRepositoryProvider));
});

final bookingsByStatusProvider = Provider.family<List<Booking>, BookingStatus>((ref, status) {
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

// --- Photo inspection ---
final inspectionPhotosProvider = StateNotifierProvider<InspectionPhotosNotifier, List<String?>>(
  (_) => InspectionPhotosNotifier(),
);

class BookingsNotifier extends StateNotifier<List<Booking>> {
  BookingsNotifier(this._repo) : super(_repo.getBookings());
  final BookingRepository _repo;

  void createBooking({
    required CarListing car,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    _repo.createBooking(car: car, startDate: startDate, endDate: endDate);
    state = _repo.getBookings();
  }

  void updateStatus(String id, BookingStatus status) {
    _repo.updateBookingStatus(id, status);
    state = _repo.getBookings();
  }

  void startRental(String id, {required double fuelLevel, required int mileage}) {
    _repo.startRental(id, fuelLevel: fuelLevel, mileage: mileage);
    state = _repo.getBookings();
  }
}

class InspectionPhotosNotifier extends StateNotifier<List<String?>> {
  InspectionPhotosNotifier() : super(List.filled(8, null));

  void setPhoto(int index, String path) {
    final updated = [...state];
    updated[index] = path;
    state = updated;
  }

  void reset() => state = List.filled(8, null);

  bool get isComplete => state.every((p) => p != null);
  int get completedCount => state.where((p) => p != null).length;
}
