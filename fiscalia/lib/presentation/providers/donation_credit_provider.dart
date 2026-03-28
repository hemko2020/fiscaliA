import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/donation_credit_model.dart';

final donationCreditServiceProvider = Provider(
  (ref) => DonationCreditService(),
);

final donationCreditProvider = StateProvider<DonationCreditModel?>(
  (ref) => null,
);

class DonationCreditService {
  double calculateReduction({
    required double amount,
    required DonationType donationType,
    required double taxableIncome,
  }) {
    final rate = donationType == DonationType.peopleInNeed ? 0.75 : 0.66;

    double eligibleAmount;
    if (donationType == DonationType.peopleInNeed) {
      eligibleAmount = amount.clamp(0, 1000);
    } else {
      eligibleAmount = amount.clamp(0, taxableIncome * 0.20);
    }

    return eligibleAmount * rate;
  }

  double getMaxDeduction(DonationType donationType, double taxableIncome) {
    if (donationType == DonationType.peopleInNeed) {
      return 1000;
    }
    return taxableIncome * 0.20;
  }

  Map<String, dynamic> calculateFullReductionDetails(
    DonationCreditModel model,
  ) {
    final reduction = calculateReduction(
      amount: model.amount,
      donationType: model.donationType,
      taxableIncome: model.taxableIncome,
    );

    final maxDeduction = getMaxDeduction(
      model.donationType,
      model.taxableIncome,
    );
    final excessDonation = model.amount > maxDeduction
        ? model.amount - maxDeduction
        : 0.0;

    return {
      'amount': model.amount,
      'donationType': model.donationType,
      'reductionRate': model.reductionRate,
      'maxDeduction': maxDeduction,
      'eligibleAmount': model.eligibleAmount,
      'reduction': reduction,
      'effectiveRate': model.amount > 0 ? reduction / model.amount : 0.0,
      'excessDonation': excessDonation,
      'countsTowardNicheCeiling': false,
    };
  }

  bool validateAmount(double amount) {
    return amount >= 0 && amount <= 1000000;
  }

  String? validateAmountMessage(double amount) {
    if (amount < 0) {
      return 'Le montant du don ne peut pas être négatif';
    }
    if (amount > 1000000) {
      return 'Le montant semble anormalement élevé. Veuillez vérifier.';
    }
    return null;
  }
}
