import 'package:flutter_test/flutter_test.dart';
import 'package:fiscalia/core/constants/tax_brackets.dart';
import 'package:fiscalia/core/services/tax_remote_config_service.dart';
import 'package:fiscalia/data/models/foyer_fiscal_model.dart';
import 'package:fiscalia/presentation/providers/fiscal_provider.dart';
import 'package:fiscalia/presentation/providers/home_employment_credit_provider.dart';

/// Verifie que le moteur de calcul suit la configuration fiscale injectee
/// (connexion Remote Config -> moteur, suite de la story 10.3).
void main() {
  FoyerFiscalModel foyerCelibataire(double revenu) => FoyerFiscalModel(
    situationFamiliale: SituationFamiliale.celibataire,
    nbEnfants: 0,
    revenuNetImposable: revenu,
  );

  group('TaxCalculator avec configuration injectee', () {
    test('par defaut, utilise les baremes embarques 2026', () {
      final result = TaxCalculator().calculerImpot(foyerCelibataire(42000));
      expect(result['tauxMarginal'], 0.30);
    });

    test('reagit a un bareme distant modifie', () {
      // Hypothese : loi de finances abaissant le seuil des 30% a 25 000.
      const config = TaxConfig(
        brackets: [
          TaxBracket(minIncome: 0, maxIncome: 11600, rate: 0),
          TaxBracket(minIncome: 11601, maxIncome: 25000, rate: 0.11),
          TaxBracket(minIncome: 25001, maxIncome: double.infinity, rate: 0.30),
        ],
        familyQuotientCeiling: 1807,
        parentIsoleQuotientCeiling: 4262,
        nicheCeilingGeneral: 10000,
        nicheCeilingOverseas: 18000,
        decoteSingleThreshold: 1927,
        decoteCoupleThreshold: 3191,
        perAnnualCeiling: 37094,
        homeEmploymentCeiling: 12000,
        childCareCeilingPerChild: 3500,
        donation75Ceiling: 1000,
        propertyDeficitCeiling: 10700,
        decoteMultiplier: 0.75,
        homeEmploymentExtraPerChild: 1500,
        homeEmploymentMaxFirstYear: 15000,
        homeEmploymentMaxWithMajorations: 18000,
        taxYear: 2027,
      );
      final calculator = TaxCalculator(config: config);
      final result = calculator.calculerImpot(foyerCelibataire(42000));

      // Avec le nouveau bareme : (25 000 - 11 600) x 11% + (42 000 - 25 001) x 30%
      expect(result['tauxMarginal'], 0.30);
      final details = result['detailsParTranche'] as Map<int, double>;
      expect(details[1], closeTo(1473.89, 1)); // 11% sur la nouvelle tranche
      expect(details[2], closeTo(5099.7, 1)); // 30% a partir de 25 001
    });

    test('reagit a un plafond de quotient familial distant', () {
      final embarque = TaxCalculator();
      final configMajoree = TaxConfig.fromJson({
        ...const TaxConfig.embedded().toJson(),
        'familyQuotientCeiling': 2500,
      });
      final distant = TaxCalculator(config: configMajoree);

      final foyer = FoyerFiscalModel(
        situationFamiliale: SituationFamiliale.marie,
        nbEnfants: 3,
        revenuNetImposable: 200000,
      );
      final impotEmbarque =
          embarque.calculerImpot(foyer)['impotApresPlafond'] as double;
      final impotDistant =
          distant.calculerImpot(foyer)['impotApresPlafond'] as double;

      // Un plafond plus genereux reduit l'impot apres plafonnement
      expect(impotDistant, lessThan(impotEmbarque));
    });
  });

  group('HomeEmploymentCreditService avec configuration injectee', () {
    test('par defaut, plafond embarque 12 000', () {
      final service = HomeEmploymentCreditService();
      final plafond = service.calculateCeiling(
        numberOfChildren: 0,
        numberOfElderly: 0,
        isFirstYear: false,
      );
      expect(plafond, 12000);
    });

    test('reagit a un plafond distant', () {
      final config = TaxConfig.fromJson({
        ...const TaxConfig.embedded().toJson(),
        'homeEmploymentCeiling': 14000,
      });
      final service = HomeEmploymentCreditService(config: config);
      final plafond = service.calculateCeiling(
        numberOfChildren: 0,
        numberOfElderly: 0,
        isFirstYear: false,
      );
      expect(plafond, 14000);
    });
  });
}
