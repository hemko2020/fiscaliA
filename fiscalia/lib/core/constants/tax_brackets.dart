class TaxBracket {
  final double minIncome;
  final double maxIncome;
  final double rate;

  const TaxBracket({
    required this.minIncome,
    required this.maxIncome,
    required this.rate,
  });
}

class TaxBrackets2026 {
  static const List<TaxBracket> ir2026 = [
    TaxBracket(minIncome: 0, maxIncome: 11600, rate: 0),
    TaxBracket(minIncome: 11601, maxIncome: 29579, rate: 0.11),
    TaxBracket(minIncome: 29580, maxIncome: 84577, rate: 0.30),
    TaxBracket(minIncome: 84578, maxIncome: 181917, rate: 0.41),
    TaxBracket(minIncome: 181918, maxIncome: double.infinity, rate: 0.45),
  ];

  static const double familyQuotientCeiling = 1807;

  /// Plafond specifique pour la part entiere du 1er enfant d'un parent
  /// isole (case T). Reference : BOFiP BOI-IR-LIQ-10-20.
  static const double parentIsoleQuotientCeiling = 4262;
  static const double nicheCeilingGeneral = 10000;
  static const double nicheCeilingOverseas = 18000;

  static const double decoteSingleThreshold = 1927;
  static const double decoteCoupleThreshold = 3191;
  static const double decoteMultiplier = 0.75;

  static const double perAnnualCeiling = 37094;
  static const int perCarryoverYears = 3;

  static const double homeEmploymentCeiling = 12000;
  static const double homeEmploymentExtraPerChild = 1500;
  static const double homeEmploymentMaxFirstYear = 15000;
  static const double homeEmploymentMaxWithMajorations = 18000;

  static const double childCareCeilingPerChild = 3500;

  static const double donation75Ceiling = 1000;
  static const double donation75Rate = 0.75;
  static const double donation66Rate = 0.66;
  static const double donation66CeilingRate = 0.20;

  static const Map<String, double> schoolFees = {
    'college': 61,
    'lycee': 153,
    'superieur': 183,
  };

  static const double alimonyMaxDeduction = 6674;

  static const double propertyDeficitCeiling = 10700;
}
