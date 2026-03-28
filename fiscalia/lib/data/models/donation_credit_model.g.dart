// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'donation_credit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DonationCreditModelAdapter extends TypeAdapter<DonationCreditModel> {
  @override
  final int typeId = 8;

  @override
  DonationCreditModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DonationCreditModel(
      amount: fields[0] as double,
      donationType: DonationType.values[fields[1] as int],
      taxableIncome: fields[2] as double,
      dateCreated: fields[3] as DateTime,
      dateModified: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, DonationCreditModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.amount)
      ..writeByte(1)
      ..write(obj.donationType.index)
      ..writeByte(2)
      ..write(obj.taxableIncome)
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
      other is DonationCreditModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
