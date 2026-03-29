import 'package:hive/hive.dart';

@HiveType(typeId: 7)
class ChildCareCreditModel {
  @HiveField(0)
  final double expenses;

  @HiveField(1)
  final int numberOfChildren;

  @HiveField(2)
  final bool isSingleParent;

  @HiveField(3)
  final DateTime dateCreated;

  @HiveField(4)
  final DateTime? dateModified;

  ChildCareCreditModel({
    required this.expenses,
    this.numberOfChildren = 1,
    this.isSingleParent = false,
    DateTime? dateCreated,
    this.dateModified,
  }) : dateCreated = dateCreated ?? DateTime.now();

  double get ceiling {
    if (isSingleParent) {
      switch (numberOfChildren) {
        case 1:
          return 3500;
        case 2:
          return 7300;
        default:
          return 7300 + (numberOfChildren - 2) * 3800;
      }
    } else {
      switch (numberOfChildren) {
        case 1:
          return 2300;
        case 2:
          return 4800;
        default:
          return 4800 + (numberOfChildren - 2) * 2500;
      }
    }
  }

  double get creditAmount {
    final eligibleExpenses = expenses.clamp(0, ceiling);
    return eligibleExpenses * 0.50;
  }

  double get effectiveRate {
    if (expenses <= 0) return 0;
    return creditAmount / expenses;
  }

  ChildCareCreditModel copyWith({
    double? expenses,
    int? numberOfChildren,
    bool? isSingleParent,
    DateTime? dateCreated,
    DateTime? dateModified,
  }) {
    return ChildCareCreditModel(
      expenses: expenses ?? this.expenses,
      numberOfChildren: numberOfChildren ?? this.numberOfChildren,
      isSingleParent: isSingleParent ?? this.isSingleParent,
      dateCreated: dateCreated ?? this.dateCreated,
      dateModified: dateModified ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expenses': expenses,
      'numberOfChildren': numberOfChildren,
      'isSingleParent': isSingleParent,
      'dateCreated': dateCreated.toIso8601String(),
      'dateModified': dateModified?.toIso8601String(),
    };
  }

  factory ChildCareCreditModel.fromJson(Map<String, dynamic> json) {
    return ChildCareCreditModel(
      expenses: (json['expenses'] as num?)?.toDouble() ?? 0,
      numberOfChildren: json['numberOfChildren'] as int? ?? 1,
      isSingleParent: json['isSingleParent'] as bool? ?? false,
      dateCreated: json['dateCreated'] != null
          ? DateTime.parse(json['dateCreated'] as String)
          : DateTime.now(),
      dateModified: json['dateModified'] != null
          ? DateTime.parse(json['dateModified'] as String)
          : null,
    );
  }
}
