import 'dart:async';

import '../../domain/repositories/alert_repository.dart';
import '../../models/alert.dart';
import '../../models/domain_enums.dart';
import '../hive_database.dart';

class AlertRepositoryImpl implements AlertRepository {
  static const _seedOffset = Duration(minutes: 10);

  Future<void> _seedIfEmpty() async {
    final box = HiveDatabase.alertsBox;
    if (box.isNotEmpty) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    box.addAll([
      AlertModel(
        id: 'seed-alert-1',
        title: 'Elephant herd movement',
        description:
            'Herd of ~12 elephants heading toward Kichwamba village. Keep distance.',
        location: 'Kichwamba',
        categoryName: AlertCategory.wildlife.name,
        severityName: AlertSeverity.urgent.name,
        createdAt: now - _seedOffset.inMilliseconds * 1,
      ),
      AlertModel(
        id: 'seed-alert-2',
        title: 'Buffalo sighting',
        description: 'Single buffalo seen near the river crossing.',
        location: 'Buliisa',
        categoryName: AlertCategory.wildlife.name,
        severityName: AlertSeverity.caution.name,
        createdAt: now - const Duration(hours: 2).inMilliseconds,
      ),
      AlertModel(
        id: 'seed-alert-3',
        title: 'Ranger patrol scheduled',
        description: 'Patrol team in your area today from 14:00 to 18:00.',
        location: 'Pakwach',
        categoryName: AlertCategory.patrols.name,
        severityName: AlertSeverity.info.name,
        createdAt: now - const Duration(hours: 6).inMilliseconds,
      ),
      AlertModel(
        id: 'seed-alert-4',
        title: 'Snare trap warning',
        description: 'Multiple snares discovered. Report any you find.',
        location: 'Wairingo',
        categoryName: AlertCategory.trapping.name,
        severityName: AlertSeverity.urgent.name,
        createdAt: now - const Duration(days: 1).inMilliseconds,
      ),
    ]);
  }

  @override
  Stream<List<AlertModel>> observeAll() {
    _seedIfEmpty();
    final controller = StreamController<List<AlertModel>>.broadcast();
    final box = HiveDatabase.alertsBox;
    controller.add(box.values.toList());
    final sub = box.watch().listen((_) {
      controller.add(box.values.toList());
    });
    sub.onDone(() => controller.close());
    return controller.stream;
  }
}