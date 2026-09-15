import 'dart:async';

import '../../models/patrol_log.dart';

class PatrolSyncResult {
  final int succeeded;
  final int failed;
  const PatrolSyncResult({required this.succeeded, required this.failed});
}

abstract class PatrolRepository {
  Stream<PatrolLogModel?> observeActivePatrol(String rangerUid);

  Future<PatrolLogModel> startPatrol(String rangerUid, String? parkId);

  Future<PatrolLogModel> resumeOrStartPatrol(String rangerUid, String? parkId);

  Future<void> appendPoint(String patrolId, RoutePoint point);

  Future<void> stopPatrol(String patrolId);

  Future<PatrolSyncResult> syncPending();
}