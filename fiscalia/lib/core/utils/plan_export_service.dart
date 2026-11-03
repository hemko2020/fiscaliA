import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../agents/models/agent_models.dart';

/// Service d'export PDF du plan d'optimisation fiscale (Story 8.8).
///
/// Genere un document complet : profil, dispositifs recommandes, economies
/// estimees, calendrier d'actions, checklist documentaire et disclaimers
/// legaux (NFR9, NFR10). Generation 100% locale (FR49).
class PlanExportService {
  final _formatMontant = NumberFormat('#,##0', 'fr_FR');
  final _formatDate = DateFormat('dd/MM/yyyy', 'fr_FR');

  /// Genere le PDF et retourne le chemin du fichier cree.
  Future<String> genererPlanPdf(AgentAnalysisResult analyse) async {
    final doc = pw.Document(
      title: 'Plan d\'optimisation fiscale FiscalIA',
      author: 'FiscalIA',
    );

    doc.addPage(_pageSynthese(analyse));
    for (final scenario in analyse.scenarios) {
      doc.addPage(_pageScenario(scenario, analyse));
    }
    doc.addPage(_pageDisclaimers());

    final dir = await getApplicationDocumentsDirectory();
    final fichier = File(
      '${dir.path}/plan_optimisation_fiscalia_'
      '${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf',
    );
    await fichier.writeAsBytes(await doc.save());
    return fichier.path;
  }

  /// Genere le PDF puis ouvre la feuille de partage systeme.
  Future<void> exporterEtPartager(AgentAnalysisResult analyse) async {
    final chemin = await genererPlanPdf(analyse);
    await Share.shareXFiles(
      [XFile(chemin)],
      subject: 'Plan d\'optimisation fiscale - FiscalIA',
    );
  }

  pw.Page _pageSynthese(AgentAnalysisResult analyse) {
    final profil = analyse.profile;
    final economieTotale = analyse.scenarios.fold<double>(
      0,
      (somme, s) => somme > s.economieTotaleEstimee
          ? somme
          : s.economieTotaleEstimee,
    );

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Plan d\'optimisation fiscale',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Genere le ${_formatDate.format(DateTime.now())} par FiscalIA - '
            'Document indicatif, voir avertissements en derniere page.',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 24),
          _titreSection('Votre profil fiscal'),
          _ligne(
            'Revenu fiscal de reference',
            '${_formatMontant.format(profil.revenuFiscalReference)} EUR',
          ),
          _ligne(
            'Taux marginal d\'imposition',
            '${(profil.tauxMarginalImposition * 100).toStringAsFixed(0)}%',
          ),
          _ligne('Parts fiscales', profil.partsFiscales.toString()),
          _ligne('Situation', profil.estEnCouple ? 'Couple' : 'Celibataire'),
          if (profil.signauxAlerte.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              'Signaux d\'alerte : ${profil.signauxAlerte.join(', ')}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.red900),
            ),
          ],
          pw.SizedBox(height: 24),
          _titreSection('Synthese des economies'),
          _ligne(
            'Economie annuelle estimee (meilleur scenario)',
            '${_formatMontant.format(economieTotale)} EUR',
          ),
          _ligne(
            'Nombre de dispositifs identifies',
            '${analyse.opportunites.length}',
          ),
          pw.SizedBox(height: 24),
          _titreSection('Dispositifs recommandes (par impact)'),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: ['Dispositif', 'Economie estimee', 'Base legale'],
            headerStyle:
                pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            cellStyle: const pw.TextStyle(fontSize: 9),
            data: analyse.opportunites
                .map(
                  (o) => [
                    o.dispositif.nom,
                    '${_formatMontant.format(o.economieEstimee)} EUR',
                    o.dispositif.baseLegale,
                  ],
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  pw.Page _pageScenario(
    StrategyScenario scenario,
    AgentAnalysisResult analyse,
  ) {
    final conformite = analyse.avisConformite
        .where((c) => c.scenario.id == scenario.id)
        .firstOrNull;

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            scenario.titre,
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(scenario.resume, style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 12),
          _ligne(
            'Economie totale estimee',
            '${_formatMontant.format(scenario.economieTotaleEstimee)} EUR',
          ),
          _ligne('Score de risque', '${scenario.risqueGlobal}/5'),
          if (conformite != null) ...[
            _ligne(
              'Conformite',
              conformite.conforme ? 'Conforme' : 'Point d\'attention requis',
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              conformite.motif,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ],
          pw.SizedBox(height: 16),
          _titreSection('Calendrier d\'actions'),
          pw.SizedBox(height: 8),
          ...scenario.planAction.map(
            (etape) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '${etape.titre} - ${etape.echeance}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    etape.description,
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ),
          ),
          pw.SizedBox(height: 16),
          _titreSection('Checklist documentaire'),
          pw.SizedBox(height: 8),
          ...scenario.opportunites.expand(
            (o) => o.conditionsRestantes.map(
              (c) => pw.Bullet(text: c, style: const pw.TextStyle(fontSize: 9)),
            ),
          ),
        ],
      ),
    );
  }

  pw.Page _pageDisclaimers() {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _titreSection('Avertissements legaux'),
          pw.SizedBox(height: 12),
          pw.Bullet(
            text:
                'Les calculs presentes sont indicatifs et fondes sur la '
                'legislation fiscale francaise en vigueur au 01/01/2026. Ils '
                'ne constituent ni un conseil fiscal, ni un conseil en '
                'investissement.',
          ),
          pw.Bullet(
            text:
                'Pour les strategies expertes (demembrement, Pacte Dutreil, '
                'SCI, Girardin), consultez imperativement un avocat '
                'fiscaliste ou un notaire avant toute decision.',
          ),
          pw.Bullet(
            text:
                'Toute strategie doit reposer sur un motif autre que '
                'principalement fiscal pour echapper a la requalification '
                'pour abus de droit (Art. L64 LPF).',
          ),
          pw.Bullet(
            text:
                'Document genere localement sur votre appareil : aucune '
                'donnee personnelle n\'a ete transmise (conformite RGPD).',
          ),
        ],
      ),
    );
  }

  pw.Widget _titreSection(String titre) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Text(
          titre,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
      );

  pw.Widget _ligne(String label, String valeur) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
            pw.Text(
              valeur,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      );
}
