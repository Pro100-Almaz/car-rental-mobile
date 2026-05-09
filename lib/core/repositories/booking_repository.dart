import '../models/booking.dart';
import '../../features/home/data/sample_cars.dart';

abstract class BookingRepository {
  List<Booking> getBookings();
  List<Booking> getBookingsByStatus(BookingStatus status);
  Booking? getBookingById(String id);
  Booking createBooking({
    required CarListing car,
    required DateTime startDate,
    required DateTime endDate,
  });
  Booking updateBookingStatus(String id, BookingStatus status);
  Booking startRental(String id, {required double fuelLevel, required int mileage});
}

class MockBookingRepository implements BookingRepository {
  final List<Booking> _bookings = [
    Booking(
      id: 'b1',
      carId: 'camry-2023',
      carName: 'Toyota Camry',
      carImageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBgX6gvNsdDqjarsBP5NG2-mvXtENO7c8q3yDxTdvaWowT2XKBcuT5RLEcPHGl9XBUN5g9-faB67vu2cjTZ-jTuPAmh2sI9AT6vb8gd0ZD5tk-IkLxVvZFPRyjKkQ3euNkJE7mZDKY1BUnrwZVsjh9MA7Caw8vuTQKwrsjtReoh77TQpaYsAxfCRdkM0c6wsaMwglQq8R2G95F952I42aPe4bZrll_7a7JgnRBccMGOAXIApfnYUHsvwDEomSP-YuY5kQtM1j52SW7v',
      category: 'comfort',
      plateNumber: 'KA 222 TTA',
      startDate: DateTime.now().add(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 5)),
      pricePerDay: 8000,
      insurance: 3000,
      serviceFee: 1500,
      total: 28500,
      status: BookingStatus.confirmed,
    ),
    Booking(
      id: 'b2',
      carId: 'mercedes-e-class',
      carName: 'Mercedes-Benz E-Class',
      carImageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuALL4nIg4zzrYI9Zi71VmGAnQcasipFNTj4NHD-m8d5N0Q11OK5mJ0blOI1alcVT5b5sWoHWN-Z4834FBlQfikHvwc7spxJf87YKub6fWNeLaAz_mcFf3WYxww9mdLVM8xdA9qRA8yzyUV8-Q1kcZPyvFsWI2FgCtzEjy4TBpAguHyRkZdBJ0DxJ7deJrQL7bI-8cWb5FOK8p9NyhtLSIK7L263MW23X48rTlaU8UmEClcG3xiCBWx_i4uH-JX1wMbdcasD9DRuAdIZ',
      category: 'business',
      plateNumber: 'KA 001 LUX',
      startDate: DateTime.now().add(const Duration(days: 10)),
      endDate: DateTime.now().add(const Duration(days: 13)),
      pricePerDay: 25000,
      insurance: 5000,
      serviceFee: 2500,
      total: 82500,
      status: BookingStatus.confirmed,
    ),
    Booking(
      id: 'b3',
      carId: 'kia-k5',
      carName: 'Kia K5',
      carImageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBAeZFhSSJsoutDhcuWnNfgh-d7ZpjUCjrWIVYQSVPkYKB9wU4sTPgkfBY550hCuJ2zIEaRck5ASG--i8xZlE8T9mNEr-wz4YwkSPVApKpPjhWpIJfcRC8vsUk99-xZGz_isFzlmSWdKQmKAFfJmlRdsvZTGpyoN0CKtpL6WZ_Qh3fGSvzlstw_mngcM70ZAaBY-Q5HVupX1wOvBauUmxXKHTTXjHi9tBVVcx4P06RYB5qQALV-2wlbWK4EO4GthICf6ETmJig6sRWM',
      category: 'economy',
      plateNumber: 'KA 789 EFG',
      startDate: DateTime.now().subtract(const Duration(days: 10)),
      endDate: DateTime.now().subtract(const Duration(days: 7)),
      pricePerDay: 6000,
      insurance: 2000,
      serviceFee: 1000,
      total: 21000,
      status: BookingStatus.completed,
    ),
  ];

  @override
  List<Booking> getBookings() => List.of(_bookings);

  @override
  List<Booking> getBookingsByStatus(BookingStatus status) =>
      _bookings.where((b) => b.status == status).toList();

  @override
  Booking? getBookingById(String id) {
    try {
      return _bookings.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Booking createBooking({
    required CarListing car,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final days = endDate.difference(startDate).inDays.clamp(1, 365);
    final insurance = (car.pricePerDay * 0.15).round();
    final serviceFee = (car.pricePerDay * 0.08).round();
    final total = car.pricePerDay * days + insurance + serviceFee;

    final booking = Booking(
      id: 'b${DateTime.now().millisecondsSinceEpoch}',
      carId: car.id,
      carName: car.name,
      carImageUrl: car.imageUrl,
      category: car.category,
      plateNumber: car.plateNumber,
      startDate: startDate,
      endDate: endDate,
      pricePerDay: car.pricePerDay,
      insurance: insurance,
      serviceFee: serviceFee,
      total: total,
      status: BookingStatus.confirmed,
    );
    _bookings.insert(0, booking);
    return booking;
  }

  @override
  Booking updateBookingStatus(String id, BookingStatus status) {
    final idx = _bookings.indexWhere((b) => b.id == id);
    if (idx == -1) throw Exception('Booking not found');
    final updated = _bookings[idx].copyWith(status: status);
    _bookings[idx] = updated;
    return updated;
  }

  @override
  Booking startRental(String id, {required double fuelLevel, required int mileage}) {
    final idx = _bookings.indexWhere((b) => b.id == id);
    if (idx == -1) throw Exception('Booking not found');
    final updated = _bookings[idx].copyWith(
      status: BookingStatus.active,
      fuelLevelAtPickup: fuelLevel,
      mileageAtPickup: mileage,
    );
    _bookings[idx] = updated;
    return updated;
  }
}
