import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/tax_document_model.dart';
import '../../../data/models/parsed_document_data.dart';
import '../../providers/document_parser_service.dart';
import '../../providers/deduction_analyzer_service.dart';

class DocumentDetailScreen extends ConsumerStatefulWidget {
  final TaxDocumentModel document;

  const DocumentDetailScreen({super.key, required this.document});

  @override
  ConsumerState<DocumentDetailScreen> createState() =>
      _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends ConsumerState<DocumentDetailScreen> {
  bool _showRawText = false;

  @override
  Widget build(BuildContext context) {
    final parserService = ref.watch(documentParserServiceProvider);
    final analyzerService = ref.watch(deductionAnalyzerServiceProvider);

    final parsedData = parserService.parseText(widget.document.extractedText);
    final analysis = analyzerService.analyze(parsedData);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.document.fileName),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showRawText ? Icons.analytics : Icons.raw_on),
            tooltip: _showRawText ? 'Voir l\'analyse' : 'Voir le texte brut',
            onPressed: () {
              setState(() {
                _showRawText = !_showRawText;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDocumentPreview(),
            const SizedBox(height: 24),

            if (_showRawText)
              _buildRawTextSection()
            else
              _buildAnalysisSection(parsedData, analysis),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentPreview() {
    if (widget.document.documentType == 'image') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(widget.document.filePath),
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const SizedBox(
            height: 200,
            child: Center(child: Icon(Icons.broken_image, size: 64)),
          ),
        ),
      );
    }

    if (widget.document.documentType == 'pdf') {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.accentOrange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.accentOrange),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.picture_as_pdf, size: 64, color: AppColors.accentOrange),
            SizedBox(height: 16),
            Text(
              'Document PDF',
              style: TextStyle(
                color: AppColors.accentOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildRawTextSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Texte brut extrait par l\'OCR Locale',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: SelectableText(
            widget.document.extractedText.isEmpty
                ? 'Aucun texte n\'a pu être extrait. L\'image est-elle floue ?'
                : widget.document.extractedText,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisSection(
    ParsedDocumentData parsedData,
    DeductionAnalysisResult analysis,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Analyse IA (Fiche de paie)',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 16),

        // Extracted Data Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.search, color: AppColors.accentOrange),
                    SizedBox(width: 8),
                    Text(
                      'Données détectées',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildDataRow(
                  'Net Imposable',
                  parsedData.netTaxableIncome != null
                      ? '${parsedData.netTaxableIncome!.toStringAsFixed(2)} €'
                      : 'Non détecté',
                ),
                const SizedBox(height: 8),
                _buildDataRow(
                  'Indemnités Transport',
                  parsedData.transportAllowance != null
                      ? '${parsedData.transportAllowance!.toStringAsFixed(2)} €'
                      : 'Non détecté',
                ),
                const SizedBox(height: 8),
                _buildDataRow(
                  'Part Employeur (Tickets Resto)',
                  parsedData.mealVoucherEmployerContribution != null
                      ? '${parsedData.mealVoucherEmployerContribution!.toStringAsFixed(2)} €'
                      : 'Non détecté',
                ),
                const SizedBox(height: 8),
                _buildDataRow(
                  'Véhicule de fonction',
                  parsedData.hasCompanyCar ? 'Oui' : 'Non',
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Suggestions Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: analysis.isRealExpensesBetter
                  ? AppColors.accentGreen
                  : AppColors.primaryBlue,
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb,
                      color: analysis.isRealExpensesBetter
                          ? AppColors.accentGreen
                          : AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Pistes d\'optimisation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                ...analysis.suggestions.map(
                  (suggestion) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            suggestion,
                            style: const TextStyle(fontSize: 14, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildDataRow(
                        'Frais Réels (estimés annuels)',
                        '${analysis.estimatedRealExpenses.toStringAsFixed(0)} €',
                      ),
                      const SizedBox(height: 4),
                      _buildDataRow(
                        'Abattement Forfaitaire (10%)',
                        '${analysis.standardDeduction.toStringAsFixed(0)} €',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade700)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
