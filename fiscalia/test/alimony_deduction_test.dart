import 'package:flutter_test/flutter_test.dart';
import 'package:fiscalia/data/models/alimony_deduction_model.dart';
import 'package:fiscalia/presentation/providers/alimony_deduction_provider.dart';

void main() {
  group('AlimonyDeductionModel', () {
    test('should calculate correct deduction amount within ceiling', () {
      final model = AlimonyDeductionModel(
        alimonyAmount: 5000,
        isSpousalSupport: true,
        isChildSupport: false,
      );

      expect(model.deductionAmount, 5000.0);
    });

    test('should cap deduction at maximum ceiling', () {
      final model = AlimonyDeductionModel(
        alimonyAmount: 8000,
        isSpousalSupport: true,
        isChildSupport: false,
      );

      expect(model.deductionAmount, 6674.0);
    });

    test('should calculate excess amount correctly', () {
      final model = AlimonyDeductionModel(
        alimonyAmount: 8000,
        isSpousalSupport: true,
        isChildSupport: false,
      );

      expect(model.excessAmount, 1326.0);
    });

    test('should return zero excess when not exceeding ceiling', () {
      final model = AlimonyDeductionModel(
        alimonyAmount: 5000,
        isSpousalSupport: true,
        isChildSupport: false,
      );

      expect(model.excessAmount, 0);
    });

    test('should identify when ceiling is reached', () {
      final model = AlimonyDeductionModel(
        alimonyAmount: 8000,
        isSpousalSupport: true,
        isChildSupport: false,
      );

      expect(model.isCeilingReached, true);
    });

    test('should identify when ceiling is not reached', () {
      final model = AlimonyDeductionModel(
        alimonyAmount: 5000,
        isSpousalSupport: true,
        isChildSupport: false,
      );

      expect(model.isCeilingReached, false);
    });

    test('should identify deductible alimony', () {
      final model = AlimonyDeductionModel(
        alimonyAmount: 5000,
        isSpousalSupport: true,
        isChildSupport: false,
      );

      expect(model.isDeductible, true);
    });

    test('should identify non-deductible alimony', () {
      final model = AlimonyDeductionModel(
        alimonyAmount: 5000,
        isSpousalSupport: false,
        isChildSupport: false,
      );

      expect(model.isDeductible, false);
    });

    test('should calculate niche ceiling impact correctly', () {
      final model = AlimonyDeductionModel(
        alimonyAmount: 5000,
        isSpousalSupport: true,
        isChildSupport: false,
      );

      expect(model.nicheCeilingImpact, 5000.0);
    });

    test('should return correct deduction type for spousal support', () {
      final model = AlimonyDeductionModel(
        alimonyAmount: 5000,
        isSpousalSupport: true,
        isChildSupport: false,
      );

      expect(model.deductionType, 'Pension alimentaire');
    });

    test('should return correct deduction type for child support', () {
      final model = AlimonyDeductionModel(
        alimonyAmount: 5000,
        isSpousalSupport: false,
        isChildSupport: true,
      );

      expect(model.deductionType, 'Pension pour enfants');
    });

    test('should return correct deduction type for both', () {
      final model = AlimonyDeductionModel(
        alimonyAmount: 5000,
        isSpousalSupport: true,
        isChildSupport: true,
      );

      expect(
        model.deductionType,
        'Pension alimentaire et pension pour enfants',
      );
    });

    test('should serialize to JSON correctly', () {
      final model = AlimonyDeductionModel(
        alimonyAmount: 5000,
        isSpousalSupport: true,
        isChildSupport: false,
      );

      final json = model.toJson();

      expect(json['alimonyAmount'], 5000);
      expect(json['isSpousalSupport'], true);
      expect(json['isChildSupport'], false);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'alimonyAmount': 5000,
        'isSpousalSupport': true,
        'isChildSupport': false,
      };

      final model = AlimonyDeductionModel.fromJson(json);

      expect(model.alimonyAmount, 5000);
      expect(model.isSpousalSupport, true);
      expect(model.isChildSupport, false);
    });

    test('should copy with new values correctly', () {
      final model = AlimonyDeductionModel(
        alimonyAmount: 5000,
        isSpousalSupport: true,
        isChildSupport: false,
      );

      final updated = model.copyWith(
        alimonyAmount: 6000,
        isSpousalSupport: false,
      );

      expect(updated.alimonyAmount, 6000);
      expect(updated.isSpousalSupport, false);
      expect(updated.isChildSupport, false);
    });
  });

  group('AlimonyDeductionService', () {
    late AlimonyDeductionService service;

    setUp(() {
      service = AlimonyDeductionService();
    });

    test('should calculate deduction correctly within ceiling', () {
      final deduction = service.calculateDeduction(alimonyAmount: 5000);

      expect(deduction, 5000.0);
    });

    test('should cap deduction at maximum ceiling', () {
      final deduction = service.calculateDeduction(alimonyAmount: 8000);

      expect(deduction, 6674.0);
    });

    test('should return full deduction details', () {
      final model = AlimonyDeductionModel(
        alimonyAmount: 5000,
        isSpousalSupport: true,
        isChildSupport: false,
      );

      final details = service.calculateFullDeductionDetails(model);

      expect(details['alimonyAmount'], 5000);
      expect(details['deductionType'], 'Pension alimentaire');
      expect(details['isDeductible'], true);
      expect(details['deduction'], 5000.0);
      expect(details['maxDeduction'], 6674.0);
      expect(details['excessAmount'], 0);
      expect(details['isCeilingReached'], false);
      expect(details['deductionRate'], 1.0);
      expect(details['countsTowardNicheCeiling'], true);
      expect(details['nicheCeilingImpact'], 5000.0);
    });

    test('should identify excess amount', () {
      final model = AlimonyDeductionModel(
        alimonyAmount: 8000,
        isSpousalSupport: true,
        isChildSupport: false,
      );

      final details = service.calculateFullDeductionDetails(model);

      expect(details['excessAmount'], 1326.0);
      expect(details['isCeilingReached'], true);
    });

    test('should validate positive alimony amount', () {
      expect(service.validateAlimonyAmount(5000), true);
      expect(service.validateAlimonyAmount(0), true);
      expect(service.validateAlimonyAmount(-100), false);
      expect(service.validateAlimonyAmount(150000), false);
    });

    test('should return validation message for invalid amount', () {
      expect(service.validateAlimonyAmountMessage(-100), isNotNull);
      expect(service.validateAlimonyAmountMessage(150000), isNotNull);
      expect(service.validateAlimonyAmountMessage(5000), isNull);
    });

    test('should provide recommendation for zero amount', () {
      final recommendation = service.getDeductionRecommendation(0, true, false);

      expect(recommendation, contains('déduction fiscale'));
    });

    test('should provide recommendation when type not specified', () {
      final recommendation = service.getDeductionRecommendation(
        5000,
        false,
        false,
      );

      expect(recommendation, contains('spécifier le type'));
    });

    test('should provide recommendation when ceiling exceeded', () {
      final recommendation = service.getDeductionRecommendation(
        8000,
        true,
        false,
      );

      expect(recommendation, contains('Attention'));
      expect(recommendation, contains('6674'));
    });

    test('should provide recommendation for normal case', () {
      final recommendation = service.getDeductionRecommendation(
        5000,
        true,
        false,
      );

      expect(recommendation, contains('5000'));
      expect(recommendation, contains('déduire'));
    });

    test('should return correct legal reference for spousal support', () {
      final reference = service.getLegalReference(true, false);

      expect(reference, contains('Article 156 II 2°'));
      expect(reference, contains('Pension alimentaire'));
    });

    test('should return correct legal reference for child support', () {
      final reference = service.getLegalReference(false, true);

      expect(reference, contains('Article 156 II 2°'));
      expect(reference, contains('Pension pour enfants'));
    });

    test('should return recipient obligation for spousal support', () {
      final obligation = service.getRecipientObligation(true, false);

      expect(obligation, contains('ex-conjoint'));
      expect(obligation, contains('déclarer'));
    });

    test('should return recipient obligation for child support', () {
      final obligation = service.getRecipientObligation(false, true);

      expect(obligation, contains('bénéficiaire'));
      expect(obligation, contains('déclarer'));
    });

    test('should return empty obligation when no type specified', () {
      final obligation = service.getRecipientObligation(false, false);

      expect(obligation, isEmpty);
    });
  });
}
