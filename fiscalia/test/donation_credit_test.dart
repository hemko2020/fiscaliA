import 'package:flutter_test/flutter_test.dart';
import 'package:fiscalia/data/models/donation_credit_model.dart';
import 'package:fiscalia/presentation/providers/donation_credit_provider.dart';

void main() {
  group('DonationCreditModel', () {
    test('should calculate correct reduction rate for general interest', () {
      final model = DonationCreditModel(
        amount: 1000,
        donationType: DonationType.generalInterest,
        taxableIncome: 50000,
      );

      expect(model.reductionRate, 0.66);
    });

    test('should calculate correct reduction rate for people in need', () {
      final model = DonationCreditModel(
        amount: 1000,
        donationType: DonationType.peopleInNeed,
        taxableIncome: 50000,
      );

      expect(model.reductionRate, 0.75);
    });

    test('should calculate correct max deduction for general interest', () {
      final model = DonationCreditModel(
        amount: 15000,
        donationType: DonationType.generalInterest,
        taxableIncome: 50000,
      );

      expect(model.maxDeductionForType, 10000);
    });

    test('should calculate correct max deduction for people in need', () {
      final model = DonationCreditModel(
        amount: 2000,
        donationType: DonationType.peopleInNeed,
        taxableIncome: 50000,
      );

      expect(model.maxDeductionForType, 1000);
    });

    test('should calculate correct reduction for general interest', () {
      final model = DonationCreditModel(
        amount: 1000,
        donationType: DonationType.generalInterest,
        taxableIncome: 50000,
      );

      expect(model.reductionAmount, 660);
    });

    test('should calculate correct reduction for people in need', () {
      final model = DonationCreditModel(
        amount: 1000,
        donationType: DonationType.peopleInNeed,
        taxableIncome: 50000,
      );

      expect(model.reductionAmount, 750);
    });

    test('should cap reduction at max deduction for general interest', () {
      final model = DonationCreditModel(
        amount: 15000,
        donationType: DonationType.generalInterest,
        taxableIncome: 50000,
      );

      expect(model.reductionAmount, 6600);
    });

    test('should cap reduction at 1000 for people in need', () {
      final model = DonationCreditModel(
        amount: 2000,
        donationType: DonationType.peopleInNeed,
        taxableIncome: 50000,
      );

      expect(model.reductionAmount, 750);
    });

    test('should calculate excess donation correctly', () {
      final model = DonationCreditModel(
        amount: 15000,
        donationType: DonationType.generalInterest,
        taxableIncome: 50000,
      );

      expect(model.excessDonation, 5000);
    });

    test('should calculate effective rate correctly', () {
      final model = DonationCreditModel(
        amount: 1000,
        donationType: DonationType.generalInterest,
        taxableIncome: 50000,
      );

      expect(model.effectiveRate, 0.66);
    });

    test('should return zero effective rate for zero amount', () {
      final model = DonationCreditModel(
        amount: 0,
        donationType: DonationType.generalInterest,
        taxableIncome: 50000,
      );

      expect(model.effectiveRate, 0);
    });

    test('should serialize to JSON correctly', () {
      final model = DonationCreditModel(
        amount: 1000,
        donationType: DonationType.peopleInNeed,
        taxableIncome: 50000,
      );

      final json = model.toJson();

      expect(json['amount'], 1000);
      expect(json['donationType'], 1);
      expect(json['taxableIncome'], 50000);
    });

    test('should deserialize from JSON correctly', () {
      final json = {'amount': 1000, 'donationType': 1, 'taxableIncome': 50000};

      final model = DonationCreditModel.fromJson(json);

      expect(model.amount, 1000);
      expect(model.donationType, DonationType.peopleInNeed);
      expect(model.taxableIncome, 50000);
    });

    test('should copy with new values correctly', () {
      final model = DonationCreditModel(
        amount: 1000,
        donationType: DonationType.generalInterest,
        taxableIncome: 50000,
      );

      final updated = model.copyWith(
        amount: 2000,
        donationType: DonationType.peopleInNeed,
      );

      expect(updated.amount, 2000);
      expect(updated.donationType, DonationType.peopleInNeed);
      expect(updated.taxableIncome, 50000);
    });
  });

  group('DonationCreditService', () {
    late DonationCreditService service;

    setUp(() {
      service = DonationCreditService();
    });

    test('should calculate reduction for general interest', () {
      final reduction = service.calculateReduction(
        amount: 1000,
        donationType: DonationType.generalInterest,
        taxableIncome: 50000,
      );

      expect(reduction, 660);
    });

    test('should calculate reduction for people in need', () {
      final reduction = service.calculateReduction(
        amount: 1000,
        donationType: DonationType.peopleInNeed,
        taxableIncome: 50000,
      );

      expect(reduction, 750);
    });

    test('should get max deduction for general interest', () {
      final maxDeduction = service.getMaxDeduction(
        DonationType.generalInterest,
        50000,
      );

      expect(maxDeduction, 10000);
    });

    test('should get max deduction for people in need', () {
      final maxDeduction = service.getMaxDeduction(
        DonationType.peopleInNeed,
        50000,
      );

      expect(maxDeduction, 1000);
    });

    test('should return full reduction details', () {
      final model = DonationCreditModel(
        amount: 1000,
        donationType: DonationType.generalInterest,
        taxableIncome: 50000,
      );

      final details = service.calculateFullReductionDetails(model);

      expect(details['amount'], 1000);
      expect(details['reductionRate'], 0.66);
      expect(details['maxDeduction'], 10000);
      expect(details['reduction'], 660);
      expect(details['effectiveRate'], 0.66);
      expect(details['excessDonation'], 0);
      expect(details['countsTowardNicheCeiling'], false);
    });

    test('should identify excess donation', () {
      final model = DonationCreditModel(
        amount: 15000,
        donationType: DonationType.generalInterest,
        taxableIncome: 50000,
      );

      final details = service.calculateFullReductionDetails(model);

      expect(details['excessDonation'], 5000);
    });

    test('should validate positive amount', () {
      expect(service.validateAmount(5000), true);
      expect(service.validateAmount(0), true);
      expect(service.validateAmount(-100), false);
      expect(service.validateAmount(2000000), false);
    });

    test('should return validation message for invalid amount', () {
      expect(service.validateAmountMessage(-100), isNotNull);
      expect(service.validateAmountMessage(2000000), isNotNull);
      expect(service.validateAmountMessage(5000), isNull);
    });
  });
}
