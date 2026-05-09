import 'package:flutter/material.dart';

class CarCategory {
  const CarCategory(this.id, this.label);
  final String id;
  final String label;
}

const List<CarCategory> kCarCategories = [
  CarCategory('all', 'All'),
  CarCategory('economy', 'Economy'),
  CarCategory('comfort', 'Comfort'),
  CarCategory('business', 'Business'),
  CarCategory('suv', 'SUV'),
];

class CarListing {
  const CarListing({
    required this.id,
    required this.name,
    required this.tagline,
    required this.imageUrl,
    required this.pricePerHour,
    required this.pricePerDay,
    required this.rating,
    required this.reviewCount,
    required this.distanceMeters,
    required this.category,
    required this.seats,
    required this.transmission,
    required this.year,
    required this.plateNumber,
    required this.fuelLevel,
    this.status = CarStatus.available,
    this.description =
        'Comfortable and well-maintained vehicle from our fleet. Fully insured with 24/7 roadside support.',
  });

  final String id;
  final String name;
  final String tagline;
  final String imageUrl;
  final int pricePerHour;
  final int pricePerDay;
  final double rating;
  final int reviewCount;
  final int distanceMeters;
  final String category;
  final int seats;
  final String transmission;
  final int year;
  final String plateNumber;
  final double fuelLevel;
  final CarStatus status;
  final String description;
}

enum CarStatus {
  available,
  reserved,
  rented,
  returning,
  inService,
  inWash,
  decommissioned,
}

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

const List<CarListing> kNearbyCars = [
  CarListing(
    id: 'camry-2023',
    name: 'Toyota Camry',
    tagline: 'Comfort class sedan',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCSn5OvPec5q6JvkFyRskxBcna8MlbYtAIEHMsCIi5yfezWKIDEHqTh_VwfM21mQsXHjm0xUmpNgGCW8RlD3u1fkrZfHakTtCEiSW627SpNtPw0nb4J91y35wF_FswrUZb7nC2njbjQGoxTQiFd1W8c1ab7DvVsESCNdOtqij_YbcdMh37GeVKZ_gGru9Vn5P8UFUvw0rb1mGlJD8f6dbELTml3WEgw2JmXQ4GZVlkYauTRrN67VXGo249doBM4ou1_EiEIshh62STs',
    pricePerHour: 800,
    pricePerDay: 8000,
    rating: 4.9,
    reviewCount: 212,
    distanceMeters: 350,
    category: 'comfort',
    seats: 5,
    transmission: 'Auto',
    year: 2023,
    plateNumber: 'KA 222 TTA',
    fuelLevel: 0.85,
  ),
  CarListing(
    id: 'tucson-2024',
    name: 'Hyundai Tucson',
    tagline: 'Spacious family SUV',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBDe9WAU9Y32fp7mxm8VT7HH7a4EXUA7ULshade1wI3HZ7HKP0j0KILQ5e4FqDDjHurkbN-eA_F19QM0sMo2JVO4BR7qi360LK7UeoL4_eV_jvRo4LpmnnIa4GsDMBvnXPtiowRdsq2KbWSLN0VeH6aPEJ_HegHlJV_X4MxI2OY4a0H6DZI2yscBi3cpOvp3EZs1HXzTUVg4HxX-UlEOjXb8JePipRI16TkF0Bs0RKPwriS93B08bj0gTX-6mJNUo_atghiAhY9PlX2',
    pricePerHour: 1200,
    pricePerDay: 12000,
    rating: 4.8,
    reviewCount: 86,
    distanceMeters: 750,
    category: 'suv',
    seats: 5,
    transmission: 'Auto',
    year: 2024,
    plateNumber: 'KA 456 BCD',
    fuelLevel: 0.72,
  ),
  CarListing(
    id: 'kia-k5',
    name: 'Kia K5',
    tagline: 'Economy with style',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBAeZFhSSJsoutDhcuWnNfgh-d7ZpjUCjrWIVYQSVPkYKB9wU4sTPgkfBY550hCuJ2zIEaRck5ASG--i8xZlE8T9mNEr-wz4YwkSPVApKpPjhWpIJfcRC8vsUk99-xZGz_isFzlmSWdKQmKAFfJmlRdsvZTGpyoN0CKtpL6WZ_Qh3fGSvzlstw_mngcM70ZAaBY-Q5HVupX1wOvBauUmxXKHTTXjHi9tBVVcx4P06RYB5qQALV-2wlbWK4EO4GthICf6ETmJig6sRWM',
    pricePerHour: 600,
    pricePerDay: 6000,
    rating: 4.7,
    reviewCount: 128,
    distanceMeters: 200,
    category: 'economy',
    seats: 5,
    transmission: 'Auto',
    year: 2023,
    plateNumber: 'KA 789 EFG',
    fuelLevel: 0.90,
  ),
];

