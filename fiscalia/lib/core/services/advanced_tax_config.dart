import '../constants/advanced_tax_constants.dart';

/// Configuration des dispositifs fiscaux avances (Epic 8) pouvant etre
/// mise a jour a distance via Firebase Remote Config, avec fallback
/// embarque. Meme pattern que [TaxConfig].
class AdvancedTaxConfig {
  // PER
  final double perAnnualCeiling;
  final double perMinDeduction;
  final int perCarryoverYears;

  // LMNP
  final double lmnpMicroBicAbattement;
  final double lmnpMicroBicCeiling;
  final double lmnpLandShare;
  final int lmnpBuildingAmortizationYears;
  final int lmnpFurnitureAmortizationYears;

  // Prelevements sociaux / IS / PFU
  final double prelevementsSociaux;
  final double isReducedRate;
  final double isReducedRateCeiling;
  final double isNormalRate;
  final double pfuDividendes;

  // Demembrement (Art. 669 CGI) : (age limite exclu, valeur usufruit)
  final List<(int, double)> usufruitBareme;

  // DMTG ligne directe
  final double abattementLigneDirecte;
  final int rappelFiscalDonationYears;
  final List<(double, double)> baremeLigneDirecte;

  // Pacte Dutreil
  final double dutreilAbattement;

  // IFI
  final double ifiSeuilImposition;
  final double ifiSeuilCalcul;
  final List<(double, double)> baremeIFI;
  final double ifiDecoteBase;
  final double ifiDecoteTaux;
  final double ifiDecotePlafond;
  final double ifiDonReductionTaux;
  final double ifiDonReductionPlafond;

  // SOFICA / Girardin
  final double soficaTauxStandard;
  final double soficaTauxMajore;
  final double soficaPlafondInvestissement;
  final double girardinRendementTypique;
  final double plafondOutreMer;

  const AdvancedTaxConfig({
    required this.perAnnualCeiling,
    required this.perMinDeduction,
    required this.perCarryoverYears,
    required this.lmnpMicroBicAbattement,
    required this.lmnpMicroBicCeiling,
    required this.lmnpLandShare,
    required this.lmnpBuildingAmortizationYears,
    required this.lmnpFurnitureAmortizationYears,
    required this.prelevementsSociaux,
    required this.isReducedRate,
    required this.isReducedRateCeiling,
    required this.isNormalRate,
    required this.pfuDividendes,
    required this.usufruitBareme,
    required this.abattementLigneDirecte,
    required this.rappelFiscalDonationYears,
    required this.baremeLigneDirecte,
    required this.dutreilAbattement,
    required this.ifiSeuilImposition,
    required this.ifiSeuilCalcul,
    required this.baremeIFI,
    required this.ifiDecoteBase,
    required this.ifiDecoteTaux,
    required this.ifiDecotePlafond,
    required this.ifiDonReductionTaux,
    required this.ifiDonReductionPlafond,
    required this.soficaTauxStandard,
    required this.soficaTauxMajore,
    required this.soficaPlafondInvestissement,
    required this.girardinRendementTypique,
    required this.plafondOutreMer,
  });

