import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../constants/app_constants.dart';
import '../data/hive_database.dart';
import '../models/domain_enums.dart';

class FcmTokenRepository {
  static const _keyToken = 'fcm_token';
  static const _keyTopicSyncVersion = 'fcm_topic_sync_version';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> get currentToken async => _messaging.getToken();

  Future<void> syncToken() async {
    final token = await _messaging.getToken();
    if (token == null) return;
    HiveDatabase.settingsBox.put(_keyToken, token);
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;
    try {
      await _db.collection('users').doc(uid).set({
        'fcm_tokens': FieldValue.arrayUnion([token]),
        'fcm_token_updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  int? get lastTopicSyncVersion =>
      HiveDatabase.settingsBox.get(_keyTopicSyncVersion) as int?;

  Future<void> setLastTopicSyncVersion(int version) =>
      HiveDatabase.settingsBox.put(_keyTopicSyncVersion, version);
}

class FcmTopicManager {
  Set<String> _activeTopics = {};

  Future<void> syncTopics(UserRole role, String? parkId) async {
    final desired = buildTopics(role, parkId);
    final toUnsubscribe = _activeTopics.difference(desired);
    final toSubscribe = desired.difference(_activeTopics);
    for (final topic in toUnsubscribe) {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    }
    for (final topic in toSubscribe) {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
    }
    _activeTopics = desired;
  }

  Set<String> buildTopics(UserRole role, String? parkId) {
    final normalizedPark = (parkId?.trim() ?? '').isEmpty
        ? null
        : normalizeTopicSegment(parkId!);
    final topics = <String>{};
    if (normalizedPark != null) {
      topics.add(AppConstants.topicParkAlerts(normalizedPark));
    }
    final roleTopic = switch (role) {
      UserRole.ranger =>
        normalizedPark == null ? null : AppConstants.topicRanger(normalizedPark),
      UserRole.warden =>
        normalizedPark == null ? null : AppConstants.topicWarden(normalizedPark),
      UserRole.uwaOfficial => AppConstants.topicUwaOfficial,
      UserRole.public => AppConstants.topicParkAlertsAll,
    };
    if (roleTopic != null) topics.add(roleTopic);
    return topics;
  }

  static String normalizeTopicSegment(String value) => value
      .trim()
      .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]}_${m[2]}')
      .replaceAll(RegExp(r'[\s-]+'), '_')
      .toLowerCase();

  Future<void> clearTopics() async {
    for (final topic in _activeTopics) {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    }
    _activeTopics = {};
  }
}