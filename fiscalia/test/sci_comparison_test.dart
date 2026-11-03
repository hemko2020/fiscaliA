import 'package:flutter_test/flutter_test.dart';
import 'package:fiscalia/data/models/sci_comparison_model.dart';
import 'package:fiscalia/presentation/providers/sci_comparison_provider.dart';

void main() {
  final service = SciComparisonService();

  group('SciComparisonService - regime IR', () {
    test('revenu foncier taxe a TMI + 17.2% de PS', () {
      final result = service.comparer(
        const SciComparisonModel(
          loyersAnnuels: 24000,
          chargesAnnuelles: 4000,
          tmi: 0.30,
        ),
      );
      // 20 000 x 47.2% = 9 440
      expect(result.regimeIR.resultat, 20000);
      expect(result.regimeIR.impotSurResultat, closeTo(9440, 1));
    });

    test('deficit foncier plafonne a 10 700 EUR, economie a la TMI', () {
      final result = service.comparer(
        const SciComparisonModel(
          loyersAnnuels: 12000,
          chargesAnnuelles: 2000,
          tmi: 0.30,
          deficitFoncierAnnuel: 15000,
        ),
      );
      expect(result.regimeIR.economieDeficitFoncier, closeTo(10700 * 0.30, 1));
    });
  });

  group('SciComparisonService - regime IS', () {
    test('IS a 15% jusqu\'a 42 500 EUR', () {
      final result = service.comparer(
        const SciComparisonModel(
          loyersAnnuels: 30000,
          chargesAnnuelles: 2000,
          valeurAmortissable: 200000,
          dureeAmortissement: 30,
          tmi: 0.30,
        ),
      );
      // Resultat = 30 000 - 2 000 - 6 667 = 21 333 < 42 500 => 15%
      expect(result.regimeIS.resultat, closeTo(21333, 5));
      expect(result.regimeIS.impotSurResultat, closeTo(21333 * 0.15, 5));
    });

    test('distribution de dividendes taxee au PFU 30%', () {
      final result = service.comparer(
        const SciComparisonModel(
          loyersAnnuels: 30000,
          chargesAnnuelles: 2000,
          valeurAmortissable: 200000,
          dureeAmortissement: 30,
          tmi: 0.30,
          tauxDistribution: 1.0,
        ),
      );
      final apresIS = result.regimeIS.resultat - result.regimeIS.impotSurResultat;
      expect(
        result.regimeIS.fiscaliteDistribution,
        closeTo(apresIS * 0.30, 1),
      );
    });

    test('sans distribution, l\'IS gagne si TMI elevee', () {
      final result = service.comparer(
        const SciComparisonModel(
          loyersAnnuels: 30000,
          chargesAnnuelles: 2000,
          valeurAmortissable: 300000,
          dureeAmortissement: 30,
          tmi: 0.41,
        ),
      );
      expect(result.regimeRecommande, 'IS');
      expect(
        result.regimeIS.fiscaliteTotale,
        lessThan(result.regimeIR.fiscaliteTotale),
      );
    });

    test('les points de vigilance mentionnent le caractere definitif', () {
      final result = service.comparer(
        const SciComparisonModel(loyersAnnuels: 10000, tmi: 0.30),
      );
      expect(
        result.pointsVigilance.any((p) => p.contains('definitive')),
        isTrue,
      );
    });
  });
}
