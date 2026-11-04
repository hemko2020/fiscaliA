import 'dart:convert';
import 'dart:io';

import 'package:fiscalia/core/services/advanced_tax_config.dart';
import 'package:fiscalia/core/services/fiscal_knowledge_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FiscalKnowledgeService service;

  setUpAll(() {
    // Charge les vrais fichiers de la base depuis le disque (tests).
    service = FiscalKnowledgeService();
    for (final f in [
      'assets/knowledge/cgi_articles.json',
      'assets/knowledge/bofip_instructions.json',
      'assets/knowledge/jurisprudence.json',
    ]) {
      service.chargerDepuisJson(File(f).readAsStringSync());
    }
  });

  group('Base de connaissance - contenu', () {
    test('charge au moins 30 documents des 3 sources', () {
      expect(service.nombreDocuments, greaterThanOrEqualTo(30));
      final sources = service.documents.map((d) => d.source).toSet();
      expect(sources.length, 3);
    });

    test('les fichiers JSON sont bien formes avec champs requis', () {
      for (final f in [
        'assets/knowledge/cgi_articles.json',
        'assets/knowledge/bofip_instructions.json',
        'assets/knowledge/jurisprudence.json',
      ]) {
        final decoded =
            jsonDecode(File(f).readAsStringSync()) as Map<String, dynamic>;
        expect(decoded['version'], isNotNull);
        for (final doc in decoded['documents'] as List<dynamic>) {
          final d = doc as Map<String, dynamic>;
          expect(d['id'], isNotEmpty);
          expect(d['reference'], isNotEmpty);
          expect(d['titre'], isNotEmpty);
          expect(d['texte'], isNotEmpty);
          expect((d['mots_cles'] as List).length, greaterThanOrEqualTo(3));
        }
      }
    });
  });

  group('Recherche (retrieval)', () {
    test('retrouve le plafond des niches pour une question en langage naturel',
        () {
      final resultats =
          service.rechercher('Quel est le plafond des niches fiscales ?');
      expect(resultats, isNotEmpty);
      expect(resultats.first.document.reference, contains('200-0 A'));
    });

    test('retrouve le PER pour une question sur la retraite', () {
      final resultats = service
          .rechercher('Comment deduire mes versements retraite PER ?');
      expect(resultats, isNotEmpty);
      expect(resultats.first.document.reference,
          contains('163 quatervicies'));
    });

    test('retrouve la jurisprudence abus de droit', () {
      final resultats =
          service.rechercher('risque abus de droit montage fictif');
      expect(resultats, isNotEmpty);
      expect(resultats.first.document.source, contains('Jurisprudence'));
    });

    test('les resultats sont tries par score decroissant', () {
      final resultats = service.rechercher('ifi dons reduction');
      for (var i = 0; i + 1 < resultats.length; i++) {
        expect(resultats[i].score,
            greaterThanOrEqualTo(resultats[i + 1].score));
      }
    });

    test('insensible aux accents et a la casse', () {
      final avecAccents = service.rechercher('déduction déficit foncier');
      final sansAccents = service.rechercher('deduction deficit foncier');
      expect(avecAccents.first.document.id, sansAccents.first.document.id);
    });

    test('requete vide ou hors sujet : pas de resultat', () {
      expect(service.rechercher('le la les'), isEmpty);
      expect(service.rechercher('astronomie telescope galaxie'), isEmpty);
    });

    test('maxResultats est respecte', () {
      final resultats = service.rechercher('impot reduction', maxResultats: 2);
      expect(resultats.length, lessThanOrEqualTo(2));
    });
  });

  group('formatContexte (injection prompt)', () {
    test('produit un bloc de contexte avec references legales', () {
      final contexte = service.formatContexte('plafond niches fiscales');
      expect(contexte, contains('Textes applicables'));
      expect(contexte, contains('Art.'));
    });

    test('message explicite si rien trouve', () {
      final contexte = service.formatContexte('xyzzy');
      expect(contexte, contains('Aucun texte'));
    });
  });

  group('AdvancedTaxConfig', () {
    test('embedded reprend les valeurs 2026', () {
      const config = AdvancedTaxConfig.embedded();
      expect(config.perAnnualCeiling, 37094);
      expect(config.ifiSeuilImposition, 1300000);
      expect(config.usufruitRatioPourAge(45), 0.60);
      expect(config.usufruitRatioPourAge(70), 0.40);
      expect(config.usufruitRatioPourAge(95), 0.10);
    });

    test('toJson/fromJson est un aller-retour exact', () {
      const original = AdvancedTaxConfig.embedded();
      final clone = AdvancedTaxConfig.fromJson(original.toJson());
      expect(clone.perAnnualCeiling, original.perAnnualCeiling);
      expect(clone.baremeIFI.length, original.baremeIFI.length);
      expect(clone.baremeIFI.last.$1, double.infinity);
      expect(clone.baremeLigneDirecte.last.$2, 0.45);
      expect(clone.usufruitBareme.length, original.usufruitBareme.length);
      expect(clone.usufruitRatioPourAge(45), 0.60);
    });

    test('les champs absents conservent les valeurs embarquees', () {
      final config = AdvancedTaxConfig.fromJson({'perAnnualCeiling': 40000});
      expect(config.perAnnualCeiling, 40000);
      expect(config.ifiSeuilImposition, 1300000);
    });
  });
}
