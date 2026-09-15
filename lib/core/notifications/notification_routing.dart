import '../models/domain_enums.dart';

String? notificationTargetId(NotificationType? type, Map<String, dynamic> data) {
  final target = switch (type) {
    NotificationType.sightingApproved => data['incidentId'],
    NotificationType.newFeedArticle => data['articleId'],
    _ => null,
  };
  return target?.toString();
}

String? notificationTargetPath(NotificationType? type, String? targetId) {
  switch (type) {
    case NotificationType.sightingApproved:
      return targetId == null ? null : '/incidents/$targetId';
    case NotificationType.newFeedArticle:
      return targetId == null ? null : '/articles/$targetId';
    case NotificationType.securityAlert:
      return '/alerts';
    case NotificationType.pendingSync:
      return targetId == null ? null : '/incidents/$targetId';
    default:
      return null;
  }
}