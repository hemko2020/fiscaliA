// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_fees_credit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SchoolFeesCreditModelAdapter extends TypeAdapter<SchoolFeesCreditModel> {
  @override
  final int typeId = 11;

  @override
  SchoolFeesCreditModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SchoolFeesCreditModel(
      expenses: fields[0] as double,
      numberOfChildren: fields[1] as int,
      isSecondaryEducation: fields[2] as bool,
      dateCreated: fields[3] as DateTime,
      dateModified: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SchoolFeesCreditModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.expenses)
      ..writeByte(1)
      ..write(obj.numberOfChildren)
      ..writeByte(2)
      ..write(obj.isSecondaryEducation)
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
      other is SchoolFeesCreditModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
