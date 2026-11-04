import 'package:flutter_test/flutter_test.dart';
import 'package:fiscalia/data/models/niche_ceiling_tracker_model.dart';
import 'package:fiscalia/presentation/providers/niche_alert_service.dart';

void main() {
  const service = NicheAlertService();

  NicheCeilingTrackerModel trackerAvec(double utilise) {
    return NicheCeilingTrackerModel(totalCeiling: 10000, usedCeiling: utilise);
  }

  group('NicheAlertService - alertes plafond (Story 4.3)', () {
    test('sous 90% : pas d\'alerte', () {
      final alerte = service.evaluer(trackerAvec(8000));
      expect(alerte.niveau, NicheAlertLevel.ok);
    });

    test('a 90% exactement : avertissement preventif', () {
      final alerte = service.evaluer(trackerAvec(9000));
      expect(alerte.niveau, NicheAlertLevel.approche);
      expect(alerte.titre, contains('bientot'));
      expect(alerte.message, contains('1000'));
    });

    test('a 95% : avertissement avec montant restant', () {
      final alerte = service.evaluer(trackerAvec(9500));
      expect(alerte.niveau, NicheAlertLevel.approche);
      expect(alerte.message, contains('500'));
      expect(
        alerte.recommandations.any((r) => r.contains('HORS plafond')),
        isTrue,
      );
    });

    test('depassement : alerte rouge avec le montant excede', () {
      final alerte = service.evaluer(trackerAvec(10500));
      expect(alerte.niveau, NicheAlertLevel.depasse);
      expect(alerte.montantDepassement, 500);
      expect(alerte.message, contains('500'));
      expect(alerte.message, contains('perdus'));
    });

    test('depassement : recommande de prioriser les forts impacts', () {
      final alerte = service.evaluer(trackerAvec(12000));
      expect(
        alerte.recommandations.any((r) => r.contains('fort impact')),
        isTrue,
      );
      expect(alerte.recommandations.any((r) => r.contains('PER')), isTrue);
    });

    test('plafond outre-mer 18 000 EUR respecte', () {
      final tracker = NicheCeilingTrackerModel(
        totalCeiling: 18000,
        usedCeiling: 12000,
      );
      final alerte = service.evaluer(tracker);
      expect(alerte.niveau, NicheAlertLevel.ok);
    });
  });

  group('NicheAlertService - suggestions hors plafond (Story 4.4)', () {
    test('propose PER, deficit foncier, Malraux et monuments historiques', () {
      final suggestions = service.suggererHorsPlafond(tmi: 0.30);
      final ids = suggestions.map((s) => s.id);
      expect(
        ids,
        containsAll([
          'per',
          'deficit_foncier',
          'malraux',
          'monuments_historiques',
        ]),
      );
    });

    test('classement par impact decroissant', () {
      final suggestions = service.suggererHorsPlafond(tmi: 0.30);
      for (var i = 0; i < suggestions.length - 1; i++) {
        expect(
          suggestions[i].economieEstimee,
          greaterThanOrEqualTo(suggestions[i + 1].economieEstimee),
        );
      }
    });

    test('chaque suggestion a un score de risque et une base legale', () {
      final suggestions = service.suggererHorsPlafond(tmi: 0.41);
      for (final s in suggestions) {
        expect(s.risqueScore, inInclusiveRange(1, 5), reason: s.id);
        expect(s.baseLegale, isNotEmpty, reason: s.id);
        expect(s.economieEstimee, greaterThan(0), reason: s.id);
      }
    });

    test('economie PER = 10% du revenu x TMI', () {
      final suggestions = service.suggererHorsPlafond(
        tmi: 0.30,
        revenuFiscalReference: 50000,
      );
      final per = suggestions.firstWhere((s) => s.id == 'per');
      // 5 000 x 30% = 1 500
      expect(per.economieEstimee, 1500);
    });

    test('economie deficit foncier = 10 700 x TMI', () {
      final suggestions = service.suggererHorsPlafond(tmi: 0.41);
      final deficit = suggestions.firstWhere((s) => s.id == 'deficit_foncier');
      expect(deficit.economieEstimee, closeTo(10700 * 0.41, 0.01));
    });

    test('TMI elevee augmente l\'economie estimee du PER', () {
      final faible = service.suggererHorsPlafond(tmi: 0.11);
      final forte = service.suggererHorsPlafond(tmi: 0.45);
      final perFaible = faible.firstWhere((s) => s.id == 'per');
      final perForte = forte.firstWhere((s) => s.id == 'per');
      expect(perForte.economieEstimee, greaterThan(perFaible.economieEstimee));
    });
  });
}
