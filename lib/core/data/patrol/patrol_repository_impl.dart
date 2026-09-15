import 'dart:async';

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../domain/repositories/patrol_remote_data_source.dart';
import '../../domain/repositories/patrol_repository.dart';
import '../../models/domain_enums.dart';
import '../../models/patrol_log.dart';
import '../hive_database.dart';
import 'patrol_remote_data_source_impl.dart';

class PatrolRepositoryImpl implements PatrolRepository {
  final PatrolRemoteDataSource _remoteDataSource = PatrolRemoteDataSourceImpl();
  final _uuid = const Uuid();

  Box<PatrolLogModel> get _box => HiveDatabase.patrolLogsBox;

  @override
  Stream<PatrolLogModel?> observeActivePatrol(String rangerUid) {
    final controller = StreamController<PatrolLogModel?>.broadcast();
    PatrolLogModel? current = _activePatrol(rangerUid);
    controller.add(current);
    final sub = _box.watch().listen((_) {
      final next = _activePatrol(rangerUid);
      if (next?.id != current?.id) {
        current = next;
        controller.add(next);
      } else {
        controller.add(next);
      }
    });
    sub.onDone(() => controller.close());
    return controller.stream;
  }

  PatrolLogModel? _activePatrol(String rangerUid) {
    for (final patrol in _box.values) {
      if (patrol.rangerUid == rangerUid && patrol.status == PatrolStatus.active) {
        return patrol;
      }
    }
    return null;
  }

  @override
  Future<PatrolLogModel> startPatrol(String rangerUid, String? parkId) async {
    final patrol = PatrolLogModel(
      id: _uuid.v4(),
      rangerUid: rangerUid,
      parkId: parkId,
      startTime: DateTime.now().toIso8601String(),
      statusName: PatrolStatus.active.name,
      syncStatusName: SyncStatus.pending.name,
      lastModified: DateTime.now().millisecondsSinceEpoch,
    );
    _box.add(patrol);
    return patrol;
  }

  @override
  Future<PatrolLogModel> resumeOrStartPatrol(
    String rangerUid,
    String? parkId,
  ) async {
    final existing = _activePatrol(rangerUid);
    if (existing != null) return existing;
    return startPatrol(rangerUid, parkId);
  }

  @override
  Future<void> appendPoint(String patrolId, RoutePoint point) async {
    final key = _findKey(patrolId);
    if (key == null) return;
    final patrol = _box.get(key);
    if (patrol == null) return;
    _box.put(
      key,
      patrol.copyWith(
        routePoints: [...patrol.routePoints, point],
        syncStatus: SyncStatus.pending,
        lastModified: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<void> stopPatrol(String patrolId) async {
    final key = _findKey(patrolId);
    if (key == null) return;
    final patrol = _box.get(key);
    if (patrol == null) return;
    _box.put(
      key,
      patrol.copyWith(
        endTime: DateTime.now().toIso8601String(),
        status: PatrolStatus.completed,
        syncStatus: SyncStatus.pending,
        lastModified: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    try {
      await _remoteDataSource.upsert(_box.get(key)!);
    } catch (_) {}
  }

  @override
  Future<PatrolSyncResult> syncPending() async {
    int succeeded = 0;
    int failed = 0;
    final pending = _box.values
        .where((p) => p.syncStatus == SyncStatus.pending)
        .toList();
    for (final patrol in pending) {
      try {
        await _remoteDataSource.upsert(patrol);
        final key = _findKey(patrol.id);
        if (key != null) {
          _box.put(key, patrol.copyWith(syncStatus: SyncStatus.synced));
        }
        succeeded++;
      } catch (_) {
        failed++;
      }
    }
    return PatrolSyncResult(succeeded: succeeded, failed: failed);
  }

  dynamic _findKey(String id) {
    for (final key in _box.keys) {
      if (_box.get(key)?.id == id) return key;
    }
    return null;
  }
}