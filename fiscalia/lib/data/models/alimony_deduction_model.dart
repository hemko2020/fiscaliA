import 'package:hive/hive.dart';

@HiveType(typeId: 13)
class AlimonyDeductionModel {
  @HiveField(0)
  final double alimonyAmount;

  @HiveField(1)
  final bool isSpousalSupport;

  @HiveField(2)
  final bool isChildSupport;

  @HiveField(3)
  final DateTime dateCreated;

  @HiveField(4)
  final DateTime? dateModified;

  AlimonyDeductionModel({
    required this.alimonyAmount,
    required this.isSpousalSupport,
    required this.isChildSupport,
    DateTime? dateCreated,
    this.dateModified,
  }) : dateCreated = dateCreated ?? DateTime.now();

  static const double maxAnnualDeduction = 6674.0;

  double get deductionAmount {
    return alimonyAmount.clamp(0, maxAnnualDeduction);
  }

  double get excessAmount {
    if (alimonyAmount <= maxAnnualDeduction) return 0;
    return alimonyAmount - maxAnnualDeduction;
  }

  bool get isCeilingReached {
    return alimonyAmount > maxAnnualDeduction;
  }

  bool get isDeductible {
    return isSpousalSupport || isChildSupport;
  }

  double get nicheCeilingImpact {
    return deductionAmount;
  }

  String get deductionType {
    if (isSpousalSupport && isChildSupport) {
      return 'Pension alimentaire et pension pour enfants';
    } else if (isSpousalSupport) {
      return 'Pension alimentaire';
    } else if (isChildSupport) {
      return 'Pension pour enfants';
    }
    return 'Non spécifié';
  }

  AlimonyDeductionModel copyWith({
    double? alimonyAmount,
    bool? isSpousalSupport,
    bool? isChildSupport,
    DateTime? dateCreated,
    DateTime? dateModified,
  }) {
    return AlimonyDeductionModel(
      alimonyAmount: alimonyAmount ?? this.alimonyAmount,
      isSpousalSupport: isSpousalSupport ?? this.isSpousalSupport,
      isChildSupport: isChildSupport ?? this.isChildSupport,
      dateCreated: dateCreated ?? this.dateCreated,
      dateModified: dateModified ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alimonyAmount': alimonyAmount,
      'isSpousalSupport': isSpousalSupport,
      'isChildSupport': isChildSupport,
      'dateCreated': dateCreated.toIso8601String(),
      'dateModified': dateModified?.toIso8601String(),
    };
  }

  factory AlimonyDeductionModel.fromJson(Map<String, dynamic> json) {
    return AlimonyDeductionModel(
      alimonyAmount: (json['alimonyAmount'] as num?)?.toDouble() ?? 0,
      isSpousalSupport: json['isSpousalSupport'] as bool? ?? false,
      isChildSupport: json['isChildSupport'] as bool? ?? false,
      dateCreated: json['dateCreated'] != null
          ? DateTime.parse(json['dateCreated'] as String)
          : DateTime.now(),
      dateModified: json['dateModified'] != null
          ? DateTime.parse(json['dateModified'] as String)
          : null,
    );
  }
}
