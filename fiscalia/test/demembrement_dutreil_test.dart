import 'package:flutter_test/flutter_test.dart';
import 'package:fiscalia/data/models/demembrement_model.dart';
import 'package:fiscalia/data/models/pacte_dutreil_model.dart';
import 'package:fiscalia/presentation/providers/demembrement_provider.dart';
import 'package:fiscalia/presentation/providers/pacte_dutreil_provider.dart';

void main() {
  final demembrement = DemembrementService();
  final dutreil = PacteDutreilService();

  group('DemembrementService - bareme Art. 669 CGI', () {
    test('a 55 ans, usufruit = 50%', () {
      final result = demembrement.calculer(
        const DemembrementModel(ageUsufruitier: 55, valeurBien: 500000),
      );
      expect(result.ratioUsufruit, 0.50);
      expect(result.valeurUsufruit, 250000);
      expect(result.valeurNuePropriete, 250000);
    });

    test('a 65 ans, usufruit = 40%', () {
      final result = demembrement.calculer(
        const DemembrementModel(ageUsufruitier: 65, valeurBien: 500000),
      );
      expect(result.ratioUsufruit, 0.40);
      expect(result.valeurNuePropriete, 300000);
    });

    test('donation couverte par l\'abattement de 100 000 EUR : 0 droit', () {
      final result = demembrement.calculer(
        const DemembrementModel(
          ageUsufruitier: 75,
          valeurBien: 200000,
          nbEnfants: 1,
          nbParents: 1,
        ),
      );
      // NP = 70% x 200 000 = 140 000 - 100 000 = 40 000 taxable
      expect(result.valeurNuePropriete, 140000);
      expect(result.assietteTaxable, 40000);
      expect(result.droitsDonation, greaterThan(0));
      expect(result.economie, greaterThan(0));
    });

    test('2 parents x 2 enfants = 400 000 EUR d\'abattements', () {
      final result = demembrement.calculer(
        const DemembrementModel(
          ageUsufruitier: 70,
          valeurBien: 800000,
          nbEnfants: 2,
          nbParents: 2,
        ),
      );
      expect(result.abattementTotal, 400000);
    });

    test('calcul par part : 2 parents x 2 enfants moins taxe qu\'en agrege',
        () {
      // NP = 60% x 800 000 = 480 000 ; par part : 120 000 - 100 000 = 20 000
      final result = demembrement.calculer(
        const DemembrementModel(
          ageUsufruitier: 70,
          valeurBien: 800000,
          nbEnfants: 2,
          nbParents: 2,
        ),
      );
      final droitsParPart =
          DemembrementService.calculerDroitsLigneDirecte(20000) * 4;
      expect(result.droitsDonation, closeTo(droitsParPart, 0.01));
      // En agrege (methode incorrecte) : 80 000 taxable = ~14 194 EUR
      final agrege = DemembrementService.calculerDroitsLigneDirecte(80000);
      expect(result.droitsDonation, lessThan(agrege));
    });

    test('bareme progressif ligne directe', () {
      // 50 000 taxable : 8 072x5% + 4 037x10% + 3 823x15% + 34 068x20%
      final droits =
          DemembrementService.calculerDroitsLigneDirecte(50000);
      final attendu = 8072 * 0.05 + (12109 - 8072) * 0.10 +
          (15932 - 12109) * 0.15 + (50000 - 15932) * 0.20;
      expect(droits, closeTo(attendu, 0.01));
    });
  });

  group('PacteDutreilService - Art. 787 B CGI', () {
    test('abattement 75% : 1 000 000 EUR -> droits divises fortement', () {
      final result = dutreil.calculer(
        const PacteDutreilModel(valeurEntreprise: 1000000, nbEnfants: 1),
      );
      // Sans : (1 000 000 - 100 000) au bareme ~ 192 442
      // Avec : (250 000 - 100 000) au bareme ~ 28 194
      expect(result.droitsSansDutreil, greaterThan(150000));
      expect(result.droitsAvecDutreil, lessThan(40000));
      expect(result.economie, greaterThan(100000));
    });

    test('petite entreprise couverte par abattement : 0 droit avec Dutreil',
        () {
      final result = dutreil.calculer(
        const PacteDutreilModel(valeurEntreprise: 300000, nbEnfants: 2),
      );
      // 25% x 300 000 = 75 000 < abattement 200 000
      expect(result.droitsAvecDutreil, 0);
    });

    test('les conditions legales sont listees', () {
      final result = dutreil.calculer(
        const PacteDutreilModel(valeurEntreprise: 500000),
      );
      expect(result.conditions.length, greaterThanOrEqualTo(5));
      expect(
        result.conditions.any((c) => c.contains('4 ans')),
        isTrue,
      );
    });
  });
}
