import 'package:get_it/get_it.dart';

import 'data/alert/alert_repository_impl.dart';
import 'data/auth/auth_repository_impl.dart';
import 'data/auth/device_session_repository_impl.dart';
import 'data/auth/user_data_repository_impl.dart';
import 'data/feed/article_repository_impl.dart';
import 'data/incident/incident_repository_impl.dart';
import 'data/location/location_repository_impl.dart';
import 'data/map/map_offline_repository_impl.dart';
import 'data/notification/notification_repository_impl.dart';
import 'data/patrol/patrol_repository_impl.dart';
import 'data/repository/park_repository_impl.dart';
import 'domain/repositories/alert_repository.dart';
import 'domain/repositories/article_repository.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/device_session_repository.dart';
import 'domain/repositories/incident_repository.dart';
import 'domain/repositories/location_repository.dart';
import 'domain/repositories/map_offline_repository.dart';
import 'domain/repositories/notification_repository.dart';
import 'domain/repositories/park_repository.dart';
import 'domain/repositories/patrol_repository.dart';
import 'domain/repositories/user_data_repository.dart';
import 'network/laravel_bridge_data_source.dart';
import 'network/laravel_bridge_data_source_impl.dart';
import 'notifications/fcm_topics.dart';
import 'sync/sync_scheduler.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton<FcmTokenRepository>(() => FcmTokenRepository());
  sl.registerLazySingleton<FcmTopicManager>(() => FcmTopicManager());
  sl.registerLazySingleton<DeviceSessionRepository>(
    () => DeviceSessionRepositoryImpl(),
  );
  sl.registerLazySingleton<UserDataRepository>(() => UserDataRepositoryImpl());
  sl.registerLazySingleton<IncidentRepository>(() => IncidentRepositoryImpl());
  sl.registerLazySingleton<ArticleRepository>(() => ArticleRepositoryImpl());
  sl.registerLazySingleton<AlertRepository>(() => AlertRepositoryImpl());
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(),
  );
  sl.registerLazySingleton<PatrolRepository>(() => PatrolRepositoryImpl());
  sl.registerLazySingleton<LocationRepository>(() => LocationRepositoryImpl());
  sl.registerLazySingleton<MapOfflineRepository>(
    () => MapOfflineRepositoryImpl(),
  );
  sl.registerLazySingleton<ParkRepository>(() => ParkRepositoryImpl());
  sl.registerLazySingleton<LaravelBridgeDataSource>(
    () => LaravelBridgeDataSourceImpl(),
  );
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  sl.registerLazySingleton<SyncScheduler>(() => SyncScheduler());
}
