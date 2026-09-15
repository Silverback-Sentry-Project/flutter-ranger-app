import 'dart:async';

import 'package:workmanager/workmanager.dart';

import '../domain/repositories/incident_repository.dart';
import '../domain/repositories/patrol_repository.dart';
import '../service_locator.dart';

const String syncTaskName = 'silverback_sentry_sync';

abstract class IncidentSyncWorker {
  static Future<void> run() async {
    final repo = sl<IncidentRepository>();
    await repo.syncPending();
    repo.startObservingRemoteChanges();
  }
}

abstract class PatrolSyncWorker {
  static Future<void> run() async {
    await sl<PatrolRepository>().syncPending();
  }
}

@pragma('vm:entry-point')
void syncDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await IncidentSyncWorker.run();
    await PatrolSyncWorker.run();
    return true;
  });
}

class SyncScheduler {
  bool _started = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    await Workmanager().initialize(syncDispatcher);
    await Workmanager().registerPeriodicTask(
      syncTaskName,
      syncTaskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }

  Future<void> stop() async {
    await Workmanager().cancelByUniqueName(syncTaskName);
  }
}