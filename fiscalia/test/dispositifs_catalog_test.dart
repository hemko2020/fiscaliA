import 'package:flutter_test/flutter_test.dart';
import 'package:fiscalia/agents/catalogs/dispositifs_fiscaux_catalog.dart';
import 'package:fiscalia/data/models/dispositif_model.dart';

void main() {
  group('DispositifsFiscauxCatalog', () {
    test('contient au moins 25 leviers fiscaux (FR35)', () {
      expect(
        DispositifsFiscauxCatalog.dispositifs.length,
        greaterThanOrEqualTo(25),
      );
    });

    test('couvre les 3 categories basique / avance / expert', () {
      final categories =
          DispositifsFiscauxCatalog.dispositifs.map((d) => d.categorie).toSet();
      expect(categories, containsAll(CategorieDispositif.values));
    });

    test('chaque dispositif a une base legale et un score de risque', () {
      for (final d in DispositifsFiscauxCatalog.dispositifs) {
        expect(d.baseLegale, isNotEmpty, reason: d.id);
        expect(d.risqueScore, inInclusiveRange(1, 5), reason: d.id);
        expect(d.nom, isNotEmpty, reason: d.id);
      }
    });

    test('les identifiants sont uniques', () {
      final ids =
          DispositifsFiscauxCatalog.dispositifs.map((d) => d.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('les dispositifs hors plafond sont correctement marques', () {
      final horsPlafond = DispositifsFiscauxCatalog.dispositifs
          .where((d) => d.horsNicheFiscale)
          .map((d) => d.id);
      expect(horsPlafond, containsAll(['per', 'deficit_foncier', 'malraux']));
    });
  });
}
