import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/parsed_document_data.dart';

final documentParserServiceProvider = Provider<DocumentParserService>((ref) {
  return DocumentParserService();
});

class DocumentParserService {
  /// Extracts fiscal data from raw OCR text
  ParsedDocumentData parseText(String rawText) {
    if (rawText.isEmpty) return const ParsedDocumentData();

    final lines = rawText.split('\n');
    final textLower = rawText.toLowerCase();

    // Regex definitions
    // Matches: Net imposable, Net fiscal, Cumul imposable
    final netImposableRegex = RegExp(r'(?:net\s*imposable|net\s*fiscal|cumul\s*imposable)[^\d]*(\d+(?:[ ,]\d+)*(?:[.,]\d+)?)', caseSensitive: false);
    
    // Matches: Transport, Navigo, Abonnement, Indemnité transport
    final transportRegex = RegExp(r'(?:transport|navigo|abonnement)[^\d]*(\d+(?:[ ,]\d+)*(?:[.,]\d+)?)', caseSensitive: false);
    
    // Matches: Ticket(s) restaurant, Titre(s) restaurant
    final mealVoucherRegex = RegExp(r'(?:ticket[s]?\s*restaurant|titre[s]?\s*restaurant|tr\s*employeur)[^\d]*(\d+(?:[ ,]\d+)*(?:[.,]\d+)?)', caseSensitive: false);
    
    // Matches: Avantage en nature véhicule
    final companyCarRegex = RegExp(r'avantage\s*en\s*nature\s*v[é|e]hicule', caseSensitive: false);

    double? netIncome;
    double? transportAllowance;
    double? mealVoucherContrib;
    bool hasCompanyCar = companyCarRegex.hasMatch(textLower);

    for (final line in lines) {
      // Net Imposable
      if (netIncome == null) {
        final netMatch = netImposableRegex.firstMatch(line);
        if (netMatch != null) {
          netIncome = _parseDouble(netMatch.group(1));
        }
      }

      // Transport
      if (transportAllowance == null) {
        final transportMatch = transportRegex.firstMatch(line);
        if (transportMatch != null) {
          transportAllowance = _parseDouble(transportMatch.group(1));
        }
      }

      // Meal Vouchers
      if (mealVoucherContrib == null) {
        final mealMatch = mealVoucherRegex.firstMatch(line);
        if (mealMatch != null) {
          mealVoucherContrib = _parseDouble(mealMatch.group(1));
        }
      }
    }

    return ParsedDocumentData(
      netTaxableIncome: netIncome,
      transportAllowance: transportAllowance,
      mealVoucherEmployerContribution: mealVoucherContrib,
      hasCompanyCar: hasCompanyCar,
      mealVoucherCount: mealVoucherContrib != null ? 20 : null, // Heuristic estimation per month
    );
  }

  double? _parseDouble(String? match) {
    if (match == null) return null;
    // Clean string: remove spaces, replace comma with dot
    final cleaned = match.replaceAll(' ', '').replaceAll(',', '.');
    return double.tryParse(cleaned);
  }
}