import 'package:flutter/material.dart';

enum BookingStatus { pending, confirmed, active, returning, completed, cancelled }

Color bookingStatusColor(BookingStatus status) => switch (status) {
  BookingStatus.pending => const Color(0xFFEAB308),
  BookingStatus.confirmed => const Color(0xFF16A34A),
  BookingStatus.active => const Color(0xFF2563EB),
  BookingStatus.returning => const Color(0xFFEAB308),
  BookingStatus.completed => const Color(0xFF8E8EA0),
  BookingStatus.cancelled => const Color(0xFFDC2626),
};

BookingStatus bookingStatusFromString(String s) => switch (s.toLowerCase()) {
  'pending' => BookingStatus.pending,
  'confirmed' => BookingStatus.confirmed,
  'active' => BookingStatus.active,
  'returning' => BookingStatus.returning,
  'completed' => BookingStatus.completed,
  'cancelled' => BookingStatus.cancelled,
  _ => BookingStatus.pending,
};

String bookingStatusToString(BookingStatus status) => switch (status) {
  BookingStatus.pending => 'pending',
  BookingStatus.confirmed => 'confirmed',
  BookingStatus.active => 'active',
  BookingStatus.returning => 'returning',
  BookingStatus.completed => 'completed',
  BookingStatus.cancelled => 'cancelled',
};

// bookingStatusLabel is now in l10n — kept here as a fallback for non-context
// code paths (e.g. copyWith, API layer).
String bookingStatusLabel(BookingStatus status) => switch (status) {
  BookingStatus.pending => 'Pending',
  BookingStatus.confirmed => 'Confirmed',
  BookingStatus.active => 'Active',
  BookingStatus.returning => 'Returning',
  BookingStatus.completed => 'Completed',
  BookingStatus.cancelled => 'Cancelled',
};

// ---------------------------------------------------------------------------
// Embedded sub-models
// ---------------------------------------------------------------------------

class BookingVehicleSummary {
  const BookingVehicleSummary({
    required this.id,
    required this.nickname,
    required this.makeModel,
    required this.photoUrl,
    this.maskedPlate,
    this.fullPlate,
  });

  final String id;
  final String nickname;
  final String makeModel;
  final String photoUrl;
  /// Plate shown only for confirmed/active: full plate. Otherwise masked.
  final String? maskedPlate;
  final String? fullPlate;

  String plateFor(BookingStatus status) {
    final reveal = status == BookingStatus.confirmed ||
        status == BookingStatus.active ||
        status == BookingStatus.returning ||
        status == BookingStatus.completed;
    if (reveal && fullPlate != null) return fullPlate!;
    return maskedPlate ?? '••• •••';
  }

  factory BookingVehicleSummary.fromJson(Map<String, dynamic> json) {
    return BookingVehicleSummary(
      id: (json['id'] as String?) ?? '',
      nickname: (json['nickname'] as String?) ?? (json['name'] as String?) ?? '',
      makeModel: (json['make_model'] as String?) ??
          '${json['make'] ?? ''} ${json['model'] ?? ''}'.trim(),
      photoUrl: (json['photo_url'] as String?) ??
          (json['image_url'] as String?) ??
          '',
      maskedPlate: json['masked_plate'] as String?,
      fullPlate: (json['plate_number'] as String?) ??
          (json['plate'] as String?),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nickname': nickname,
    'make_model': makeModel,
    'photo_url': photoUrl,
    if (maskedPlate != null) 'masked_plate': maskedPlate,
    if (fullPlate != null) 'plate_number': fullPlate,
  };
}

class AdditionalService {
  const AdditionalService({
    required this.id,
    required this.name,
    required this.price,
  });

  final String id;
  final String name;
  final int price;

  factory AdditionalService.fromJson(Map<String, dynamic> json) {
    return AdditionalService(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'price': price};
}

class BookingFees {
  const BookingFees({
    this.fuel = 0,
    this.mileage = 0,
    this.damage = 0,
    this.fines = 0,
  });

  final int fuel;
  final int mileage;
  final int damage;
  final int fines;

  int get total => fuel + mileage + damage + fines;