const List<CarListing> kTopRated = [
  CarListing(
    id: 'mercedes-e-class',
    name: 'Mercedes-Benz E-Class',
    tagline: 'Premium business sedan',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCVf_bNClrNRpg6iiPogTtENm7qdAcqE9-9MEKrM_odC22IQi9-h8Ttia86N3kfFLfWMYnwKKFIImOLXkgo2urDGxeXyXiCufg7AY0hWa0MAeUwmu_nkMjuCjTH9diYXaOUCjb_jArFLSGydOA-Sm5lDEmBefr6MriV_Iuna81cMz5ByyGLfN_XgW_1I6f0pdW7Mn3Z4b1kILN33b2calhm49J-fyA4izaqcxi0sMh7lMs4ilAn-u0rK06MW3ary9aW35q2OPI_WG5o',
    pricePerHour: 2500,
    pricePerDay: 25000,
    rating: 5.0,
    reviewCount: 120,
    distanceMeters: 1200,
    category: 'business',
    seats: 5,
    transmission: 'Auto',
    year: 2024,
    plateNumber: 'KA 001 LUX',
    fuelLevel: 0.95,
  ),
  CarListing(
    id: 'toyota-corolla',
    name: 'Toyota Corolla',
    tagline: 'Reliable economy choice',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBXd2mNDto6UZ2qBRG7mGMvKLf9cxqkNGfRpqmxBrBXYZy1vbSpUct9rjeDvKvpBjmDOOxysHs2eqb6zeJGvLRv2q-DVzmIrfa3POBl1YQXK0SxPY4Uqt3PZ5ugF_QkgtpOaGz6rMtehqdLH63rWW5fKPFlmfzo4DKxKhTrS-CpCLju8TDYRvlFRJ9IYjewgOgjz2FPX2Z9V0oFVtgqgKusP9PJefkYS5QikKg3z2_yvzt8HQ6IbMNUFlrelvXTn91DzcRcWYJ9aPMk',
    pricePerHour: 500,
    pricePerDay: 5000,
    rating: 4.9,
    reviewCount: 245,
    distanceMeters: 500,
    category: 'economy',
    seats: 5,
    transmission: 'Auto',
    year: 2023,
    plateNumber: 'KA 112 ABC',
    fuelLevel: 0.80,
  ),
];

class BookingSummary {
  const BookingSummary({
    required this.id,
    required this.carName,
    required this.imageUrl,
    required this.category,
    required this.dateRange,
    required this.status,
    required this.total,
    required this.statusColor,
  });

  final String id;
  final String carName;
  final String imageUrl;
  final String category;
  final String dateRange;
  final String status;
  final int total;
  final Color statusColor;
}

const List<BookingSummary> kUpcomingBookings = [
  BookingSummary(
    id: 'b1',
    carName: 'Toyota Camry',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBgX6gvNsdDqjarsBP5NG2-mvXtENO7c8q3yDxTdvaWowT2XKBcuT5RLEcPHGl9XBUN5g9-faB67vu2cjTZ-jTuPAmh2sI9AT6vb8gd0ZD5tk-IkLxVvZFPRyjKkQ3euNkJE7mZDKY1BUnrwZVsjh9MA7Caw8vuTQKwrsjtReoh77TQpaYsAxfCRdkM0c6wsaMwglQq8R2G95F952I42aPe4bZrll_7a7JgnRBccMGOAXIApfnYUHsvwDEomSP-YuY5kQtM1j52SW7v',
    category: 'comfort',
    dateRange: 'range1',
    status: 'confirmed',
    total: 24000,
    statusColor: Color(0xFF16A34A),
  ),
  BookingSummary(
    id: 'b2',
    carName: 'Mercedes-Benz E-Class',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuALL4nIg4zzrYI9Zi71VmGAnQcasipFNTj4NHD-m8d5N0Q11OK5mJ0blOI1alcVT5b5sWoHWN-Z4834FBlQfikHvwc7spxJf87YKub6fWNeLaAz_mcFf3WYxww9mdLVM8xdA9qRA8yzyUV8-Q1kcZPyvFsWI2FgCtzEjy4TBpAguHyRkZdBJ0DxJ7deJrQL7bI-8cWb5FOK8p9NyhtLSIK7L263MW23X48rTlaU8UmEClcG3xiCBWx_i4uH-JX1wMbdcasD9DRuAdIZ',
    category: 'business',
    dateRange: 'range2',
    status: 'confirmed',
    total: 75000,
    statusColor: Color(0xFF16A34A),
  ),
];
