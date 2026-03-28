import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/child_care_credit_model.dart';

final childCareCreditServiceProvider = Provider(
  (ref) => ChildCareCreditService(),
);

final childCareCreditProvider = StateProvider<ChildCareCreditModel?>(
  (ref) => null,
);

class ChildCareCreditService {
  double calculateCeiling({
    required int numberOfChildren,
    required bool isSingleParent,
  }) {
    if (isSingleParent) {
      switch (numberOfChildren) {
        case 1:
          return 3500;
        case 2:
          return 7300;
        default:
          return 7300 + (numberOfChildren - 2) * 3800;
      }
    } else {
      switch (numberOfChildren) {
        case 1:
          return 2300;
        case 2:
          return 4800;
        default:
          return 4800 + (numberOfChildren - 2) * 2500;
      }
    }
  }

  double calculateCredit({
    required double expenses,
    required int numberOfChildren,
    required bool isSingleParent,
  }) {
    final ceiling = calculateCeiling(
      numberOfChildren: numberOfChildren,
      isSingleParent: isSingleParent,
    );

    final eligibleExpenses = expenses.clamp(0, ceiling);
    return eligibleExpenses * 0.50;
  }

  Map<String, dynamic> calculateFullCreditDetails(ChildCareCreditModel model) {
    final ceiling = calculateCeiling(
      numberOfChildren: model.numberOfChildren,
      isSingleParent: model.isSingleParent,
    );

    final credit = calculateCredit(
      expenses: model.expenses,
      numberOfChildren: model.numberOfChildren,
      isSingleParent: model.isSingleParent,
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
    return expenses >= 0 && expenses <= 50000;
  }

  String? validateExpensesMessage(double expenses) {
    if (expenses < 0) {
      return 'Le montant des dépenses ne peut pas être négatif';
    }
    if (expenses > 50000) {
      return 'Le montant semble anormalement élevé. Veuillez vérifier.';
    }
    return null;
  }
}
