import 'package:hive/hive.dart';

part 'home_employment_credit_model.g.dart';

@HiveType(typeId: 6)
class HomeEmploymentCreditModel {
  @HiveField(0)
  final double expenses;

  @HiveField(1)
  final int numberOfChildren;

  @HiveField(2)
  final int numberOfElderly;

  @HiveField(3)
  final bool isFirstYear;

  @HiveField(4)
  final DateTime dateCreated;

  @HiveField(5)
  final DateTime? dateModified;

  HomeEmploymentCreditModel({
    required this.expenses,
    this.numberOfChildren = 0,
    this.numberOfElderly = 0,
    this.isFirstYear = false,
    DateTime? dateCreated,
    this.dateModified,
  }) : dateCreated = dateCreated ?? DateTime.now();

  double get ceiling {
    double base = 12000;
    base += numberOfChildren * 1500;
    base += numberOfElderly * 1500;
    if (isFirstYear) {
      return (base + 3000).clamp(0, 18000);
    }
    return base.clamp(0, 15000);
  }

  double get creditAmount {
    final eligibleExpenses = expenses.clamp(0, ceiling);
    return eligibleExpenses * 0.50;
  }

  double get effectiveRate {
    if (expenses <= 0) return 0;
    return creditAmount / expenses;
  }

  HomeEmploymentCreditModel copyWith({
    double? expenses,
    int? numberOfChildren,
    int? numberOfElderly,
    bool? isFirstYear,
    DateTime? dateCreated,
    DateTime? dateModified,
  }) {
    return HomeEmploymentCreditModel(
      expenses: expenses ?? this.expenses,
      numberOfChildren: numberOfChildren ?? this.numberOfChildren,
      numberOfElderly: numberOfElderly ?? this.numberOfElderly,
      isFirstYear: isFirstYear ?? this.isFirstYear,
      dateCreated: dateCreated ?? this.dateCreated,
      dateModified: dateModified ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expenses': expenses,
      'numberOfChildren': numberOfChildren,
      'numberOfElderly': numberOfElderly,
      'isFirstYear': isFirstYear,
      'dateCreated': dateCreated.toIso8601String(),
      'dateModified': dateModified?.toIso8601String(),
    };
  }

  factory HomeEmploymentCreditModel.fromJson(Map<String, dynamic> json) {
    return HomeEmploymentCreditModel(
      expenses: (json['expenses'] as num?)?.toDouble() ?? 0,
      numberOfChildren: json['numberOfChildren'] as int? ?? 0,
      numberOfElderly: json['numberOfElderly'] as int? ?? 0,
      isFirstYear: json['isFirstYear'] as bool? ?? false,
      dateCreated: json['dateCreated'] != null
          ? DateTime.parse(json['dateCreated'] as String)
          : DateTime.now(),
      dateModified: json['dateModified'] != null
          ? DateTime.parse(json['dateModified'] as String)
          : null,
    );
  }
}
