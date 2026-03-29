import 'package:hive/hive.dart';

@HiveType(typeId: 11)
class SchoolFeesCreditModel {
  @HiveField(0)
  final double expenses;

  @HiveField(1)
  final int numberOfChildren;

  @HiveField(2)
  final bool isSecondaryEducation;

  @HiveField(3)
  final DateTime dateCreated;

  @HiveField(4)
  final DateTime? dateModified;

  SchoolFeesCreditModel({
    required this.expenses,
    this.numberOfChildren = 1,
    this.isSecondaryEducation = false,
    DateTime? dateCreated,
    this.dateModified,
  }) : dateCreated = dateCreated ?? DateTime.now();

  double get ceiling {
    if (isSecondaryEducation) {
      return 153.0 * numberOfChildren;
    }
    return 100.0 * numberOfChildren;
  }

  double get creditAmount {
    final eligibleExpenses = expenses.clamp(0, ceiling);
    return eligibleExpenses * 0.50;
  }

  double get effectiveRate {
    if (expenses <= 0) return 0;
    return creditAmount / expenses;
  }

  SchoolFeesCreditModel copyWith({
    double? expenses,
    int? numberOfChildren,
    bool? isSecondaryEducation,
    DateTime? dateCreated,
    DateTime? dateModified,
  }) {
    return SchoolFeesCreditModel(
      expenses: expenses ?? this.expenses,
      numberOfChildren: numberOfChildren ?? this.numberOfChildren,
      isSecondaryEducation: isSecondaryEducation ?? this.isSecondaryEducation,
      dateCreated: dateCreated ?? this.dateCreated,
      dateModified: dateModified ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expenses': expenses,
      'numberOfChildren': numberOfChildren,
      'isSecondaryEducation': isSecondaryEducation,
      'dateCreated': dateCreated.toIso8601String(),
      'dateModified': dateModified?.toIso8601String(),
    };
  }

  factory SchoolFeesCreditModel.fromJson(Map<String, dynamic> json) {
    return SchoolFeesCreditModel(
      expenses: (json['expenses'] as num?)?.toDouble() ?? 0,
      numberOfChildren: json['numberOfChildren'] as int? ?? 1,
      isSecondaryEducation: json['isSecondaryEducation'] as bool? ?? false,
      dateCreated: json['dateCreated'] != null
          ? DateTime.parse(json['dateCreated'] as String)
          : DateTime.now(),
      dateModified: json['dateModified'] != null
          ? DateTime.parse(json['dateModified'] as String)
          : null,
    );
  }
}
