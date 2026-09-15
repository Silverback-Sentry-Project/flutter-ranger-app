import 'dart:async';

import 'package:fpdart/fpdart.dart';

import '../../error/failure.dart';
import '../../models/national_park.dart';

abstract class ParkRepository {
  Stream<List<NationalPark>> getParks();

  Stream<List<ParkAttraction>> getAttractions(String parkId);

  Future<NationalPark?> findNearestPark(double latitude, double longitude);

  Future<NationalPark?> getPark(String parkId);

  Future<Either<Failure, void>> createAttraction(ParkAttraction attraction);
}