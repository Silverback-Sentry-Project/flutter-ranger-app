import 'dart:async';

import '../../models/alert.dart';

abstract class AlertRepository {
  Stream<List<AlertModel>> observeAll();
}