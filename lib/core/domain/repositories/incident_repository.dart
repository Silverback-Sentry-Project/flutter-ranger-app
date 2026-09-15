import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../error/failure.dart';
import '../../models/domain_enums.dart';
import '../../models/incident.dart';
import 'sync_result.dart';

class NewIncidentDetails extends Equatable {
  final IncidentType type;
  final Park park;
  final String? district;
  final String? subCounty;
  final String? parish;
  final String community;
  final String species;
  final IncidentSeverity severity;
  final String? category;
  final String? summary;
  final double lat;
  final double lng;
  final String? locationName;
  final List<String> localImageUris;
  final bool? animalSeen;
  final String? answersJson;
  final String? schemaVersion;

  const NewIncidentDetails({
    required this.type,
    required this.park,
    this.district,
    this.subCounty,
    this.parish,
    required this.community,
    required this.species,
    required this.severity,
    this.category,
    this.summary,
    required this.lat,
    required this.lng,
    this.locationName,
    this.localImageUris = const [],
    this.animalSeen,
    this.answersJson,
    this.schemaVersion,
  });

  @override
  List<Object?> get props => [
        type,
        park,
        district,
        subCounty,
        parish,
        community,
        species,
        severity,
        category,
        summary,
        lat,
        lng,
        locationName,
        localImageUris,
        animalSeen,
        answersJson,
        schemaVersion,
      ];
}

abstract class IncidentRepository {
  Stream<List<IncidentModel>> observeAll();

  Future<IncidentModel?> getById(String id);

  Future<Either<Failure, IncidentModel>> create(
    NewIncidentDetails details, {
    bool asDraft = false,
  });

  Future<Either<Failure, void>> update(
    String id,
    NewIncidentDetails details, {
    bool asDraft = false,
  });

  Future<Either<Failure, void>> assignToSelf(String id);

  Future<SyncResult> syncPending();

  void startObservingRemoteChanges();
}