  /// Configuration embarquee (fallback) : valeurs 2026 compilees dans l'app.
  const AdvancedTaxConfig.embedded()
      : perAnnualCeiling = AdvancedTaxConstants.perAnnualCeiling,
        perMinDeduction = AdvancedTaxConstants.perMinDeduction,
        perCarryoverYears = AdvancedTaxConstants.perCarryoverYears,
        lmnpMicroBicAbattement = AdvancedTaxConstants.lmnpMicroBicAbattement,
        lmnpMicroBicCeiling = AdvancedTaxConstants.lmnpMicroBicCeiling,
        lmnpLandShare = AdvancedTaxConstants.lmnpLandShare,
        lmnpBuildingAmortizationYears =
            AdvancedTaxConstants.lmnpBuildingAmortizationYears,
        lmnpFurnitureAmortizationYears =
            AdvancedTaxConstants.lmnpFurnitureAmortizationYears,
        prelevementsSociaux = AdvancedTaxConstants.prelevementsSociaux,
        isReducedRate = AdvancedTaxConstants.isReducedRate,
        isReducedRateCeiling = AdvancedTaxConstants.isReducedRateCeiling,
        isNormalRate = AdvancedTaxConstants.isNormalRate,
        pfuDividendes = AdvancedTaxConstants.pfuDividendes,
        usufruitBareme = const [
          (21, 0.90), (31, 0.80), (41, 0.70), (51, 0.60), (61, 0.50),
          (71, 0.40), (81, 0.30), (91, 0.20), (2147483647, 0.10),
        ],
        abattementLigneDirecte = AdvancedTaxConstants.abattementLigneDirecte,
        rappelFiscalDonationYears =
            AdvancedTaxConstants.rappelFiscalDonationYears,
        baremeLigneDirecte = AdvancedTaxConstants.baremeLigneDirecte,
        dutreilAbattement = AdvancedTaxConstants.dutreilAbattement,
        ifiSeuilImposition = AdvancedTaxConstants.ifiSeuilImposition,
        ifiSeuilCalcul = AdvancedTaxConstants.ifiSeuilCalcul,
        baremeIFI = AdvancedTaxConstants.baremeIFI,
        ifiDecoteBase = AdvancedTaxConstants.ifiDecoteBase,
        ifiDecoteTaux = AdvancedTaxConstants.ifiDecoteTaux,
        ifiDecotePlafond = AdvancedTaxConstants.ifiDecotePlafond,
        ifiDonReductionTaux = AdvancedTaxConstants.ifiDonReductionTaux,
        ifiDonReductionPlafond = AdvancedTaxConstants.ifiDonReductionPlafond,
        soficaTauxStandard = AdvancedTaxConstants.soficaTauxStandard,
        soficaTauxMajore = AdvancedTaxConstants.soficaTauxMajore,
        soficaPlafondInvestissement =
            AdvancedTaxConstants.soficaPlafondInvestissement,
        girardinRendementTypique =
            AdvancedTaxConstants.girardinRendementTypique,
        plafondOutreMer = AdvancedTaxConstants.plafondOutreMer;

  /// Valeur de l'usufruit en fraction (0..1) selon l'age (Art. 669 CGI).
  double usufruitRatioPourAge(int age) {
    for (final (ageLimite, ratio) in usufruitBareme) {
      if (age < ageLimite) return ratio;
    }
    return usufruitBareme.last.$2;
  }

  static double _d(Map<String, dynamic> json, String key, double fallback) =>
      (json[key] as num?)?.toDouble() ?? fallback;

  static int _i(Map<String, dynamic> json, String key, int fallback) =>
      (json[key] as num?)?.toInt() ?? fallback;

  /// Parse une liste de paires [[seuil, taux], ...] ; 0 = sans borne.
  static List<(double, double)> _bareme(
      Map<String, dynamic> json, String key, List<(double, double)> fallback) {
    final raw = json[key] as List<dynamic>?;
    if (raw == null || raw.isEmpty) return fallback;
    return raw.map((e) {
      final pair = e as List<dynamic>;
      final seuil = (pair[0] as num).toDouble();
      return (seuil <= 0 ? double.infinity : seuil, (pair[1] as num).toDouble());
    }).toList();
  }

  static List<(int, double)> _usufruit(
      Map<String, dynamic> json, List<(int, double)> fallback) {
    final raw = json['usufruitBareme'] as List<dynamic>?;
    if (raw == null || raw.isEmpty) return fallback;
    return raw.map((e) {
      final pair = e as List<dynamic>;
      return ((pair[0] as num).toInt(), (pair[1] as num).toDouble());
    }).toList();
  }

