class AppConstants {
  static const String signInLinkUrl = 'https://wildwatch-82abc.web.app/';
  static const String androidPackageName = 'com.silversentry.sentry';
  static const String rangerSignInPolicyMessage =
      'Ranger accounts must sign in with a Google account ending in @gmail.com.';
  static const String genericErrorMessage =
      'Something went wrong. Please try again.';

  static const String offlineStyleUri = 'mapbox://styles/mapbox/streets-v12';
  static const int offlineMinZoom = 0;
  static const int offlineMaxZoom = 16;

  static const int patrolPointIntervalMs = 30000;

  static const String feedCollection = 'feed';
  static const String parksCollection = 'parks';
  static const String poisCollection = 'pois';
  static const String incidentsCollection = 'incidents';
  static const String patrolLogsCollection = 'patrol_logs';

  static const String topicParkAlertsAll = 'park_alerts_all';
  static const String topicUwaOfficial = 'uwa_official';

  static String topicParkAlerts(String parkId) => 'park_alerts_$parkId';
  static String topicRanger(String parkId) => 'ranger_$parkId';
  static String topicWarden(String parkId) => 'warden_$parkId';
}