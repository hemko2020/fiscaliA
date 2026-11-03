import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/advanced_tax_constants.dart';
import '../../data/models/per_optimization_model.dart';

final perOptimizationServiceProvider = Provider(
  (ref) => PerOptimizationService(),
);

final perOptimizationProvider = StateProvider<PerOptimizationResult?>(
  (ref) => null,
);

/// Service de calcul des strategies PER avancees (Story 8.1).
///
/// Reference : Art. 163 quatervicies CGI.
/// - Plafond = 10% des revenus professionnels, plafonne a 37 094 EUR (2026),
///   avec un plancher de 4 637 EUR pour les faibles revenus.
/// - Les plafonds non utilises sont reportables 3 ans.
/// - Les conjoints peuvent mutualiser leurs plafonds (case 6QR).
class PerOptimizationService {
  PerOptimizationResult optimiser(PerOptimizationModel input) {
    final plafondAnnuel1 = PerOptimizationModel.plafondAnnuel(
      input.revenuDeclarant1,
      AdvancedTaxConstants.perAnnualCeiling,
      AdvancedTaxConstants.perMinDeduction,
    );
    final reports1 = input.reportsDeclarant1.fold<double>(
      0,
      (somme, r) => somme + r,
    );
    final disponible1 = plafondAnnuel1 + reports1;

    double disponible2 = 0;
    if (input.estEnCouple) {
      final plafondAnnuel2 = PerOptimizationModel.plafondAnnuel(
        input.revenuDeclarant2,
        AdvancedTaxConstants.perAnnualCeiling,
        AdvancedTaxConstants.perMinDeduction,
      );
      final reports2 = input.reportsDeclarant2.fold<double>(
        0,
        (somme, r) => somme + r,
      );
      disponible2 = plafondAnnuel2 + reports2;
    }

    // Mutualisation : le couple peut additionner ses plafonds (Art. 163
    // quatervicies, alinea 3 CGI - declaration case 6QR).
    final plafondMutualise = disponible1 + disponible2;

    final versementOptimal = input.versementEnvisage > plafondMutualise
        ? plafondMutualise
        : input.versementEnvisage;
    final excedent = input.versementEnvisage - versementOptimal;

    // Economie = deduction x TMI (le versement vient en deduction du revenu
    // imposable ; hors plafond global des niches fiscales).
    final economie = versementOptimal * input.tmi;

    // Le report le plus ancien (N-3) expire au 31/12 s'il n'est pas utilise.
    final reportsExpirants =
        (input.reportsDeclarant1.isNotEmpty
                ? input.reportsDeclarant1.last
                : 0.0) +
            (input.estEnCouple && input.reportsDeclarant2.isNotEmpty
                ? input.reportsDeclarant2.last
                : 0.0);

    final recommandations = <String>[];
    if (input.estEnCouple) {
      recommandations.add(
        'En tant que couple, vous pouvez mutualiser vos plafonds PER '
        '(case 6QR de la declaration) : plafond combine de '
        '${plafondMutualise.toStringAsFixed(0)} EUR.',
      );
    }
    if (reportsExpirants > 0 && versementOptimal < reportsExpirants) {
      recommandations.add(
        'Attention : ${reportsExpirants.toStringAsFixed(0)} EUR de plafonds '
        'reportes de N-3 expirent definitivement au 31/12.',
      );
    }
    if (excedent > 0) {
      recommandations.add(
        '${excedent.toStringAsFixed(0)} EUR de votre versement depassent le '
        'plafond disponible et ne seront pas deductibles.',
      );
    }
    if (input.tmi >= 0.30) {
      recommandations.add(
        'Avec une TMI de ${(input.tmi * 100).toStringAsFixed(0)}%, chaque '
        'euro verse au PER vous fait economiser '
        '${input.tmi.toStringAsFixed(2)} EUR d\'impot (hors plafond des '
        'niches fiscales).',
      );
    }

    return PerOptimizationResult(
      plafondDisponibleDeclarant1: disponible1,
      plafondDisponibleDeclarant2: disponible2,
      plafondMutualise: plafondMutualise,
      versementOptimal: versementOptimal,
      economieImpot: economie,
      excedentNonDeductible: excedent > 0 ? excedent : 0,
      reportsExpirants: reportsExpirants,
      recommandations: recommandations,
    );
  }
}