  factory AdvancedTaxConfig.fromJson(Map<String, dynamic> json) {
    const embedded = AdvancedTaxConfig.embedded();
    return AdvancedTaxConfig(
      perAnnualCeiling: _d(json, 'perAnnualCeiling', embedded.perAnnualCeiling),
      perMinDeduction: _d(json, 'perMinDeduction', embedded.perMinDeduction),
      perCarryoverYears:
          _i(json, 'perCarryoverYears', embedded.perCarryoverYears),
      lmnpMicroBicAbattement: _d(
          json, 'lmnpMicroBicAbattement', embedded.lmnpMicroBicAbattement),
      lmnpMicroBicCeiling:
          _d(json, 'lmnpMicroBicCeiling', embedded.lmnpMicroBicCeiling),
      lmnpLandShare: _d(json, 'lmnpLandShare', embedded.lmnpLandShare),
      lmnpBuildingAmortizationYears: _i(json, 'lmnpBuildingAmortizationYears',
          embedded.lmnpBuildingAmortizationYears),
      lmnpFurnitureAmortizationYears: _i(json, 'lmnpFurnitureAmortizationYears',
          embedded.lmnpFurnitureAmortizationYears),
      prelevementsSociaux:
          _d(json, 'prelevementsSociaux', embedded.prelevementsSociaux),
      isReducedRate: _d(json, 'isReducedRate', embedded.isReducedRate),
      isReducedRateCeiling:
          _d(json, 'isReducedRateCeiling', embedded.isReducedRateCeiling),
      isNormalRate: _d(json, 'isNormalRate', embedded.isNormalRate),
      pfuDividendes: _d(json, 'pfuDividendes', embedded.pfuDividendes),
      usufruitBareme: _usufruit(json, embedded.usufruitBareme),
      abattementLigneDirecte: _d(
          json, 'abattementLigneDirecte', embedded.abattementLigneDirecte),
      rappelFiscalDonationYears: _i(json, 'rappelFiscalDonationYears',
          embedded.rappelFiscalDonationYears),
      baremeLigneDirecte:
          _bareme(json, 'baremeLigneDirecte', embedded.baremeLigneDirecte),
      dutreilAbattement:
          _d(json, 'dutreilAbattement', embedded.dutreilAbattement),
      ifiSeuilImposition:
          _d(json, 'ifiSeuilImposition', embedded.ifiSeuilImposition),
      ifiSeuilCalcul: _d(json, 'ifiSeuilCalcul', embedded.ifiSeuilCalcul),
      baremeIFI: _bareme(json, 'baremeIFI', embedded.baremeIFI),
      ifiDecoteBase: _d(json, 'ifiDecoteBase', embedded.ifiDecoteBase),
      ifiDecoteTaux: _d(json, 'ifiDecoteTaux', embedded.ifiDecoteTaux),
      ifiDecotePlafond:
          _d(json, 'ifiDecotePlafond', embedded.ifiDecotePlafond),
      ifiDonReductionTaux:
          _d(json, 'ifiDonReductionTaux', embedded.ifiDonReductionTaux),
      ifiDonReductionPlafond:
          _d(json, 'ifiDonReductionPlafond', embedded.ifiDonReductionPlafond),
      soficaTauxStandard:
          _d(json, 'soficaTauxStandard', embedded.soficaTauxStandard),
      soficaTauxMajore: _d(json, 'soficaTauxMajore', embedded.soficaTauxMajore),
      soficaPlafondInvestissement: _d(json, 'soficaPlafondInvestissement',
          embedded.soficaPlafondInvestissement),
      girardinRendementTypique: _d(json, 'girardinRendementTypique',
          embedded.girardinRendementTypique),
      plafondOutreMer: _d(json, 'plafondOutreMer', embedded.plafondOutreMer),
    );
  }

  Map<String, dynamic> toJson() => {
        'perAnnualCeiling': perAnnualCeiling,
        'perMinDeduction': perMinDeduction,
        'perCarryoverYears': perCarryoverYears,
        'lmnpMicroBicAbattement': lmnpMicroBicAbattement,
        'lmnpMicroBicCeiling': lmnpMicroBicCeiling,
        'lmnpLandShare': lmnpLandShare,
        'lmnpBuildingAmortizationYears': lmnpBuildingAmortizationYears,
        'lmnpFurnitureAmortizationYears': lmnpFurnitureAmortizationYears,
        'prelevementsSociaux': prelevementsSociaux,
        'isReducedRate': isReducedRate,
        'isReducedRateCeiling': isReducedRateCeiling,
        'isNormalRate': isNormalRate,
        'pfuDividendes': pfuDividendes,
        'usufruitBareme': usufruitBareme.map((e) => [e.$1, e.$2]).toList(),
        'abattementLigneDirecte': abattementLigneDirecte,
        'rappelFiscalDonationYears': rappelFiscalDonationYears,
        'baremeLigneDirecte': baremeLigneDirecte
            .map((e) => [e.$1.isInfinite ? 0 : e.$1, e.$2])
            .toList(),
        'dutreilAbattement': dutreilAbattement,
        'ifiSeuilImposition': ifiSeuilImposition,
        'ifiSeuilCalcul': ifiSeuilCalcul,
        'baremeIFI':
            baremeIFI.map((e) => [e.$1.isInfinite ? 0 : e.$1, e.$2]).toList(),
        'ifiDecoteBase': ifiDecoteBase,
        'ifiDecoteTaux': ifiDecoteTaux,
        'ifiDecotePlafond': ifiDecotePlafond,
        'ifiDonReductionTaux': ifiDonReductionTaux,
        'ifiDonReductionPlafond': ifiDonReductionPlafond,
        'soficaTauxStandard': soficaTauxStandard,
        'soficaTauxMajore': soficaTauxMajore,
        'soficaPlafondInvestissement': soficaPlafondInvestissement,
        'girardinRendementTypique': girardinRendementTypique,
        'plafondOutreMer': plafondOutreMer,
      };
}
