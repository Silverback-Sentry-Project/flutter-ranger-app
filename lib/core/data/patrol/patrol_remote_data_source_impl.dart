import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/app_constants.dart';
import '../../domain/repositories/patrol_remote_data_source.dart';
import '../../models/patrol_log.dart';

class PatrolRemoteDataSourceImpl implements PatrolRemoteDataSource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<void> upsert(PatrolLogModel patrolLog) async {
    await _db
        .collection(AppConstants.patrolLogsCollection)
        .doc(patrolLog.id)
        .set(patrolLog.toFirestoreMap(), SetOptions(merge: true));
  }
}