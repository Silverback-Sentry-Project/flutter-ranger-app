import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import '../../domain/repositories/device_session_repository.dart';
import '../../error/failure.dart';
import '../hive_database.dart';

class DeviceSessionRepositoryImpl implements DeviceSessionRepository {
  static const _keyDeviceId = 'device_id';
  static const _keySessionVersion = 'session_version';

  final _uuid = const Uuid();
  late final HttpsCallable _syncActiveDevice =
      FirebaseFunctions.instance.httpsCallable('syncActiveDevice');

  String _getOrCreateDeviceId() {
    final box = HiveDatabase.settingsBox;
    var id = box.get(_keyDeviceId) as String?;
    if (id == null) {
      id = _uuid.v4();
      box.put(_keyDeviceId, id);
    }
    return id;
  }

  @override
  Future<Either<Failure, int>> registerCurrentDevice() async {
    try {
      final deviceId = _getOrCreateDeviceId();
      final result = await _syncActiveDevice.call({
        'deviceId': deviceId,
        'platform': 'android',
        'deviceName': 'Flutter',
      });
      final sessionVersion =
          (result.data as Map<String, dynamic>)['deviceSession']['sessionVersion'];
      final version = sessionVersion is num ? sessionVersion.toInt() : 1;
      HiveDatabase.settingsBox.put(_keySessionVersion, version);
      return right(version);
    } catch (e) {
      return left(ServerFailure('$e'));
    }
  }

  @override
  Future<void> clearLocalSession() async {
    await HiveDatabase.settingsBox.delete(_keySessionVersion);
  }
}