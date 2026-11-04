import 'package:flutter_test/flutter_test.dart';
import 'package:fiscalia/presentation/providers/fiscal_provider.dart';
import 'package:fiscalia/data/models/foyer_fiscal_model.dart';
import 'package:fiscalia/core/constants/tax_brackets.dart';

void main() {
  late TaxCalculator calculator;

  setUp(() {
    calculator = TaxCalculator();
  });

  group('TaxCalculator - Story 2.1: Tax Bracket Calculator', () {
    test('should calculate tax correctly for 42,000€ single person', () {
      final foyer = FoyerFiscalModel(
        situationFamiliale: SituationFamiliale.celibataire,
        nbEnfants: 0,
        revenuNetImposable: 42000,
      );

      final result = calculator.calculerImpot(foyer);

      // Expected from spec:
      // Tranche 1 (0%): 0€
      // Tranche 2 (11%): (29,579 - 11,600) × 11% = 1,977.69€
      // Tranche 3 (30%): (42,000 - 29,580) × 30% = 3,726€
      // Total: 5,703.69€

      expect(result['tauxMarginal'], 0.30);
      expect(result['parts'], 1.0);

      // Check bracket details
      final details = result['detailsParTranche'] as Map<int, double>;
      expect(details[0], closeTo(0, 0.01)); // 0% bracket
      expect(details[1], closeTo(1977.69, 1)); // 11% bracket
      expect(details[2], closeTo(3726, 1)); // 30% bracket
    });

    test('should calculate tax for 85,000€ with correct marginal rate 41%', () {
      final foyer = FoyerFiscalModel(
        situationFamiliale: SituationFamiliale.celibataire,
        nbEnfants: 0,
        revenuNetImposable: 85000,
      );

      final result = calculator.calculerImpot(foyer);

      expect(result['tauxMarginal'], 0.41);
    });

    test(
      'should calculate tax for 200,000€ with correct marginal rate 45%',
      () {
        final foyer = FoyerFiscalModel(
          situationFamiliale: SituationFamiliale.celibataire,
          nbEnfants: 0,
          revenuNetImposable: 200000,
        );

        final result = calculator.calculerImpot(foyer);

        expect(result['tauxMarginal'], 0.45);
      },
    );

    test('getTMI should return marginal rate', () {
      final foyer = FoyerFiscalModel(
        situationFamiliale: SituationFamiliale.celibataire,
        nbEnfants: 0,
        revenuNetImposable: 42000,
      );

      // Regression test : la cle interne est 'tauxMarginal'
      expect(calculator.getTMI(foyer), 0.30);
    });

    test('should handle 0€ income correctly', () {
      final foyer = FoyerFiscalModel(
        situationFamiliale: SituationFamiliale.celibataire,
        nbEnfants: 0,
        revenuNetImposable: 0,
      );

      final result = calculator.calculerImpot(foyer);

      expect(result['impotBrut'], 0);
      expect(result['impotNet'], 0);
      expect(result['tauxMoyen'], 0);
    });

    test('should handle income below first bracket threshold', () {
      final foyer = FoyerFiscalModel(
        situationFamiliale: SituationFamiliale.celibataire,
        nbEnfants: 0,
        revenuNetImposable: 10000,
      );

      final result = calculator.calculerImpot(foyer);

      expect(result['impotBrut'], 0);
      expect(result['tauxMarginal'], 0);
    });
  });

  group('TaxCalculator - Story 2.2: Family Quotient System', () {
    test(
      'should calculate parts correctly for married couple with 2 children',
      () {
        final foyer = FoyerFiscalModel(
          situationFamiliale: SituationFamiliale.marie,
          nbEnfants: 2,
          revenuNetImposable: 95000,
        );

        // Base: 2 parts (married) + 0.5 per child = 1 part (2 children) = 3 parts total
        expect(foyer.partsFiscales, 3.0);

        final result = calculator.calculerImpot(foyer);

        // Tax calculated on 95000/3 = 31667€ then multiplied by 3
        expect(result['parts'], 3.0);
      },
    );

    test('should calculate parts correctly for single with 1 child', () {
      final foyer = FoyerFiscalModel(
        situationFamiliale: SituationFamiliale.celibataire,
        nbEnfants: 1,
        revenuNetImposable: 50000,
      );

      // Base: 1 part + 0.5 per child = 1.5 parts
      expect(foyer.partsFiscales, 1.5);
    });

    test('should calculate parts correctly for single with 3 children', () {
      final foyer = FoyerFiscalModel(
        situationFamiliale: SituationFamiliale.celibataire,
        nbEnfants: 3,
        revenuNetImposable: 60000,
      );

      // CGI art. 194 : 1er et 2e enfant = 0,5 part chacun, 3e enfant = 1 part
      // Base: 1 part + 0.5 + 0.5 + 1.0 = 3.0 parts
      expect(foyer.partsFiscales, 3.0);
    });

    test('should calculate parts for married couple with 3 children', () {
      final foyer = FoyerFiscalModel(
        situationFamiliale: SituationFamiliale.marie,
        nbEnfants: 3,
        revenuNetImposable: 80000,
      );

      // Base: 2 parts + 0.5 + 0.5 + 1.0 = 4.0 parts
      expect(foyer.partsFiscales, 4.0);
    });

    test('should compute full part for first child of single parent', () {
      final foyer = FoyerFiscalModel(
        situationFamiliale: SituationFamiliale.celibataire,
        nbEnfants: 1,
        revenuNetImposable: 50000,
        parentIsole: true,
      );

      // CGI art. 195 / BOI-IR-LIQ-10-20 : parent isole (case T) :
      // le 1er enfant donne droit a 1 part entiere
      // Base: 1 part + 1 part = 2.0 parts
      expect(foyer.partsFiscales, 2.0);
    });

    test('should compute parts for single parent with 3 children', () {
      final foyer = FoyerFiscalModel(
        situationFamiliale: SituationFamiliale.divorce,
        nbEnfants: 3,
        revenuNetImposable: 60000,
        parentIsole: true,
      );

      // 1 part (base) + 1 part (1er enfant) + 0.5 (2e) + 1.0 (3e) = 3.5
      expect(foyer.partsFiscales, 3.5);
    });

    test('should NOT cap family quotient when advantage is below ceiling', () {
      // Couple marie, 2 enfants (3 parts), 60 000 EUR
      final foyer = FoyerFiscalModel(
        situationFamiliale: SituationFamiliale.marie,
        nbEnfants: 2,
        revenuNetImposable: 60000,
      );

      final result = calculator.calculerImpot(foyer);

      // I_QF : 20 000/part -> 924 EUR/part -> 2 772 EUR
      expect(result['impotBrut'], closeTo(2772, 1));
      // I_ref (2 parts) : 30 000/part -> 2 103.58 EUR/part -> 4 207.16 EUR
      // Avantage = 4 207.16 - 2 772 = 1 435.16 < plafond (2 x 1 807)
      expect(result['reductionQuotientFamilial'], closeTo(1435.16, 0.5));
      // Pas de plafonnement : impot apres plafond = I_QF
      expect(result['impotApresPlafond'], closeTo(2772, 1));
    });

    test('should cap family quotient when advantage exceeds ceiling', () {
      // Couple marie, 2 enfants (3 parts), 150 000 EUR
      final foyer = FoyerFiscalModel(
        situationFamiliale: SituationFamiliale.marie,
        nbEnfants: 2,
        revenuNetImposable: 150000,
      );

      final result = calculator.calculerImpot(foyer);

      // I_QF : 50 000/part -> 8 103.58 EUR/part -> 24 310.74 EUR
      expect(result['impotBrut'], closeTo(24310.74, 1));
      // Plafond = 2 demi-parts x 1 807 = 3 614 EUR
      expect(result['plafondQuotientFamilial'], 3614);
      // I_ref (2 parts) : 75 000/part -> 15 603.58 EUR/part -> 31 207.16 EUR
      // Avantage = 6 896.42 > 3 614 -> plafonne
      expect(result['reductionQuotientFamilial'], 3614);
      // Impot apres plafond = I_ref - plafond = 31 207.16 - 3 614
      expect(result['impotApresPlafond'], closeTo(27593.16, 1));
    });

    test('should cap family quotient for single with 1 child', () {
      // Celibataire, 1 enfant (1.5 parts), 50 000 EUR
      final foyer = FoyerFiscalModel(
        situationFamiliale: SituationFamiliale.celibataire,
        nbEnfants: 1,
        revenuNetImposable: 50000,
      );

      final result = calculator.calculerImpot(foyer);

      // Plafond = 1 demi-part x 1 807 = 1 807 EUR
      expect(result['plafondQuotientFamilial'], 1807);
      // I_ref (1 part) = 8 103.58 ; I_QF = 4 655.37
      // Avantage = 3 448.21 > 1 807 -> plafonne
      expect(result['reductionQuotientFamilial'], 1807);
      // Impot apres plafond = 8 103.58 - 1 807 = 6 296.58
      expect(result['impotApresPlafond'], closeTo(6296.58, 1));
    });

    test('should apply specific ceiling for single parent first child', () {
      // Celibataire parent isole, 1 enfant (2 parts), 50 000 EUR
      final foyer = FoyerFiscalModel(
        situationFamiliale: SituationFamiliale.celibataire,
        nbEnfants: 1,
        revenuNetImposable: 50000,
        parentIsole: true,
      );

      final result = calculator.calculerImpot(foyer);

      // Plafond specifique parent isole : 4 262 EUR (part entiere 1er enfant)
      expect(result['plafondQuotientFamilial'], 4262);
      // I_ref (1 part) = 8 103.58 ; I_QF (2 parts) = 2 947.78
      // Avantage = 5 155.80 > 4 262 -> plafonne
      expect(result['reductionQuotientFamilial'], 4262);
      // Impot apres plafond = 8 103.58 - 4 262 = 3 841.58
      expect(result['impotApresPlafond'], closeTo(3841.58, 1));
    });

    test('should apply family quotient ceiling', () {
      final foyer = FoyerFiscalModel(
        situationFamiliale: SituationFamiliale.marie,
        nbEnfants: 4,
        revenuNetImposable: 300000,
      );

      final result = calculator.calculerImpot(foyer);

      // 4 enfants marie = 5 parts (0.5+0.5+1+1 = 3 parts supplementaires)
      // soit 6 demi-parts : plafond = 6 x 1 807 = 10 842 EUR
      expect(result['plafondQuotientFamilial'], 10842);
    });
  });

  group('TaxCalculator - Story 2.3: Decote Calculation', () {
    test('should apply decote for single person with low income', () {
      final foyer = FoyerFiscalModel(
        situationFamiliale: SituationFamiliale.celibataire,
        nbEnfants: 0,
        revenuNetImposable: 18000,
      );

      final result = calculator.calculerImpot(foyer);

      // For single: decote = 1,927€ - (0.75 × tax)
      // If resulting decote is positive, it's subtracted from tax
      expect(result['decote'], greaterThan(0));
    });

    test('should apply decote for couple with low income', () {
      final foyer = FoyerFiscalModel(
        situationFamiliale: SituationFamiliale.marie,
        nbEnfants: 0,
        revenuNetImposable: 32000,
      );

      final result = calculator.calculerImpot(foyer);

      // For couple: decote = 3,191€ - (0.75 × tax)
      expect(result['decote'], greaterThan(0));
    });

    test('should not apply decote if tax is above threshold', () {
      final foyer = FoyerFiscalModel(
        situationFamiliale: SituationFamiliale.celibataire,
        nbEnfants: 0,
        revenuNetImposable: 100000,
      );

      final result = calculator.calculerImpot(foyer);

      // For high income, decote should be 0 or negative (not applied)
      expect(result['decote'], 0);
    });
  });

  group('TaxCalculator - Story 2.4: CEHR Calculation', () {
    test('should return 0 for income below 250,000€ for single', () {
      final cehr = calculator.calculerCehr(200000, false);
      expect(cehr, 0);
    });

    test('should return 0 for income below 500,000€ for couple', () {
      final cehr = calculator.calculerCehr(450000, true);
      expect(cehr, 0);
    });

    test('should calculate 3% CEHR for single between 250K and 500K', () {
      final cehr = calculator.calculerCehr(300000, false);
      // 3% of (300000 - 250000) = 3% of 50000 = 1500
      expect(cehr, 1500);
    });

    test('should calculate 3% CEHR for couple between 500K and 1M', () {
      final cehr = calculator.calculerCehr(750000, true);
      // 3% of (750000 - 500000) = 3% of 250000 = 7500
      expect(cehr, 7500);
    });

    test('should calculate 4% CEHR for single above 500K', () {
      final cehr = calculator.calculerCehr(600000, false);
      // 7500 + 4% of (600000 - 500000) = 7500 + 4000 = 11500
      expect(cehr, 11500);
    });

    test('should calculate 4% CEHR for couple above 1M', () {
      final cehr = calculator.calculerCehr(1200000, true);
      // 15000 + 4% of (1200000 - 1000000) = 15000 + 8000 = 23000
      expect(cehr, 23000);
    });
  });

  group('TaxCalculator - Story 2.5: Real Expenses vs 10% Deduction', () {
    test('should calculate 10% deduction correctly', () {
      final deduction = calculator.calculerDeduction10Pourcent(45000);
      // 10% of 45000 = 4500, capped at 14556
      expect(deduction, 4500);
    });

    test('should cap 10% deduction at ceiling', () {
      final deduction = calculator.calculerDeduction10Pourcent(200000);
      // 10% of 200000 = 20000, capped at 14556
      expect(deduction, 14556);
    });

    test('should recommend real expenses when higher', () {
      final comparison = calculator.comparerDepensesReellesVs10Pourcent(
        revenuBrut: 45000,
        depensesReelles: 5000,
      );

      // 10% = 4500, real expenses = 5000
      expect(comparison['meilleurOption'], 'reelles');
      expect(comparison['economie'], 500);
    });

    test('should recommend 10% when higher', () {
      final comparison = calculator.comparerDepensesReellesVs10Pourcent(
        revenuBrut: 45000,
        depensesReelles: 3000,
      );

      // 10% = 4500, real expenses = 3000
      expect(comparison['meilleurOption'], 'forfait');
      expect(comparison['economie'], 1500);
    });

    test('should handle zero expenses', () {
      final comparison = calculator.comparerDepensesReellesVs10Pourcent(
        revenuBrut: 45000,
        depensesReelles: 0,
      );

      expect(comparison['meilleurOption'], 'forfait');
      expect(comparison['depensesReelles'], 0);
    });
  });

  group('TaxCalculator - Complete Calculation', () {
    test('should calculate complete tax with all components', () {
      final foyer = FoyerFiscalModel(
        situationFamiliale: SituationFamiliale.celibataire,
        nbEnfants: 0,
        revenuNetImposable: 42000,
      );

      final result = calculator.calculerImpotComplet(foyer);

      expect(result.containsKey('impotBrut'), true);
      expect(result.containsKey('decote'), true);
      expect(result.containsKey('impotNet'), true);
      expect(result.containsKey('cehr'), true);
      expect(result.containsKey('tauxMarginal'), true);
      expect(result.containsKey('tauxMoyen'), true);
      expect(result.containsKey('parts'), true);
      expect(result.containsKey('detailsParTranche'), true);
      expect(result.containsKey('expensesComparison'), true);
    });

    test('should include CEHR in total for high income', () {
      final foyer = FoyerFiscalModel(
        situationFamiliale: SituationFamiliale.celibataire,
        nbEnfants: 0,
        revenuNetImposable: 300000,
      );

      final result = calculator.calculerImpotComplet(foyer);

      // CEHR for 300K single = 1500
      expect(result['cehr'], 1500);
      expect(result['impotTotal'], greaterThan(result['impotNet']));
    });
  });

  group('TaxBrackets2026 Constants', () {
    test('should have correct bracket thresholds', () {
      expect(TaxBrackets2026.ir2026[0].minIncome, 0);
      expect(TaxBrackets2026.ir2026[0].maxIncome, 11600);
      expect(TaxBrackets2026.ir2026[0].rate, 0);

      expect(TaxBrackets2026.ir2026[1].minIncome, 11601);
      expect(TaxBrackets2026.ir2026[1].maxIncome, 29579);
      expect(TaxBrackets2026.ir2026[1].rate, 0.11);

      expect(TaxBrackets2026.ir2026[2].minIncome, 29580);
      expect(TaxBrackets2026.ir2026[2].maxIncome, 84577);
      expect(TaxBrackets2026.ir2026[2].rate, 0.30);

      expect(TaxBrackets2026.ir2026[3].minIncome, 84578);
      expect(TaxBrackets2026.ir2026[3].maxIncome, 181917);
      expect(TaxBrackets2026.ir2026[3].rate, 0.41);

      expect(TaxBrackets2026.ir2026[4].minIncome, 181918);
      expect(TaxBrackets2026.ir2026[4].maxIncome, double.infinity);
      expect(TaxBrackets2026.ir2026[4].rate, 0.45);
    });

    test('should have correct decote thresholds', () {
      expect(TaxBrackets2026.decoteSingleThreshold, 1927);
      expect(TaxBrackets2026.decoteCoupleThreshold, 3191);
      expect(TaxBrackets2026.decoteMultiplier, 0.75);
    });

    test('should have correct family quotient ceiling', () {
      expect(TaxBrackets2026.familyQuotientCeiling, 1807);
    });
  });
}
