import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/notification_provider.dart';
import '../../core/push/notification_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/error_retry_widget.dart';
import '../../core/widgets/shimmer_box.dart';
import '../../l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Time helpers
// ---------------------------------------------------------------------------

String _timeAgo(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'Yesterday';
  return '${diff.inDays}d ago';
}

bool _isToday(DateTime t) {
  final now = DateTime.now();
  return t.year == now.year && t.month == now.month && t.day == now.day;
}

bool _isThisWeek(DateTime t) {
  final now = DateTime.now();
  final weekStart = now.subtract(Duration(days: now.weekday - 1));
  return !_isToday(t) &&
      t.isAfter(weekStart.subtract(const Duration(days: 1)));
}

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final notifAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.neutral900),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.notificationsTitle,
          style: const TextStyle(
            color: AppColors.neutral900,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          notifAsync.maybeWhen(
            data: (items) => TextButton(
              onPressed: items.any((n) => !n.isRead)
                  ? () =>
                      ref.read(notificationsProvider.notifier).markAllAsRead()
                  : null,
              child: Text(
                'Mark all read',
                style: TextStyle(
                  color: items.any((n) => !n.isRead)
                      ? AppColors.primary
                      : AppColors.neutral300,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: notifAsync.when(
        loading: () => const _NotificationsLoadingSkeleton(),
        error: (e, _) => ErrorRetryWidget(
          message: 'Could not load notifications. Please try again.',
          onRetry: () => ref.invalidate(notificationsProvider),
        ),
        data: (notifications) => RefreshIndicator(
          onRefresh: () =>
              ref.read(notificationsProvider.notifier).refresh(),
          child: notifications.isEmpty
              ? ListView(children: [
                  SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.25),
                  EmptyStateView(
                    icon: Icons.notifications_off_outlined,
                    title: l10n.notificationsEmpty,
                  ),
                ])
              : _NotificationsList(notifications: notifications),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading skeleton (M6.A)
// ---------------------------------------------------------------------------

class _NotificationsLoadingSkeleton extends StatelessWidget {
  const _NotificationsLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      children: List.generate(
        5,
        (_) => Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(
                  width: 12,
                  height: 12,
                  borderRadius: BorderRadius.circular(6)),
              const SizedBox(width: AppSpacing.xs),
              ShimmerBox(
                  width: 40,
                  height: 40,
                  borderRadius: BorderRadius.circular(AppRadius.md)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(
                        height: 14,
                        width: double.infinity,
                        borderRadius: BorderRadius.circular(4)),
                    const SizedBox(height: 6),
                    ShimmerBox(
                        height: 12,
                        width: 200,
                        borderRadius: BorderRadius.circular(4)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationsList extends ConsumerWidget {
  const _NotificationsList({required this.notifications});
  final List<AppNotification> notifications;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);

    final today = notifications.where((n) => _isToday(n.createdAt)).toList();
    final thisWeek =
        notifications.where((n) => _isThisWeek(n.createdAt)).toList();
    final earlier = notifications
        .where((n) => !_isToday(n.createdAt) && !_isThisWeek(n.createdAt))
        .toList();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      children: [
        if (today.isNotEmpty) ...[
          _GroupHeader(l10n.notificationsToday),
          ...today.map((n) => _NotificationCard(
                notification: n,
                onTap: () {
                  ref.read(notificationsProvider.notifier).markAsRead(n.id);
                  routeNotification(context, n);
                },
                onDismiss: () =>
                    ref.read(notificationsProvider.notifier).dismiss(n.id),
              )),
        ],
        if (thisWeek.isNotEmpty) ...[
          _GroupHeader(l10n.notificationsThisWeek),
          ...thisWeek.map((n) => _NotificationCard(
                notification: n,
                onTap: () {
                  ref.read(notificationsProvider.notifier).markAsRead(n.id);
                  routeNotification(context, n);
                },
                onDismiss: () =>
                    ref.read(notificationsProvider.notifier).dismiss(n.id),
              )),
        ],
        if (earlier.isNotEmpty) ...[
          _GroupHeader(l10n.notificationsEarlier),
          ...earlier.map((n) => _NotificationCard(
                notification: n,
                onTap: () {
                  ref.read(notificationsProvider.notifier).markAsRead(n.id);
                  routeNotification(context, n);
                },
                onDismiss: () =>
                    ref.read(notificationsProvider.notifier).dismiss(n.id),
              )),
        ],
      ],
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral500,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(notification.category);
    final icon = categoryIcon(notification.category);

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        color: AppColors.error,
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.white, size: 24),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: notification.isRead
                  ? AppColors.white
                  : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: notification.isRead
                    ? AppColors.neutral200
                    : AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Unread dot
                SizedBox(
                  width: 12,
                  child: notification.isRead
                      ? null
                      : Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                ),
                const SizedBox(width: AppSpacing.xs),
                // Type icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: notification.isRead
                                    ? FontWeight.w500
                                    : FontWeight.w700,
                                color: AppColors.neutral900,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            _timeAgo(notification.createdAt),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.neutral500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        notification.body,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.neutral700,
                          height: 1.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
