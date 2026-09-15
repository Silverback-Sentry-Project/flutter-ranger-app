import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/repositories/location_repository.dart';
import '../../error/failure.dart';
import '../../models/domain_enums.dart';

class LocationRepositoryImpl implements LocationRepository {
  static const Map<Park, List<double>> _parkBounds = {
    Park.bwindiImpenetrable: [-1.3189, 29.6629, -0.9854, 29.8828],
    Park.mgahingaGorilla: [-1.3973, 29.5675, -1.3136, 29.6689],
    Park.murchisonFalls: [2.1530, 31.6354, 2.4110, 32.4216],
    Park.queenElizabeth: [-0.3759, 29.9000, 0.0800, 30.1213],
    Park.kibale: [0.3591, 30.2567, 0.6561, 30.5106],
    Park.kidepoValley: [3.6634, 33.6965, 3.9723, 33.9074],
    Park.rwenzoriMountains: [0.3614, 29.8214, 0.8466, 30.1425],
    Park.mountElgon: [1.0218, 34.3008, 1.2614, 34.5909],
    Park.lakeMburo: [-0.7650, 30.8960, -0.5620, 31.0496],
    Park.semuliki: [0.8827, 30.0772, 1.1078, 30.2820],
  };

  @override
  Future<Either<Failure, GeoLocation>> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return right(GeoLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
      ));
    } on LocationServiceDisabledException {
      return left(const LocationFailure('Location services are disabled'));
    } on PermissionDeniedException {
      return left(const PermissionFailure('Location permission denied'));
    } catch (e) {
      return left(LocationFailure('$e'));
    }
  }

  @override
  Future<String?> reverseGeocode(double latitude, double longitude) async {
    try {
      final geocoding = Geocoding();
      final places =
          await geocoding.placemarkFromCoordinates(latitude, longitude);
      if (places.isEmpty) return null;
      final place = places.first;
      final parts = <String>[
        if (place.name != null && place.name!.isNotEmpty) place.name!,
        if (place.subLocality != null && place.subLocality!.isNotEmpty)
          place.subLocality!,
        if (place.locality != null && place.locality!.isNotEmpty)
          place.locality!,
        if (place.country != null && place.country!.isNotEmpty) place.country!,
      ];
      return parts.take(3).join(', ');
    } catch (_) {
      return null;
    }
  }

  @override
  String? getParkFromLocation(double latitude, double longitude) {
    for (final entry in _parkBounds.entries) {
      final b = entry.value;
      if (latitude >= b[0] &&
          latitude <= b[2] &&
          longitude >= b[1] &&
          longitude <= b[3]) {
        return entry.key.wire;
      }
    }
    return null;
  }

  @override
  Stream<GeoLocation> observeLocationUpdates(int intervalMs) {
    return Geolocator.getPositionStream(
      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.high,
        intervalDuration: Duration(milliseconds: intervalMs),
      ),
    ).map(
      (position) => GeoLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
      ),
    );
  }
}