  factory BookingFees.fromJson(Map<String, dynamic> json) {
    return BookingFees(
      fuel: (json['fuel'] as num?)?.toInt() ?? 0,
      mileage: (json['mileage'] as num?)?.toInt() ?? 0,
      damage: (json['damage'] as num?)?.toInt() ?? 0,
      fines: (json['fines'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'fuel': fuel,
    'mileage': mileage,
    'damage': damage,
    'fines': fines,
  };
}

class StatusHistoryEntry {
  const StatusHistoryEntry({
    required this.status,
    required this.timestamp,
  });

  final BookingStatus status;
  final DateTime timestamp;

  factory StatusHistoryEntry.fromJson(Map<String, dynamic> json) {
    return StatusHistoryEntry(
      status: bookingStatusFromString((json['status'] as String?) ?? ''),
      timestamp: DateTime.tryParse((json['timestamp'] as String?) ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': bookingStatusToString(status),
    'timestamp': timestamp.toIso8601String(),
  };
}

// ---------------------------------------------------------------------------
// Main Booking model
// ---------------------------------------------------------------------------

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
    this.vehicle,
    this.actualStart,
    this.actualEnd,
    this.additionalServices = const [],
    this.deposit = 0,
    this.fees,
    this.estimatedTotal,
    this.actualTotal,
    this.pickupNotes,
    this.pickupLocation,
    this.managerPhone,
    this.fuelLevelAtPickup,
    this.mileageAtPickup,
    this.cancellationReason,
    this.cancelledAt,
    this.statusHistory = const [],
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

  // Extended v1 fields
  final BookingVehicleSummary? vehicle;
  final DateTime? actualStart;
  final DateTime? actualEnd;
  final List<AdditionalService> additionalServices;
  final int deposit;
  final BookingFees? fees;
  final int? estimatedTotal;
  final int? actualTotal;
  final String? pickupNotes;
  final String? pickupLocation;
  final String? managerPhone;
  final double? fuelLevelAtPickup;
  final int? mileageAtPickup;
  final String? cancellationReason;
  final DateTime? cancelledAt;
  final List<StatusHistoryEntry> statusHistory;

  int get days => endDate.difference(startDate).inDays.clamp(1, 365);

  /// Short reference e.g. "A1B2" (last 4 of id, uppercased)
  String get shortRef => id.length >= 4
      ? id.substring(id.length - 4).toUpperCase()
      : id.toUpperCase();

  /// Whether plate should be shown in full
  bool get isPlateRevealed =>
      status == BookingStatus.confirmed ||
      status == BookingStatus.active ||
      status == BookingStatus.returning ||
      status == BookingStatus.completed;

  /// Displayed plate — uses vehicle summary if available, else plateNumber field
  String get displayPlate {
    if (vehicle != null) return vehicle!.plateFor(status);
    if (isPlateRevealed) return plateNumber;
    return plateNumber.isNotEmpty ? '${plateNumber.substring(0, 1)}•• •••' : '••• •••';
  }

  // ---------------------------------------------------------------------------
  // JSON parsing — tolerant of partial responses
  // ---------------------------------------------------------------------------

  factory Booking.fromJson(Map<String, dynamic> json) {
    BookingStatus status;
    try {
      status = bookingStatusFromString((json['status'] as String?) ?? '');
    } catch (_) {
      status = BookingStatus.pending;
    }

    final vehicleJson = json['vehicle'] as Map<String, dynamic>?;

    // Parse additional services (may be array of objects or array of ids)
    final rawServices = json['additional_services'] as List<dynamic>?;
    final additionalServices = rawServices
            ?.whereType<Map<String, dynamic>>()
            .map(AdditionalService.fromJson)
            .toList() ??
        const <AdditionalService>[];

    // Parse fees
    BookingFees? fees;
    final feesJson = json['fees'] as Map<String, dynamic>?;
    if (feesJson != null) fees = BookingFees.fromJson(feesJson);

    // Parse status history
    final rawHistory = json['status_history'] as List<dynamic>?;
    final statusHistory = rawHistory
            ?.whereType<Map<String, dynamic>>()
            .map(StatusHistoryEntry.fromJson)
            .toList() ??
        const <StatusHistoryEntry>[];

    // Dates — try scheduled_start / scheduled_end first (backend names)
    DateTime parseDate(String key, String altKey) {
      final v = (json[key] as String?) ?? (json[altKey] as String?);
      return (v != null ? DateTime.tryParse(v) : null) ?? DateTime.now();
    }

    final startDate = parseDate('scheduled_start', 'start_date');
    final endDate = parseDate('scheduled_end', 'end_date');

    return Booking(
      id: (json['id'] as String?) ?? '',
      carId: vehicleJson != null
          ? ((vehicleJson['id'] as String?) ?? '')
          : ((json['vehicle_id'] as String?) ?? (json['car_id'] as String?) ?? ''),
      carName: vehicleJson != null
          ? ((vehicleJson['nickname'] as String?) ?? '')
          : ((json['car_name'] as String?) ?? ''),
      carImageUrl: vehicleJson != null
          ? ((vehicleJson['photo_url'] as String?) ?? (vehicleJson['image_url'] as String?) ?? '')
          : ((json['car_image_url'] as String?) ?? ''),
      category: (json['category'] as String?) ?? '',
      plateNumber: vehicleJson != null
          ? ((vehicleJson['plate_number'] as String?) ?? (vehicleJson['plate'] as String?) ?? '')
          : ((json['plate_number'] as String?) ?? ''),
      startDate: startDate,
      endDate: endDate,
      pricePerDay: (json['daily_rate'] as num?)?.toInt() ??
          (json['price_per_day'] as num?)?.toInt() ??
          0,
      insurance: (json['insurance'] as num?)?.toInt() ?? 0,
      serviceFee: (json['service_fee'] as num?)?.toInt() ?? 0,
      total: (json['estimated_total'] as num?)?.toInt() ??
          (json['actual_total'] as num?)?.toInt() ??
          (json['total'] as num?)?.toInt() ??
          0,
      status: status,
      vehicle: vehicleJson != null
          ? BookingVehicleSummary.fromJson(vehicleJson)
          : null,
      actualStart: json['actual_start'] != null
          ? DateTime.tryParse(json['actual_start'] as String)
          : null,
      actualEnd: json['actual_end'] != null
          ? DateTime.tryParse(json['actual_end'] as String)
          : null,
      additionalServices: additionalServices,
      deposit: (json['deposit'] as num?)?.toInt() ?? 0,
      fees: fees,
      estimatedTotal: (json['estimated_total'] as num?)?.toInt(),
      actualTotal: (json['actual_total'] as num?)?.toInt(),
      pickupNotes: json['pickup_notes'] as String?,
      pickupLocation: json['pickup_location'] as String?,
      managerPhone: json['manager_phone'] as String?,
      fuelLevelAtPickup: (json['fuel_level_at_pickup'] as num?)?.toDouble(),
      mileageAtPickup: (json['mileage_at_pickup'] as num?)?.toInt(),
      cancellationReason: json['cancellation_reason'] as String?,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.tryParse(json['cancelled_at'] as String)
          : null,
      statusHistory: statusHistory,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'vehicle_id': carId,
    'status': bookingStatusToString(status),
    'scheduled_start': startDate.toIso8601String(),
    'scheduled_end': endDate.toIso8601String(),
    'daily_rate': pricePerDay,
    'estimated_total': estimatedTotal ?? total,
    if (vehicle != null) 'vehicle': vehicle!.toJson(),
    if (actualStart != null) 'actual_start': actualStart!.toIso8601String(),
    if (actualEnd != null) 'actual_end': actualEnd!.toIso8601String(),
    'additional_services': additionalServices.map((s) => s.toJson()).toList(),
    'deposit': deposit,
    if (fees != null) 'fees': fees!.toJson(),
    if (actualTotal != null) 'actual_total': actualTotal,
    if (pickupNotes != null) 'pickup_notes': pickupNotes,
    if (pickupLocation != null) 'pickup_location': pickupLocation,
    if (managerPhone != null) 'manager_phone': managerPhone,
    if (fuelLevelAtPickup != null) 'fuel_level_at_pickup': fuelLevelAtPickup,
    if (mileageAtPickup != null) 'mileage_at_pickup': mileageAtPickup,
    if (cancellationReason != null) 'cancellation_reason': cancellationReason,
    if (cancelledAt != null) 'cancelled_at': cancelledAt!.toIso8601String(),
    'status_history': statusHistory.map((e) => e.toJson()).toList(),
  };

  Booking copyWith({
    BookingStatus? status,
    double? fuelLevelAtPickup,
    int? mileageAtPickup,
    String? managerPhone,
    String? cancellationReason,
    DateTime? cancelledAt,
    List<StatusHistoryEntry>? statusHistory,
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
      vehicle: vehicle,
      actualStart: actualStart,
      actualEnd: actualEnd,
      additionalServices: additionalServices,
      deposit: deposit,
      fees: fees,
      estimatedTotal: estimatedTotal,
      actualTotal: actualTotal,
      pickupNotes: pickupNotes,
      pickupLocation: pickupLocation,
      managerPhone: managerPhone ?? this.managerPhone,
      fuelLevelAtPickup: fuelLevelAtPickup ?? this.fuelLevelAtPickup,
      mileageAtPickup: mileageAtPickup ?? this.mileageAtPickup,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      statusHistory: statusHistory ?? this.statusHistory,
    );
  }
}

// ---------------------------------------------------------------------------
// BookingResponse — lightweight DTO returned by POST /mobile/rentals/
// Kept from M3 for compatibility with booking_request_screen.
// ---------------------------------------------------------------------------

class BookingResponse {
  const BookingResponse({
    required this.id,
    required this.status,
    required this.vehicleId,
    this.estimatedTotal,
  });

  final String id;
  final String status;
  final String vehicleId;
  final int? estimatedTotal;

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      id: (json['id'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'pending',
      vehicleId: (json['vehicle_id'] as String?) ?? '',
      estimatedTotal: (json['estimated_total'] as num?)?.toInt(),
    );
  }
}
