import 'package:hive/hive.dart';

part 'per_tracker_model.g.dart';

@HiveType(typeId: 19)
class PerTrackerModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double currentYearCeiling;

  @HiveField(2)
  final double carryoverYear1; // Ceiling from N-1

  @HiveField(3)
  final double carryoverYear2; // Ceiling from N-2

  @HiveField(4)
  final double carryoverYear3; // Ceiling from N-3 (Expires this year)

  @HiveField(5)
  final double totalContributedThisYear;

  const PerTrackerModel({
    required this.id,
    required this.currentYearCeiling,
    this.carryoverYear1 = 0,
    this.carryoverYear2 = 0,
    this.carryoverYear3 = 0,
    this.totalContributedThisYear = 0,
  });

  double get totalAvailableCeiling =>
      currentYearCeiling + carryoverYear1 + carryoverYear2 + carryoverYear3;

  double get remainingCeiling {
    final remaining = totalAvailableCeiling - totalContributedThisYear;
    return remaining > 0 ? remaining : 0;
  }

  bool get isApproachingExpiration {
    // If they haven't contributed enough to cover Year 3 carryover, it's at risk of expiring
    return carryoverYear3 > 0 && totalContributedThisYear < carryoverYear3;
  }

  double get expiringAmount {
    if (!isApproachingExpiration) return 0;
    return carryoverYear3 - totalContributedThisYear;
  }

  PerTrackerModel copyWith({
    String? id,
    double? currentYearCeiling,
    double? carryoverYear1,
    double? carryoverYear2,
    double? carryoverYear3,
    double? totalContributedThisYear,
  }) {
    return PerTrackerModel(
      id: id ?? this.id,
      currentYearCeiling: currentYearCeiling ?? this.currentYearCeiling,
      carryoverYear1: carryoverYear1 ?? this.carryoverYear1,
      carryoverYear2: carryoverYear2 ?? this.carryoverYear2,
      carryoverYear3: carryoverYear3 ?? this.carryoverYear3,
      totalContributedThisYear:
          totalContributedThisYear ?? this.totalContributedThisYear,
    );
  }
}
