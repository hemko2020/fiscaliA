/// Modele pour la simulation LMNP avec amortissement (Story 8.2).
///
/// Reference : Art. 50-0 et 72 CGI (micro-BIC), Art. 39 C (amortissement),
/// BOI-BIC-CHAMP-40 (statut LMNP).
class LmnpSimulationModel {
  /// Prix d'acquisition du bien (terrain inclus).
  final double prixAcquisition;

  /// Valeur du mobilier.
  final double valeurMobilier;

  /// Loyers annuels encaisses.
  final double loyersAnnuels;

  /// Charges deductibles annuelles (taxe fonciere, interets, copropriete...).
  final double chargesAnnuelles;

  /// Taux marginal d'imposition du foyer (ex: 0.30).
  final double tmi;

  /// Duree de projection (annees).
  final int dureeAnnees;

  const LmnpSimulationModel({
    required this.prixAcquisition,
    this.valeurMobilier = 0,
    required this.loyersAnnuels,
    this.chargesAnnuelles = 0,
    required this.tmi,
    this.dureeAnnees = 10,
  });
}

/// Comparaison annuelle micro-BIC vs regime reel.
class LmnpComparaisonAnnuelle {
  final int annee;

  // --- Micro-BIC (abattement forfaitaire 50%) ---
  final double baseImposableMicro;
  final double impotMicro;

  // --- Reel (charges + amortissements) ---
  final double amortissementBatiment;
  final double amortissementMobilier;
  final double resultatFonctionnel;
  final double baseImposableReel;
  final double impotReel;
  final double amortissementsReportes;

  /// Economie realisee cette annee avec le reel vs micro-BIC.
  final double economieReel;

  const LmnpComparaisonAnnuelle({
    required this.annee,
    required this.baseImposableMicro,
    required this.impotMicro,
    required this.amortissementBatiment,
    required this.amortissementMobilier,
    required this.resultatFonctionnel,
    required this.baseImposableReel,
    required this.impotReel,
    required this.amortissementsReportes,
    required this.economieReel,
  });
}

/// Resultat global de la simulation LMNP.
class LmnpSimulationResult {
  final List<LmnpComparaisonAnnuelle> projection;
  final double economieTotaleReel;
  final double impotTotalMicro;
  final double impotTotalReel;

  /// Taux de fiscalite moyen des loyers au reel sur la periode.
  final double tauxFiscaliteReel;
  final List<String> recommandations;

  const LmnpSimulationResult({
    required this.projection,
    required this.economieTotaleReel,
    required this.impotTotalMicro,
    required this.impotTotalReel,
    required this.tauxFiscaliteReel,
    required this.recommandations,
  });
}
