import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/tax_remote_config_service.dart';
import '../../data/models/home_employment_credit_model.dart';
import 'monitoring_providers.dart';

final homeEmploymentCreditServiceProvider = Provider(
  (ref) => HomeEmploymentCreditService(config: ref.watch(taxConfigProvider)),
);

final homeEmploymentCreditProvider = StateProvider<HomeEmploymentCreditModel?>(
  (ref) => null,
);

class HomeEmploymentCreditService {
  /// Configuration fiscale (distante si disponible, embarquee sinon).
  final TaxConfig config;

  HomeEmploymentCreditService({this.config = const TaxConfig.embedded()});

  double calculateCeiling({
    required int numberOfChildren,
    required int numberOfElderly,
    required bool isFirstYear,
  }) {
    double base = config.homeEmploymentCeiling;
    base += numberOfChildren * config.homeEmploymentExtraPerChild;
    base += numberOfElderly * config.homeEmploymentExtraPerChild;

    if (isFirstYear) {
      return base.clamp(0, config.homeEmploymentMaxWithMajorations);
    }
    return base.clamp(0, config.homeEmploymentMaxFirstYear);
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
