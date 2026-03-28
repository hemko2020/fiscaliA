import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/tax_brackets.dart';
import '../../data/models/home_employment_credit_model.dart';

final homeEmploymentCreditServiceProvider = Provider(
  (ref) => HomeEmploymentCreditService(),
);

final homeEmploymentCreditProvider = StateProvider<HomeEmploymentCreditModel?>(
  (ref) => null,
);

class HomeEmploymentCreditService {
  double calculateCeiling({
    required int numberOfChildren,
    required int numberOfElderly,
    required bool isFirstYear,
  }) {
    double base = TaxBrackets2026.homeEmploymentCeiling;
    base += numberOfChildren * TaxBrackets2026.homeEmploymentExtraPerChild;
    base += numberOfElderly * TaxBrackets2026.homeEmploymentExtraPerChild;

    if (isFirstYear) {
      return base.clamp(0, TaxBrackets2026.homeEmploymentMaxWithMajorations);
    }
    return base.clamp(0, TaxBrackets2026.homeEmploymentMaxFirstYear);
  }

  double calculateCredit({
    required double expenses,
    required int numberOfChildren,
    required int numberOfElderly,
    required bool isFirstYear,
  }) {
    final ceiling = calculateCeiling(
      numberOfChildren: numberOfChildren,
      numberOfElderly: numberOfElderly,
      isFirstYear: isFirstYear,
    );

    final eligibleExpenses = expenses.clamp(0, ceiling);
    return eligibleExpenses * 0.50;
  }

  Map<String, dynamic> calculateFullCreditDetails(
    HomeEmploymentCreditModel model,
  ) {
    final ceiling = calculateCeiling(
      numberOfChildren: model.numberOfChildren,
      numberOfElderly: model.numberOfElderly,
      isFirstYear: model.isFirstYear,
    );

    final credit = calculateCredit(
      expenses: model.expenses,
      numberOfChildren: model.numberOfChildren,
      numberOfElderly: model.numberOfElderly,
      isFirstYear: model.isFirstYear,
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
