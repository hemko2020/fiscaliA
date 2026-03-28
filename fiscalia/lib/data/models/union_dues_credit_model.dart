import 'package:hive/hive.dart';

@HiveType(typeId: 12)
class UnionDuesCreditModel {
  @HiveField(0)
  final double unionDues;

  @HiveField(1)
  final double grossIncome;

  @HiveField(2)
  final DateTime dateCreated;

  @HiveField(3)
  final DateTime? dateModified;

  UnionDuesCreditModel({
    required this.unionDues,
    required this.grossIncome,
    DateTime? dateCreated,
    this.dateModified,
  }) : dateCreated = dateCreated ?? DateTime.now();

  double get ceiling {
    return grossIncome * 0.01;
  }

  double get creditAmount {
    final eligibleDues = unionDues.clamp(0, ceiling);
    return eligibleDues * 0.66;
  }

  double get effectiveRate {
    if (unionDues <= 0) return 0;
    return creditAmount / unionDues;
  }

  bool get isCeilingReached {
    return unionDues > ceiling;
  }

  double get excessDues {
    if (unionDues <= ceiling) return 0;
    return unionDues - ceiling;
  }

  UnionDuesCreditModel copyWith({
    double? unionDues,
    double? grossIncome,
    DateTime? dateCreated,
    DateTime? dateModified,
  }) {
    return UnionDuesCreditModel(
      unionDues: unionDues ?? this.unionDues,
      grossIncome: grossIncome ?? this.grossIncome,
      dateCreated: dateCreated ?? this.dateCreated,
      dateModified: dateModified ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unionDues': unionDues,
      'grossIncome': grossIncome,
      'dateCreated': dateCreated.toIso8601String(),
      'dateModified': dateModified?.toIso8601String(),
    };
  }

  factory UnionDuesCreditModel.fromJson(Map<String, dynamic> json) {
    return UnionDuesCreditModel(
      unionDues: (json['unionDues'] as num?)?.toDouble() ?? 0,
      grossIncome: (json['grossIncome'] as num?)?.toDouble() ?? 0,
      dateCreated: json['dateCreated'] != null
          ? DateTime.parse(json['dateCreated'] as String)
          : DateTime.now(),
      dateModified: json['dateModified'] != null
          ? DateTime.parse(json['dateModified'] as String)
          : null,
    );
  }
}
