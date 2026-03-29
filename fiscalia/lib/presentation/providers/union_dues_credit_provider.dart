import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/union_dues_credit_model.dart';

final unionDuesCreditServiceProvider = Provider(
  (ref) => UnionDuesCreditService(),
);

final unionDuesCreditProvider = StateProvider<UnionDuesCreditModel?>(
  (ref) => null,
);

class UnionDuesCreditService {
  double calculateCeiling({required double grossIncome}) {
    return grossIncome * 0.01;
  }

  double calculateCredit({
    required double unionDues,
    required double grossIncome,
  }) {
    final ceiling = calculateCeiling(grossIncome: grossIncome);
    final eligibleDues = unionDues.clamp(0, ceiling);
    return eligibleDues * 0.66;
  }

  Map<String, dynamic> calculateFullCreditDetails(UnionDuesCreditModel model) {
    final ceiling = calculateCeiling(grossIncome: model.grossIncome);

    final credit = calculateCredit(
      unionDues: model.unionDues,
      grossIncome: model.grossIncome,
    );

    final excessDues = model.unionDues > ceiling
        ? model.unionDues - ceiling
        : 0.0;

    return {
      'unionDues': model.unionDues,
      'grossIncome': model.grossIncome,
      'ceiling': ceiling,
      'credit': credit,
      'effectiveRate': model.unionDues > 0 ? credit / model.unionDues : 0.0,
      'excessDues': excessDues,
      'isCeilingReached': model.unionDues > ceiling,
      'countsTowardNicheCeiling': true,
      'nicheCeilingImpact': credit,
    };
  }

  bool validateUnionDues(double unionDues) {
    return unionDues >= 0 && unionDues <= 10000;
  }

  bool validateGrossIncome(double grossIncome) {
    return grossIncome >= 0 && grossIncome <= 1000000;
  }

  String? validateUnionDuesMessage(double unionDues) {
    if (unionDues < 0) {
      return 'Le montant des cotisations ne peut pas être négatif';
    }
    if (unionDues > 10000) {
      return 'Le montant semble anormalement élevé. Veuillez vérifier.';
    }
    return null;
  }

  String? validateGrossIncomeMessage(double grossIncome) {
    if (grossIncome < 0) {
      return 'Le revenu brut ne peut pas être négatif';
    }
    if (grossIncome > 1000000) {
      return 'Le revenu brut semble anormalement élevé. Veuillez vérifier.';
    }
    return null;
  }

  String getCreditRecommendation(double unionDues, double grossIncome) {
    final ceiling = calculateCeiling(grossIncome: grossIncome);
    final credit = calculateCredit(
      unionDues: unionDues,
      grossIncome: grossIncome,
    );

    if (unionDues == 0) {
      return 'Si vous payez des cotisations syndicales, vous pouvez bénéficier d\'un crédit d\'impôt de 66%.';
    }

    if (unionDues > ceiling) {
      return 'Attention: Seulement ${ceiling.toStringAsFixed(2)}€ de vos cotisations sont éligibles au crédit d\'impôt.';
    }

    return 'Vous pouvez récupérer ${credit.toStringAsFixed(2)}€ grâce à vos cotisations syndicales.';
  }
}
