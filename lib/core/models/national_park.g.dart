// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'national_park.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NationalParkAdapter extends TypeAdapter<NationalPark> {
  @override
  final int typeId = 26;

  @override
  NationalPark read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NationalPark(
      id: fields[0] as String,
      name: fields[1] as String,
      locationLat: fields[2] as double?,
      locationLng: fields[3] as double?,
      districts: (fields[4] as List).cast<String>(),
      description: fields[5] as String,
      zoomLevel: fields[6] as double,
      boundaryGeoJson: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, NationalPark obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.locationLat)
      ..writeByte(3)
      ..write(obj.locationLng)
      ..writeByte(4)
      ..write(obj.districts)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.zoomLevel)
      ..writeByte(7)
      ..write(obj.boundaryGeoJson);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NationalParkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ParkAttractionAdapter extends TypeAdapter<ParkAttraction> {
  @override
  final int typeId = 27;

  @override
  ParkAttraction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ParkAttraction(
      id: fields[0] as String,
      parkId: fields[1] as String,
      name: fields[2] as String,
      typeName: fields[3] as String,
      locationLat: fields[4] as double?,
      locationLng: fields[5] as double?,
      description: fields[6] as String,
      animalSpecies: fields[7] as String?,
      reportedBy: fields[8] as String?,
      createdAt: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ParkAttraction obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.parkId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.typeName)
      ..writeByte(4)
      ..write(obj.locationLat)
      ..writeByte(5)
      ..write(obj.locationLng)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.animalSpecies)
      ..writeByte(8)
      ..write(obj.reportedBy)
      ..writeByte(9)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParkAttractionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
