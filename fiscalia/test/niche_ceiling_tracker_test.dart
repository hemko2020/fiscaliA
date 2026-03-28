import 'package:flutter_test/flutter_test.dart';
import 'package:fiscalia/data/models/niche_ceiling_tracker_model.dart';

void main() {
  group('NicheCeilingTrackerModel', () {
    test('should calculate correct remaining ceiling', () {
      final tracker = NicheCeilingTrackerModel(
        totalCeiling: 10000,
        usedCeiling: 2500,
      );

      expect(tracker.remainingCeiling, 7500);
    });

    test('should calculate correct utilization rate', () {
      final tracker = NicheCeilingTrackerModel(
        totalCeiling: 10000,
        usedCeiling: 2500,
      );

      expect(tracker.utilizationRate, 0.25);
    });

    test('should detect over ceiling', () {
      final tracker = NicheCeilingTrackerModel(
        totalCeiling: 10000,
        usedCeiling: 11000,
      );

      expect(tracker.isOverCeiling, true);
    });

    test('should detect near ceiling', () {
      final tracker = NicheCeilingTrackerModel(
        totalCeiling: 10000,
        usedCeiling: 8500,
      );

      expect(tracker.isNearCeiling, true);
    });

    test('should add credit correctly', () {
      final tracker = NicheCeilingTrackerModel(
        totalCeiling: 10000,
        usedCeiling: 2000,
      );

      final updated = tracker.addCredit(
        creditType: 'Emploi à domicile',
        amount: 1000,
        description: 'Garde d\'enfants',
      );

      expect(updated.usedCeiling, 3000);
      expect(updated.creditEntries.length, 1);
      expect(updated.creditEntries.first.amount, 1000);
    });

    test('should remove credit correctly', () {
      final tracker = NicheCeilingTrackerModel(
        totalCeiling: 10000,
        usedCeiling: 3000,
        creditEntries: [
          NicheCreditEntry(creditType: 'Emploi à domicile', amount: 1000),
          NicheCreditEntry(creditType: 'Garde d\'enfants', amount: 2000),
        ],
      );

      final entryId = tracker.creditEntries.first.id;
      final updated = tracker.removeCredit(entryId);

      expect(updated.usedCeiling, 2000);
      expect(updated.creditEntries.length, 1);
    });

    test('should clear all credits', () {
      final tracker = NicheCeilingTrackerModel(
        totalCeiling: 10000,
        usedCeiling: 3000,
        creditEntries: [
          NicheCreditEntry(creditType: 'Emploi à domicile', amount: 1000),
          NicheCreditEntry(creditType: 'Garde d\'enfants', amount: 2000),
        ],
      );

      final cleared = tracker.clearAll();

      expect(cleared.usedCeiling, 0);
      expect(cleared.creditEntries.length, 0);
    });

    test('should get credit breakdown', () {
      final tracker = NicheCeilingTrackerModel(
        totalCeiling: 10000,
        usedCeiling: 3000,
        creditEntries: [
          NicheCreditEntry(creditType: 'Emploi à domicile', amount: 1000),
          NicheCreditEntry(creditType: 'Garde d\'enfants', amount: 2000),
        ],
      );

      final breakdown = tracker.getCreditBreakdown();

      expect(breakdown['Emploi à domicile'], 1000);
      expect(breakdown['Garde d\'enfants'], 2000);
    });

    test('should serialize to JSON correctly', () {
      final tracker = NicheCeilingTrackerModel(
        totalCeiling: 10000,
        usedCeiling: 2500,
      );

      final json = tracker.toJson();

      expect(json['totalCeiling'], 10000);
      expect(json['usedCeiling'], 2500);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'totalCeiling': 10000,
        'usedCeiling': 2500,
        'creditEntries': [],
      };

      final tracker = NicheCeilingTrackerModel.fromJson(json);

      expect(tracker.totalCeiling, 10000);
      expect(tracker.usedCeiling, 2500);
    });

    test('should copy with new values correctly', () {
      final tracker = NicheCeilingTrackerModel(
        totalCeiling: 10000,
        usedCeiling: 2500,
      );

      final updated = tracker.copyWith(totalCeiling: 15000, usedCeiling: 3000);

      expect(updated.totalCeiling, 15000);
      expect(updated.usedCeiling, 3000);
    });
  });

  group('NicheCreditEntry', () {
    test('should create entry with unique ID', () {
      final entry1 = NicheCreditEntry(
        creditType: 'Emploi à domicile',
        amount: 1000,
      );

      final entry2 = NicheCreditEntry(
        creditType: 'Garde d\'enfants',
        amount: 2000,
      );

      expect(entry1.id.isNotEmpty, true);
      expect(entry2.id.isNotEmpty, true);
      expect(entry1.id != entry2.id, true);
    });

    test('should serialize to JSON correctly', () {
      final entry = NicheCreditEntry(
        creditType: 'Emploi à domicile',
        amount: 1000,
        description: 'Garde d\'enfants',
      );

      final json = entry.toJson();

      expect(json['creditType'], 'Emploi à domicile');
      expect(json['amount'], 1000);
      expect(json['description'], 'Garde d\'enfants');
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'creditType': 'Emploi à domicile',
        'amount': 1000,
        'description': 'Garde d\'enfants',
      };

      final entry = NicheCreditEntry.fromJson(json);

      expect(entry.creditType, 'Emploi à domicile');
      expect(entry.amount, 1000);
      expect(entry.description, 'Garde d\'enfants');
    });
  });
}
