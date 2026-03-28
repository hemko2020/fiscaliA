import 'package:hive/hive.dart';
import 'foyer_fiscal_model.dart';

@HiveType(typeId: 2)
class SimulationModel {
  @HiveField(0)
  final FoyerFiscalModel foyerFiscal;

  @HiveField(1)
  final double impotBrut;

  @HiveField(2)
  final double decote;

  @HiveField(3)
  final List<ReductionModel>? reductions;

  @HiveField(4)
  final List<CreditModel>? credits;

  @HiveField(5)
  final double impotNet;

  @HiveField(6)
  final double tauxMoyen;

  @HiveField(7)
  final double tauxMarginal;

  @HiveField(8)
  final DateTime dateSimulation;

  @HiveField(9)
  final Map<int, double>? detailsParTranche;

  SimulationModel({
    required this.foyerFiscal,
    required this.impotBrut,
    this.decote = 0,
    this.reductions,
    this.credits,
    required this.impotNet,
    required this.tauxMoyen,
    required this.tauxMarginal,
    required this.dateSimulation,
    this.detailsParTranche,
  });

  double get totalAvantages {
    double total = 0;
    if (reductions != null) {
      total += reductions!.fold(0.0, (sum, r) => sum + r.montant);
    }
    if (credits != null) {
      total += credits!.fold(0.0, (sum, c) => sum + c.montant);
    }
    return total;
  }
}

@HiveType(typeId: 3)
class ReductionModel {
  @HiveField(0)
  final String dispositifId;

  @HiveField(1)
  final String nom;

  @HiveField(2)
  final double montant;

  ReductionModel({
    required this.dispositifId,
    required this.nom,
    required this.montant,
  });
}

@HiveType(typeId: 4)
class CreditModel {
  @HiveField(0)
  final String dispositifId;

  @HiveField(1)
  final String nom;

  @HiveField(2)
  final double montant;

  CreditModel({
    required this.dispositifId,
    required this.nom,
    required this.montant,
  });
}
