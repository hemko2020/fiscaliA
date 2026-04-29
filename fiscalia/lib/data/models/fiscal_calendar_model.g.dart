// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fiscal_calendar_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FiscalCalendarModelAdapter extends TypeAdapter<FiscalCalendarModel> {
  @override
  final int typeId = 16;

  @override
  FiscalCalendarModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FiscalCalendarModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      date: fields[3] as DateTime,
      type: fields[4] as FiscalEventType,
      department: fields[5] as String,
      isDepartmentSpecific: fields[6] as bool,
      isReminderEnabled: fields[7] as bool,
      reminderDaysBefore: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, FiscalCalendarModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.department)
      ..writeByte(6)
      ..write(obj.isDepartmentSpecific)
      ..writeByte(7)
      ..write(obj.isReminderEnabled)
      ..writeByte(8)
      ..write(obj.reminderDaysBefore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FiscalCalendarModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FiscalEventTypeAdapter extends TypeAdapter<FiscalEventType> {
  @override
  final int typeId = 17;

  @override
  FiscalEventType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FiscalEventType.declaration;
      case 1:
        return FiscalEventType.deadline;
      case 2:
        return FiscalEventType.contribution;
      case 3:
        return FiscalEventType.payment;
      case 4:
        return FiscalEventType.notification;
      case 5:
        return FiscalEventType.reminder;
      default:
        return FiscalEventType.declaration;
    }
  }

  @override
  void write(BinaryWriter writer, FiscalEventType obj) {
    switch (obj) {
      case FiscalEventType.declaration:
        writer.writeByte(0);
        break;
      case FiscalEventType.deadline:
        writer.writeByte(1);
        break;
      case FiscalEventType.contribution:
        writer.writeByte(2);
        break;
      case FiscalEventType.payment:
        writer.writeByte(3);
        break;
      case FiscalEventType.notification:
        writer.writeByte(4);
        break;
      case FiscalEventType.reminder:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FiscalEventTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}