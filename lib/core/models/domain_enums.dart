enum IncidentType {
  conflict,
  sighting,
  emergency,
  poaching,
  snare;

  String get wire => name;

  static IncidentType fromWire(String? value) {
    switch (value?.toLowerCase()) {
      case 'conflict':
        return IncidentType.conflict;
      case 'emergency':
        return IncidentType.emergency;
      case 'poaching':
        return IncidentType.poaching;
      case 'snare':
        return IncidentType.snare;
      default:
        return IncidentType.sighting;
    }
  }

  static IncidentType fromName(String? value) => values.firstWhere(
        (e) => e.name == value,
        orElse: () => IncidentType.sighting,
      );
}

enum IncidentStatus {
  open,
  inProgress,
  resolved;

  String get wire => name == 'inProgress' ? 'in_progress' : name;

  static IncidentStatus fromWire(String? value) {
    switch (value?.toLowerCase()) {
      case 'in_progress':
        return IncidentStatus.inProgress;
      case 'resolved':
        return IncidentStatus.resolved;
      default:
        return IncidentStatus.open;
    }
  }

  static IncidentStatus fromName(String? value) => values.firstWhere(
        (e) => e.name == value,
        orElse: () => IncidentStatus.open,
      );
}

enum RangerProgress {
  enRoute,
  onSite,
  completed;

  String get wire =>
      name == 'enRoute' ? 'en_route' : (name == 'onSite' ? 'on_site' : name);

  static RangerProgress? fromWire(String? value) {
    switch (value?.toLowerCase()) {
      case 'en_route':
        return RangerProgress.enRoute;
      case 'on_site':
        return RangerProgress.onSite;
      case 'completed':
        return RangerProgress.completed;
      default:
        return null;
    }
  }

  static RangerProgress? fromName(String? value) {
    for (final e in RangerProgress.values) {
      if (e.name == value) return e;
    }
    return null;
  }
}

enum SyncStatus {
  draft,
  pending,
  pendingUpdate,
  syncing,
  synced,
  failed;

  static SyncStatus fromName(String? value) {
    for (final e in SyncStatus.values) {
      if (e.name == value) return e;
    }
    return SyncStatus.synced;
  }
}

enum Park {
  bwindiImpenetrable('BWINDI_IMPENETRABLE'),
  mgahingaGorilla('MGAHINGA_GORILLA'),
  murchisonFalls('MURCHISON_FALLS'),
  queenElizabeth('QUEEN_ELIZABETH'),
  kibale('KIBALE'),
  kidepoValley('KIDEPO_VALLEY'),
  rwenzoriMountains('RWENZORI_MOUNTAINS'),
  mountElgon('MOUNT_ELGON'),
  lakeMburo('LAKE_MBURO'),
  semuliki('SEMULIKI');

  const Park(this.wire);

  final String wire;

  static Park fromWire(String? value) =>
      values.firstWhere((e) => e.wire == value, orElse: () => Park.bwindiImpenetrable);

  static Park fromName(String? value) => values.firstWhere(
        (e) => e.name == value,
        orElse: () => Park.bwindiImpenetrable,
      );
}

enum IncidentSeverity {
  low,
  high,
  light,
  medium;

  String get wire => name;

  static IncidentSeverity fromWire(String? value) {
    switch (value?.toLowerCase()) {
      case 'low':
        return IncidentSeverity.low;
      case 'high':
        return IncidentSeverity.high;
      case 'light':
        return IncidentSeverity.light;
      default:
        return IncidentSeverity.medium;
    }
  }

  static IncidentSeverity fromName(String? value) =>
      values.firstWhere((e) => e.name == value, orElse: () => IncidentSeverity.medium);
}

enum UserRole {
  public,
  ranger,
  warden,
  uwaOfficial;

  String get wire => name == 'uwaOfficial' ? 'uwa_official' : name;

  static UserRole fromClaim(String? role) {
    switch (role?.toLowerCase()) {
      case 'ranger':
        return UserRole.ranger;
      case 'warden':
        return UserRole.warden;
      case 'uwa_official':
        return UserRole.uwaOfficial;
      default:
        return UserRole.public;
    }
  }

  static UserRole fromName(String? value) => values.firstWhere(
        (e) => e.name == value,
        orElse: () => UserRole.public,
      );
}

enum AlertCategory {
  wildlife,
  safety,
  patrols,
  trapping;

  static AlertCategory fromName(String? value) => values.firstWhere(
        (e) => e.name == value,
        orElse: () => AlertCategory.wildlife,
      );
}

enum AlertSeverity {
  urgent,
  caution,
  info;

  static AlertSeverity fromName(String? value) =>
      values.firstWhere((e) => e.name == value, orElse: () => AlertSeverity.info);
}

enum NotificationType {
  system,
  sightingApproved,
  securityAlert,
  like,
  comment,
  newFeedArticle,
  pendingSync;

  static NotificationType? fromName(String? value) {
    for (final e in NotificationType.values) {
      if (e.name == value) return e;
    }
    return null;
  }

  static NotificationType? fromWire(String? value) {
    switch (value?.toUpperCase()) {
      case 'SYSTEM':
        return NotificationType.system;
      case 'SIGHTING_APPROVED':
        return NotificationType.sightingApproved;
      case 'SECURITY_ALERT':
        return NotificationType.securityAlert;
      case 'LIKE':
        return NotificationType.like;
      case 'COMMENT':
        return NotificationType.comment;
      case 'NEW_FEED_ARTICLE':
        return NotificationType.newFeedArticle;
      case 'PENDING_SYNC':
        return NotificationType.pendingSync;
      default:
        return null;
    }
  }
}

enum ArticleTheme {
  forest,
  sunset,
  sky,
  wildlife,
  security;

  static ArticleTheme fromWire(String? value) {
    for (final e in ArticleTheme.values) {
      if (e.name == value?.toLowerCase()) return e;
    }
    return ArticleTheme.forest;
  }

  static ArticleTheme fromName(String? value) => values.firstWhere(
        (e) => e.name == value,
        orElse: () => ArticleTheme.forest,
      );
}

enum PatrolStatus {
  active,
  completed;

  static PatrolStatus fromName(String? value) =>
      values.firstWhere((e) => e.name == value, orElse: () => PatrolStatus.active);
}

enum AttractionType {
  animalHabitat('ANIMAL_HABITAT'),
  landmark('LANDMARK'),
  rangerStation('RANGER_STATION'),
  gate('GATE'),
  waterSource('WATER_SOURCE'),
  viewpoint('VIEWPOINT'),
  dangerZone('DANGER_ZONE');

  const AttractionType(this.wire);

  final String wire;

  static AttractionType fromWire(String? value) =>
      values.firstWhere((e) => e.wire == value, orElse: () => AttractionType.landmark);

  static AttractionType fromName(String? value) => values.firstWhere(
        (e) => e.name == value,
        orElse: () => AttractionType.landmark,
      );
}