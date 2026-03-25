// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simulation_model.dart';

class SimulationModelAdapter extends TypeAdapter<SimulationModel> {
  @override
  final int typeId = 3;

  @override
  SimulationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SimulationModel(
      foyerFiscal: fields[0] as FoyerFiscalModel,
      impotBrut: fields[1] as double,
      decote: fields[2] as double,
      reductions: (fields[3] as List?)?.cast<ReductionModel>(),
      credits: (fields[4] as List?)?.cast<CreditModel>(),
      impotNet: fields[5] as double,
      tauxMoyen: fields[6] as double,
      tauxMarginal: fields[7] as double,
      dateSimulation: fields[8] as DateTime,
      detailsParTranche: (fields[9] as Map?)?.cast<int, double>(),
    );
  }

  @override
  void write(BinaryWriter writer, SimulationModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.foyerFiscal)
      ..writeByte(1)
      ..write(obj.impotBrut)
      ..writeByte(2)
      ..write(obj.decote)
      ..writeByte(3)
      ..write(obj.reductions)
      ..writeByte(4)
      ..write(obj.credits)
      ..writeByte(5)
      ..write(obj.impotNet)
      ..writeByte(6)
      ..write(obj.tauxMoyen)
      ..writeByte(7)
      ..write(obj.tauxMarginal)
      ..writeByte(8)
      ..write(obj.dateSimulation)
      ..writeByte(9)
      ..write(obj.detailsParTranche);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimulationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReductionModelAdapter extends TypeAdapter<ReductionModel> {
  @override
  final int typeId = 4;

  @override
  ReductionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReductionModel(
      dispositifId: fields[0] as String,
      nom: fields[1] as String,
      montant: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ReductionModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.dispositifId)
      ..writeByte(1)
      ..write(obj.nom)
      ..writeByte(2)
      ..write(obj.montant);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReductionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CreditModelAdapter extends TypeAdapter<CreditModel> {
  @override
  final int typeId = 5;

  @override
  CreditModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreditModel(
      dispositifId: fields[0] as String,
      nom: fields[1] as String,
      montant: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, CreditModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.dispositifId)
      ..writeByte(1)
      ..write(obj.nom)
      ..writeByte(2)
      ..write(obj.montant);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreditModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
