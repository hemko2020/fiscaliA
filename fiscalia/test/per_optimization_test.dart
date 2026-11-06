import 'package:flutter_test/flutter_test.dart';
import 'package:fiscalia/data/models/per_optimization_model.dart';
import 'package:fiscalia/presentation/providers/per_optimization_provider.dart';

void main() {
  final service = PerOptimizationService();

  group('PerOptimizationService - plafonds individuels', () {
    test('plafond annuel = 10% du revenu', () {
      final result = service.optimiser(
        const PerOptimizationModel(
          revenuDeclarant1: 75000,
          tmi: 0.30,
          versementEnvisage: 5000,
        ),
      );
      // 10% x 75 000 = 7 500
      expect(result.plafondDisponibleDeclarant1, 7500);
      expect(result.versementOptimal, 5000);
      expect(result.economieImpot, 1500);
    });

    test('plafond borne au maximum legal de 37 094 EUR', () {
      final result = service.optimiser(
        const PerOptimizationModel(
          revenuDeclarant1: 500000,
          tmi: 0.45,
          versementEnvisage: 40000,
        ),
      );
      expect(result.plafondDisponibleDeclarant1, 37094);
      expect(result.versementOptimal, 37094);
      expect(result.excedentNonDeductible, closeTo(2906, 0.01));
    });

    test('plancher de 4 637 EUR pour les faibles revenus', () {
      final result = service.optimiser(
        const PerOptimizationModel(
          revenuDeclarant1: 20000,
          tmi: 0.11,
          versementEnvisage: 4000,
        ),
      );
      expect(result.plafondDisponibleDeclarant1, 4637);
    });

    test('reports des 3 dernieres annees ajoutes au plafond', () {
      final result = service.optimiser(
        const PerOptimizationModel(
          revenuDeclarant1: 75000,
          tmi: 0.30,
          reportsDeclarant1: [3000, 2000, 1000],
          versementEnvisage: 13500,
        ),
      );
      expect(result.plafondDisponibleDeclarant1, 13500);
      expect(result.reportsExpirants, 1000);
    });
  });

  group('PerOptimizationService - mutualisation couple', () {
    test(
      'couple 150 000 EUR : plafond combine 74 188 EUR borne a 2 x 37 094',
      () {
        final result = service.optimiser(
          const PerOptimizationModel(
            revenuDeclarant1: 500000,
            revenuDeclarant2: 400000,
            tmi: 0.41,
            versementEnvisage: 50000,
          ),
        );
        expect(result.plafondMutualise, 74188);
      },
    );

    test('economie = versement x TMI', () {
      final result = service.optimiser(
        const PerOptimizationModel(
          revenuDeclarant1: 75000,
          tmi: 0.30,
          versementEnvisage: 7500,
        ),
      );
      // 7 500 x 30% = 2 250
      expect(result.economieImpot, 2250);
    });

    test('recommandation mutualisation presente pour un couple', () {
      final result = service.optimiser(
        const PerOptimizationModel(
          revenuDeclarant1: 80000,
          revenuDeclarant2: 70000,
          tmi: 0.30,
          versementEnvisage: 5000,
        ),
      );
      expect(
        result.recommandations.any((r) => r.contains('mutualiser')),
        isTrue,
      );
    });
  });
}
