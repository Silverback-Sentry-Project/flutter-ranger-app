import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../data/hive_database.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/incident_remote_data_source.dart';
import '../../domain/repositories/incident_repository.dart';
import '../../domain/repositories/sync_result.dart';
import '../../error/failure.dart';
import '../../models/domain_enums.dart';
import '../../models/incident.dart';
import '../../network/laravel_bridge_data_source.dart';
import '../../service_locator.dart';
import 'incident_remote_data_source_impl.dart';

class IncidentRepositoryImpl implements IncidentRepository {
  final IncidentRemoteDataSource _remoteDataSource;
  final LaravelBridgeDataSource _laravelBridge;
  final _uuid = const Uuid();
  StreamSubscription? _remoteSub;
  final _syncMutex = _Mutex();

  IncidentRepositoryImpl({
    IncidentRemoteDataSource? remoteDataSource,
    LaravelBridgeDataSource? laravelBridge,
  })  : _remoteDataSource = remoteDataSource ?? IncidentRemoteDataSourceImpl(),
        _laravelBridge = laravelBridge ?? sl<LaravelBridgeDataSource>();

  Box<IncidentModel> get _box => HiveDatabase.incidentsBox;

  @override
  Stream<List<IncidentModel>> observeAll() {
    final controller = StreamController<List<IncidentModel>>.broadcast();
    controller.add(_box.values.toList());
    final sub = _box.watch().listen((_) {
      controller.add(_box.values.toList());
    });
    sub.onDone(() => controller.close());
    return controller.stream;
  }

  @override
  Future<IncidentModel?> getById(String id) async {
    final key = _box.keys.firstWhere(
      (k) => _box.get(k)?.id == id,
      orElse: () => null,
    );
    return key == null ? null : _box.get(key);
  }

