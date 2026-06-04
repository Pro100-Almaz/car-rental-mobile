import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum VehicleCategory { economy, comfort, business, suv, minivan }

enum FuelType { petrol, diesel, hybrid, electric }

enum Transmission { automatic, manual }

enum CarStatus {
  available,
  reserved,
  rented,
  returning,
  inService,
  inWash,
  decommissioned,
}

// ---------------------------------------------------------------------------
// Legacy CarCategory — kept for sample_cars.dart compatibility
// ---------------------------------------------------------------------------

class CarCategory {
  const CarCategory(this.id, this.label);
  final String id;
  final String label;
}

// ---------------------------------------------------------------------------
// Enum helpers
// ---------------------------------------------------------------------------

VehicleCategory vehicleCategoryFromString(String s) {
  switch (s.toLowerCase()) {
    case 'comfort':
      return VehicleCategory.comfort;
    case 'business':
      return VehicleCategory.business;
    case 'suv':
      return VehicleCategory.suv;
    case 'minivan':
      return VehicleCategory.minivan;
    case 'economy':
    default:
      return VehicleCategory.economy;
  }
}

String vehicleCategoryToString(VehicleCategory c) {
  switch (c) {
    case VehicleCategory.economy:
      return 'economy';
    case VehicleCategory.comfort:
      return 'comfort';
    case VehicleCategory.business:
      return 'business';
    case VehicleCategory.suv:
      return 'suv';
    case VehicleCategory.minivan:
      return 'minivan';
  }
}

FuelType fuelTypeFromString(String s) {
  switch (s.toLowerCase()) {
    case 'diesel':
      return FuelType.diesel;
    case 'hybrid':
      return FuelType.hybrid;
    case 'electric':
      return FuelType.electric;
    case 'petrol':
    default:
      return FuelType.petrol;
  }
}

String fuelTypeToString(FuelType f) {
  switch (f) {
    case FuelType.petrol:
      return 'petrol';
    case FuelType.diesel:
      return 'diesel';
    case FuelType.hybrid:
      return 'hybrid';
    case FuelType.electric:
      return 'electric';
  }
}

Transmission transmissionFromString(String s) {
  switch (s.toLowerCase()) {
    case 'manual':
      return Transmission.manual;
    case 'automatic':
    default:
      return Transmission.automatic;
  }
}

String transmissionToString(Transmission t) {
  switch (t) {
    case Transmission.automatic:
      return 'automatic';
    case Transmission.manual:
      return 'manual';
  }
}

CarStatus carStatusFromString(String s) {
  switch (s.toLowerCase()) {
    case 'reserved':
      return CarStatus.reserved;
    case 'rented':
      return CarStatus.rented;
    case 'returning':
      return CarStatus.returning;
    case 'in_service':
      return CarStatus.inService;
    case 'in_wash':
      return CarStatus.inWash;
    case 'decommissioned':
      return CarStatus.decommissioned;
    case 'available':
    default:
      return CarStatus.available;
  }
}

// ---------------------------------------------------------------------------
// CarListing — v1 model matching GET /mobile/vehicles/ and /mobile/vehicles/{id}
// ---------------------------------------------------------------------------

class CarListing {
  const CarListing({
    required this.id,
    required this.nickname,
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.maskedPlate,
    required this.category,
    required this.photos,
    required this.dailyRate,
    required this.fuelType,
    required this.transmission,
    required this.currentMileage,
    required this.features,
    this.status = CarStatus.available,
    // Legacy fields kept for existing screens that haven't been refactored yet
    this.name = '',
    this.tagline = '',
    this.imageUrl = '',
    this.pricePerHour = 0,
    this.pricePerDay = 0,
    this.rating = 0,
    this.reviewCount = 0,
    this.distanceMeters = 0,
    this.seats = 5,
    this.plateNumber = '',
    this.fuelLevel = 1.0,
    this.description = '',
  });

  final String id;
  final String nickname;
  final String make;
  final String model;
  final int year;
  final String color;

  /// Partially masked license plate, e.g. "*** 123"
  final String maskedPlate;
  final VehicleCategory category;

  /// List of S3 photo URLs
  final List<String> photos;

