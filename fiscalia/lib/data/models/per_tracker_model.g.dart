// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'per_tracker_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PerTrackerModelAdapter extends TypeAdapter<PerTrackerModel> {
  @override
  final int typeId = 19;

  @override
  PerTrackerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PerTrackerModel(
      id: fields[0] as String,
      currentYearCeiling: fields[1] as double,
      carryoverYear1: fields[2] as double,
      carryoverYear2: fields[3] as double,
      carryoverYear3: fields[4] as double,
      totalContributedThisYear: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, PerTrackerModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.currentYearCeiling)
      ..writeByte(2)
      ..write(obj.carryoverYear1)
      ..writeByte(3)
      ..write(obj.carryoverYear2)
      ..writeByte(4)
      ..write(obj.carryoverYear3)
      ..writeByte(5)
      ..write(obj.totalContributedThisYear);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PerTrackerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
