import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../error/failure.dart';

class GeoLocation extends Equatable {
  final double latitude;
  final double longitude;
  final double? accuracyMeters;

  const GeoLocation({
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
  });

  @override
  List<Object?> get props => [latitude, longitude, accuracyMeters];
}

abstract class LocationRepository {
  Future<Either<Failure, GeoLocation>> getCurrentLocation();

  Future<String?> reverseGeocode(double latitude, double longitude);

  String? getParkFromLocation(double latitude, double longitude);

  Stream<GeoLocation> observeLocationUpdates(int intervalMs);
}