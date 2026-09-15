import 'dart:async';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../domain/repositories/location_repository.dart';
import '../domain/repositories/patrol_repository.dart';
import '../models/patrol_log.dart';
import '../service_locator.dart';

class PatrolTrackingService {
  static const String _channelId = 'patrol_tracking';
  static const String _channelName = 'Patrol tracking';

  StreamSubscription? _locationSub;
  static bool _foregroundConfigured = false;

  Future<void> startTracking(String rangerUid, String? parkId) async {
    final patrolRepo = sl<PatrolRepository>();
    final patrol = await patrolRepo.resumeOrStartPatrol(rangerUid, parkId);
    await _startForegroundService();
    _locationSub?.cancel();
    _locationSub = sl<LocationRepository>()
        .observeLocationUpdates(30000)
        .listen((location) {
      patrolRepo.appendPoint(
        patrol.id,
        RoutePoint(
          lat: location.latitude,
          lng: location.longitude,
          timestamp: DateTime.now().toIso8601String(),
        ),
      );
    });
  }

  Future<void> stopTracking(String patrolId) async {
    _locationSub?.cancel();
    _locationSub = null;
    await _stopForegroundService();
    await sl<PatrolRepository>().stopPatrol(patrolId);
    await sl<PatrolRepository>().syncPending();
  }

  Future<void> _startForegroundService() async {
    if (!_foregroundConfigured) {
      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: _channelId,
          channelName: _channelName,
          channelDescription:
              'Shown while background patrol GPS tracking is active',
          channelImportance: NotificationChannelImportance.LOW,
          priority: NotificationPriority.LOW,
          enableVibration: false,
          playSound: false,
          showWhen: false,
          showBadge: false,
        ),
        iosNotificationOptions: const IOSNotificationOptions(
          showNotification: true,
          playSound: false,
        ),
        foregroundTaskOptions: ForegroundTaskOptions(
          eventAction: ForegroundTaskEventAction.nothing(),
          autoRunOnBoot: false,
          allowWakeLock: true,
        ),
      );
      _foregroundConfigured = true;
    }
    if (!await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.startService(
        serviceTypes: const [ForegroundServiceTypes.location],
        notificationTitle: 'Patrol tracking active',
        notificationText: 'Recording your route in the background',
      );
    }
  }

  Future<void> _stopForegroundService() async {
    try {
      await FlutterForegroundTask.stopService();
    } catch (_) {}
  }

  void dispose() {
    _locationSub?.cancel();
    _locationSub = null;
  }
}