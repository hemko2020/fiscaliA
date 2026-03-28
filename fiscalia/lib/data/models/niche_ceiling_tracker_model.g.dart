// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'niche_ceiling_tracker_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NicheCeilingTrackerModelAdapter
    extends TypeAdapter<NicheCeilingTrackerModel> {
  @override
  final int typeId = 9;

  @override
  NicheCeilingTrackerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NicheCeilingTrackerModel(
      totalCeiling: fields[0] as double,
      usedCeiling: fields[1] as double,
      creditEntries: (fields[2] as List)
          .map((e) => e as NicheCreditEntry)
          .toList(),
      dateCreated: fields[3] as DateTime,
      dateModified: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, NicheCeilingTrackerModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.totalCeiling)
      ..writeByte(1)
      ..write(obj.usedCeiling)
      ..writeByte(2)
      ..write(obj.creditEntries)
      ..writeByte(3)
      ..write(obj.dateCreated)
      ..writeByte(4)
      ..write(obj.dateModified);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NicheCeilingTrackerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NicheCreditEntryAdapter extends TypeAdapter<NicheCreditEntry> {
  @override
  final int typeId = 10;

  @override
  NicheCreditEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    final entry = NicheCreditEntry(
      creditType: fields[1] as String,
      amount: fields[2] as double,
      description: fields[3] as String?,
      dateAdded: fields[4] as DateTime,
    );
    return entry;
  }

  @override
  void write(BinaryWriter writer, NicheCreditEntry obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.creditType)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.dateAdded);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NicheCreditEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
