import 'package:fpdart/fpdart.dart';

import '../../domain/repositories/map_offline_repository.dart';
import '../../error/failure.dart';
import '../../models/national_park.dart';

class MapOfflineRepositoryImpl implements MapOfflineRepository {
  @override
  Future<Either<Failure, void>> downloadParkRegion(NationalPark park) async {
    return right(null);
  }
}

class OfflineMapCoordinatorImpl implements OfflineMapCoordinator {
  @override
  bool shouldPrefetchOfflineMap(String? parkClaim, String? addressClaim) {
    return parkClaim != null && parkClaim.isNotEmpty;
  }

  @override
  Future<void> prefetchIfNeeded() async {}
}