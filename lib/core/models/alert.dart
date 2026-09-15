import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'domain_enums.dart';
part 'alert.g.dart';
@HiveType(typeId: 22)
class AlertModel extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final String location;
  @HiveField(4)
  final String categoryName;
  @HiveField(5)
  final String severityName;
  @HiveField(6)
  final int createdAt;
const AlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.categoryName,
    required this.severityName,
    required this.createdAt,
  });

  AlertCategory get category => AlertCategory.fromName(categoryName);
  AlertSeverity get severity => AlertSeverity.fromName(severityName);
  factory AlertModel.fromFirestoreMap(String documentId, Map<String, dynamic> data) => AlertModel(
        id: documentId,
        title: data['title'] as String? ?? '',
        description: data['description'] as String? ?? '',
        location: data['location'] as String? ?? '',
        categoryName: _categoryByName(data['category'] as String?),
        severityName: _severityByName(data['severity'] as String?),
        createdAt: (data['createdAt'] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch,
      );
  static String _categoryByName(String? name) {
    for (final e in AlertCategory.values) {
      if (e.name == name) return e.name;
    }
    return AlertCategory.wildlife.name;
  }
  static String _severityByName(String? name) {
    for (final e in AlertSeverity.values) {
      if (e.name == name) return e.name;
    }
    return AlertSeverity.info.name;
  }
  @override
  List<Object?> get props =>
      [id, title, description, location, category, severity, createdAt];
}
