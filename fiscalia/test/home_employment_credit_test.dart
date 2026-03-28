import 'package:flutter_test/flutter_test.dart';
import 'package:fiscalia/data/models/home_employment_credit_model.dart';
import 'package:fiscalia/presentation/providers/home_employment_credit_provider.dart';

void main() {
  group('HomeEmploymentCreditModel', () {
    test('should calculate correct ceiling with no majorations', () {
      final model = HomeEmploymentCreditModel(
        expenses: 10000,
        numberOfChildren: 0,
        numberOfElderly: 0,
        isFirstYear: false,
      );

      expect(model.ceiling, 12000);
    });

    test('should calculate correct ceiling with children majorations', () {
      final model = HomeEmploymentCreditModel(
        expenses: 15000,
        numberOfChildren: 2,
        numberOfElderly: 0,
        isFirstYear: false,
      );

      expect(model.ceiling, 15000);
    });

    test('should calculate correct ceiling with elderly majorations', () {
      final model = HomeEmploymentCreditModel(
        expenses: 15000,
        numberOfChildren: 0,
        numberOfElderly: 1,
        isFirstYear: false,
      );

      expect(model.ceiling, 13500);
    });

    test('should calculate correct ceiling with first year bonus', () {
      final model = HomeEmploymentCreditModel(
        expenses: 18000,
        numberOfChildren: 0,
        numberOfElderly: 0,
        isFirstYear: true,
      );

      expect(model.ceiling, 15000);
    });

    test('should calculate correct ceiling with all majorations', () {
      final model = HomeEmploymentCreditModel(
        expenses: 20000,
        numberOfChildren: 2,
        numberOfElderly: 1,
        isFirstYear: true,
      );

      expect(model.ceiling, 18000);
    });

    test('should calculate correct credit amount at 50%', () {
      final model = HomeEmploymentCreditModel(
        expenses: 10000,
        numberOfChildren: 0,
        numberOfElderly: 0,
        isFirstYear: false,
      );

      expect(model.creditAmount, 5000);
    });

    test('should cap credit at ceiling', () {
      final model = HomeEmploymentCreditModel(
        expenses: 20000,
        numberOfChildren: 0,
        numberOfElderly: 0,
        isFirstYear: false,
      );

      expect(model.creditAmount, 6000);
    });

    test('should calculate effective rate correctly', () {
      final model = HomeEmploymentCreditModel(
        expenses: 10000,
        numberOfChildren: 0,
        numberOfElderly: 0,
        isFirstYear: false,
      );

      expect(model.effectiveRate, 0.5);
    });

    test('should return zero effective rate for zero expenses', () {
      final model = HomeEmploymentCreditModel(
        expenses: 0,
        numberOfChildren: 0,
        numberOfElderly: 0,
        isFirstYear: false,
      );

      expect(model.effectiveRate, 0);
    });

    test('should serialize to JSON correctly', () {
      final model = HomeEmploymentCreditModel(
        expenses: 10000,
        numberOfChildren: 2,
        numberOfElderly: 1,
        isFirstYear: true,
      );

      final json = model.toJson();

      expect(json['expenses'], 10000);
      expect(json['numberOfChildren'], 2);
      expect(json['numberOfElderly'], 1);
      expect(json['isFirstYear'], true);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'expenses': 10000,
        'numberOfChildren': 2,
        'numberOfElderly': 1,
        'isFirstYear': true,
      };

      final model = HomeEmploymentCreditModel.fromJson(json);

      expect(model.expenses, 10000);
      expect(model.numberOfChildren, 2);
      expect(model.numberOfElderly, 1);
      expect(model.isFirstYear, true);
    });

    test('should copy with new values correctly', () {
      final model = HomeEmploymentCreditModel(
        expenses: 10000,
        numberOfChildren: 0,
        numberOfElderly: 0,
        isFirstYear: false,
      );

      final updated = model.copyWith(expenses: 15000, numberOfChildren: 1);

      expect(updated.expenses, 15000);
      expect(updated.numberOfChildren, 1);
      expect(updated.numberOfElderly, 0);
      expect(updated.isFirstYear, false);
    });
  });

  group('HomeEmploymentCreditService', () {
    late HomeEmploymentCreditService service;

    setUp(() {
      service = HomeEmploymentCreditService();
    });

    test('should calculate ceiling correctly', () {
      final ceiling = service.calculateCeiling(
        numberOfChildren: 2,
        numberOfElderly: 1,
        isFirstYear: false,
      );

      expect(ceiling, 15000);
    });

    test('should calculate credit correctly', () {
      final credit = service.calculateCredit(
        expenses: 10000,
        numberOfChildren: 0,
        numberOfElderly: 0,
        isFirstYear: false,
      );

      expect(credit, 5000);
    });

    test('should return full credit details', () {
      final model = HomeEmploymentCreditModel(
        expenses: 10000,
        numberOfChildren: 0,
        numberOfElderly: 0,
        isFirstYear: false,
      );

      final details = service.calculateFullCreditDetails(model);

      expect(details['expenses'], 10000);
      expect(details['ceiling'], 12000);
      expect(details['credit'], 5000);
      expect(details['effectiveRate'], 0.5);
      expect(details['excessExpenses'], 0);
      expect(details['countsTowardNicheCeiling'], true);
    });

    test('should identify excess expenses', () {
      final model = HomeEmploymentCreditModel(
        expenses: 20000,
        numberOfChildren: 0,
        numberOfElderly: 0,
        isFirstYear: false,
      );

      final details = service.calculateFullCreditDetails(model);

      expect(details['excessExpenses'], 8000);
    });

    test('should validate positive expenses', () {
      expect(service.validateExpenses(5000), true);
      expect(service.validateExpenses(0), true);
      expect(service.validateExpenses(-100), false);
      expect(service.validateExpenses(150000), false);
    });

    test('should return validation message for invalid expenses', () {
      expect(service.validateExpensesMessage(-100), isNotNull);
      expect(service.validateExpensesMessage(150000), isNotNull);
      expect(service.validateExpensesMessage(5000), isNull);
    });
  });
}
