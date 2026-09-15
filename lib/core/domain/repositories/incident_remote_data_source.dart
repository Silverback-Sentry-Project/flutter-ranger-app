import 'dart:async';

import '../../models/incident.dart';

abstract class IncidentRemoteDataSource {
  Future<IncidentModel> upsert(IncidentModel incident);

  Stream<RemoteIncidentChange> observeChanges();
}

class RemoteIncidentChange {
  final IncidentModel incident;
  final bool isRemoved;
  const RemoteIncidentChange({required this.incident, required this.isRemoved});
}