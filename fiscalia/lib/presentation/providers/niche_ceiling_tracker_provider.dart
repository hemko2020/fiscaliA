import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/niche_ceiling_tracker_model.dart';
import 'niche_alert_service.dart';

final nicheCeilingTrackerProvider =
    StateNotifierProvider<
      NicheCeilingTrackerNotifier,
      NicheCeilingTrackerModel
    >((ref) {
      return NicheCeilingTrackerNotifier();
    });

/// Service d'alertes plafond (Story 4.3) et suggestions hors plafond (4.4).
final nicheAlertServiceProvider = Provider<NicheAlertService>(
  (ref) => const NicheAlertService(),
);

/// Alerte courante, recalculee a chaque changement du tracker (Story 4.3).
final nicheAlertProvider = Provider<NicheAlert>((ref) {
  final tracker = ref.watch(nicheCeilingTrackerProvider);
  return ref.watch(nicheAlertServiceProvider).evaluer(tracker);
});

/// TMI utilisee pour estimer l'economie des suggestions (ajustable).
final nicheSuggestionTmiProvider = StateProvider<double>((ref) => 0.30);

/// Suggestions de dispositifs hors plafond, classees par impact (4.4).
final suggestionsHorsPlafondProvider = Provider<List<SuggestionHorsPlafond>>((
  ref,
) {
  final tmi = ref.watch(nicheSuggestionTmiProvider);
  return ref.watch(nicheAlertServiceProvider).suggererHorsPlafond(tmi: tmi);
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
