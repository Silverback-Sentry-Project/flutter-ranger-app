// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patrol_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoutePointAdapter extends TypeAdapter<RoutePoint> {
  @override
  final int typeId = 25;

  @override
  RoutePoint read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RoutePoint(
      lat: fields[0] as double,
      lng: fields[1] as double,
      timestamp: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RoutePoint obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.lat)
      ..writeByte(1)
      ..write(obj.lng)
      ..writeByte(2)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutePointAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PatrolLogModelAdapter extends TypeAdapter<PatrolLogModel> {
  @override
  final int typeId = 24;

  @override
  PatrolLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PatrolLogModel(
      id: fields[0] as String,
      rangerUid: fields[1] as String,
      parkId: fields[2] as String?,
      routePoints: (fields[3] as List).cast<RoutePoint>(),
      startTime: fields[4] as String,
      endTime: fields[5] as String?,
      statusName: fields[6] as String,
      syncStatusName: fields[7] as String,
      lastModified: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PatrolLogModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.rangerUid)
      ..writeByte(2)
      ..write(obj.parkId)
      ..writeByte(3)
      ..write(obj.routePoints)
      ..writeByte(4)
      ..write(obj.startTime)
      ..writeByte(5)
      ..write(obj.endTime)
      ..writeByte(6)
      ..write(obj.statusName)
      ..writeByte(7)
      ..write(obj.syncStatusName)
      ..writeByte(8)
      ..write(obj.lastModified);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatrolLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
