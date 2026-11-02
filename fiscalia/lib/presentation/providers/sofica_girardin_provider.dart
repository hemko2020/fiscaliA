import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/advanced_tax_constants.dart';
import '../../data/models/sofica_girardin_model.dart';

final soficaGirardinServiceProvider = Provider(
  (ref) => SoficaGirardinService(),
);

final soficaGirardinProvider = StateProvider<SoficaGirardinResult?>(
  (ref) => null,
);

/// Service de calcul SOFICA et Girardin industriel (Story 8.7).
///
/// - SOFICA (Art. 199 unvicies CGI) : reduction de 30% (48% si conditions
///   renforcees) des souscriptions en numeraire, plafond d'investissement
///   de 18 000 EUR, parts conservees au moins 5 ans. Entre dans le plafond
///   specifique de 18 000 EUR.
/// - Girardin industriel (Art. 199 undecies B CGI) : reduction one-shot
///   superieure a l'investissement (typiquement 110% avec agreement),
///   imputee integralement en une fois. Entre dans le plafond de 18 000 EUR.
class SoficaGirardinService {
  SoficaGirardinResult calculer(SoficaGirardinModel input) {
    // --- SOFICA ---
    final baseSofica = input.investissementSofica >
            AdvancedTaxConstants.soficaPlafondInvestissement
        ? AdvancedTaxConstants.soficaPlafondInvestissement
        : input.investissementSofica;
    final tauxSofica = input.soficaTauxMajore
        ? AdvancedTaxConstants.soficaTauxMajore
        : AdvancedTaxConstants.soficaTauxStandard;
    final reductionSofica = baseSofica * tauxSofica;

    // --- Girardin industriel ---
    // La reduction est calculee sur l'investissement x rendement promis
    // par l'operateur (mecanisme one-shot).
    final reductionGirardin =
        input.investissementGirardin * input.rendementGirardin;
    final gainNet = reductionGirardin - input.investissementGirardin;

    // --- Imputabilite ---
    // Les deux reductions s'imputent sur l'impot de l'annee. La SOFICA
    // est reportable 5 ans ; l'excedent Girardin est en pratique perdu
    // (sauf cas particuliers), d'ou l'importance de calibrer.
    final totale = reductionSofica + reductionGirardin;
    final imputable = totale > input.impotAvantReductions
        ? input.impotAvantReductions
        : totale;
    final nonImputable = totale - imputable;

    final avertissements = <String>[
      'Risque 4/5 : ces dispositifs relevent du plafond specifique de '
          '18 000 EUR (plafond global 10 000 EUR + 8 000 EUR).',
      'Girardin : la reduction one-shot est perdue si elle depasse votre '
          'impot - calibrez precisement l\'investissement.',
      'Girardin : choisissez un operateur solide - en cas de defaillance, '
          'la reprise de la reduction est possible. Exigez l\'agrement '
          'prealable du ministere de l\'Economie.',
      'SOFICA : blocage des parts 5 ans minimum, liquidite nulle, rendement '
          'du fonds incertain - c\'est d\'abord un investissement dans le '
          'cinema.',
    ];
    if (nonImputable > 0) {
      avertissements.add(
        '${nonImputable.toStringAsFixed(0)} EUR de reductions depassent '
        'votre impot : seule la part SOFICA est reportable 5 ans.',
      );
    }

    return SoficaGirardinResult(
      reductionSofica: reductionSofica,
      reductionGirardin: reductionGirardin,
      reductionImputable: imputable,
      reductionNonImputable: nonImputable,
      gainNetGirardin: gainNet,
      risqueScore: 4,
      avertissements: avertissements,
    );
  }
}
