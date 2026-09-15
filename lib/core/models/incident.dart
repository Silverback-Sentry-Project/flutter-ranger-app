import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'domain_enums.dart';
part 'incident.g.dart';
@HiveType(typeId: 20)
class IncidentModel extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String typeName;
  @HiveField(2)
  final String statusName;
  @HiveField(3)
  final String? rangerProgressName;
  @HiveField(4)
  final bool isEscalated;
  @HiveField(5)
  final String parkName;
  @HiveField(6)
  final String? district;
  @HiveField(7)
  final String? subCounty;
  @HiveField(8)
  final String? parish;
  @HiveField(9)
  final bool? animalSeen;
  @HiveField(10)
  final String? answersJson;
  @HiveField(11)
  final String? schemaVersion;
  @HiveField(12)
  final String community;
  @HiveField(13)
  final String species;
  @HiveField(14)
  final String severityName;
  @HiveField(15)
  final String? category;
  @HiveField(16)
  final String? summary;
  @HiveField(17)
  final double lat;
  @HiveField(18)
  final double lng;
  @HiveField(19)
  final String? locationName;
  @HiveField(20)
  final String? userName;
  @HiveField(21)
  final String? userEmail;
  @HiveField(22)
  final String? userId;
  @HiveField(23)
  final String reportedAt;
  @HiveField(24)
  final String? assignedTo;
  @HiveField(25)
  final String? assignedToName;
  @HiveField(26)
  final bool hasEvidence;
  @HiveField(27)
  final int evidenceCount;
  @HiveField(28)
  final List<String> evidencePhotoUrls;
  @HiveField(29)
  final List<String> localImageUris;
  @HiveField(30)
  final String? voiceNoteUrl;
  @HiveField(31)
  final int? voiceNoteDurationSec;
  @HiveField(32)
  final String syncStatusName;
  @HiveField(33)
  final String? syncedAt;
  @HiveField(34)
  final int lastModified;
  @HiveField(35)
  final String sourceSystem;
  IncidentType get type => IncidentType.fromName(typeName);
  IncidentStatus get status => IncidentStatus.fromName(statusName);
  RangerProgress? get rangerProgress => RangerProgress.fromName(rangerProgressName);
  Park get park => Park.fromName(parkName);
  IncidentSeverity get severity => IncidentSeverity.fromName(severityName);
  SyncStatus get syncStatus => SyncStatus.fromName(syncStatusName);
  const IncidentModel({
    required this.id,
    required this.typeName,
    required this.statusName,
    this.rangerProgressName,
    this.isEscalated = false,
    required this.parkName,
    this.district,
    this.subCounty,
    this.parish,
    this.animalSeen,
    this.answersJson,
    this.schemaVersion,
    required this.community,
    required this.species,
    required this.severityName,
    this.category,
    this.summary,
    required this.lat,
    required this.lng,
    this.locationName,
    this.userName,
    this.userEmail,
    this.userId,
    required this.reportedAt,
    this.assignedTo,
    this.assignedToName,
    this.hasEvidence = false,
    this.evidenceCount = 0,
    this.evidencePhotoUrls = const [],
    this.localImageUris = const [],
    this.voiceNoteUrl,
    this.voiceNoteDurationSec,
    required this.syncStatusName,
    this.syncedAt,
    required this.lastModified,
    this.sourceSystem = 'firestore',
  });
  static bool _coordinateIsPresent(double value) => value.abs() > 0.0000001;
  Map<String, dynamic> toFirestoreMap() => {
        'type': type.wire,
        'status': status.wire,
        'rangerProgress': rangerProgress?.wire,
        'isEscalated': isEscalated,
        'park': park.wire,
        'district': district,
        'sub_county': subCounty,
        'parish': parish,
        'animalSeen': animalSeen,
        'answers': answersJson == null ? null : jsonDecode(answersJson!) as Object?,
        'schemaVersion': schemaVersion,
        'community': community,
        'species': species,
        'severity': severity.wire,
        'category': category,
        'summary': summary,
        'lat': _coordinateIsPresent(lat) ? lat : null,
        'lng': _coordinateIsPresent(lng) ? lng : null,
        'locationName': locationName,
        'userId': userId,
        'reportedAt': reportedAt,
        'synced': true,
        'syncedAt': syncedAt,
        'assignedTo': assignedTo,
        'assignedToName': assignedToName,
        'hasEvidence': hasEvidence,
        'evidenceCount': evidenceCount,
        'evidencePhotoUrls': evidencePhotoUrls,
'voiceNoteUrl': voiceNoteUrl,
        'voiceNoteDurationSec': voiceNoteDurationSec,
        'source_system': sourceSystem,
      };
  factory IncidentModel.fromFirestoreMap(
      String documentId, Map<String, dynamic> data) {
    final answers = data['answers'];
    return IncidentModel(
      id: documentId,
      typeName: IncidentType.fromWire(_asString(data['type'])).name,
      statusName: IncidentStatus.fromWire(_asString(data['status'])).name,
      rangerProgressName: RangerProgress.fromWire(_asString(data['rangerProgress']))?.name,
      isEscalated: data['isEscalated'] as bool? ?? false,
      parkName: Park.fromWire(_asString(data['park'])).name,
      district: _asString(data['district']),
      subCounty: _asString(data['sub_county']),
      parish: _asString(data['parish']),
      animalSeen: data['animalSeen'] as bool?,
      answersJson: _encodeAnswers(answers),
      schemaVersion: _asString(data['schemaVersion']),
      community: _asString(data['community']) ?? '',
      species: _asString(data['species']) ?? '',
      severityName: IncidentSeverity.fromWire(_asString(data['severity'])).name,
      category: _asString(data['category']),
      summary: _asString(data['summary']),
      lat: (data['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (data['lng'] as num?)?.toDouble() ?? 0.0,
      locationName: _asString(data['locationName']),
      userName: _asString(data['userName']),
      userEmail: _asString(data['userEmail']),
      userId: _asString(data['userId']),
      reportedAt: _asString(data['reportedAt']) ?? '',
      assignedTo: _asString(data['assignedTo']),
      assignedToName: _asString(data['assignedToName']),
      evidencePhotoUrls:
          (data['evidencePhotoUrls'] as List?)?.cast<String>() ?? const [],
      localImageUris: const [],
      voiceNoteUrl: _asString(data['voiceNoteUrl']),
      voiceNoteDurationSec: (data['voiceNoteDurationSec'] as num?)?.toInt(),
      syncStatusName: SyncStatus.synced.name,
      syncedAt: _asString(data['syncedAt']),
      lastModified: DateTime.now().millisecondsSinceEpoch,
      sourceSystem: _asString(data['source_system']) ?? 'firestore',
    );
  }
  static String? _encodeAnswers(Object? value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    if (value is Map) {
      final entries = value.entries.map((e) {
        final v = e.value;
        final encoded = switch (v) {
          null => 'null',
          final bool b => b.toString(),
          final num n => n.toString(),
          _ => '"${v.toString().replaceAll('"', '\\"')}"',
        };
        return '"${e.key.toString()}":$encoded';
      }).join(',');
      return '{$entries}';
    }
    return null;
  }
  static String? _asString(Object? value) {
    if (value == null) return null;
    final s = value.toString();
    return s.trim().isEmpty ? null : s;
  }
  IncidentModel copyWith({
    String? id,
    IncidentType? type,
    IncidentStatus? status,
    RangerProgress? rangerProgress,
    bool clearRangerProgress = false,
    bool? isEscalated,
    Park? park,
    String? district,
    String? subCounty,
    String? parish,
    bool? animalSeen,
    String? answersJson,
    String? schemaVersion,
    String? community,
    String? species,
    IncidentSeverity? severity,
    String? category,
    String? summary,
    double? lat,
    double? lng,
    String? locationName,
    String? userName,
    String? userEmail,
    String? userId,
    String? reportedAt,
    String? assignedTo,
    String? assignedToName,
    bool? hasEvidence,
    int? evidenceCount,
    List<String>? evidencePhotoUrls,
    List<String>? localImageUris,
    String? voiceNoteUrl,
    int? voiceNoteDurationSec,
    SyncStatus? syncStatus,
    String? syncedAt,
    int? lastModified,
    String? sourceSystem,
  }) =>
      IncidentModel(
        id: id ?? this.id,
        typeName: (type ?? this.type).name,
        statusName: (status ?? this.status).name,
        rangerProgressName: (clearRangerProgress
            ? null
            : (rangerProgress ?? this.rangerProgress))?.name,
        isEscalated: isEscalated ?? this.isEscalated,
        parkName: (park ?? this.park).name,
        district: district ?? this.district,
        subCounty: subCounty ?? this.subCounty,
        parish: parish ?? this.parish,
        animalSeen: animalSeen ?? this.animalSeen,
        answersJson: answersJson ?? this.answersJson,
        schemaVersion: schemaVersion ?? this.schemaVersion,
        community: community ?? this.community,
        species: species ?? this.species,
        severityName: (severity ?? this.severity).name,
        category: category ?? this.category,
        summary: summary ?? this.summary,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        locationName: locationName ?? this.locationName,
        userName: userName ?? this.userName,
        userEmail: userEmail ?? this.userEmail,
        userId: userId ?? this.userId,
        reportedAt: reportedAt ?? this.reportedAt,
        assignedTo: assignedTo ?? this.assignedTo,
        assignedToName: assignedToName ?? this.assignedToName,
        hasEvidence: hasEvidence ?? this.hasEvidence,
        evidenceCount: evidenceCount ?? this.evidenceCount,
        evidencePhotoUrls: evidencePhotoUrls ?? this.evidencePhotoUrls,
        localImageUris: localImageUris ?? this.localImageUris,
        voiceNoteUrl: voiceNoteUrl ?? this.voiceNoteUrl,
        voiceNoteDurationSec: voiceNoteDurationSec ?? this.voiceNoteDurationSec,
        syncStatusName: (syncStatus ?? this.syncStatus).name,
        syncedAt: syncedAt ?? this.syncedAt,
        lastModified: lastModified ?? this.lastModified,
        sourceSystem: sourceSystem ?? this.sourceSystem,
      );
  @override
  List<Object?> get props => [
        id,
        type,
        status,
        rangerProgress,
        isEscalated,
        park,
        district,
        subCounty,
        parish,
        animalSeen,
        answersJson,
        schemaVersion,
        community,
        species,
        severity,
        category,
        summary,
        lat,
        lng,
        locationName,
        userName,
        userEmail,
        userId,
        reportedAt,
        assignedTo,
        assignedToName,
        hasEvidence,
        evidenceCount,
        evidencePhotoUrls,
        localImageUris,
        voiceNoteUrl,
        voiceNoteDurationSec,
        syncStatus,
        syncedAt,
        lastModified,
        sourceSystem,
      ];
}
