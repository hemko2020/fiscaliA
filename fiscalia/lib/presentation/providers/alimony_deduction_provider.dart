import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/alimony_deduction_model.dart';

final alimonyDeductionServiceProvider = Provider(
  (ref) => AlimonyDeductionService(),
);

final alimonyDeductionProvider = StateProvider<AlimonyDeductionModel?>(
  (ref) => null,
);

class AlimonyDeductionService {
  static const double maxAnnualDeduction = 6674.0;

  double calculateDeduction({required double alimonyAmount}) {
    return alimonyAmount.clamp(0, maxAnnualDeduction);
  }

  Map<String, dynamic> calculateFullDeductionDetails(
    AlimonyDeductionModel model,
  ) {
    final deduction = calculateDeduction(alimonyAmount: model.alimonyAmount);

    final excessAmount = model.alimonyAmount > maxAnnualDeduction
        ? model.alimonyAmount - maxAnnualDeduction
        : 0.0;

    return {
      'alimonyAmount': model.alimonyAmount,
      'deductionType': model.deductionType,
      'isDeductible': model.isDeductible,
      'deduction': deduction,
      'maxDeduction': maxAnnualDeduction,
      'excessAmount': excessAmount,
      'isCeilingReached': model.isCeilingReached,
      'deductionRate': model.alimonyAmount > 0
          ? deduction / model.alimonyAmount
          : 0.0,
      'countsTowardNicheCeiling': true,
      'nicheCeilingImpact': deduction,
    };
  }

  bool validateAlimonyAmount(double amount) {
    return amount >= 0 && amount <= 100000;
  }

  String? validateAlimonyAmountMessage(double amount) {
    if (amount < 0) {
      return 'Le montant ne peut pas être négatif';
    }
    if (amount > 100000) {
      return 'Le montant semble anormalement élevé. Veuillez vérifier.';
    }
    return null;
  }

  String getDeductionRecommendation(
    double alimonyAmount,
    bool isSpousalSupport,
    bool isChildSupport,
  ) {
    final deduction = calculateDeduction(alimonyAmount: alimonyAmount);

    if (alimonyAmount == 0) {
      return 'Si vous versez une pension alimentaire, vous pouvez bénéficier d\'une déduction fiscale.';
    }

    if (!isSpousalSupport && !isChildSupport) {
      return 'Veuillez spécifier le type de pension (alimentaire ou pour enfants).';
    }

    if (alimonyAmount > maxAnnualDeduction) {
      return 'Attention: Seulement ${maxAnnualDeduction.toStringAsFixed(0)}€ sont déductibles par an.';
    }

    return 'Vous pouvez déduire ${deduction.toStringAsFixed(0)}€ de vos revenus imposables.';
  }

  String getLegalReference(bool isSpousalSupport, bool isChildSupport) {
    if (isSpousalSupport) {
      return 'Article 156 II 2° du CGI - Pension alimentaire';
    } else if (isChildSupport) {
      return 'Article 156 II 2° du CGI - Pension pour enfants';
    }
    return 'Article 156 II 2° du CGI';
  }

  String getRecipientObligation(bool isSpousalSupport, bool isChildSupport) {
    if (isSpousalSupport && isChildSupport) {
      return 'Le bénéficiaire doit déclarer ces sommes comme revenus imposables.';
    } else if (isSpousalSupport) {
      return 'Votre ex-conjoint doit déclarer cette pension comme revenu imposable.';
    } else if (isChildSupport) {
      return 'Le bénéficiaire doit déclarer cette pension comme revenu imposable.';
    }
    return '';
  }
}
