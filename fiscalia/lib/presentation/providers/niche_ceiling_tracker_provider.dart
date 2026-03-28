import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/niche_ceiling_tracker_model.dart';

final nicheCeilingTrackerProvider =
    StateNotifierProvider<
      NicheCeilingTrackerNotifier,
      NicheCeilingTrackerModel
    >((ref) {
      return NicheCeilingTrackerNotifier();
    });

class NicheCeilingTrackerNotifier
    extends StateNotifier<NicheCeilingTrackerModel> {
  NicheCeilingTrackerNotifier() : super(NicheCeilingTrackerModel());

  void addCredit({
    required String creditType,
    required double amount,
    String? description,
  }) {
    state = state.addCredit(
      creditType: creditType,
      amount: amount,
      description: description,
    );
  }

  void removeCredit(String entryId) {
    state = state.removeCredit(entryId);
  }

  void clearAll() {
    state = state.clearAll();
  }

  void updateTotalCeiling(double newCeiling) {
    state = state.copyWith(totalCeiling: newCeiling);
  }

  Map<String, double> getCreditBreakdown() {
    return state.getCreditBreakdown();
  }

  bool isOverCeiling() {
    return state.isOverCeiling;
  }

  bool isNearCeiling() {
    return state.isNearCeiling;
  }
}
