import 'package:fpdart/fpdart.dart';

import '../../error/failure.dart';

abstract class DeviceSessionRepository {
  Future<Either<Failure, int>> registerCurrentDevice();

  Future<void> clearLocalSession();
}