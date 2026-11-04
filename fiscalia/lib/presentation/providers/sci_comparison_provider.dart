import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/advanced_tax_config.dart';
import 'monitoring_providers.dart';
import '../../core/constants/tax_brackets.dart';
import '../../data/models/sci_comparison_model.dart';

final sciComparisonServiceProvider = Provider(
  (ref) => SciComparisonService(config: ref.watch(advancedTaxConfigProvider)),
);

final sciComparisonProvider = StateProvider<SciComparisonResult?>(
  (ref) => null,
);

/// Service de comparaison SCI IR vs IS (Story 8.3).
///
/// - SCI a l'IR (Art. 8 CGI) : transparence fiscale, les revenus fonciers
///   sont taxes a la TMI + 17.2% de PS entre les mains des associes. Le
///   deficit foncier s'impute sur le revenu global jusqu'a 10 700 EUR/an
///   (Art. 156 I 3 CGI).
/// - SCI a l'IS (Art. 206, 219 CGI) : amortissement du bien, IS a 15%
///   jusqu'a 42 500 EUR puis 25%, puis PFU de 30% sur les dividendes
///   distribues. Option en principe definitive.
class SciComparisonService {
  /// Configuration des dispositifs avances (distante si disponible,
  /// embarquee 2026 sinon).
  final AdvancedTaxConfig config;

  SciComparisonService({this.config = const AdvancedTaxConfig.embedded()});

  SciComparisonResult comparer(SciComparisonModel input) {
    final ir = _calculerRegimeIR(input);
    final is_ = _calculerRegimeIS(input);

    final recommande =
        ir.fiscaliteTotale <= is_.fiscaliteTotale ? 'IR' : 'IS';
    final avantage = (ir.fiscaliteTotale - is_.fiscaliteTotale).abs();

    final pointsVigilance = <String>[
      'L\'option pour l\'IS est en principe definitive : a la cession ou '
          'liquidation, les amortissements deduits sont reintegres dans la '
          'plus-value imposable (Art. 1655 ter CGI).',
      'A l\'IS, le report des deficits est limite a 1 M EUR par an '
          '(+ 50% du benefice au-dela).',
      'A l\'IR, le deficit foncier imputable sur le revenu global est '
          'plafonne a 10 700 EUR/an ; l\'excedent est reportable 10 ans sur '
          'les revenus fonciers.',
    ];
    if (recommande == 'IS' && input.tauxDistribution > 0) {
      pointsVigilance.add(
        'Distribuer des dividendes declenche le PFU de 30% : pour maximiser '
        'l\'avantage de l\'IS, conservez la tresorerie dans la SCI.',
      );
    }

    return SciComparisonResult(
      regimeIR: ir,
      regimeIS: is_,
      regimeRecommande: recommande,
      avantageAnnuel: avantage,
      pointsVigilance: pointsVigilance,
    );
  }

  SciRegimeResult _calculerRegimeIR(SciComparisonModel input) {
    // Revenu foncier net (pas d'amortissement a l'IR, seulement les charges).
    final revenuFoncierNet = input.loyersAnnuels - input.chargesAnnuelles;
    final baseImposable = revenuFoncierNet > 0 ? revenuFoncierNet : 0.0;
    final impot = baseImposable *
        (input.tmi + config.prelevementsSociaux);

    // Le deficit foncier s'impute sur le revenu global : economie a la TMI
    // (pas de prelevements sociaux sur le revenu global).
    const plafondDeficit = TaxBrackets2026.propertyDeficitCeiling;
    final deficitImputable = input.deficitFoncierAnnuel > plafondDeficit
        ? plafondDeficit
        : input.deficitFoncierAnnuel;
    final economieDeficit = deficitImputable * input.tmi;

    return SciRegimeResult(
      resultat: revenuFoncierNet,
      impotSurResultat: impot,
      fiscaliteDistribution: 0,
      economieDeficitFoncier: economieDeficit,
      fiscaliteTotale: impot - economieDeficit,
    );
  }

  SciRegimeResult _calculerRegimeIS(SciComparisonModel input) {
    final amortissement =
        input.dureeAmortissement > 0
            ? input.valeurAmortissable / input.dureeAmortissement
            : 0.0;
    final resultat =
        input.loyersAnnuels - input.chargesAnnuelles - amortissement;
    final baseImposable = resultat > 0 ? resultat : 0.0;

    // Bareme IS PME : 15% jusqu'a 42 500 EUR, 25% au-dela (Art. 219 CGI).
    final tranche15 = baseImposable > config.isReducedRateCeiling
        ? config.isReducedRateCeiling
        : baseImposable;
    final tranche25 = baseImposable - tranche15;
    final impotIS = tranche15 * config.isReducedRate +
        tranche25 * config.isNormalRate;

    // PFU 30% sur la part distribuee du resultat apres IS.
    final resultatApresIS = baseImposable - impotIS;
    final dividendes = resultatApresIS * input.tauxDistribution;
    final fiscaliteDistribution = dividendes * config.pfuDividendes;

    return SciRegimeResult(
      resultat: resultat,
      impotSurResultat: impotIS,
      fiscaliteDistribution: fiscaliteDistribution,
      economieDeficitFoncier: 0,
      fiscaliteTotale: impotIS + fiscaliteDistribution,
    );
  }
}
