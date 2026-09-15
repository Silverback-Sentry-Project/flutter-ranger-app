import 'dart:async';

import '../../models/patrol_log.dart';

abstract class PatrolRemoteDataSource {
  Future<void> upsert(PatrolLogModel patrolLog);
}