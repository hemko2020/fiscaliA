import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/tax_remote_config_service.dart';
import '../../data/models/foyer_fiscal_model.dart';
import 'monitoring_providers.dart';

/// Moteur de calcul alimente par la configuration fiscale courante :
/// barèmes distants (Remote Config) si disponibles, embarques sinon.
final taxCalculatorProvider = Provider(
  (ref) => TaxCalculator(config: ref.watch(taxConfigProvider)),
);

class TaxCalculator {
  /// Configuration fiscale utilisee pour tous les calculs.
  /// Par defaut : les barèmes embarques 2026.
  final TaxConfig config;

  TaxCalculator({this.config = const TaxConfig.embedded()});
  /// Calcule l'impot brut progressif pour un revenu et un nombre de parts
  /// donnes (application du bareme par tranches au quotient R/parts, puis
  /// multiplication par le nombre de parts).
  /// Retourne aussi le detail par tranche et le taux marginal.
  Map<String, dynamic> _calculerProgressif(double revenu, double parts) {
    final revenuQuotiente = revenu / parts;

    double impotBrut = 0;
    final detailsParTranche = <int, double>{};
    double tauxMarginal = 0;

    for (int i = 0; i < config.brackets.length; i++) {
      final tranche = config.brackets[i];
      double montantDansTranche = 0;

      if (revenuQuotiente > tranche.minIncome) {
        if (revenuQuotiente >= tranche.maxIncome) {
          montantDansTranche = tranche.maxIncome - tranche.minIncome;
        } else {
          montantDansTranche = revenuQuotiente - tranche.minIncome;
        }
        montantDansTranche = montantDansTranche.clamp(0, double.infinity);
      }

      final impotTranche = montantDansTranche * tranche.rate;
      impotBrut += impotTranche;
      detailsParTranche[i] = impotTranche * parts;

      if (montantDansTranche > 0) {
        tauxMarginal = tranche.rate;
      }
    }

    impotBrut *= parts;

    return {
      'impotBrut': impotBrut,
      'detailsParTranche': detailsParTranche,
      'tauxMarginal': tauxMarginal,
    };
  }

  Map<String, dynamic> calculerImpot(FoyerFiscalModel foyer) {
    final parts = foyer.partsFiscales;
    final isCouple =
        foyer.situationFamiliale == SituationFamiliale.marie ||
        foyer.situationFamiliale == SituationFamiliale.pacse;

    final progressif = _calculerProgressif(foyer.revenuNetImposable, parts);
    final impotBrut = progressif['impotBrut'] as double;
    final detailsParTranche =
        progressif['detailsParTranche'] as Map<int, double>;
    final tauxMarginal = progressif['tauxMarginal'] as double;

    // Plafonnement du quotient familial (BOFiP BOI-IR-LIQ-10) :
    // l'avantage procure par les demi-parts supplementaires est plafonne.
    // 1. I_QF  = impot avec les parts reelles
    // 2. I_ref = impot avec 1 part (celibataire) ou 2 parts (couple)
    // 3. Si I_ref - I_QF > plafond, l'impot du est I_ref - plafond.
    final partsReference = isCouple ? 2.0 : 1.0;
    final demiPartsSupplementaires = (parts - partsReference) * 2;

    double plafondQuotientFamilial = 0;
    if (demiPartsSupplementaires > 0) {
      if (foyer.parentIsole && !isCouple && foyer.nbEnfants > 0) {
        // Parent isole : la part entiere du 1er enfant a un plafond
        // specifique, les demi-parts suivantes le plafond classique.
        plafondQuotientFamilial =
            config.parentIsoleQuotientCeiling +
            (demiPartsSupplementaires - 2) *
                config.familyQuotientCeiling;
      } else {
        plafondQuotientFamilial =
            demiPartsSupplementaires * config.familyQuotientCeiling;
      }
    }

    double impotApresPlafond = impotBrut;
    double reductionQuotientFamilial = 0;
    if (impotBrut > 0 && demiPartsSupplementaires > 0) {
      final impotReference = _calculerProgressif(
        foyer.revenuNetImposable,
        partsReference,
      )['impotBrut'] as double;
      final avantage = impotReference - impotBrut;
      reductionQuotientFamilial = avantage > plafondQuotientFamilial
          ? plafondQuotientFamilial
          : avantage;
      impotApresPlafond = impotReference - reductionQuotientFamilial;
    }

    double decote = 0;
    if (impotApresPlafond > 0) {
      final seuil = isCouple
          ? config.decoteCoupleThreshold
          : config.decoteSingleThreshold;
      final decoteCalculee =
          seuil - (impotApresPlafond * config.decoteMultiplier);
      if (decoteCalculee > 0) {
        decote = decoteCalculee;
      }
    }

    final impotApresDecote = (impotApresPlafond - decote).clamp(
      0,
      double.infinity,
    );
    final impotNet = impotApresDecote;
    final tauxMoyen = foyer.revenuNetImposable > 0
        ? impotNet / foyer.revenuNetImposable
        : 0;

    return {
      'impotBrut': impotBrut,
      'decote': decote,
      'impotNet': impotNet,
      'impotApresPlafond': impotApresPlafond,
      'tauxMarginal': tauxMarginal,
      'tauxMoyen': tauxMoyen,
      'parts': parts,
      'detailsParTranche': detailsParTranche,
      'reductionQuotientFamilial': reductionQuotientFamilial,
      'plafondQuotientFamilial': plafondQuotientFamilial,
    };
  }