  /// Daily rental rate in KZT (tenge)
  final int dailyRate;
  final FuelType fuelType;
  final Transmission transmission;
  final int currentMileage;

  /// Arbitrary key-value features from backend
  final Map<String, dynamic> features;
  final CarStatus status;

  // ---- Legacy fields (kept while old screens compile) ----
  final String name;
  final String tagline;
  final String imageUrl;
  final int pricePerHour;
  final int pricePerDay;
  final double rating;
  final int reviewCount;
  final int distanceMeters;
  final int seats;
  final String plateNumber;
  final double fuelLevel;
  final String description;

  /// Convenience: primary photo URL or empty string.
  String get primaryPhoto => photos.isNotEmpty ? photos.first : imageUrl;

  /// Display name for cards: "Make Model (Year)"
  String get displayTitle =>
      nickname.isNotEmpty ? nickname : '$make $model';

  /// Subtitle: "Make Model · Year"
  String get displaySubtitle => '$make $model · $year';

  // ---------------------------------------------------------------------------
  // JSON factory — defensive parser for both DRF and custom formats
  // ---------------------------------------------------------------------------

  factory CarListing.fromJson(Map<String, dynamic> json) {
    final photosRaw = json['photos'];
    final List<String> photos = photosRaw is List
        ? photosRaw.map((e) => e.toString()).toList()
        : [];

    final featuresRaw = json['features'];
    final Map<String, dynamic> features =
        (featuresRaw is Map<String, dynamic>) ? featuresRaw : {};

    final plate = json['license_plate'] as String? ?? '';
    final maskedPlate = _maskPlate(plate);

    return CarListing(
      id: json['id']?.toString() ?? '',
      nickname: json['nickname'] as String? ?? '',
      make: json['make'] as String? ?? '',
      model: json['model'] as String? ?? '',
      year: (json['year'] as num?)?.toInt() ?? 0,
      color: json['color'] as String? ?? '',
      maskedPlate: maskedPlate,
      category: vehicleCategoryFromString(
          json['category'] as String? ?? 'economy'),
      photos: photos,
      dailyRate: (json['daily_rate'] as num?)?.toInt() ?? 0,
      fuelType: fuelTypeFromString(
          json['fuel_type'] as String? ?? 'petrol'),
      transmission: transmissionFromString(
          json['transmission'] as String? ?? 'automatic'),
      currentMileage:
          (json['current_mileage'] as num?)?.toInt() ?? 0,
      features: features,
      status: carStatusFromString(
          json['status'] as String? ?? 'available'),
      // Legacy fallbacks
      name: json['nickname'] as String? ??
          '${json['make'] ?? ''} ${json['model'] ?? ''}'.trim(),
      pricePerDay: (json['daily_rate'] as num?)?.toInt() ?? 0,
      imageUrl: photos.isNotEmpty ? photos.first : '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nickname': nickname,
        'make': make,
        'model': model,
        'year': year,
        'color': color,
        'license_plate': maskedPlate,
        'category': vehicleCategoryToString(category),
        'photos': photos,
        'daily_rate': dailyRate,
        'fuel_type': fuelTypeToString(fuelType),
        'transmission': transmissionToString(transmission),
        'current_mileage': currentMileage,
        'features': features,
        'status': status.name,
      };
}

// ---------------------------------------------------------------------------
// Paginated response wrapper — handles DRF limit-offset and page-based formats
// ---------------------------------------------------------------------------

class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.hasMore,
  });

  final List<T> items;
  final int page;
  final int pageSize;
  final int total;
  final bool hasMore;

  static PaginatedResponse<CarListing> fromJson(
    Map<String, dynamic> json, {
    int currentPage = 1,
    int pageSize = 20,
  }) {
    // Accept both "results" (DRF) and "vehicles" (custom) keys
    final rawList = json['results'] ?? json['vehicles'] ?? json['items'] ?? [];
    final List<CarListing> items = (rawList as List)
        .map((e) => CarListing.fromJson(e as Map<String, dynamic>))
        .toList();

    final total = (json['count'] as num?)?.toInt() ??
        (json['total'] as num?)?.toInt() ??
        items.length;

    final hasMore = json['next'] != null ||
        (json['has_more'] as bool? ?? false) ||
        (total > currentPage * pageSize);

    return PaginatedResponse<CarListing>(
      items: items,
      page: currentPage,
      pageSize: pageSize,
      total: total,
      hasMore: hasMore,
    );
  }
}

