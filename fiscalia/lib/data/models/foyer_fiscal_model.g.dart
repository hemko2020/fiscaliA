// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'foyer_fiscal_model.dart';

class SituationFamilialeAdapter extends TypeAdapter<SituationFamiliale> {
  @override
  final int typeId = 0;

  @override
  SituationFamiliale read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SituationFamiliale.celibataire;
      case 1:
        return SituationFamiliale.marie;
      case 2:
        return SituationFamiliale.pacse;
      case 3:
        return SituationFamiliale.divorce;
      case 4:
        return SituationFamiliale.veuf;
      default:
        return SituationFamiliale.celibataire;
    }
  }

  @override
  void write(BinaryWriter writer, SituationFamiliale obj) {
    switch (obj) {
      case SituationFamiliale.celibataire:
        writer.writeByte(0);
        break;
      case SituationFamiliale.marie:
        writer.writeByte(1);
        break;
      case SituationFamiliale.pacse:
        writer.writeByte(2);
        break;
      case SituationFamiliale.divorce:
        writer.writeByte(3);
        break;
      case SituationFamiliale.veuf:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SituationFamilialeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FoyerFiscalModelAdapter extends TypeAdapter<FoyerFiscalModel> {
  @override
  final int typeId = 1;

  @override
  FoyerFiscalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FoyerFiscalModel(
      situationFamiliale: fields[0] as SituationFamiliale,
      nbEnfants: fields[1] as int,
      nbPartsSupplementaires: fields[2] as double,
      revenuNetImposable: fields[3] as double,
      autresRevenus: (fields[4] as List?)?.cast<RevenuModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, FoyerFiscalModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.situationFamiliale)
      ..writeByte(1)
      ..write(obj.nbEnfants)
      ..writeByte(2)
      ..write(obj.nbPartsSupplementaires)
      ..writeByte(3)
      ..write(obj.revenuNetImposable)
      ..writeByte(4)
      ..write(obj.autresRevenus);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoyerFiscalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RevenuModelAdapter extends TypeAdapter<RevenuModel> {
  @override
  final int typeId = 2;

  @override
  RevenuModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RevenuModel(
      type: fields[0] as String,
      montant: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, RevenuModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.montant);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RevenuModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
