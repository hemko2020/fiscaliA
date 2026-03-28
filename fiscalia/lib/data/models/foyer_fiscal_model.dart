import 'package:hive/hive.dart';

part 'foyer_fiscal_model.g.dart';

enum SituationFamiliale { celibataire, marie, pacse, divorce, veuf }

@HiveType(typeId: 0)
class FoyerFiscalModel {
  @HiveField(0)
  final SituationFamiliale situationFamiliale;

  @HiveField(1)
  final int nbEnfants;

  @HiveField(2)
  final double nbPartsSupplementaires;

  @HiveField(3)
  final double revenuNetImposable;

  @HiveField(4)
  final List<RevenuModel>? autresRevenus;

  FoyerFiscalModel({
    required this.situationFamiliale,
    required this.nbEnfants,
    this.nbPartsSupplementaires = 0,
    required this.revenuNetImposable,
    this.autresRevenus,
  });

  double get partsFiscales {
    double baseParts;
    switch (situationFamiliale) {
      case SituationFamiliale.celibataire:
      case SituationFamiliale.divorce:
      case SituationFamiliale.veuf:
        baseParts = 1;
        break;
      case SituationFamiliale.marie:
      case SituationFamiliale.pacse:
        baseParts = 2;
        break;
    }
    final partsEnfants = nbEnfants * 0.5;
    return baseParts + partsEnfants + nbPartsSupplementaires;
  }

  FoyerFiscalModel copyWith({
    SituationFamiliale? situationFamiliale,
    int? nbEnfants,
    double? nbPartsSupplementaires,
    double? revenuNetImposable,
    List<RevenuModel>? autresRevenus,
  }) {
    return FoyerFiscalModel(
      situationFamiliale: situationFamiliale ?? this.situationFamiliale,
      nbEnfants: nbEnfants ?? this.nbEnfants,
      nbPartsSupplementaires:
          nbPartsSupplementaires ?? this.nbPartsSupplementaires,
      revenuNetImposable: revenuNetImposable ?? this.revenuNetImposable,
      autresRevenus: autresRevenus ?? this.autresRevenus,
    );
  }
}

@HiveType(typeId: 1)
class RevenuModel {
  @HiveField(0)
  final String type;

  @HiveField(1)
  final double montant;

  RevenuModel({required this.type, required this.montant});
}
