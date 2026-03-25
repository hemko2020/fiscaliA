// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispositif_model.dart';

class CategorieDispositifAdapter extends TypeAdapter<CategorieDispositif> {
  @override
  final int typeId = 6;

  @override
  CategorieDispositif read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CategorieDispositif.basique;
      case 1:
        return CategorieDispositif.avance;
      case 2:
        return CategorieDispositif.expert;
      default:
        return CategorieDispositif.basique;
    }
  }

  @override
  void write(BinaryWriter writer, CategorieDispositif obj) {
    switch (obj) {
      case CategorieDispositif.basique:
        writer.writeByte(0);
        break;
      case CategorieDispositif.avance:
        writer.writeByte(1);
        break;
      case CategorieDispositif.expert:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategorieDispositifAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TypeDispositifAdapter extends TypeAdapter<TypeDispositif> {
  @override
  final int typeId = 7;

  @override
  TypeDispositif read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TypeDispositif.reduction;
      case 1:
        return TypeDispositif.credit;
      case 2:
        return TypeDispositif.deduction;
      default:
        return TypeDispositif.reduction;
    }
  }

  @override
  void write(BinaryWriter writer, TypeDispositif obj) {
    switch (obj) {
      case TypeDispositif.reduction:
        writer.writeByte(0);
        break;
      case TypeDispositif.credit:
        writer.writeByte(1);
        break;
      case TypeDispositif.deduction:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TypeDispositifAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DispositifModelAdapter extends TypeAdapter<DispositifModel> {
  @override
  final int typeId = 8;

  @override
  DispositifModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DispositifModel(
      id: fields[0] as String,
      nom: fields[1] as String,
      description: fields[2] as String,
      categorie: fields[3] as CategorieDispositif,
      type: fields[4] as TypeDispositif,
      tauxAvantage: fields[5] as double,
      plafond: fields[6] as double?,
      conditionsEligibilite: (fields[7] as List?)?.cast<String>(),
      horsNicheFiscale: fields[8] as bool,
      baseLegale: fields[9] as String,
      risqueScore: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DispositifModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nom)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.categorie)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.tauxAvantage)
      ..writeByte(6)
      ..write(obj.plafond)
      ..writeByte(7)
      ..write(obj.conditionsEligibilite)
      ..writeByte(8)
      ..write(obj.horsNicheFiscale)
      ..writeByte(9)
      ..write(obj.baseLegale)
      ..writeByte(10)
      ..write(obj.risqueScore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispositifModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
