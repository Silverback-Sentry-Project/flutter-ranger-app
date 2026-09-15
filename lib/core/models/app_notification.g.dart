// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_notification.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppNotificationModelAdapter extends TypeAdapter<AppNotificationModel> {
  @override
  final int typeId = 23;

  @override
  AppNotificationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppNotificationModel(
      id: fields[0] as String,
      typeName: fields[1] as String,
      title: fields[2] as String,
      message: fields[3] as String,
      isRead: fields[4] as bool,
      createdAt: fields[5] as int,
      targetId: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AppNotificationModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.typeName)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.message)
      ..writeByte(4)
      ..write(obj.isRead)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.targetId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppNotificationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
