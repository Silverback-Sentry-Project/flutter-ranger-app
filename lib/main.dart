import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'config/routes/app_routes.dart';
import 'core/data/hive_database.dart';
import 'core/domain/repositories/auth_repository.dart';
import 'core/domain/repositories/user_data_repository.dart';
import 'core/firebase/firebase_app.dart';
import 'core/service_locator.dart' as di;
import 'core/services/app_services.dart';
import 'core/sync/sync_scheduler.dart';
import 'core/theme/app_theme.dart';
import 'features/tracking/presentation/pages/ranger_tracking_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (mapboxPublicToken.isNotEmpty) {
    MapboxOptions.setAccessToken(mapboxPublicToken);
  }
  await FirebaseAppBuilder.init();
  await HiveDatabase.init();
  await di.init();
  RouterGate.bind(di.sl<AuthRepository>());
  await AppServices.initialize();
  di.sl<SyncScheduler>().start();
  runApp(const SilverBackSentryApp());
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  AppServices.configureMessageHandling((path) => router.go(path));
}

class SilverBackSentryApp extends StatelessWidget {
  const SilverBackSentryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool?>(
      stream: di.sl<UserDataRepository>().darkThemeConfig,
      initialData: null,
      builder: (context, snapshot) {
        final dark = snapshot.data;
        return MaterialApp.router(
          title: 'SilverBack Sentry',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: dark == null ? ThemeMode.system : (dark ? ThemeMode.dark : ThemeMode.light),
          routerConfig: router,
        );
      },
    );
  }
}