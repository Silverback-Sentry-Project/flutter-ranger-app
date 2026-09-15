// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incident.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IncidentModelAdapter extends TypeAdapter<IncidentModel> {
  @override
  final int typeId = 20;

  @override
  IncidentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IncidentModel(
      id: fields[0] as String,
      typeName: fields[1] as String,
      statusName: fields[2] as String,
      rangerProgressName: fields[3] as String?,
      isEscalated: fields[4] as bool,
      parkName: fields[5] as String,
      district: fields[6] as String?,
      subCounty: fields[7] as String?,
      parish: fields[8] as String?,
      animalSeen: fields[9] as bool?,
      answersJson: fields[10] as String?,
      schemaVersion: fields[11] as String?,
      community: fields[12] as String,
      species: fields[13] as String,
      severityName: fields[14] as String,
      category: fields[15] as String?,
      summary: fields[16] as String?,
      lat: fields[17] as double,
      lng: fields[18] as double,
      locationName: fields[19] as String?,
      userName: fields[20] as String?,
      userEmail: fields[21] as String?,
      userId: fields[22] as String?,
      reportedAt: fields[23] as String,
      assignedTo: fields[24] as String?,
      assignedToName: fields[25] as String?,
      hasEvidence: fields[26] as bool,
      evidenceCount: fields[27] as int,
      evidencePhotoUrls: (fields[28] as List).cast<String>(),
      localImageUris: (fields[29] as List).cast<String>(),
      voiceNoteUrl: fields[30] as String?,
      voiceNoteDurationSec: fields[31] as int?,
      syncStatusName: fields[32] as String,
      syncedAt: fields[33] as String?,
      lastModified: fields[34] as int,
      sourceSystem: fields[35] as String,
    );
  }

  @override
  void write(BinaryWriter writer, IncidentModel obj) {
    writer
      ..writeByte(36)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.typeName)
      ..writeByte(2)
      ..write(obj.statusName)
      ..writeByte(3)
      ..write(obj.rangerProgressName)
      ..writeByte(4)
      ..write(obj.isEscalated)
      ..writeByte(5)
      ..write(obj.parkName)
      ..writeByte(6)
      ..write(obj.district)
      ..writeByte(7)
      ..write(obj.subCounty)
      ..writeByte(8)
      ..write(obj.parish)
      ..writeByte(9)
      ..write(obj.animalSeen)
      ..writeByte(10)
      ..write(obj.answersJson)
      ..writeByte(11)
      ..write(obj.schemaVersion)
      ..writeByte(12)
      ..write(obj.community)
      ..writeByte(13)
      ..write(obj.species)
      ..writeByte(14)
      ..write(obj.severityName)
      ..writeByte(15)
      ..write(obj.category)
      ..writeByte(16)
      ..write(obj.summary)
      ..writeByte(17)
      ..write(obj.lat)
      ..writeByte(18)
      ..write(obj.lng)
      ..writeByte(19)
      ..write(obj.locationName)
      ..writeByte(20)
      ..write(obj.userName)
      ..writeByte(21)
      ..write(obj.userEmail)
      ..writeByte(22)
      ..write(obj.userId)
      ..writeByte(23)
      ..write(obj.reportedAt)
      ..writeByte(24)
      ..write(obj.assignedTo)
      ..writeByte(25)
      ..write(obj.assignedToName)
      ..writeByte(26)
      ..write(obj.hasEvidence)
      ..writeByte(27)
      ..write(obj.evidenceCount)
      ..writeByte(28)
      ..write(obj.evidencePhotoUrls)
      ..writeByte(29)
      ..write(obj.localImageUris)
      ..writeByte(30)
      ..write(obj.voiceNoteUrl)
      ..writeByte(31)
      ..write(obj.voiceNoteDurationSec)
      ..writeByte(32)
      ..write(obj.syncStatusName)
      ..writeByte(33)
      ..write(obj.syncedAt)
      ..writeByte(34)
      ..write(obj.lastModified)
      ..writeByte(35)
      ..write(obj.sourceSystem);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncidentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
