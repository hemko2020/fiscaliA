import 'package:hive/hive.dart';

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

  /// Parent isole (case T de la declaration) : celibataire, divorce ou veuf
  /// vivant seul avec au moins un enfant a charge.
  /// Le 1er enfant donne alors droit a 1 part entiere (au lieu de 0,5).
  /// Reference : CGI art. 195 / BOFiP BOI-IR-LIQ-10-20.
  @HiveField(5)
  final bool parentIsole;

  FoyerFiscalModel({
    required this.situationFamiliale,
    required this.nbEnfants,
    this.nbPartsSupplementaires = 0,
    required this.revenuNetImposable,
    this.autresRevenus,
    this.parentIsole = false,
  });

  /// Nombre de parts fiscales.
  /// Regles (CGI art. 194-195) :
  /// - couple (marie/pacse) : 2 parts ; autre situation : 1 part
  /// - 1er et 2e enfant : 0,5 part chacun ; 3e enfant et suivants : 1 part
  /// - parent isole : le 1er enfant compte pour 1 part entiere
  double get partsFiscales {
    final isCouple =
        situationFamiliale == SituationFamiliale.marie ||
        situationFamiliale == SituationFamiliale.pacse;
    final double baseParts = isCouple ? 2 : 1;

    double partsEnfants = 0;
    for (int i = 1; i <= nbEnfants; i++) {
      if (i == 1 && parentIsole && !isCouple) {
        partsEnfants += 1; // part entiere pour le 1er enfant (parent isole)
      } else if (i <= 2) {
        partsEnfants += 0.5;
      } else {
        partsEnfants += 1; // 3e enfant et suivants
      }
    }
    return baseParts + partsEnfants + nbPartsSupplementaires;
  }

  FoyerFiscalModel copyWith({
    SituationFamiliale? situationFamiliale,
    int? nbEnfants,
    double? nbPartsSupplementaires,
    double? revenuNetImposable,
    List<RevenuModel>? autresRevenus,
    bool? parentIsole,
  }) {
    return FoyerFiscalModel(
      situationFamiliale: situationFamiliale ?? this.situationFamiliale,
      nbEnfants: nbEnfants ?? this.nbEnfants,
      nbPartsSupplementaires:
          nbPartsSupplementaires ?? this.nbPartsSupplementaires,
      revenuNetImposable: revenuNetImposable ?? this.revenuNetImposable,
      autresRevenus: autresRevenus ?? this.autresRevenus,
      parentIsole: parentIsole ?? this.parentIsole,
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
