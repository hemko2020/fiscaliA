// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_document_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaxDocumentModelAdapter extends TypeAdapter<TaxDocumentModel> {
  @override
  final int typeId = 20;

  @override
  TaxDocumentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaxDocumentModel(
      id: fields[0] as String,
      fileName: fields[1] as String,
      filePath: fields[2] as String,
      dateAdded: fields[3] as DateTime,
      documentType: fields[4] as String,
      extractedText: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TaxDocumentModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fileName)
      ..writeByte(2)
      ..write(obj.filePath)
      ..writeByte(3)
      ..write(obj.dateAdded)
      ..writeByte(4)
      ..write(obj.documentType)
      ..writeByte(5)
      ..write(obj.extractedText);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaxDocumentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}