import 'package:flutter_test/flutter_test.dart';
import 'package:fiscalia/data/models/per_tracker_model.dart';
import 'package:fiscalia/presentation/providers/per_tracker_provider.dart';

void main() {
  group('PerTrackerModel', () {
    test('should calculate total available ceiling correctly', () {
      const per = PerTrackerModel(
        id: '1',
        currentYearCeiling: 4000,
        carryoverYear1: 1000,
        carryoverYear2: 500,
        carryoverYear3: 200,
      );

      expect(per.totalAvailableCeiling, 5700);
    });

    test('should calculate remaining ceiling correctly', () {
      const per = PerTrackerModel(
        id: '1',
        currentYearCeiling: 4000,
        carryoverYear1: 1000,
        totalContributedThisYear: 2000,
      );

      expect(per.remainingCeiling, 3000);
    });

    test('should identify expiration risk', () {
      // Has carryover from Year 3 but no contribution yet
      const perAtRisk = PerTrackerModel(
        id: '1',
        currentYearCeiling: 4000,
        carryoverYear3: 500,
        totalContributedThisYear: 100, // Not enough to cover year 3
      );

      expect(perAtRisk.isApproachingExpiration, isTrue);
      expect(perAtRisk.expiringAmount, 400);

      // Has carryover from Year 3 and contributed enough
      const perSafe = PerTrackerModel(
        id: '2',
        currentYearCeiling: 4000,
        carryoverYear3: 500,
        totalContributedThisYear: 600, // Covers year 3
      );

      expect(perSafe.isApproachingExpiration, isFalse);
      expect(perSafe.expiringAmount, 0);
    });
  });

  group('PerCalculationService', () {
    test('should calculate potential savings correctly', () {
      final service = PerCalculationService();

      // 1000€ contribution with 30% TMI
      final savings = service.calculatePotentialSavings(1000, 30);
      expect(savings, 300);

      // 5000€ contribution with 41% TMI
      final savingsHigh = service.calculatePotentialSavings(5000, 41);
      expect(savingsHigh, 2050);
    });
  });
}
