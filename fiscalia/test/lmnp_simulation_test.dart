import 'package:flutter_test/flutter_test.dart';
import 'package:fiscalia/data/models/lmnp_simulation_model.dart';
import 'package:fiscalia/presentation/providers/lmnp_provider.dart';

void main() {
  final service = LmnpSimulationService();

  group('LmnpSimulationService', () {
    test('micro-BIC : abattement forfaitaire de 50%', () {
      final result = service.simuler(
        const LmnpSimulationModel(
          prixAcquisition: 200000,
          loyersAnnuels: 12000,
          tmi: 0.30,
          dureeAnnees: 1,
        ),
      );
      // Base micro = 12 000 x 50% = 6 000, taxe a 47.2%
      expect(result.projection.first.baseImposableMicro, 6000);
      expect(result.projection.first.impotMicro, closeTo(2832, 1));
    });

    test('reel : l\'amortissement neutralise l\'essentiel des loyers', () {
      final result = service.simuler(
        const LmnpSimulationModel(
          prixAcquisition: 200000,
          valeurMobilier: 5000,
          loyersAnnuels: 12000,
          chargesAnnuelles: 2000,
          tmi: 0.30,
          dureeAnnees: 10,
        ),
      );
      // Amortissements : batiment 170 000 / 30 = 5 667 + mobilier 714
      // Resultat : 12 000 - 2 000 - 5 667 - 714 = 3 619 la 1ere annee
      final annee1 = result.projection.first;
      expect(annee1.amortissementBatiment, closeTo(5667, 5));
      expect(annee1.baseImposableReel, closeTo(3619, 5));
      // Le reel est plus avantageux que le micro
      expect(result.economieTotaleReel, greaterThan(0));
    });

    test('l\'amortissement ne peut pas creer de deficit : report', () {
      final result = service.simuler(
        const LmnpSimulationModel(
          prixAcquisition: 400000,
          loyersAnnuels: 8000,
          chargesAnnuelles: 1000,
          tmi: 0.30,
          dureeAnnees: 1,
        ),
      );
      // Batiment : 340 000 / 30 = 11 333 > resultat avant amort (7 000)
      // Base = 0 et excedent reporte
      final annee1 = result.projection.first;
      expect(annee1.baseImposableReel, 0);
      expect(annee1.impotReel, 0);
      expect(annee1.amortissementsReportes, greaterThan(0));
    });

    test('le mobilier cesse de s\'amortir apres 7 ans', () {
      final result = service.simuler(
        const LmnpSimulationModel(
          prixAcquisition: 100000,
          valeurMobilier: 7000,
          loyersAnnuels: 15000,
          tmi: 0.30,
          dureeAnnees: 10,
        ),
      );
      expect(result.projection[6].amortissementMobilier, greaterThan(0));
      expect(result.projection[7].amortissementMobilier, 0);
    });

    test('taux de fiscalite effectif faible au reel', () {
      final result = service.simuler(
        const LmnpSimulationModel(
          prixAcquisition: 250000,
          valeurMobilier: 10000,
          loyersAnnuels: 14000,
          chargesAnnuelles: 3000,
          tmi: 0.30,
          dureeAnnees: 10,
        ),
      );
      expect(result.tauxFiscaliteReel, lessThan(0.25));
      expect(result.recommandations, isNotEmpty);
    });
  });
}
