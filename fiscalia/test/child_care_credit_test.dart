import 'package:flutter_test/flutter_test.dart';
import 'package:fiscalia/data/models/child_care_credit_model.dart';
import 'package:fiscalia/presentation/providers/child_care_credit_provider.dart';

void main() {
  group('ChildCareCreditModel', () {
    test('should calculate correct ceiling for couple with 1 child', () {
      final model = ChildCareCreditModel(
        expenses: 3000,
        numberOfChildren: 1,
        isSingleParent: false,
      );

      expect(model.ceiling, 2300);
    });

    test('should calculate correct ceiling for couple with 2 children', () {
      final model = ChildCareCreditModel(
        expenses: 5000,
        numberOfChildren: 2,
        isSingleParent: false,
      );

      expect(model.ceiling, 4800);
    });

    test('should calculate correct ceiling for couple with 3 children', () {
      final model = ChildCareCreditModel(
        expenses: 8000,
        numberOfChildren: 3,
        isSingleParent: false,
      );

      expect(model.ceiling, 7300);
    });

    test('should calculate correct ceiling for single parent with 1 child', () {
      final model = ChildCareCreditModel(
        expenses: 4000,
        numberOfChildren: 1,
        isSingleParent: true,
      );

      expect(model.ceiling, 3500);
    });

    test(
      'should calculate correct ceiling for single parent with 2 children',
      () {
        final model = ChildCareCreditModel(
          expenses: 8000,
          numberOfChildren: 2,
          isSingleParent: true,
        );

        expect(model.ceiling, 7300);
      },
    );

    test('should calculate correct credit amount at 50%', () {
      final model = ChildCareCreditModel(
        expenses: 2000,
        numberOfChildren: 1,
        isSingleParent: false,
      );

      expect(model.creditAmount, 1000);
    });

    test('should cap credit at ceiling', () {
      final model = ChildCareCreditModel(
        expenses: 5000,
        numberOfChildren: 1,
        isSingleParent: false,
      );

      expect(model.creditAmount, 1150);
    });

    test('should calculate effective rate correctly', () {
      final model = ChildCareCreditModel(
        expenses: 2000,
        numberOfChildren: 1,
        isSingleParent: false,
      );

      expect(model.effectiveRate, 0.5);
    });

    test('should return zero effective rate for zero expenses', () {
      final model = ChildCareCreditModel(
        expenses: 0,
        numberOfChildren: 1,
        isSingleParent: false,
      );

      expect(model.effectiveRate, 0);
    });

    test('should serialize to JSON correctly', () {
      final model = ChildCareCreditModel(
        expenses: 3000,
        numberOfChildren: 2,
        isSingleParent: true,
      );

      final json = model.toJson();

      expect(json['expenses'], 3000);
      expect(json['numberOfChildren'], 2);
      expect(json['isSingleParent'], true);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'expenses': 3000,
        'numberOfChildren': 2,
        'isSingleParent': true,
      };

      final model = ChildCareCreditModel.fromJson(json);

      expect(model.expenses, 3000);
      expect(model.numberOfChildren, 2);
      expect(model.isSingleParent, true);
    });

    test('should copy with new values correctly', () {
      final model = ChildCareCreditModel(
        expenses: 2000,
        numberOfChildren: 1,
        isSingleParent: false,
      );

      final updated = model.copyWith(expenses: 4000, isSingleParent: true);

      expect(updated.expenses, 4000);
      expect(updated.numberOfChildren, 1);
      expect(updated.isSingleParent, true);
    });
  });

  group('ChildCareCreditService', () {
    late ChildCareCreditService service;

    setUp(() {
      service = ChildCareCreditService();
    });

    test('should calculate ceiling correctly for couple', () {
      final ceiling = service.calculateCeiling(
        numberOfChildren: 2,
        isSingleParent: false,
      );

      expect(ceiling, 4800);
    });

    test('should calculate ceiling correctly for single parent', () {
      final ceiling = service.calculateCeiling(
        numberOfChildren: 1,
        isSingleParent: true,
      );

      expect(ceiling, 3500);
    });

    test('should calculate credit correctly', () {
      final credit = service.calculateCredit(
        expenses: 2000,
        numberOfChildren: 1,
        isSingleParent: false,
      );

      expect(credit, 1000);
    });

    test('should return full credit details', () {
      final model = ChildCareCreditModel(
        expenses: 2000,
        numberOfChildren: 1,
        isSingleParent: false,
      );

      final details = service.calculateFullCreditDetails(model);

      expect(details['expenses'], 2000);
      expect(details['ceiling'], 2300);
      expect(details['credit'], 1000);
      expect(details['effectiveRate'], 0.5);
      expect(details['excessExpenses'], 0);
      expect(details['countsTowardNicheCeiling'], true);
    });

    test('should identify excess expenses', () {
      final model = ChildCareCreditModel(
        expenses: 5000,
        numberOfChildren: 1,
        isSingleParent: false,
      );

      final details = service.calculateFullCreditDetails(model);

      expect(details['excessExpenses'], 2700);
    });

    test('should validate positive expenses', () {
      expect(service.validateExpenses(5000), true);
      expect(service.validateExpenses(0), true);
      expect(service.validateExpenses(-100), false);
      expect(service.validateExpenses(60000), false);
    });

    test('should return validation message for invalid expenses', () {
      expect(service.validateExpensesMessage(-100), isNotNull);
      expect(service.validateExpensesMessage(60000), isNotNull);
      expect(service.validateExpensesMessage(5000), isNull);
    });
  });
}
