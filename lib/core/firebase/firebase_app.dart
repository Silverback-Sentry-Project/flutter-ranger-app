import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseAppBuilder {
  static FirebaseApp? _app;

  static Future<FirebaseApp> init() async {
    if (_app != null) return _app!;
    _app = await Firebase.initializeApp();
    try {
      await FirebaseAppCheck.instance.activate(
        providerAndroid: const AndroidDebugProvider(),
      );
    } catch (_) {}
    return _app!;
  }
}