import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'domain_enums.dart';
part 'national_park.g.dart';
@HiveType(typeId: 26)
class NationalPark extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final double? locationLat;
  @HiveField(3)
  final double? locationLng;
  @HiveField(4)
  final List<String> districts;
  @HiveField(5)
  final String description;
  @HiveField(6)
  final double zoomLevel;
  @HiveField(7)
  final String boundaryGeoJson;
  const NationalPark({
    required this.id,
    required this.name,
    this.locationLat,
    this.locationLng,
    this.districts = const [],
    this.description = '',
    this.zoomLevel = 12.0,
    this.boundaryGeoJson = '',
  });
  double get centerLat => locationLat ?? 0.0;
  double get centerLng => locationLng ?? 0.0;
  NationalPark copyWith({String? boundaryGeoJson, double? zoomLevel}) =>
      NationalPark(
        id: id,
        name: name,
        locationLat: locationLat,
        locationLng: locationLng,
        districts: districts,
        description: description,
        zoomLevel: zoomLevel ?? this.zoomLevel,
        boundaryGeoJson: boundaryGeoJson ?? this.boundaryGeoJson,
      );
  @override
  List<Object?> get props => [
        id,
        name,
        locationLat,
        locationLng,
        districts,
        description,
        zoomLevel,
        boundaryGeoJson,
      ];
}
@HiveType(typeId: 27)
class ParkAttraction extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String parkId;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final String typeName;
  @HiveField(4)
  final double? locationLat;
  @HiveField(5)
  final double? locationLng;
  @HiveField(6)
  final String description;
  @HiveField(7)
  final String? animalSpecies;
  @HiveField(8)
  final String? reportedBy;
  @HiveField(9)
  final String? createdAt;
  const ParkAttraction({
    required this.id,
    required this.parkId,
    required this.name,
    this.typeName = 'landmark',
    this.locationLat,
    this.locationLng,
    this.description = '',
    this.animalSpecies,
    this.reportedBy,
    this.createdAt,
  });
  AttractionType get type => AttractionType.fromName(typeName);
  ParkAttraction copyWith({required String id}) => ParkAttraction(
        id: id,
        parkId: parkId,
        name: name,
        typeName: type.name,
        locationLat: locationLat,
        locationLng: locationLng,
        description: description,
        animalSpecies: animalSpecies,
        reportedBy: reportedBy,
        createdAt: createdAt,
      );
  @override
  List<Object?> get props => [
        id,
        parkId,
        name,
        type,
        locationLat,
        locationLng,
        description,
        animalSpecies,
        reportedBy,
        createdAt,
      ];
}
