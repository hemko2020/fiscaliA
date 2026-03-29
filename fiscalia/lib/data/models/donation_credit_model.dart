import 'package:hive/hive.dart';

enum DonationType {
  @HiveField(0)
  generalInterest,
  @HiveField(1)
  peopleInNeed,
}

@HiveType(typeId: 8)
class DonationCreditModel {
  @HiveField(0)
  final double amount;

  @HiveField(1)
  final DonationType donationType;

  @HiveField(2)
  final double taxableIncome;

  @HiveField(3)
  final DateTime dateCreated;

  @HiveField(4)
  final DateTime? dateModified;

  DonationCreditModel({
    required this.amount,
    this.donationType = DonationType.generalInterest,
    this.taxableIncome = 0,
    DateTime? dateCreated,
    this.dateModified,
  }) : dateCreated = dateCreated ?? DateTime.now();

  double get reductionRate {
    return donationType == DonationType.peopleInNeed ? 0.75 : 0.66;
  }

  double get maxDeductionForType {
    if (donationType == DonationType.peopleInNeed) {
      return 1000;
    }
    return taxableIncome * 0.20;
  }

  double get eligibleAmount {
    if (donationType == DonationType.peopleInNeed) {
      return amount.clamp(0, 1000);
    }
    return amount.clamp(0, taxableIncome * 0.20);
  }

  double get reductionAmount {
    return eligibleAmount * reductionRate;
  }

  double get excessDonation {
    if (donationType == DonationType.peopleInNeed) {
      return amount > 1000 ? amount - 1000 : 0;
    }
    final maxGeneral = taxableIncome * 0.20;
    return amount > maxGeneral ? amount - maxGeneral : 0;
  }

  double get effectiveRate {
    if (amount <= 0) return 0;
    return reductionAmount / amount;
  }

  DonationCreditModel copyWith({
    double? amount,
    DonationType? donationType,
    double? taxableIncome,
    DateTime? dateCreated,
    DateTime? dateModified,
  }) {
    return DonationCreditModel(
      amount: amount ?? this.amount,
      donationType: donationType ?? this.donationType,
      taxableIncome: taxableIncome ?? this.taxableIncome,
      dateCreated: dateCreated ?? this.dateCreated,
      dateModified: dateModified ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'donationType': donationType.index,
      'taxableIncome': taxableIncome,
      'dateCreated': dateCreated.toIso8601String(),
      'dateModified': dateModified?.toIso8601String(),
    };
  }

  factory DonationCreditModel.fromJson(Map<String, dynamic> json) {
    return DonationCreditModel(
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      donationType: DonationType.values[json['donationType'] as int? ?? 0],
      taxableIncome: (json['taxableIncome'] as num?)?.toDouble() ?? 0,
      dateCreated: json['dateCreated'] != null
          ? DateTime.parse(json['dateCreated'] as String)
          : DateTime.now(),
      dateModified: json['dateModified'] != null
          ? DateTime.parse(json['dateModified'] as String)
          : null,
    );
  }
}
