/// Modele pour le calculateur IFI (Story 8.6).
///
/// Reference : Art. 964 a 983 CGI - impot sur la fortune immobiliere.
class IfiModel {
  /// Patrimoine immobilier brut taxable.
  final double patrimoineImmobilierBrut;

  /// Dettes deductibles (emprunts immobiliers...).
  final double dettesDeductibles;

  /// Dons IFI envisages (reduction de 75%, Art. 885-0 V bis A CGI).
  final double donsIfi;

  /// Age de l'usufruitier si strategie de demembrement (0 = pas de
  /// demembrement).
  final int ageUsufruitier;

  const IfiModel({
    required this.patrimoineImmobilierBrut,
    this.dettesDeductibles = 0,
    this.donsIfi = 0,
    this.ageUsufruitier = 0,
  });

  double get patrimoineNetTaxable {
    final net = patrimoineImmobilierBrut - dettesDeductibles;
    return net > 0 ? net : 0;
  }
}

/// Detail d'une tranche du bareme IFI.
class IfiTranche {
  final double borneBasse;
  final double borneHaute;
  final double taux;
  final double montantTaxe;

  const IfiTranche({
    required this.borneBasse,
    required this.borneHaute,
    required this.taux,
    required this.montantTaxe,
  });
}

/// Resultat du calcul IFI.
class IfiResult {
  /// Patrimoine net taxable retenu.
  final double patrimoineNetTaxable;

  /// Assujetti a l'IFI (patrimoine net > 1 300 000 EUR).
  final bool assujetti;

  /// IFI brut par tranches (calcul a partir de 800 000 EUR).
  final List<IfiTranche> tranches;

  /// IFI brut avant decote.
  final double ifiBrut;

  /// Decote applicable (patrimoine entre 1.3M et 1.4M).
  final double decote;

  /// IFI apres decote.
  final double ifiApresDecote;

  /// Reduction pour dons IFI (75% des dons, plafond 50 000 EUR).
  final double reductionDons;

  /// IFI final a payer.
  final double ifiFinal;

  /// Strategies de reduction suggerees.
  final List<String> strategies;

  const IfiResult({
    required this.patrimoineNetTaxable,
    required this.assujetti,
    required this.tranches,
    required this.ifiBrut,
    required this.decote,
    required this.ifiApresDecote,
    required this.reductionDons,
    required this.ifiFinal,
    required this.strategies,
  });
}
