import 'dart:async';

import '../../models/app_notification.dart';
import '../../models/domain_enums.dart';

abstract class NotificationRepository {
  Stream<List<AppNotificationModel>> observeAll();

  Stream<int> observeUnreadCount();

  Future<void> markRead(String id);

  Future<void> notifyPendingSync(String incidentId);

  Future<void> clearAll();

  Future<void> recordIncoming(
    NotificationType type,
    String title,
    String message,
    String? targetId,
  );
}