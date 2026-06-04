import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../models/app_notification.dart';

// Re-export so existing import sites continue to compile.
export '../models/app_notification.dart'
    show AppNotification, NotificationCategory, categoryIcon, categoryColor;

/// AsyncNotifier that fetches notifications from GET /mobile/notifications/
class NotificationsNotifier extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() async {
    return _fetch();
  }

  Future<List<AppNotification>> _fetch() async {
    final api = ref.read(mobileNotificationsApiProvider);
    final result = await api.list();
    return result.items;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  /// Marks a notification as read locally and calls POST …/{id}/read.
  Future<void> markAsRead(String id) async {
    // Optimistic local update.
    state = state.whenData((items) => [
          for (final n in items)
            if (n.id == id) n.copyWith(readAt: DateTime.now()) else n,
        ]);
    try {
      await ref.read(mobileNotificationsApiProvider).markRead(id);
    } catch (_) {
      // Best-effort — stale local state is acceptable.
    }
  }

  void markAllAsRead() {
    final now = DateTime.now();
    state = state.whenData((items) =>
        [for (final n in items) n.copyWith(readAt: now)]);
  }

  void dismiss(String id) {
    state = state.whenData(
        (items) => items.where((n) => n.id != id).toList());
  }
}

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<AppNotification>>(
        NotificationsNotifier.new);

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).maybeWhen(
        data: (items) => items.where((n) => !n.isRead).length,
        orElse: () => 0,
      );
});
