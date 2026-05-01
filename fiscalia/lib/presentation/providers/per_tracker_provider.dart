import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/per_tracker_model.dart';

final perTrackerProvider = StateNotifierProvider<PerTrackerNotifier, PerTrackerModel?>((ref) {
  return PerTrackerNotifier();
});

class PerTrackerNotifier extends StateNotifier<PerTrackerModel?> {
  final _box = Hive.box<PerTrackerModel>('perTracker');
  final _uuid = const Uuid();

  PerTrackerNotifier() : super(_getInitialState());

  static PerTrackerModel? _getInitialState() {
    final box = Hive.box<PerTrackerModel>('perTracker');
    if (box.isEmpty) return null;
    return box.values.first; // We assume a single PER for simplicity in MVP
  }

  Future<void> savePerData({
    required double currentYearCeiling,
    double carryoverYear1 = 0,
    double carryoverYear2 = 0,
    double carryoverYear3 = 0,
  }) async {
    final model = state?.copyWith(
      currentYearCeiling: currentYearCeiling,
      carryoverYear1: carryoverYear1,
      carryoverYear2: carryoverYear2,
      carryoverYear3: carryoverYear3,
    ) ?? PerTrackerModel(
      id: _uuid.v4(),
      currentYearCeiling: currentYearCeiling,
      carryoverYear1: carryoverYear1,
      carryoverYear2: carryoverYear2,
      carryoverYear3: carryoverYear3,
    );

    await _box.put(model.id, model);
    state = model;
  }

  Future<void> updateContributions(double totalContributed) async {
    if (state == null) return;

    final updated = state!.copyWith(totalContributedThisYear: totalContributed);
    await _box.put(updated.id, updated);
    state = updated;
  }
  
  Future<void> deletePer() async {
    if (state != null) {
      await _box.delete(state!.id);
      state = null;
    }
  }
}

// Service to calculate tax savings
final perCalculationServiceProvider = Provider<PerCalculationService>((ref) {
  return PerCalculationService();
});

class PerCalculationService {
  /// Calculates potential tax savings based on Marginal Tax Rate (TMI)
  double calculatePotentialSavings(double contribution, double tmi) {
    // The savings are exactly the contribution multiplied by the marginal tax rate
    return contribution * (tmi / 100);
  }
}