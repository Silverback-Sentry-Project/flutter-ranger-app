import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../data/hive_database.dart';
import '../data/notification/notification_repository_impl.dart';
import '../domain/repositories/notification_repository.dart';
import '../models/domain_enums.dart';
import '../notifications/fcm_topics.dart';
import '../notifications/notification_routing.dart';
import '../service_locator.dart' as di;

typedef NotificationTapCallback = void Function(String path);

class AppServices {
  static FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();
  static NotificationTapCallback? _onTap;
  static int _notificationId = 0;

  static Future<void> initialize() async {
    await _initLocalNotifications();
    await FirebaseMessaging.instance.requestPermission();
    try {
      await GoogleSignIn.instance.initialize();
    } catch (_) {}
  }

  static Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        final path = response.payload;
        if (path != null && path.isNotEmpty) _onTap?.call(path);
      },
    );
  }

  static void configureMessageHandling(NotificationTapCallback onTap) {
    _onTap = onTap;
    FirebaseMessaging.onMessage.listen(_showForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_routeMessage);
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) _routeMessage(message);
    });
    FirebaseMessaging.instance.onTokenRefresh.listen((_) {
      di.sl<FcmTokenRepository>().syncToken();
    });
    getNotificationAppLaunchDetails(onTap);
  }

  static void getNotificationAppLaunchDetails(NotificationTapCallback onTap) {
    localNotifications.getNotificationAppLaunchDetails().then((details) {
      if (details?.didNotificationLaunchApp == true &&
          details?.notificationResponse?.payload != null) {
        final path = details!.notificationResponse!.payload!;
        if (path.isNotEmpty) onTap(path);
      }
    }).catchError((_) {});
  }

  static Future<void> _showForegroundMessage(RemoteMessage message) async {
    final type = NotificationType.fromWire(message.data['type']);
    final targetId = notificationTargetId(type, message.data);
    final title = message.notification?.title ?? 'SilverBack Sentry';
    final body = message.notification?.body ?? '';
    await showLocalNotification(title, body, notificationTargetPath(type, targetId));
    if (type != null) {
      await di.sl<NotificationRepository>()
          .recordIncoming(type, title, body, targetId);
    }
  }

  static void _routeMessage(RemoteMessage message) {
    final type = NotificationType.fromWire(message.data['type']);
    final targetId = notificationTargetId(type, message.data);
    final path = notificationTargetPath(type, targetId);
    if (path != null) _onTap?.call(path);
  }

  static Future<void> showLocalNotification(
    String title,
    String body,
    String? path,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'SilverBack Sentry Alerts',
      channelDescription: 'Urgent conservation and security updates',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      enableLights: true,
    );
    const details = NotificationDetails(android: androidDetails);
    await localNotifications.show(
      id: _notificationId++,
      title: title,
      body: body,
      notificationDetails: details,
      payload: path,
    );
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await HiveDatabase.init();
    await AppServices._initLocalNotifications();
  } catch (_) {}
  final type = NotificationType.fromWire(message.data['type']);
  final targetId = notificationTargetId(type, message.data);
  final title = message.notification?.title ?? 'SilverBack Sentry';
  final body = message.notification?.body ?? '';
  try {
    await AppServices.showLocalNotification(
        title, body, notificationTargetPath(type, targetId));
  } catch (_) {}
  if (type != null) {
    try {
      await NotificationRepositoryImpl().recordIncoming(type, title, body, targetId);
    } catch (_) {}
  }
}