import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/repositories/notification_repository.dart';
import '../../../../core/models/app_notification.dart';
import '../../../../core/models/domain_enums.dart';
import '../../../../core/notifications/notification_routing.dart';
import '../../../../core/service_locator.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.checklist),
            tooltip: 'Mark all read',
            onPressed: () async {
              final repo = sl<NotificationRepository>();
              final notifications = await repo.observeAll().first;
              for (final n in notifications) {
                if (!n.isRead) await repo.markRead(n.id);
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<AppNotificationModel>>(
        stream: sl<NotificationRepository>().observeAll(),
        builder: (context, snapshot) {
          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications'));
          }
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _NotificationTile(
                notification: notification,
                onTap: () {
                  sl<NotificationRepository>().markRead(notification.id);
                  final path = notificationTargetPath(
                    notification.type,
                    notification.targetId,
                  );
                  if (path != null) context.push(path);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotificationModel notification;
  final VoidCallback onTap;
  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: notification.isRead
            ? scheme.surfaceContainerHighest
            : scheme.primary.withAlpha(38),
        child: Icon(
          _typeIcon(notification.type),
          color: notification.isRead ? scheme.onSurfaceVariant : scheme.primary,
        ),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Text(
        notification.message,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
      trailing: notification.isRead
          ? null
          : Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFFED4956),
                shape: BoxShape.circle,
              ),
            ),
    );
  }

  IconData _typeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.securityAlert:
        return Icons.warning_amber_outlined;
      case NotificationType.sightingApproved:
        return Icons.check_circle_outline;
      case NotificationType.pendingSync:
        return Icons.cloud_upload_outlined;
      case NotificationType.newFeedArticle:
        return Icons.article_outlined;
      case NotificationType.like:
        return Icons.favorite_outline;
      case NotificationType.comment:
        return Icons.chat_bubble_outline;
      default:
        return Icons.notifications_outlined;
    }
  }
}