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

    double decote = 0;
    final isCouple =
        foyer.situationFamiliale == SituationFamiliale.marie ||
        foyer.situationFamiliale == SituationFamiliale.pacse;

    if (impotBrut > 0) {
      final seuil = isCouple
          ? TaxBrackets2026.decoteCoupleThreshold
          : TaxBrackets2026.decoteSingleThreshold;
      final decoteCalculee =
          seuil - (impotBrut * TaxBrackets2026.decoteMultiplier);
      if (decoteCalculee > 0) {
        decote = decoteCalculee;
      }
    }

    final impotApresDecote = (impotBrut - decote).clamp(0, double.infinity);
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
    };
  }

  double calculerCehr(double revenuNetImposable, bool isCouple) {
    final seuil = isCouple ? 500000.0 : 250000.0;
    if (revenuNetImposable <= seuil) return 0;

    double cehr = 0;
    final excedant = revenuNetImposable - seuil;

    if (revenuNetImposable <= 500000) {
      cehr = excedant * 0.03;
    } else if (revenuNetImposable <= 1000000) {
      cehr = 7500 + (excedant - 250000) * 0.04;
    } else {
      cehr = 7500 + 10000 + (excedant - 500000) * 0.04;
    }

    return cehr;
  }

  double calculerDeduction10Pourcent(double revenuBrut) {
    final deduction = revenuBrut * 0.10;
    return deduction.clamp(0, TaxBrackets2026.nicheCeilingGeneral);
  }
}
