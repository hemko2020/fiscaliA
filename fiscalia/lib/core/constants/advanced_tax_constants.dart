/// Constantes fiscales 2026 pour les dispositifs avances et experts.
///
/// Sources : CGI (art. 669, 787 B, 885 U V bis...), BOFiP, loi de finances 2026.
/// Chaque calcul est documente avec sa reference legislative.
class AdvancedTaxConstants {
  AdvancedTaxConstants._();

  // ---------------------------------------------------------------------------
  // PER - Plan Epargne Retraite (Art. 163 quatervicies CGI)
  // ---------------------------------------------------------------------------

  /// Plafond annuel de deduction PER 2026 (10% des revenus pro, max 8 PASS).
  static const double perAnnualCeiling = 37094;

  /// Plancher de deduction (10% du PASS) pour les faibles revenus.
  static const double perMinDeduction = 4637;

  /// Nombre d'annees de report des plafonds non utilises.
  static const int perCarryoverYears = 3;

  // ---------------------------------------------------------------------------
  // LMNP - Location Meublee Non Professionnelle (Art. 50-0, 72 CGI)
  // ---------------------------------------------------------------------------

  /// Abattement forfaitaire micro-BIC location meublee classique.
  static const double lmnpMicroBicAbattement = 0.50;

  /// Plafond de recettes micro-BIC meuble classique.
  static const double lmnpMicroBicCeiling = 77700;

  /// Part du terrain (non amortissable) dans le prix d'acquisition.
  static const double lmnpLandShare = 0.15;

  /// Duree d'amortissement standard du batiment (annees).
  static const int lmnpBuildingAmortizationYears = 30;

  /// Duree d'amortissement standard du mobilier (annees).
  static const int lmnpFurnitureAmortizationYears = 7;

  // ---------------------------------------------------------------------------
  // Prelevements sociaux sur revenus du patrimoine.
  // ---------------------------------------------------------------------------
  static const double prelevementsSociaux = 0.172;

  // ---------------------------------------------------------------------------
  // Impot sur les societes (Art. 219 CGI) - PME.
  // ---------------------------------------------------------------------------
  static const double isReducedRate = 0.15;
  static const double isReducedRateCeiling = 42500;
  static const double isNormalRate = 0.25;

  /// Flat tax (PFU) sur les dividendes distribues : 12.8% IR + 17.2% PS.
  static const double pfuDividendes = 0.30;

  // ---------------------------------------------------------------------------
  // Demembrement de propriete (Art. 669 CGI) - Bareme economique.
  // Valeur de l'usufruit selon l'age de l'usufruitier.
  // ---------------------------------------------------------------------------

  /// Retourne la valeur de l'usufruit en fraction (0..1) selon l'age.
  static double usufruitRatioPourAge(int age) {
    if (age < 21) return 0.90;
    if (age < 31) return 0.80;
    if (age < 41) return 0.70;
    if (age < 51) return 0.60;
    if (age < 61) return 0.50;
    if (age < 71) return 0.40;
    if (age < 81) return 0.30;
    if (age < 91) return 0.20;
    return 0.10;
  }

  // ---------------------------------------------------------------------------
  // Droits de mutation a titre gratuit (DMTG) - Ligne directe (Art. 777 CGI).
  // ---------------------------------------------------------------------------

  /// Abattement en ligne directe par parent et par enfant (tous les 15 ans).
  static const double abattementLigneDirecte = 100000;

  /// Duree de rappel fiscal pour les donations (annees).
  static const int rappelFiscalDonationYears = 15;

  /// Bareme progressif ligne directe : (seuil, taux).
  static const List<(double, double)> baremeLigneDirecte = [
    (8072, 0.05),
    (12109, 0.10),
    (15932, 0.15),
    (552324, 0.20),
    (902838, 0.30),
    (1805677, 0.40),
    (double.infinity, 0.45),
  ];

  // ---------------------------------------------------------------------------
  // Pacte Dutreil (Art. 787 B et 787 C CGI).
  // ---------------------------------------------------------------------------

  /// Abattement Dutreil sur la valeur de l'entreprise transmise.
  static const double dutreilAbattement = 0.75;

  // ---------------------------------------------------------------------------
  // IFI - Impot sur la Fortune Immobiliere (Art. 964 a 983 CGI).
  // ---------------------------------------------------------------------------

  /// Seuil d'assujettissement a l'IFI.
  static const double ifiSeuilImposition = 1300000;

  /// Seuil de declenchement du calcul (taxation des 800k des que > 1.3M).
  static const double ifiSeuilCalcul = 800000;

  /// Bareme IFI 2026 : (seuil, taux).
  static const List<(double, double)> baremeIFI = [
    (800000, 0.0),
    (1300000, 0.005),
    (2570000, 0.007),
    (5000000, 0.01),
    (10000000, 0.0125),
    (double.infinity, 0.015),
  ];

  /// Decote pour patrimoine entre 1.3M et 1.4M :
  /// IFI = 17500 - 1.25% x patrimoine net taxable.
  static const double ifiDecoteBase = 17500;
  static const double ifiDecoteTaux = 0.0125;
  static const double ifiDecotePlafond = 1400000;

  /// Reduction IFI pour dons (75%) - Art. 885-0 V bis A CGI.
  static const double ifiDonReductionTaux = 0.75;
  static const double ifiDonReductionPlafond = 50000;

  // ---------------------------------------------------------------------------
  // SOFICA (Art. 199 unvicies CGI) et Girardin industriel (Art. 199 undecies B).
  // ---------------------------------------------------------------------------

  /// Taux de reduction SOFICA standard.
  static const double soficaTauxStandard = 0.30;

  /// Taux majore si >= 10% investi dans des PME de production.
  static const double soficaTauxMajore = 0.48;

  /// Plafond d'investissement annuel SOFICA.
  static const double soficaPlafondInvestissement = 18000;

  /// Rendement brut typique d'un Girardin industriel one-shot (110%).
  static const double girardinRendementTypique = 1.10;

  /// Plafond specifique outre-mer (SOFICA + Girardin).
  static const double plafondOutreMer = 18000;
}
