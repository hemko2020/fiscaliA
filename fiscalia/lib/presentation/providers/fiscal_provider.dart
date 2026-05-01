import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/tax_brackets.dart';
import '../../data/models/foyer_fiscal_model.dart';

final taxCalculatorProvider = Provider((ref) => TaxCalculator());

class TaxCalculator {
  Map<String, dynamic> calculerImpot(FoyerFiscalModel foyer) {
    final parts = foyer.partsFiscales;
    final revenuQuotiente = foyer.revenuNetImposable / parts;

    double impotBrut = 0;
    final detailsParTranche = <int, double>{};
    double tauxMarginal = 0;

    for (int i = 0; i < TaxBrackets2026.ir2026.length; i++) {
      final tranche = TaxBrackets2026.ir2026[i];
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

    // Apply family quotient ceiling (plafond du quotient familial)
    final halfParts =
        parts -
        (foyer.situationFamiliale == SituationFamiliale.marie ||
                foyer.situationFamiliale == SituationFamiliale.pacse
            ? 2
            : 1);
    final plafondQuotientFamilial =
        halfParts * TaxBrackets2026.familyQuotientCeiling;

    double impotApresPlafond = impotBrut;
    double reductionQuotientFamilial = 0;
    if (impotBrut > 0 && parts > 1) {
      // The quotient familial reduction cannot exceed 1,807€ per half-part
      reductionQuotientFamilial = (impotBrut - (revenuQuotiente * parts)).abs();
      if (reductionQuotientFamilial > plafondQuotientFamilial) {
        reductionQuotientFamilial = plafondQuotientFamilial;
        impotApresPlafond = impotBrut - reductionQuotientFamilial;
      }
    }

    double decote = 0;
    final isCouple =
        foyer.situationFamiliale == SituationFamiliale.marie ||
        foyer.situationFamiliale == SituationFamiliale.pacse;

    if (impotApresPlafond > 0) {
      final seuil = isCouple
          ? TaxBrackets2026.decoteCoupleThreshold
          : TaxBrackets2026.decoteSingleThreshold;
      final decoteCalculee =
          seuil - (impotApresPlafond * TaxBrackets2026.decoteMultiplier);
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
    return res['taux_marginal'] ?? 0.0;
  }
}
