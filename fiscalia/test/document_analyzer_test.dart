import 'package:flutter_test/flutter_test.dart';
import 'package:fiscalia/data/models/parsed_document_data.dart';
import 'package:fiscalia/presentation/providers/document_parser_service.dart';
import 'package:fiscalia/presentation/providers/deduction_analyzer_service.dart';

void main() {
  group('DocumentParserService', () {
    late DocumentParserService parser;

    setUp(() {
      parser = DocumentParserService();
    });

    test('should extract net taxable income', () {
      const text =
          '... some text ...\nNet imposable 2500,50\n... more text ...';
      final parsed = parser.parseText(text);
      expect(parsed.netTaxableIncome, 2500.50);
    });

    test('should extract transport allowance and meal vouchers', () {
      const text = '''
      Indemnité Navigo : 42.10
      Titre restaurant part employeur : 120,00
      Net fiscal mensuel 3000.00
      ''';

      final parsed = parser.parseText(text);
      expect(parsed.netTaxableIncome, 3000.0);
      expect(parsed.transportAllowance, 42.10);
      expect(parsed.mealVoucherEmployerContribution, 120.0);
      expect(parsed.hasCompanyCar, isFalse);
    });

    test('should detect company car', () {
      const text = 'Avantage en nature véhicule : 250\nNet imposable 4000';
      final parsed = parser.parseText(text);
      expect(parsed.hasCompanyCar, isTrue);
      expect(parsed.netTaxableIncome, 4000.0);
    });
  });

  group('DeductionAnalyzerService', () {
    late DeductionAnalyzerService analyzer;

    setUp(() {
      analyzer = DeductionAnalyzerService();
    });

    test(
      'should recommend 10% standard deduction if real expenses are low',
      () {
        // Net income: 3000/month (36000/year). 10% = 3600
        const parsed = ParsedDocumentData(
          netTaxableIncome: 3000,
          transportAllowance:
              80, // High allowance makes real expenses less attractive
          mealVoucherEmployerContribution:
              100, // Very high employer contribution
          mealVoucherCount: 20,
        );

        final analysis = analyzer.analyze(parsed, distanceToWorkKm: 5);

        expect(analysis.standardDeduction, 300.0); // Monthly 10%
        expect(analysis.isRealExpensesBetter, isFalse);
      },
    );

    test('should recommend real expenses if distance is high', () {
      const parsed = ParsedDocumentData(
        netTaxableIncome: 2000, // 10% is 200
        transportAllowance: 0, // No allowance
        mealVoucherEmployerContribution: null, // No vouchers
        mealVoucherCount: 20,
      );

      // Distance is 40km (80km round trip)
      final analysis = analyzer.analyze(parsed, distanceToWorkKm: 40);

      expect(analysis.standardDeduction, 200.0); // Monthly 10%
      expect(analysis.isRealExpensesBetter, isTrue);
      // Real expenses should be much higher than 200
      expect(analysis.estimatedRealExpenses / 12, greaterThan(200.0));
    });
  });
}
