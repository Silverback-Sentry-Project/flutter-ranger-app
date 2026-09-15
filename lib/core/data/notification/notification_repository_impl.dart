import 'dart:async';
import 'package:uuid/uuid.dart';

import '../../domain/repositories/notification_repository.dart';
import '../../models/app_notification.dart';
import '../../models/domain_enums.dart';
import '../hive_database.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final _uuid = const Uuid();
  StreamSubscription? _watchSub;
  final _streamController = StreamController<List<AppNotificationModel>>.broadcast();
  final _unreadController = StreamController<int>.broadcast();

  NotificationRepositoryImpl() {
    _watchSub = HiveDatabase.notificationsBox.watch().listen((_) {
      _streamController.add(HiveDatabase.notificationsBox.values.toList());
      _unreadController.add(_unreadCount());
    });
    _streamController.add(HiveDatabase.notificationsBox.values.toList());
    _unreadController.add(_unreadCount());
  }

  void dispose() {
    _watchSub?.cancel();
    _streamController.close();
    _unreadController.close();
  }

  @override
  Stream<List<AppNotificationModel>> observeAll() => _streamController.stream;

  @override
  Stream<int> observeUnreadCount() => _unreadController.stream;

  int _unreadCount() => HiveDatabase.notificationsBox.values
      .where((n) => !n.isRead)
      .length;

  @override
  Future<void> markRead(String id) async {
    final box = HiveDatabase.notificationsBox;
    final key = box.keys.firstWhere(
      (k) => box.get(k)?.id == id,
      orElse: () => null,
    );
    if (key != null) {
      final n = box.get(key);
      if (n != null) box.put(key, n.copyWith(isRead: true));
    }
  }

  @override
  Future<void> recordIncoming(
    NotificationType type,
    String title,
    String message,
    String? targetId,
  ) async {
    final notification = AppNotificationModel(
      id: _uuid.v4(),
      typeName: type.name,
      title: title,
      message: message,
      isRead: false,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      targetId: targetId,
    );
    HiveDatabase.notificationsBox.add(notification);
  }

  @override
  Future<void> notifyPendingSync(String incidentId) async {
    await recordIncoming(
      NotificationType.pendingSync,
      'Pending sync',
      'An incident is waiting to sync',
      incidentId,
    );
  }

  @override
  Future<void> clearAll() async {
    HiveDatabase.notificationsBox.clear();
  }
}