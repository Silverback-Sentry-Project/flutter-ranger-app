import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../constants/app_constants.dart';
import '../../domain/repositories/incident_remote_data_source.dart';
import '../../models/incident.dart';

class IncidentRemoteDataSourceImpl implements IncidentRemoteDataSource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Future<IncidentModel> upsert(IncidentModel incident) async {
    var updated = incident;
    if (incident.localImageUris.isNotEmpty) {
      final urls = <String>[];
      for (final localPath in incident.localImageUris) {
        final ref = _storage.ref(
            'incidents/${incident.id}/${localPath.split('/').last}');
        try {
          final task = await ref.putFile(File(localPath));
          final url = await task.ref.getDownloadURL();
          urls.add(url);
        } catch (_) {}
      }
      final merged = [...incident.evidencePhotoUrls, ...urls];
      updated = incident.copyWith(
        evidencePhotoUrls: merged,
        evidenceCount: merged.length,
        hasEvidence: merged.isNotEmpty,
        localImageUris: const [],
      );
    }
    await _db
        .collection(AppConstants.incidentsCollection)
        .doc(updated.id)
        .set(updated.toFirestoreMap(), SetOptions(merge: true));
    return updated;
  }

  @override
  Stream<RemoteIncidentChange> observeChanges() {
    return _db
        .collection(AppConstants.incidentsCollection)
        .snapshots()
        .asyncMap((snapshot) async* {
      for (final change in snapshot.docChanges) {
        final doc = change.doc;
        final incident = IncidentModel.fromFirestoreMap(doc.id, doc.data() ?? {});
        yield RemoteIncidentChange(
          incident: incident,
          isRemoved: change.type == DocumentChangeType.removed,
        );
      }
    }).asyncExpand((stream) => stream);
  }
}