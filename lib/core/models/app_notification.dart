import 'package:flutter/material.dart';

/// High-level category for grouping and icon mapping.
enum NotificationCategory {
  booking,
  fine,
  payment,
  document,
  promotion,
  critical,
}

NotificationCategory _categoryFromType(String type) {
  if (type.startsWith('booking') ||
      type == 'pickup_reminder' ||
      type == 'return_reminder' ||
      type == 'overdue_alert' ||
      type == 'rental_completed') {
    return NotificationCategory.booking;
  }
  if (type == 'fine_added') return NotificationCategory.fine;
  if (type.startsWith('payment')) return NotificationCategory.payment;
  if (type.startsWith('document')) return NotificationCategory.document;
  if (type == 'promotion') return NotificationCategory.promotion;
  return NotificationCategory.critical;
}

IconData categoryIcon(NotificationCategory cat) => switch (cat) {
      NotificationCategory.booking => Icons.calendar_today_rounded,
      NotificationCategory.fine => Icons.receipt_long_rounded,
      NotificationCategory.payment => Icons.payment_rounded,
      NotificationCategory.document => Icons.badge_outlined,
      NotificationCategory.promotion => Icons.local_offer_rounded,
      NotificationCategory.critical => Icons.warning_amber_rounded,
    };

Color categoryColor(NotificationCategory cat) => switch (cat) {
      NotificationCategory.booking => const Color(0xFF1A73E8),
      NotificationCategory.fine => const Color(0xFFDC2626),
      NotificationCategory.payment => const Color(0xFF16A34A),
      NotificationCategory.document => const Color(0xFF7C3AED),
      NotificationCategory.promotion => const Color(0xFF7C3AED),
      NotificationCategory.critical => const Color(0xFFEAB308),
    };

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.category,
    this.data = const {},
    this.readAt,
  });

  final String id;

  /// Raw type string from backend: booking_confirmed, fine_added, etc.
  final String type;
  final String title;
  final String body;
  final DateTime createdAt;
  final NotificationCategory category;
  final Map<String, dynamic> data;
  final DateTime? readAt;

  bool get isRead => readAt != null;

  AppNotification copyWith({DateTime? readAt}) => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        createdAt: createdAt,
        category: category,
        data: data,
        readAt: readAt ?? this.readAt,
      );

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'general';
    final createdRaw =
        json['created_at'] as String? ?? json['createdAt'] as String? ?? '';
    final readRaw =
        json['read_at'] as String? ?? json['readAt'] as String?;
    final rawData = json['data'];
    final data = rawData is Map<String, dynamic> ? rawData : const <String, dynamic>{};

    return AppNotification(
      id: (json['id'] ?? '').toString(),
      type: type,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? json['message'] as String? ?? '',
      createdAt: DateTime.tryParse(createdRaw) ?? DateTime.now(),
      category: _categoryFromType(type),
      data: data,
      readAt: readRaw != null ? DateTime.tryParse(readRaw) : null,
    );
  }
}
