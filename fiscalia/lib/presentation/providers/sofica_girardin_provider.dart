import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/advanced_tax_config.dart';
import 'monitoring_providers.dart';
import '../../data/models/sofica_girardin_model.dart';

final soficaGirardinServiceProvider = Provider(
  (ref) => SoficaGirardinService(config: ref.watch(advancedTaxConfigProvider)),
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
  /// Configuration des dispositifs avances (distante si disponible,
  /// embarquee 2026 sinon).
  final AdvancedTaxConfig config;

  SoficaGirardinService({this.config = const AdvancedTaxConfig.embedded()});

  SoficaGirardinResult calculer(SoficaGirardinModel input) {
    // --- SOFICA ---
    final baseSofica = input.investissementSofica >
            config.soficaPlafondInvestissement
        ? config.soficaPlafondInvestissement
        : input.investissementSofica;
    final tauxSofica = input.soficaTauxMajore
        ? config.soficaTauxMajore
        : config.soficaTauxStandard;
    final reductionSofica = baseSofica * tauxSofica;

    // --- Girardin industriel ---
    // La reduction est calculee sur l'investissement x rendement promis
    // par l'operateur (mecanisme one-shot).
    final reductionGirardin =
        input.investissementGirardin * input.rendementGirardin;
    final gainNet = reductionGirardin - input.investissementGirardin;

    // --- Imputabilite ---
    // Les deux reductions s'imputent sur l'impot de l'annee. Contrairement
    // aux dons, l'excedent (reduction > impot) n'est NI reportable NI
    // remboursable pour la SOFICA comme pour le Girardin : il est perdu.
    final totale = reductionSofica + reductionGirardin;
    final imputable = totale > input.impotAvantReductions
        ? input.impotAvantReductions
        : totale;
    final nonImputable = totale - imputable;

    final avertissements = <String>[
      'Risque 4/5 : ces dispositifs relevent du plafond specifique de '
          '18 000 EUR (plafond global 10 000 EUR + 8 000 EUR).',
      'L\'excedent de reduction au-dela de votre impot est PERDU (ni '
          'reportable, ni remboursable, contrairement aux dons) : calibrez '
          'precisement l\'investissement.',
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
        'votre impot et seront definitivement perdus.',
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
