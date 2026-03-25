import 'package:hive/hive.dart';

part 'dispositif_model.g.dart';

enum CategorieDispositif {
  basique,
  avance,
  expert,
}

enum TypeDispositif {
  reduction,
  credit,
  deduction,
}

@HiveType(typeId: 5)
class DispositifModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nom;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final CategorieDispositif categorie;

  @HiveField(4)
  final TypeDispositif type;

  @HiveField(5)
  final double tauxAvantage;

  @HiveField(6)
  final double? plafond;

  @HiveField(7)
  final List<String>? conditionsEligibilite;

  @HiveField(8)
  final bool horsNicheFiscale;

  @HiveField(9)
  final String baseLegale;

  @HiveField(10)
  final int risqueScore;

  DispositifModel({
    required this.id,
    required this.nom,
    required this.description,
    required this.categorie,
    required this.type,
    required this.tauxAvantage,
    this.plafond,
    this.conditionsEligibilite,
    this.horsNicheFiscale = false,
    required this.baseLegale,
    this.risqueScore = 1,
  });

  double calculerAvantage(double montantDepense) {
    if (plafond != null && montantDepense > plafond!) {
      montantDepense = plafond!;
    }
    return montantDepense * tauxAvantage;
  }
}
