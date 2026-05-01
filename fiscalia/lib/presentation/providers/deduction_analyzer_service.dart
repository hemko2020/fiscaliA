import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/parsed_document_data.dart';

final deductionAnalyzerServiceProvider = Provider<DeductionAnalyzerService>((
  ref,
) {
  return DeductionAnalyzerService();
});

class DeductionAnalysisResult {
  final double standardDeduction;
  final double estimatedRealExpenses;
  final bool isRealExpensesBetter;
  final List<String> suggestions;

  const DeductionAnalysisResult({
    required this.standardDeduction,
    required this.estimatedRealExpenses,
    required this.isRealExpensesBetter,
    required this.suggestions,
  });
}

class DeductionAnalyzerService {
  /// Fiscal 2024/2026 constants for meals
  static const double mealDeductionWithoutCanteen = 5.20;

  DeductionAnalysisResult analyze(
    ParsedDocumentData data, {
    bool hasCompanyCanteen = false,
    double distanceToWorkKm = 10,
  }) {
    if (data.netTaxableIncome == null) {
      return const DeductionAnalysisResult(
        standardDeduction: 0,
        estimatedRealExpenses: 0,
        isRealExpensesBetter: false,
        suggestions: [
          'Impossible d\'analyser : Salaire net imposable introuvable.',
        ],
      );
    }

    // 10% standard deduction (Abattement forfaitaire)
    final standardDeduction = data.netTaxableIncome! * 0.10;

    // Estimate Real Expenses (Frais réels)
    double estimatedRealExpenses = 0;
    final List<String> suggestions = [];

    // 1. Meal expenses (Frais de repas)
    if (!hasCompanyCanteen) {
      // Typically ~220 working days per year. If monthly slip, ~20 days.
      final days = data.mealVoucherCount ?? 20;
      double mealExpense = days * mealDeductionWithoutCanteen;

      // Subtract employer contribution for meal vouchers
      if (data.mealVoucherEmployerContribution != null) {
        mealExpense -= data.mealVoucherEmployerContribution!;
      }

      if (mealExpense > 0) {
        estimatedRealExpenses += mealExpense;
        suggestions.add(
          'Frais de repas déductibles estimés : ${mealExpense.toStringAsFixed(2)}€/mois',
        );
      }
    }

    // 2. Transport expenses
    // Simple estimation based on distance (using a flat rough average of 0.35€/km for calculation simplicity)
    if (!data.hasCompanyCar) {
      final days = 20; // monthly working days
      final roundTripKm = distanceToWorkKm * 2;
      final monthlyTransportCost = roundTripKm * 0.35 * days;

      // If user gets transport allowance, it must be added back to income if they claim real expenses
      // Or they can deduct the difference.
      final allowance = data.transportAllowance ?? 0;

      if (monthlyTransportCost > allowance) {
        estimatedRealExpenses += monthlyTransportCost;
        suggestions.add(
          'Frais kilométriques estimés : ${monthlyTransportCost.toStringAsFixed(2)}€/mois (contre ${allowance.toStringAsFixed(2)}€ remboursés)',
        );
      }
    } else {
      suggestions.add(
        'Véhicule de fonction détecté. Les frais kilométriques ne sont pas applicables.',
      );
    }

    final isRealExpensesBetter =
        estimatedRealExpenses > (standardDeduction / 12); // monthly comparison

    if (isRealExpensesBetter) {
      suggestions.insert(
        0,
        '💡 Les frais réels semblent plus avantageux que l\'abattement de 10% !',
      );
    } else {
      suggestions.insert(
        0,
        '💡 L\'abattement forfaitaire de 10% reste l\'option la plus avantageuse pour vous.',
      );
    }

    return DeductionAnalysisResult(
      standardDeduction: standardDeduction,
      estimatedRealExpenses: estimatedRealExpenses * 12, // Annualized
      isRealExpensesBetter: isRealExpensesBetter,
      suggestions: suggestions,
    );
  }
}
