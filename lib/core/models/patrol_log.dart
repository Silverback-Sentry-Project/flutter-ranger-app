import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'domain_enums.dart';
part 'patrol_log.g.dart';
@HiveType(typeId: 25)
class RoutePoint extends Equatable {
  @HiveField(0)
  final double lat;
  @HiveField(1)
  final double lng;
  @HiveField(2)
  final String timestamp;
  const RoutePoint({
    required this.lat,
    required this.lng,
    required this.timestamp,
  });
  Map<String, dynamic> toFirestoreMap() => {
        'lat': lat,
        'lng': lng,
        'timestamp': timestamp,
      };
  @override
  List<Object?> get props => [lat, lng, timestamp];
}
@HiveType(typeId: 24)
class PatrolLogModel extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String rangerUid;
  @HiveField(2)
  final String? parkId;
  @HiveField(3)
  final List<RoutePoint> routePoints;
  @HiveField(4)
  final String startTime;
  @HiveField(5)
  final String? endTime;
  @HiveField(6)
  final String statusName;
  @HiveField(7)
  final String syncStatusName;
  @HiveField(8)
  final int lastModified;
  const PatrolLogModel({
    required this.id,
    required this.rangerUid,
    this.parkId,
    this.routePoints = const [],
    required this.startTime,
    this.endTime,
    this.statusName = 'active',
    this.syncStatusName = 'pending',
    this.lastModified = 0,
  });
  PatrolStatus get status => PatrolStatus.fromName(statusName);
  SyncStatus get syncStatus => SyncStatus.fromName(syncStatusName);
  Map<String, dynamic> toFirestoreMap() => {
        'ranger_uid': rangerUid,
        'park_id': parkId,
        'route_points': routePoints.map((p) => p.toFirestoreMap()).toList(),
        'startTime': startTime,
        'endTime': endTime,
      };
  PatrolLogModel copyWith({
    List<RoutePoint>? routePoints,
    String? endTime,
    PatrolStatus? status,
    SyncStatus? syncStatus,
    int? lastModified,
  }) =>
      PatrolLogModel(
        id: id,
        rangerUid: rangerUid,
        parkId: parkId,
        routePoints: routePoints ?? this.routePoints,
        startTime: startTime,
        endTime: endTime ?? this.endTime,
        statusName: (status ?? this.status).name,
        syncStatusName: (syncStatus ?? this.syncStatus).name,
        lastModified: lastModified ?? this.lastModified,
      );
  @override
  List<Object?> get props => [
        id,
        rangerUid,
        parkId,
        routePoints,
        startTime,
        endTime,
        status,
        syncStatus,
        lastModified,
      ];
}
