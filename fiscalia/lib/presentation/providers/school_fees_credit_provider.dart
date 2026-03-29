import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/school_fees_credit_model.dart';

final schoolFeesCreditServiceProvider = Provider(
  (ref) => SchoolFeesCreditService(),
);

final schoolFeesCreditProvider = StateProvider<SchoolFeesCreditModel?>(
  (ref) => null,
);

class SchoolFeesCreditService {
  double calculateCeiling({
    required int numberOfChildren,
    required bool isSecondaryEducation,
  }) {
    if (isSecondaryEducation) {
      return 153.0 * numberOfChildren;
    }
    return 100.0 * numberOfChildren;
  }

  double calculateCredit({
    required double expenses,
    required int numberOfChildren,
    required bool isSecondaryEducation,
  }) {
    final ceiling = calculateCeiling(
      numberOfChildren: numberOfChildren,
      isSecondaryEducation: isSecondaryEducation,
    );
    final eligibleExpenses = expenses.clamp(0, ceiling);
    return eligibleExpenses * 0.50;
  }

  Map<String, dynamic> calculateFullCreditDetails(SchoolFeesCreditModel model) {
    final ceiling = calculateCeiling(
      numberOfChildren: model.numberOfChildren,
      isSecondaryEducation: model.isSecondaryEducation,
    );
    final credit = calculateCredit(
      expenses: model.expenses,
      numberOfChildren: model.numberOfChildren,
      isSecondaryEducation: model.isSecondaryEducation,
    );

    final excessExpenses = model.expenses > ceiling
        ? model.expenses - ceiling
        : 0.0;

    return {
      'expenses': model.expenses,
      'ceiling': ceiling,
      'credit': credit,
      'effectiveRate': model.expenses > 0 ? credit / model.expenses : 0.0,
      'excessExpenses': excessExpenses,
      'countsTowardNicheCeiling': true,
      'nicheCeilingImpact': credit,
    };
  }

  bool validateExpenses(double expenses) {
    return expenses >= 0 && expenses <= 100000;
  }

  String? validateExpensesMessage(double expenses) {
    if (expenses < 0) {
      return 'Le montant des dépenses ne peut pas être négatif';
    }
    if (expenses > 100000) {
      return 'Le montant semble anormalement élevé. Veuillez vérifier.';
    }
    return null;
  }
}
