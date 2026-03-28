// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_employment_credit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HomeEmploymentCreditModelAdapter
    extends TypeAdapter<HomeEmploymentCreditModel> {
  @override
  final int typeId = 6;

  @override
  HomeEmploymentCreditModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HomeEmploymentCreditModel(
      expenses: fields[0] as double,
      numberOfChildren: fields[1] as int,
      numberOfElderly: fields[2] as int,
      isFirstYear: fields[3] as bool,
      dateCreated: fields[4] as DateTime,
      dateModified: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, HomeEmploymentCreditModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.expenses)
      ..writeByte(1)
      ..write(obj.numberOfChildren)
      ..writeByte(2)
      ..write(obj.numberOfElderly)
      ..writeByte(3)
      ..write(obj.isFirstYear)
      ..writeByte(4)
      ..write(obj.dateCreated)
      ..writeByte(5)
      ..write(obj.dateModified);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeEmploymentCreditModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
