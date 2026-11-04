import 'dart:convert';

import 'package:fiscalia/core/constants/tax_brackets.dart';
import 'package:fiscalia/core/services/monitoring_service.dart';
import 'package:fiscalia/core/services/tax_remote_config_service.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeRemoteConfigClient implements RemoteConfigClient {
  String valeur = '';
  bool throwOnFetch = false;
  bool defaultsSet = false;

  @override
  Future<void> setConfigSettings(
      {required Duration fetchTimeout,
      required Duration minimumFetchInterval}) async {}

  @override
  Future<void> setDefaults(Map<String, dynamic> defaults) async {
    defaultsSet = true;
  }

  @override
  Future<bool> fetchAndActivate() async {
    if (throwOnFetch) throw Exception('reseau indisponible');
    return true;
  }

  @override
  String getString(String key) => valeur;
}

void main() {
  group('TaxConfig', () {
    test('la configuration embarquee reprend les baremes 2026', () {
      final config = TaxConfig.embedded();
      expect(config.taxYear, 2026);
      expect(config.brackets.length, TaxBrackets2026.ir2026.length);
      expect(config.nicheCeilingGeneral, 10000);
      expect(config.nicheCeilingOverseas, 18000);
    });

    test('fromJson parse des baremes distants complets', () {
      final json = {
        'taxYear': 2027,
        'brackets': [
          {'minIncome': 0, 'maxIncome': 12000, 'rate': 0},
          {'minIncome': 12001, 'maxIncome': 0, 'rate': 0.11},
        ],
        'nicheCeilingGeneral': 11000,
      };
      final config = TaxConfig.fromJson(json);
      expect(config.taxYear, 2027);
      expect(config.brackets.length, 2);
      expect(config.brackets[1].maxIncome, double.infinity);
      expect(config.nicheCeilingGeneral, 11000);
      // Les champs absents conservent les valeurs embarquees
      expect(config.perAnnualCeiling, TaxBrackets2026.perAnnualCeiling);
    });

    test('fromJson refuse des baremes vides', () {
      expect(() => TaxConfig.fromJson({'brackets': []}),
          throwsFormatException);
    });

    test('toJson/fromJson est un aller-retour exact', () {
      final original = TaxConfig.embedded();
      final clone = TaxConfig.fromJson(original.toJson());
      expect(clone.taxYear, original.taxYear);
      expect(clone.brackets.length, original.brackets.length);
      expect(clone.brackets.last.maxIncome, double.infinity);
      expect(clone.propertyDeficitCeiling, original.propertyDeficitCeiling);
    });
  });

  group('TaxRemoteConfigService', () {
    test('sans client, retourne toujours la config embarquee', () async {
      final service = TaxRemoteConfigService();
      expect(await service.actualiser(), isFalse);
      expect(service.current.taxYear, 2026);
    });

    test('applique la config distante apres actualisation', () async {
      final client = FakeRemoteConfigClient();
      client.valeur = jsonEncode({
        'taxYear': 2027,
        'brackets': [
          {'minIncome': 0, 'maxIncome': 12000, 'rate': 0},
        ],
        'donation75Ceiling': 1500,
      });
      final service = TaxRemoteConfigService(client: client);
      await service.initialiser();
      expect(client.defaultsSet, isTrue);

      final maj = await service.actualiser();
      expect(maj, isTrue);
      expect(service.current.taxYear, 2027);
      expect(service.current.donation75Ceiling, 1500);
    });

    test('fallback embarque si le fetch echoue', () async {
      final client = FakeRemoteConfigClient()..throwOnFetch = true;
      final service = TaxRemoteConfigService(client: client);
      final maj = await service.actualiser();
      expect(maj, isFalse);
      expect(service.current.taxYear, 2026);
    });

    test('fallback embarque si le JSON distant est invalide', () async {
      final client = FakeRemoteConfigClient()..valeur = '{casse';
      final service = TaxRemoteConfigService(client: client);
      final maj = await service.actualiser();
      expect(maj, isFalse);
      expect(service.current.taxYear, 2026);
    });

    test('fallback embarque si la cle distante est vide', () async {
      final client = FakeRemoteConfigClient();
      final service = TaxRemoteConfigService(client: client);
      expect(await service.actualiser(), isFalse);
      expect(service.current.taxYear, 2026);
    });
  });

  group('MonitoringService', () {
    test('inactif par defaut : les appels sont sans effet', () async {
      final service = MonitoringService();
      expect(service.estActif, isFalse);
      expect(service.observateurNavigation(), isNull);
      // Ne doit pas lever d'exception
      service.enregistrerErreur(Exception('test'), StackTrace.current);
      await service.journaliserEvenement('test_event');
      await service.definirIdentifiantUtilisateur('user-1');
    });
  });
}
