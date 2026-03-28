import 'package:flutter_test/flutter_test.dart';
import 'package:fiscalia/data/models/union_dues_credit_model.dart';
import 'package:fiscalia/presentation/providers/union_dues_credit_provider.dart';

void main() {
  group('UnionDuesCreditModel', () {
    test('should calculate correct ceiling at 1% of gross income', () {
      final model = UnionDuesCreditModel(unionDues: 300, grossIncome: 50000);

      expect(model.ceiling, 500.0);
    });

    test('should calculate correct credit amount at 66%', () {
      final model = UnionDuesCreditModel(unionDues: 300, grossIncome: 50000);

      expect(model.creditAmount, 198.0);
    });

    test('should cap credit at ceiling', () {
      final model = UnionDuesCreditModel(unionDues: 800, grossIncome: 50000);

      expect(model.creditAmount, 330.0);
    });

    test('should calculate effective rate correctly', () {
      final model = UnionDuesCreditModel(unionDues: 300, grossIncome: 50000);

      expect(model.effectiveRate, 0.66);
    });

    test('should return zero effective rate for zero dues', () {
      final model = UnionDuesCreditModel(unionDues: 0, grossIncome: 50000);

      expect(model.effectiveRate, 0);
    });

    test('should identify when ceiling is reached', () {
      final model = UnionDuesCreditModel(unionDues: 800, grossIncome: 50000);

      expect(model.isCeilingReached, true);
    });

    test('should identify when ceiling is not reached', () {
      final model = UnionDuesCreditModel(unionDues: 300, grossIncome: 50000);

      expect(model.isCeilingReached, false);
    });

    test('should calculate excess dues correctly', () {
      final model = UnionDuesCreditModel(unionDues: 800, grossIncome: 50000);

      expect(model.excessDues, 300.0);
    });

    test('should return zero excess dues when not exceeding ceiling', () {
      final model = UnionDuesCreditModel(unionDues: 300, grossIncome: 50000);

      expect(model.excessDues, 0);
    });

    test('should serialize to JSON correctly', () {
      final model = UnionDuesCreditModel(unionDues: 300, grossIncome: 50000);

      final json = model.toJson();

      expect(json['unionDues'], 300);
      expect(json['grossIncome'], 50000);
    });

    test('should deserialize from JSON correctly', () {
      final json = {'unionDues': 300, 'grossIncome': 50000};

      final model = UnionDuesCreditModel.fromJson(json);

      expect(model.unionDues, 300);
      expect(model.grossIncome, 50000);
    });

    test('should copy with new values correctly', () {
      final model = UnionDuesCreditModel(unionDues: 300, grossIncome: 50000);

      final updated = model.copyWith(unionDues: 400, grossIncome: 60000);

      expect(updated.unionDues, 400);
      expect(updated.grossIncome, 60000);
    });
  });

  group('UnionDuesCreditService', () {
    late UnionDuesCreditService service;

    setUp(() {
      service = UnionDuesCreditService();
    });

    test('should calculate ceiling correctly at 1% of gross income', () {
      final ceiling = service.calculateCeiling(grossIncome: 50000);

      expect(ceiling, 500.0);
    });

    test('should calculate ceiling for different income levels', () {
      expect(service.calculateCeiling(grossIncome: 30000), 300.0);
      expect(service.calculateCeiling(grossIncome: 75000), 750.0);
      expect(service.calculateCeiling(grossIncome: 100000), 1000.0);
    });

    test('should calculate credit correctly at 66%', () {
      final credit = service.calculateCredit(
        unionDues: 300,
        grossIncome: 50000,
      );

      expect(credit, 198.0);
    });

    test('should cap credit at ceiling', () {
      final credit = service.calculateCredit(
        unionDues: 800,
        grossIncome: 50000,
      );

      expect(credit, 330.0);
    });

    test('should return full credit details', () {
      final model = UnionDuesCreditModel(unionDues: 300, grossIncome: 50000);

      final details = service.calculateFullCreditDetails(model);

      expect(details['unionDues'], 300);
      expect(details['grossIncome'], 50000);
      expect(details['ceiling'], 500.0);
      expect(details['credit'], 198.0);
      expect(details['effectiveRate'], 0.66);
      expect(details['excessDues'], 0);
      expect(details['isCeilingReached'], false);
      expect(details['countsTowardNicheCeiling'], true);
    });

    test('should identify excess dues', () {
      final model = UnionDuesCreditModel(unionDues: 800, grossIncome: 50000);

      final details = service.calculateFullCreditDetails(model);

      expect(details['excessDues'], 300.0);
      expect(details['isCeilingReached'], true);
    });

    test('should validate positive union dues', () {
      expect(service.validateUnionDues(500), true);
      expect(service.validateUnionDues(0), true);
      expect(service.validateUnionDues(-100), false);
      expect(service.validateUnionDues(15000), false);
    });

    test('should validate positive gross income', () {
      expect(service.validateGrossIncome(50000), true);
      expect(service.validateGrossIncome(0), true);
      expect(service.validateGrossIncome(-1000), false);
      expect(service.validateGrossIncome(2000000), false);
    });

    test('should return validation message for invalid union dues', () {
      expect(service.validateUnionDuesMessage(-100), isNotNull);
      expect(service.validateUnionDuesMessage(15000), isNotNull);
      expect(service.validateUnionDuesMessage(500), isNull);
    });

    test('should return validation message for invalid gross income', () {
      expect(service.validateGrossIncomeMessage(-1000), isNotNull);
      expect(service.validateGrossIncomeMessage(2000000), isNotNull);
      expect(service.validateGrossIncomeMessage(50000), isNull);
    });

    test('should provide recommendation for zero dues', () {
      final recommendation = service.getCreditRecommendation(0, 50000);

      expect(recommendation, contains('crédit d\'impôt de 66%'));
    });

    test('should provide recommendation when ceiling exceeded', () {
      final recommendation = service.getCreditRecommendation(800, 50000);

      expect(recommendation, contains('Attention'));
      expect(recommendation, contains('500.00'));
    });

    test('should provide recommendation for normal case', () {
      final recommendation = service.getCreditRecommendation(300, 50000);

      expect(recommendation, contains('198.00'));
      expect(recommendation, contains('récupérer'));
    });
  });
}
