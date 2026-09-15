import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'domain_enums.dart';
part 'app_notification.g.dart';
@HiveType(typeId: 23)
class AppNotificationModel extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String typeName;
  @HiveField(2)
  final String title;
  @HiveField(3)
  final String message;
  @HiveField(4)
  final bool isRead;
  @HiveField(5)
  final int createdAt;
  @HiveField(6)
  final String? targetId;
  const AppNotificationModel({
    required this.id,
    required this.typeName,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.targetId,
  });
  NotificationType get type => NotificationType.fromName(typeName) ?? NotificationType.system;
  AppNotificationModel copyWith({bool? isRead}) => AppNotificationModel(
        id: id,
        typeName: type.name,
        title: title,
        message: message,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
        targetId: targetId,
      );
  @override
  List<Object?> get props => [id, type, title, message, isRead, createdAt, targetId];
}
