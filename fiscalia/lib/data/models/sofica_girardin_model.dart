/// Modele pour les calculs SOFICA et Girardin industriel (Story 8.7).
///
/// Reference : Art. 199 unvicies CGI (SOFICA), Art. 199 undecies B CGI
/// (Girardin industriel). Les deux relevent du plafond specifique de
/// 18 000 EUR (plafond global 10K + 8K).
class SoficaGirardinModel {
  /// Montant investi en SOFICA cette annee.
  final double investissementSofica;

  /// La SOFICA respecte les conditions de taux majore
  /// (>= 10% en PME de production, >= 44% en oeuvres d'art).
  final bool soficaTauxMajore;

  /// Montant investi en Girardin industriel avec agrément.
  final double investissementGirardin;

  /// Rendement promis par l'operateur Girardin (ex: 1.10 = 110%).
  final double rendementGirardin;

  /// Impot sur le revenu avant reductions (pour verifier l'imputabilite).
  final double impotAvantReductions;

  const SoficaGirardinModel({
    this.investissementSofica = 0,
    this.soficaTauxMajore = false,
    this.investissementGirardin = 0,
    this.rendementGirardin = 1.10,
    required this.impotAvantReductions,
  });
}

/// Resultat des calculs SOFICA + Girardin.
class SoficaGirardinResult {
  /// Reduction SOFICA (30% ou 48% de l'investissement).
  final double reductionSofica;

  /// Reduction Girardin (one-shot : investissement x rendement).
  final double reductionGirardin;

  /// Reduction totale imputable sur l'impot de l'annee.
  final double reductionImputable;

  /// Part non imputable cette annee (reduction > impot).
  /// Attention : contrairement aux dons, les excedents SOFICA et Girardin
  /// ne sont NI reportables NI remboursables - ils sont perdus.
  final double reductionNonImputable;

  /// Gain net Girardin (reduction - investissement).
  final double gainNetGirardin;

  /// Niveau de risque (1-5).
  final int risqueScore;
  final List<String> avertissements;

  const SoficaGirardinResult({
    required this.reductionSofica,
    required this.reductionGirardin,
    required this.reductionImputable,
    required this.reductionNonImputable,
    required this.gainNetGirardin,
    required this.risqueScore,
    required this.avertissements,
  });
}