  double calculerCehr(double revenuNetImposable, bool isCouple) {
    final seuil = isCouple ? 500000.0 : 250000.0;
    if (revenuNetImposable <= seuil) return 0;

    double cehr = 0;

    if (isCouple) {
      // For couples: 3% from 500K to 1M, 4% above 1M
      if (revenuNetImposable <= 1000000) {
        cehr = (revenuNetImposable - seuil) * 0.03;
      } else {
        cehr = 15000 + (revenuNetImposable - 1000000) * 0.04;
      }
    } else {
      // For single: 3% from 250K to 500K, 4% above 500K
      if (revenuNetImposable <= 500000) {
        cehr = (revenuNetImposable - seuil) * 0.03;
      } else {
        cehr = 7500 + (revenuNetImposable - 500000) * 0.04;
      }
    }

    return cehr;
  }

  double calculerDeduction10Pourcent(double revenuBrut) {
    final deduction = revenuBrut * 0.10;
    return deduction.clamp(0, 14556); // 2026 ceiling for 10% deduction
  }

  Map<String, dynamic> comparerDepensesReellesVs10Pourcent({
    required double revenuBrut,
    required double depensesReelles,
  }) {
    final deduction10 = calculerDeduction10Pourcent(revenuBrut);
    final depensesReellesDeductibles = depensesReelles.clamp(0, revenuBrut);

    final meilleurOption = depensesReellesDeductibles > deduction10
        ? 'reelles'
        : 'forfait';
    final economie = (depensesReellesDeductibles - deduction10).abs();

    return {
      'deduction10Pourcent': deduction10,
      'depensesReelles': depensesReellesDeductibles,
      'meilleurOption': meilleurOption,
      'economie': economie,
      'revenuBrut': revenuBrut,
    };
  }

  Map<String, dynamic> calculerImpotComplet(
    FoyerFiscalModel foyer, {
    double depensesReelles = 0,
    bool useRealExpenses = false,
  }) {
    final result = calculerImpot(foyer);
    final isCouple =
        foyer.situationFamiliale == SituationFamiliale.marie ||
        foyer.situationFamiliale == SituationFamiliale.pacse;

    // Calculate CEHR
    final cehr = calculerCehr(foyer.revenuNetImposable, isCouple);

    // Calculate expenses comparison
    final revenuBrut =
        foyer.revenuNetImposable * 1.25; // Approximate gross from net
    final expensesComparison = comparerDepensesReellesVs10Pourcent(
      revenuBrut: revenuBrut,
      depensesReelles: depensesReelles,
    );

    double impotNet = result['impotNet'] as double;
    double impotApresDeduction = impotNet;

    // Apply better expense option if selected
    if (useRealExpenses && depensesReelles > 0) {
      final deduction =
          (expensesComparison['meilleurOption'] as String) == 'reelles'
          ? depensesReelles
          : expensesComparison['deduction10Pourcent'] as double;
      impotApresDeduction = (impotNet - deduction).clamp(0, double.infinity);
    }

    return {
      ...result,
      'cehr': cehr,
      'impotTotal': impotApresDeduction + cehr,
      'impotApresDeduction': impotApresDeduction,
      'expensesComparison': expensesComparison,
    };
  }

  List<Map<String, dynamic>> getDetailsParTrancheLisible(
    Map<int, double> detailsParTranche,
    double parts,
  ) {
    final labels = ['0%', '11%', '30%', '41%', '45%'];
    final colors = [0xFF27AE60, 0xFF2ECC71, 0xFFF1C40F, 0xFFE67E22, 0xFFE74C3C];
    final result = <Map<String, dynamic>>[];

    for (int i = 0; i < 5; i++) {
      final montant = detailsParTranche[i] ?? 0;
      if (montant > 0) {
        result.add({
          'tranche': labels[i],
          'montant': montant,
          'couleur': colors[i],
        });
      }
    }

    return result;
  }

  double getTMI(FoyerFiscalModel foyer) {
    final res = calculerImpot(foyer);
    return (res['tauxMarginal'] as num?)?.toDouble() ?? 0.0;
  }
}
