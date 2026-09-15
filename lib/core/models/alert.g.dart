// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlertModelAdapter extends TypeAdapter<AlertModel> {
  @override
  final int typeId = 22;

  @override
  AlertModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AlertModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      location: fields[3] as String,
      categoryName: fields[4] as String,
      severityName: fields[5] as String,
      createdAt: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AlertModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.categoryName)
      ..writeByte(5)
      ..write(obj.severityName)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