// ---------------------------------------------------------------------------
// DayAvailability — calendar day states
// ---------------------------------------------------------------------------

enum DayAvailability { available, booked, pending, past }

DayAvailability dayAvailabilityFromString(String s) {
  switch (s.toLowerCase()) {
    case 'booked':
      return DayAvailability.booked;
    case 'pending':
      return DayAvailability.pending;
    case 'available':
    default:
      return DayAvailability.available;
  }
}

// ---------------------------------------------------------------------------
// AdditionalService — stubbed catalog (replace with GET /mobile/additional-services/)
// ---------------------------------------------------------------------------

class AdditionalService {
  const AdditionalService({
    required this.id,
    required this.name,
    required this.price,
    required this.perDay,
  });

  final String id;
  final String name;
  final int price;

  /// true = price per day; false = flat fee
  final bool perDay;

  int totalFor(int days) => perDay ? price * days : price;
}

// TODO(backend): replace with GET /mobile/additional-services/
const List<AdditionalService> kStubAdditionalServices = [
  AdditionalService(
    id: 'child_seat',
    name: 'Child seat',
    price: 1000,
    perDay: true,
  ),
  AdditionalService(
    id: 'delivery',
    name: 'Delivery',
    price: 5000,
    perDay: false,
  ),
  AdditionalService(
    id: 'gps',
    name: 'GPS navigator',
    price: 500,
    perDay: true,
  ),
];

// ---------------------------------------------------------------------------
// Booking response model (minimal — M4 will expand)
// ---------------------------------------------------------------------------

class BookingResponse {
  const BookingResponse({
    required this.id,
    required this.vehicleId,
    required this.status,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.estimatedTotal,
  });

  final String id;
  final String vehicleId;
  final String status;
  final DateTime scheduledStart;
  final DateTime scheduledEnd;
  final int estimatedTotal;

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      id: json['id']?.toString() ?? '',
      vehicleId: json['vehicle_id']?.toString() ?? '',
      status: json['status'] as String? ?? 'pending',
      scheduledStart: DateTime.tryParse(
              json['scheduled_start'] as String? ?? '') ??
          DateTime.now(),
      scheduledEnd: DateTime.tryParse(
              json['scheduled_end'] as String? ?? '') ??
          DateTime.now(),
      estimatedTotal:
          (json['estimated_total'] as num?)?.toInt() ?? 0,
    );
  }
}

// ---------------------------------------------------------------------------
// Status helpers (kept from original)
// ---------------------------------------------------------------------------

Color carStatusColor(CarStatus status) {
  switch (status) {
    case CarStatus.available:
      return const Color(0xFF16A34A);
    case CarStatus.reserved:
      return const Color(0xFF7C3AED);
    case CarStatus.rented:
      return const Color(0xFF2563EB);
    case CarStatus.returning:
      return const Color(0xFFEAB308);
    case CarStatus.inService:
      return const Color(0xFFF97316);
    case CarStatus.inWash:
      return const Color(0xFF06B6D4);
    case CarStatus.decommissioned:
      return const Color(0xFF6B7280);
  }
}

String carStatusLabel(CarStatus status) {
  switch (status) {
    case CarStatus.available:
      return 'Available';
    case CarStatus.reserved:
      return 'Reserved';
    case CarStatus.rented:
      return 'Rented';
    case CarStatus.returning:
      return 'Returning';
    case CarStatus.inService:
      return 'In Service';
    case CarStatus.inWash:
      return 'In Wash';
    case CarStatus.decommissioned:
      return 'Decommissioned';
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _maskPlate(String plate) {
  if (plate.isEmpty) return '*** ***';
  final parts = plate.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    // Mask all but the last segment
    final last = parts.last;
    return '*** $last';
  }
  // Short plate: mask first half
  final half = (plate.length / 2).ceil();
  return '${'*' * half}${plate.substring(half)}';
}
