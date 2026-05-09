class ActiveRental {
  const ActiveRental({
    required this.bookingId,
    required this.carId,
    required this.carName,
    required this.carImageUrl,
    required this.plateNumber,
    required this.startTime,
    required this.endTime,
    required this.pricePerHour,
    required this.pricePerDay,
    required this.pickupPhotos,
    this.fuelLevelAtPickup = 0.0,
    this.mileageAtPickup = 0,
  });

  final String bookingId;
  final String carId;
  final String carName;
  final String carImageUrl;
  final String plateNumber;
  final DateTime startTime;
  final DateTime endTime;
  final int pricePerHour;
  final int pricePerDay;
  final List<String> pickupPhotos;
  final double fuelLevelAtPickup;
  final int mileageAtPickup;

  Duration get elapsed => DateTime.now().difference(startTime);
  Duration get remaining => endTime.difference(DateTime.now());
  bool get isOverdue => DateTime.now().isAfter(endTime);

  int get currentCost {
    final hours = elapsed.inMinutes / 60.0;
    if (hours <= 3) return (hours.ceil() * pricePerHour);
    final days = (hours / 24).ceil();
    return days * pricePerDay;
  }
}
