/// Modele pour la comparaison SCI a l'IR vs SCI a l'IS (Story 8.3).
///
/// Reference : Art. 8 CGI (transparence IR), Art. 206 et 219 CGI (IS),
/// Art. 156 I 3 CGI (deficit foncier imputable sur revenu global).
class SciComparisonModel {
  /// Loyers annuels.
  final double loyersAnnuels;

  /// Charges deductibles annuelles (hors amortissement).
  final double chargesAnnuelles;

  /// Valeur amortissable du bien (prix - terrain) pour l'IS.
  final double valeurAmortissable;

  /// Duree d'amortissement a l'IS (annees).
  final int dureeAmortissement;

  /// TMI des associes (regime IR).
  final double tmi;

  /// Part du resultat distribuee chaque annee en dividendes (0 a 1).
  /// Le reste est conserve en tresorerie dans la SCI.
  final double tauxDistribution;

  /// Deficit foncier annuel generable (travaux > loyers), borne a 10 700 EUR.
  final double deficitFoncierAnnuel;

  const SciComparisonModel({
    required this.loyersAnnuels,
    this.chargesAnnuelles = 0,
    this.valeurAmortissable = 0,
    this.dureeAmortissement = 30,
    required this.tmi,
    this.tauxDistribution = 0,
    this.deficitFoncierAnnuel = 0,
  });
}

/// Resultat annuel pour un regime donne.
class SciRegimeResult {
  /// Resultat comptable (loyers - charges - amortissements eventuels).
  final double resultat;
  final double impotSurResultat;

  /// Fiscalite sur les dividendes distribues (PFU 30%) - IS uniquement.
  final double fiscaliteDistribution;

  /// Economie d'impot generee par le deficit foncier (IR uniquement).
  final double economieDeficitFoncier;

  /// Fiscalite totale nette de l'annee.
  final double fiscaliteTotale;

  const SciRegimeResult({
    required this.resultat,
    required this.impotSurResultat,
    required this.fiscaliteDistribution,
    required this.economieDeficitFoncier,
    required this.fiscaliteTotale,
  });
}

/// Comparaison complete IR vs IS.
class SciComparisonResult {
  final SciRegimeResult regimeIR;
  final SciRegimeResult regimeIS;

  /// Regime le plus avantageux cette annee ('IR' ou 'IS').
  final String regimeRecommande;
  final double avantageAnnuel;

  /// Point de vigilance : l'option IS est definitive et la sortie
  /// (cession/liquidation) declenche l'imposition des plus-values latentes.
  final List<String> pointsVigilance;

  const SciComparisonResult({
    required this.regimeIR,
    required this.regimeIS,
    required this.regimeRecommande,
    required this.avantageAnnuel,
    required this.pointsVigilance,
  });
}
