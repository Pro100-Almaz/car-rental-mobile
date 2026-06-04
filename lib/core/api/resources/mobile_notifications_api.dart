import 'package:dio/dio.dart';

import '../../models/app_notification.dart';
import '../api_endpoints.dart';
import '../error_mapper.dart';

/// Paginated wrapper used by the notifications list response.
class PaginatedNotifications {
  const PaginatedNotifications({
    required this.items,
    required this.page,
    this.totalCount,
  });

  final List<AppNotification> items;
  final int page;
  final int? totalCount;
}

/// Notifications resource: /mobile/notifications/*
class MobileNotificationsApi {
  const MobileNotificationsApi(this._dio);
  final Dio _dio;

  /// GET /mobile/notifications/?page=N
  Future<PaginatedNotifications> list({
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.notifications,
        queryParameters: {'page': page, 'page_size': pageSize},
      );

      final data = response.data;
      List<dynamic> rawItems;
      int? totalCount;

      if (data is List) {
        rawItems = data;
      } else if (data is Map<String, dynamic>) {
        rawItems = data['results'] as List? ?? [];
        totalCount = data['count'] as int?;
      } else {
        rawItems = const [];
      }

      final items = rawItems
          .whereType<Map<String, dynamic>>()
          .map(AppNotification.fromJson)
          .toList();

      return PaginatedNotifications(
        items: items,
        page: page,
        totalCount: totalCount,
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// POST /mobile/notifications/{id}/read
  Future<void> markRead(String notificationId) async {
    try {
      await _dio.post(ApiEndpoints.readNotification(notificationId));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
