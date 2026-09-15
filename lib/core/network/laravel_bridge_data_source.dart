import 'package:fpdart/fpdart.dart';

import '../error/failure.dart';
import '../models/incident.dart';

abstract class LaravelBridgeDataSource {
  Future<Either<Failure, void>> postIncidentEvent(
    IncidentModel incident,
    String eventType,
  );
}