import 'package:flutter_test/flutter_test.dart';
import 'package:fiscalia/data/models/ifi_model.dart';
import 'package:fiscalia/data/models/sofica_girardin_model.dart';
import 'package:fiscalia/presentation/providers/ifi_provider.dart';
import 'package:fiscalia/presentation/providers/sofica_girardin_provider.dart';

void main() {
  final ifi = IfiService();
  final sofica = SoficaGirardinService();

  group('IfiService', () {
    test('sous 1 300 000 EUR net : pas assujetti', () {
      final result = ifi.calculer(
        const IfiModel(patrimoineImmobilierBrut: 1200000),
      );
      expect(result.assujetti, isFalse);
      expect(result.ifiFinal, 0);
    });

    test('2 000 000 EUR net : IFI par tranches depuis 800 000 EUR', () {
      final result = ifi.calculer(
        const IfiModel(patrimoineImmobilierBrut: 2000000),
      );
      // 800k-1.3M a 0.5% = 2 500 ; 1.3M-2M a 0.7% = 4 900 ; total 7 400
      expect(result.assujetti, isTrue);
      expect(result.ifiBrut, closeTo(7400, 1));
    });

    test('dettes deductibles reduisent l\'assiette', () {
      final result = ifi.calculer(
        const IfiModel(
          patrimoineImmobilierBrut: 2000000,
          dettesDeductibles: 800000,
        ),
      );
      expect(result.assujetti, isFalse);
    });

    test('decote pour patrimoine entre 1.3M et 1.4M', () {
      final result = ifi.calculer(
        const IfiModel(patrimoineImmobilierBrut: 1350000),
      );
      // Brut : 500 000 x 0.5% + 50 000 x 0.7% = 2 850
      // Decote : 17 500 - 1.25% x 1 350 000 = 625
      expect(result.ifiBrut, closeTo(2850, 1));
      expect(result.ifiApresDecote, closeTo(625, 1));
      expect(result.decote, greaterThan(0));
    });

    test('dons IFI : reduction 75% plafonnee a 50 000 EUR', () {
      final result = ifi.calculer(
        const IfiModel(patrimoineImmobilierBrut: 3000000, donsIfi: 100000),
      );
      expect(result.reductionDons, lessThanOrEqualTo(50000));
      expect(
        result.ifiFinal,
        closeTo(result.ifiApresDecote - result.reductionDons, 0.01),
      );
    });
  });

  group('SoficaGirardinService', () {
    test('SOFICA 30% standard, 48% majore', () {
      final standard = sofica.calculer(
        const SoficaGirardinModel(
          investissementSofica: 10000,
          impotAvantReductions: 20000,
        ),
      );
      expect(standard.reductionSofica, 3000);

      final majore = sofica.calculer(
        const SoficaGirardinModel(
          investissementSofica: 10000,
          soficaTauxMajore: true,
          impotAvantReductions: 20000,
        ),
      );
      expect(majore.reductionSofica, 4800);
    });

    test('plafond d\'investissement SOFICA 18 000 EUR', () {
      final result = sofica.calculer(
        const SoficaGirardinModel(
          investissementSofica: 25000,
          impotAvantReductions: 20000,
        ),
      );
      expect(result.reductionSofica, 18000 * 0.30);
    });

    test('Girardin one-shot : reduction > investissement', () {
      final result = sofica.calculer(
        const SoficaGirardinModel(
          investissementGirardin: 10000,
          impotAvantReductions: 20000,
        ),
      );
      expect(result.reductionGirardin, 11000);
      expect(result.gainNetGirardin, 1000);
    });

    test('excedent au-dela de l\'impot signale comme non imputable', () {
      final result = sofica.calculer(
        const SoficaGirardinModel(
          investissementSofica: 18000,
          investissementGirardin: 10000,
          impotAvantReductions: 8000,
        ),
      );
      expect(result.reductionImputable, 8000);
      expect(result.reductionNonImputable, greaterThan(0));
      expect(
        result.avertissements.any((a) => a.contains('depassent')),
        isTrue,
      );
    });
  });
}
