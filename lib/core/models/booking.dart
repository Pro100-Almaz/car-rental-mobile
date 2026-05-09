import 'package:flutter/material.dart';

enum BookingStatus { pending, confirmed, active, completed, cancelled }

Color bookingStatusColor(BookingStatus status) => switch (status) {
  BookingStatus.pending => const Color(0xFFEAB308),
  BookingStatus.confirmed => const Color(0xFF16A34A),
  BookingStatus.active => const Color(0xFF2563EB),
  BookingStatus.completed => const Color(0xFF8E8EA0),
  BookingStatus.cancelled => const Color(0xFFDC2626),
};

String bookingStatusLabel(BookingStatus status) => switch (status) {
  BookingStatus.pending => 'Pending',
  BookingStatus.confirmed => 'Confirmed',
  BookingStatus.active => 'Active',
  BookingStatus.completed => 'Completed',
  BookingStatus.cancelled => 'Cancelled',
};

class Booking {
  const Booking({
    required this.id,
    required this.carId,
    required this.carName,
    required this.carImageUrl,
    required this.category,
    required this.plateNumber,
    required this.startDate,
    required this.endDate,
    required this.pricePerDay,
    required this.insurance,
    required this.serviceFee,
    required this.total,
    required this.status,
    this.fuelLevelAtPickup,
    this.mileageAtPickup,
  });

  final String id;
  final String carId;
  final String carName;
  final String carImageUrl;
  final String category;
  final String plateNumber;
  final DateTime startDate;
  final DateTime endDate;
  final int pricePerDay;
  final int insurance;
  final int serviceFee;
  final int total;
  final BookingStatus status;
  final double? fuelLevelAtPickup;
  final int? mileageAtPickup;

  int get days => endDate.difference(startDate).inDays.clamp(1, 365);

  Booking copyWith({
    BookingStatus? status,
    double? fuelLevelAtPickup,
    int? mileageAtPickup,
  }) {
    return Booking(
      id: id,
      carId: carId,
      carName: carName,
      carImageUrl: carImageUrl,
      category: category,
      plateNumber: plateNumber,
      startDate: startDate,
      endDate: endDate,
      pricePerDay: pricePerDay,
      insurance: insurance,
      serviceFee: serviceFee,
      total: total,
      status: status ?? this.status,
      fuelLevelAtPickup: fuelLevelAtPickup ?? this.fuelLevelAtPickup,
      mileageAtPickup: mileageAtPickup ?? this.mileageAtPickup,
    );
  }
}