  @override
  Future<Either<Failure, IncidentModel>> create(
    NewIncidentDetails details, {
    bool asDraft = false,
  }) async {
    try {
      final user = await sl<AuthRepository>().currentUser.first;
      final id = _uuid.v4();
      final now = DateTime.now().toIso8601String();
      final incident = IncidentModel(
        id: id,
        typeName: details.type.name,
        statusName: IncidentStatus.open.name,
        parkName: details.park.name,
        district: details.district,
        subCounty: details.subCounty,
        parish: details.parish,
        community: details.community,
        species: details.species,
        severityName: details.severity.name,
        category: details.category,
        summary: details.summary,
        lat: details.lat,
        lng: details.lng,
        locationName: details.locationName,
        localImageUris: details.localImageUris,
        animalSeen: details.animalSeen,
        answersJson: details.answersJson,
        schemaVersion: details.schemaVersion,
        userName: user?.displayName,
        userEmail: user?.email,
        userId: user?.uid,
        reportedAt: now,
        syncStatusName: asDraft ? SyncStatus.draft.name : SyncStatus.pending.name,
        lastModified: DateTime.now().millisecondsSinceEpoch,
      );
      _box.add(incident);
      if (!asDraft) {
        try {
          final uploaded = await _remoteDataSource.upsert(incident);
          _updateLocal(uploaded);
          final bridge = await _laravelBridge.postIncidentEvent(uploaded, 'create');
          if (bridge.isRight()) {
            final synced = uploaded.copyWith(
              syncStatus: SyncStatus.synced,
              syncedAt: DateTime.now().toIso8601String(),
            );
            _updateLocal(synced);
            return right(synced);
          }
          return right(uploaded);
        } catch (_) {
          return right(incident);
        }
      }
      return right(incident);
    } catch (e) {
      return left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, void>> update(
    String id,
    NewIncidentDetails details, {
    bool asDraft = false,
  }) async {
    try {
      final existing = await getById(id);
      if (existing == null) return left(CacheFailure('Incident not found'));
      final updated = existing.copyWith(
        type: details.type,
        status: asDraft ? null : existing.status,
        park: details.park,
        district: details.district,
        subCounty: details.subCounty,
        parish: details.parish,
        community: details.community,
        species: details.species,
        severity: details.severity,
        category: details.category,
        summary: details.summary,
        lat: details.lat,
        lng: details.lng,
        locationName: details.locationName,
        localImageUris: details.localImageUris,
        animalSeen: details.animalSeen,
        answersJson: details.answersJson,
        syncStatus: SyncStatus.pendingUpdate,
        lastModified: DateTime.now().millisecondsSinceEpoch,
      );
      _updateLocal(updated);
      if (!asDraft) {
        try {
          final uploaded = await _remoteDataSource.upsert(updated);
          _updateLocal(uploaded);
          final bridge = await _laravelBridge.postIncidentEvent(uploaded, 'update');
          if (bridge.isRight()) {
            _updateLocal(uploaded.copyWith(
              syncStatus: SyncStatus.synced,
              syncedAt: DateTime.now().toIso8601String(),
            ));
          }
        } catch (_) {}
      }
      return right(null);
    } catch (e) {
      return left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, void>> assignToSelf(String id) async {
    try {
      final existing = await getById(id);
      if (existing == null) return left(CacheFailure('Incident not found'));
      final user = await sl<AuthRepository>().currentUser.first;
      if (user == null) return right(null);
      final updated = existing.copyWith(
        status: IncidentStatus.inProgress,
        rangerProgress: RangerProgress.enRoute,
        assignedTo: user.uid,
        assignedToName: user.displayNameOrFallback,
        syncStatus: SyncStatus.pendingUpdate,
        lastModified: DateTime.now().millisecondsSinceEpoch,
      );
      _updateLocal(updated);
      try {
        final uploaded = await _remoteDataSource.upsert(updated);
        _updateLocal(uploaded);
        final bridge = await _laravelBridge.postIncidentEvent(uploaded, 'update');
        if (bridge.isRight()) {
          _updateLocal(uploaded.copyWith(
            syncStatus: SyncStatus.synced,
            syncedAt: DateTime.now().toIso8601String(),
          ));
        }
      } catch (_) {}
      return right(null);
    } catch (e) {
      return left(ServerFailure('$e'));
    }
  }

  @override
  Future<SyncResult> syncPending() => _syncMutex.run(() async {
        int succeeded = 0;
        int failed = 0;
        final pending = _box.values.where(
          (i) => i.syncStatus == SyncStatus.pending ||
              i.syncStatus == SyncStatus.pendingUpdate ||
              i.syncStatus == SyncStatus.failed,
        );
        for (final incident in pending) {
          final eventType =
              incident.syncStatus == SyncStatus.pending ? 'create' : 'update';
          try {
            final uploaded = await _remoteDataSource.upsert(incident);
            _updateLocal(uploaded);
            final bridge =
                await _laravelBridge.postIncidentEvent(uploaded, eventType);
            if (bridge.isRight()) {
              _updateLocal(uploaded.copyWith(
                syncStatus: SyncStatus.synced,
                syncedAt: DateTime.now().toIso8601String(),
              ));
              succeeded++;
            } else {
              failed++;
            }
          } catch (_) {
            _updateLocal(incident.copyWith(
              syncStatus: SyncStatus.failed,
              lastModified: DateTime.now().millisecondsSinceEpoch,
            ));
            failed++;
          }
        }
        return SyncResult(succeeded: succeeded, failed: failed);
      });

  @override
  void startObservingRemoteChanges() {
    _remoteSub?.cancel();
    _remoteSub = _remoteDataSource.observeChanges().listen((change) {
      if (change.isRemoved) {
        _removeById(change.incident.id);
      } else {
        _upsertLocal(change.incident);
      }
    });
  }

  void _updateLocal(IncidentModel incident) {
    final key = _box.keys.firstWhere(
      (k) => _box.get(k)?.id == incident.id,
      orElse: () => null,
    );
    if (key != null) _box.put(key, incident);
  }

  void _upsertLocal(IncidentModel incident) {
    final key = _box.keys.firstWhere(
      (k) => _box.get(k)?.id == incident.id,
      orElse: () => null,
    );
    if (key != null) {
      _box.put(key, incident);
    } else {
      _box.add(incident);
    }
  }

  void _removeById(String id) {
    final key = _box.keys.firstWhere(
      (k) => _box.get(k)?.id == id,
      orElse: () => null,
    );
    if (key != null) _box.delete(key);
  }
}

class _Mutex {
  Future<void> _tail = Future.value();

  Future<T> run<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _tail = _tail.then((_) async {
      try {
        final value = await action();
        completer.complete(value);
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }
}