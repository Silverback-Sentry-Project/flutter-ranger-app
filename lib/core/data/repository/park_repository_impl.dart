import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import '../../constants/app_constants.dart';
import '../../domain/repositories/park_repository.dart';
import '../../error/failure.dart';
import '../../models/national_park.dart';
import '../hive_database.dart';

class ParkRepositoryImpl implements ParkRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  @override
  Stream<List<NationalPark>> getParks() {
    final controller = StreamController<List<NationalPark>>.broadcast();
    final box = HiveDatabase.parksBox;
    controller.add(box.values.toList());
    final sub = box.watch().listen((_) {
      controller.add(box.values.toList());
    });
    sub.onDone(() => controller.close());
    _syncParks();
    return controller.stream;
  }

  Future<void> _syncParks() async {
    try {
      final snapshot = await _db.collection(AppConstants.parksCollection).get();
      final box = HiveDatabase.parksBox;
      for (final doc in snapshot.docs) {
        final park = _parkFromDoc(doc.id, doc.data());
        final key = box.keys.firstWhere(
          (k) => box.get(k)?.id == park.id,
          orElse: () => null,
        );
        if (key != null) {
          box.put(key, park);
        } else {
          box.add(park);
        }
      }
    } catch (_) {}
  }

  NationalPark _parkFromDoc(String id, Map<String, dynamic> data) {
    final location = data['location'];
    return NationalPark(
      id: id,
      name: data['name'] as String? ?? '',
      locationLat: location is GeoPoint
          ? location.latitude
          : (data['location_lat'] as num?)?.toDouble() ??
              (data['lat'] as num?)?.toDouble(),
      locationLng: location is GeoPoint
          ? location.longitude
          : (data['location_lng'] as num?)?.toDouble() ??
              (data['lng'] as num?)?.toDouble(),
      districts: (data['districts'] as List?)?.cast<String>() ?? const [],
      description: data['description'] as String? ?? '',
      zoomLevel: (data['zoom_level'] as num?)?.toDouble() ?? 12.0,
      boundaryGeoJson: data['boundary_geojson'] as String? ?? '',
    );
  }

  @override
  Stream<List<ParkAttraction>> getAttractions(String parkId) {
    final controller = StreamController<List<ParkAttraction>>.broadcast();
    _db
        .collection(AppConstants.poisCollection)
        .where('parkId', isEqualTo: parkId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              final location = data['location'];
              return ParkAttraction(
                id: doc.id,
                parkId: data['parkId'] as String? ?? parkId,
                name: data['name'] as String? ?? '',
                typeName: data['type'] as String? ?? 'landmark',
                locationLat: location is GeoPoint
                    ? location.latitude
                    : (data['lat'] as num?)?.toDouble(),
                locationLng: location is GeoPoint
                    ? location.longitude
                    : (data['lng'] as num?)?.toDouble(),
                description: data['description'] as String? ?? '',
                animalSpecies: data['animalSpecies'] as String?,
                reportedBy: data['reportedBy'] as String?,
                createdAt: data['createdAt'] as String?,
              );
            }).toList())
        .listen((attractions) => controller.add(attractions));
    return controller.stream;
  }

  @override
  Future<NationalPark?> findNearestPark(
    double latitude,
    double longitude,
  ) async {
    final parks = HiveDatabase.parksBox.values.toList();
    if (parks.isEmpty) {
      try {
        await _syncParks();
      } catch (_) {}
    }
    NationalPark? nearest;
    double minDistance = double.infinity;
    for (final park in parks) {
      final dLat = park.centerLat - latitude;
      final dLng = park.centerLng - longitude;
      final distance = dLat * dLat + dLng * dLng;
      if (distance < minDistance) {
        minDistance = distance;
        nearest = park;
      }
    }
    return nearest;
  }

  @override
  Future<NationalPark?> getPark(String parkId) async {
    try {
      final doc =
          await _db.collection(AppConstants.parksCollection).doc(parkId).get();
      if (!doc.exists) {
        for (final key in HiveDatabase.parksBox.keys) {
          if (HiveDatabase.parksBox.get(key)?.id == parkId) {
            return HiveDatabase.parksBox.get(key);
          }
        }
        return null;
      }
      return _parkFromDoc(doc.id, doc.data()!);
    } catch (_) {
      for (final key in HiveDatabase.parksBox.keys) {
        if (HiveDatabase.parksBox.get(key)?.id == parkId) {
          return HiveDatabase.parksBox.get(key);
        }
      }
      return null;
    }
  }

  @override
  Future<Either<Failure, void>> createAttraction(
    ParkAttraction attraction,
  ) async {
    try {
      final doc = _db.collection(AppConstants.poisCollection).doc(_uuid.v4());
      await doc.set({
        'parkId': attraction.parkId,
        'name': attraction.name,
        'type': attraction.typeName,
        'lat': attraction.locationLat,
        'lng': attraction.locationLng,
        'description': attraction.description,
        'animalSpecies': attraction.animalSpecies,
        'reportedBy': attraction.reportedBy,
        'createdAt': attraction.createdAt ??
            DateTime.now().toIso8601String(),
      });
      return right(null);
    } catch (e) {
      return left(ServerFailure('$e'));
    }
  }
}