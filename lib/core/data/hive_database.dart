import 'package:hive_flutter/hive_flutter.dart';

import '../models/alert.dart';
import '../models/app_notification.dart';
import '../models/article.dart';
import '../models/incident.dart';
import '../models/national_park.dart';
import '../models/patrol_log.dart';

class HiveDatabase {
  static const String incidentsBoxName = 'incidents';
  static const String articlesBoxName = 'articles';
  static const String alertsBoxName = 'alerts';
  static const String notificationsBoxName = 'notifications';
  static const String patrolLogsBoxName = 'patrol_logs';
  static const String parksBoxName = 'parks';
  static const String settingsBoxName = 'settings';

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await Hive.initFlutter();

    Hive.registerAdapter(IncidentModelAdapter());
    Hive.registerAdapter(ArticleModelAdapter());
    Hive.registerAdapter(AlertModelAdapter());
    Hive.registerAdapter(AppNotificationModelAdapter());
    Hive.registerAdapter(PatrolLogModelAdapter());
    Hive.registerAdapter(RoutePointAdapter());
    Hive.registerAdapter(NationalParkAdapter());
    Hive.registerAdapter(ParkAttractionAdapter());

    await Hive.openBox<IncidentModel>(incidentsBoxName);
    await Hive.openBox<ArticleModel>(articlesBoxName);
    await Hive.openBox<AlertModel>(alertsBoxName);
    await Hive.openBox<AppNotificationModel>(notificationsBoxName);
    await Hive.openBox<PatrolLogModel>(patrolLogsBoxName);
    await Hive.openBox<NationalPark>(parksBoxName);
    await Hive.openBox(settingsBoxName);
  }

  static Box<IncidentModel> get incidentsBox =>
      Hive.box<IncidentModel>(incidentsBoxName);

  static Box<ArticleModel> get articlesBox =>
      Hive.box<ArticleModel>(articlesBoxName);

  static Box<AlertModel> get alertsBox => Hive.box<AlertModel>(alertsBoxName);

  static Box<AppNotificationModel> get notificationsBox =>
      Hive.box<AppNotificationModel>(notificationsBoxName);

  static Box<PatrolLogModel> get patrolLogsBox =>
      Hive.box<PatrolLogModel>(patrolLogsBoxName);

  static Box<NationalPark> get parksBox => Hive.box<NationalPark>(parksBoxName);

  static Box get settingsBox => Hive.box(settingsBoxName);
}