class ParsedDocumentData {
  final double? netTaxableIncome;
  final double? transportAllowance;
  final double? mealVoucherEmployerContribution;
  final int? mealVoucherCount;
  final bool hasCompanyCar;
  
  const ParsedDocumentData({
    this.netTaxableIncome,
    this.transportAllowance,
    this.mealVoucherEmployerContribution,
    this.mealVoucherCount,
    this.hasCompanyCar = false,
  });

  bool get isPaySlip => netTaxableIncome != null;

  ParsedDocumentData copyWith({
    double? netTaxableIncome,
    double? transportAllowance,
    double? mealVoucherEmployerContribution,
    int? mealVoucherCount,
    bool? hasCompanyCar,
  }) {
    return ParsedDocumentData(
      netTaxableIncome: netTaxableIncome ?? this.netTaxableIncome,
      transportAllowance: transportAllowance ?? this.transportAllowance,
      mealVoucherEmployerContribution: mealVoucherEmployerContribution ?? this.mealVoucherEmployerContribution,
      mealVoucherCount: mealVoucherCount ?? this.mealVoucherCount,
      hasCompanyCar: hasCompanyCar ?? this.hasCompanyCar,
    );
  }
}