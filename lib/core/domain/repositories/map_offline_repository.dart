import 'package:fpdart/fpdart.dart';

import '../../error/failure.dart';
import '../../models/national_park.dart';

abstract class MapOfflineRepository {
  Future<Either<Failure, void>> downloadParkRegion(NationalPark park);
}

abstract class OfflineMapCoordinator {
  bool shouldPrefetchOfflineMap(String? parkClaim, String? addressClaim);

  Future<void> prefetchIfNeeded();
}