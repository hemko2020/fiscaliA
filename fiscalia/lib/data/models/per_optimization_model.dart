/// Modele pour les strategies PER avancees (Story 8.1).
///
/// Reference : Art. 163 quatervicies CGI - deduction des versements PER,
/// plafond 10% des revenus professionnels (max 8 PASS), report 3 ans,
/// mutualisation possible entre conjoints (case 6QR / plafonds 6QS).
class PerOptimizationModel {
  /// Revenu net imposable du declarant 1.
  final double revenuDeclarant1;

  /// Revenu net imposable du declarant 2 (0 si celibataire).
  final double revenuDeclarant2;

  /// Taux marginal d'imposition du foyer (ex: 0.30).
  final double tmi;

  /// Plafonds non utilises reportables (N-1, N-2, N-3) pour le declarant 1.
  final List<double> reportsDeclarant1;

  /// Plafonds non utilises reportables pour le declarant 2.
  final List<double> reportsDeclarant2;

  /// Versement PER envisage cette annee.
  final double versementEnvisage;

  const PerOptimizationModel({
    required this.revenuDeclarant1,
    this.revenuDeclarant2 = 0,
    required this.tmi,
    this.reportsDeclarant1 = const [0, 0, 0],
    this.reportsDeclarant2 = const [0, 0, 0],
    this.versementEnvisage = 0,
  });

  bool get estEnCouple => revenuDeclarant2 > 0;

  /// Plafond de deduction annuel : 10% du revenu, borne au plafond legal.
  static double plafondAnnuel(
    double revenu,
    double plafondLegal,
    double plancher,
  ) {
    final calcul = revenu * 0.10;
    if (calcul > plafondLegal) return plafondLegal;
    if (calcul < plancher) return plancher;
    return calcul;
  }
}

/// Resultat complet d'une optimisation PER.
class PerOptimizationResult {
  /// Plafond individuel disponible (annee N + reports) pour chaque declarant.
  final double plafondDisponibleDeclarant1;
  final double plafondDisponibleDeclarant2;

  /// Plafond mutualise du couple (= somme si mutualisation activee).
  final double plafondMutualise;

  /// Versement optimal recommande (min du versement envisage et du plafond).
  final double versementOptimal;

  /// Economie d'impot estimee = versement deductible x TMI.
  final double economieImpot;

  /// Part du versement non deductible (au-dela du plafond).
  final double excedentNonDeductible;

  /// Reports qui expireront au 31/12 si non utilises (N-3).
  final double reportsExpirants;

  /// Messages strategiques (mutualisation, expiration...).
  final List<String> recommandations;

  const PerOptimizationResult({
    required this.plafondDisponibleDeclarant1,
    required this.plafondDisponibleDeclarant2,
    required this.plafondMutualise,
    required this.versementOptimal,
    required this.economieImpot,
    required this.excedentNonDeductible,
    required this.reportsExpirants,
    required this.recommandations,
  });
}
