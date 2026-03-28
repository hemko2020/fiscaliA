import 'package:flutter_test/flutter_test.dart';
import 'package:fiscalia/data/models/school_fees_credit_model.dart';
import 'package:fiscalia/presentation/providers/school_fees_credit_provider.dart';

void main() {
  group('SchoolFeesCreditModel', () {
    test('should calculate correct ceiling for secondary education', () {
      final model = SchoolFeesCreditModel(
        expenses: 500,
        numberOfChildren: 2,
        isSecondaryEducation: true,
      );

      expect(model.ceiling, 306);
    });

    test('should calculate correct ceiling for higher education', () {
      final model = SchoolFeesCreditModel(
        expenses: 500,
        numberOfChildren: 2,
        isSecondaryEducation: false,
      );

      expect(model.ceiling, 200);
    });

    test('should calculate correct credit amount at 50%', () {
      final model = SchoolFeesCreditModel(
        expenses: 200,
        numberOfChildren: 1,
        isSecondaryEducation: false,
      );

      expect(model.creditAmount, 50.0);
    });

    test('should cap credit at ceiling', () {
      final model = SchoolFeesCreditModel(
        expenses: 500,
        numberOfChildren: 1,
        isSecondaryEducation: false,
      );

      expect(model.creditAmount, 50);
    });

    test('should calculate effective rate correctly', () {
      final model = SchoolFeesCreditModel(
        expenses: 200,
        numberOfChildren: 1,
        isSecondaryEducation: false,
      );

      expect(model.effectiveRate, 0.25);
    });

    test('should return zero effective rate for zero expenses', () {
      final model = SchoolFeesCreditModel(
        expenses: 0,
        numberOfChildren: 1,
        isSecondaryEducation: false,
      );

      expect(model.effectiveRate, 0);
    });

    test('should serialize to JSON correctly', () {
      final model = SchoolFeesCreditModel(
        expenses: 300,
        numberOfChildren: 2,
        isSecondaryEducation: true,
      );

      final json = model.toJson();

      expect(json['expenses'], 300);
      expect(json['numberOfChildren'], 2);
      expect(json['isSecondaryEducation'], true);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'expenses': 300,
        'numberOfChildren': 2,
        'isSecondaryEducation': true,
      };

      final model = SchoolFeesCreditModel.fromJson(json);

      expect(model.expenses, 300);
      expect(model.numberOfChildren, 2);
      expect(model.isSecondaryEducation, true);
    });

    test('should copy with new values correctly', () {
      final model = SchoolFeesCreditModel(
        expenses: 200,
        numberOfChildren: 1,
        isSecondaryEducation: false,
      );

      final updated = model.copyWith(expenses: 400, isSecondaryEducation: true);

      expect(updated.expenses, 400);
      expect(updated.numberOfChildren, 1);
      expect(updated.isSecondaryEducation, true);
    });
  });

  group('SchoolFeesCreditService', () {
    late SchoolFeesCreditService service;

    setUp(() {
      service = SchoolFeesCreditService();
    });

    test('should calculate ceiling correctly for secondary education', () {
      final ceiling = service.calculateCeiling(
        numberOfChildren: 2,
        isSecondaryEducation: true,
      );

      expect(ceiling, 306);
    });

    test('should calculate ceiling correctly for higher education', () {
      final ceiling = service.calculateCeiling(
        numberOfChildren: 2,
        isSecondaryEducation: false,
      );

      expect(ceiling, 200);
    });

    test('should calculate credit correctly', () {
      final credit = service.calculateCredit(
        expenses: 200,
        numberOfChildren: 1,
        isSecondaryEducation: false,
      );

      expect(credit, 50.0);
    });

    test('should return full credit details', () {
      final model = SchoolFeesCreditModel(
        expenses: 200,
        numberOfChildren: 1,
        isSecondaryEducation: false,
      );

      final details = service.calculateFullCreditDetails(model);

      expect(details['expenses'], 200);
      expect(details['ceiling'], 100);
      expect(details['credit'], 50.0);
      expect(details['effectiveRate'], 0.25);
      expect(details['excessExpenses'], 100.0);
      expect(details['countsTowardNicheCeiling'], true);
    });

    test('should identify excess expenses', () {
      final model = SchoolFeesCreditModel(
        expenses: 500,
        numberOfChildren: 1,
        isSecondaryEducation: false,
      );

      final details = service.calculateFullCreditDetails(model);

      expect(details['excessExpenses'], 400);
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
