// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationSettingsModelAdapter
    extends TypeAdapter<NotificationSettingsModel> {
  @override
  final int typeId = 18;

  @override
  NotificationSettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationSettingsModel(
      isPushEnabled: fields[0] as bool,
      notifyDeadlines: fields[1] as bool,
      notifyDeclarations: fields[2] as bool,
      notifyPayments: fields[3] as bool,
      reminderDaysBefore: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationSettingsModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.isPushEnabled)
      ..writeByte(1)
      ..write(obj.notifyDeadlines)
      ..writeByte(2)
      ..write(obj.notifyDeclarations)
      ..writeByte(3)
      ..write(obj.notifyPayments)
      ..writeByte(4)
      ..write(obj.reminderDaysBefore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationSettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
