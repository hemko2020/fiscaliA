import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/advanced_tax_constants.dart';
import '../../data/models/lmnp_simulation_model.dart';

final lmnpServiceProvider = Provider((ref) => LmnpSimulationService());

final lmnpSimulationProvider = StateProvider<LmnpSimulationResult?>(
  (ref) => null,
);

/// Service de simulation LMNP (Story 8.2).
///
/// Compare le micro-BIC (abattement forfaitaire de 50%, Art. 50-0 CGI)
/// au regime reel avec amortissement (Art. 39 C CGI) :
/// - Le batiment s'amortit sur ~30 ans (hors terrain, estime a 15% du prix).
/// - Le mobilier s'amortit sur ~7 ans.
/// - L'amortissement ne peut pas creer de deficit : l'excedent est reporte
///   sans limite de duree sur les benefices ulterieurs.
/// - Le revenu taxable est soumis a la TMI + 17.2% de prelevements sociaux.
class LmnpSimulationService {
  LmnpSimulationResult simuler(LmnpSimulationModel input) {
    final tauxGlobal = input.tmi + AdvancedTaxConstants.prelevementsSociaux;

    // Amortissement annuel theorique.
    final baseBatiment =
        input.prixAcquisition * (1 - AdvancedTaxConstants.lmnpLandShare);
    final amortBatimentAnnuel =
        baseBatiment / AdvancedTaxConstants.lmnpBuildingAmortizationYears;
    final amortMobilierAnnuel =
        input.valeurMobilier / AdvancedTaxConstants.lmnpFurnitureAmortizationYears;

    final projection = <LmnpComparaisonAnnuelle>[];
    var amortissementsReportes = 0.0;
    var impotTotalMicro = 0.0;
    var impotTotalReel = 0.0;

    for (var annee = 1; annee <= input.dureeAnnees; annee++) {
      // --- Micro-BIC : abattement forfaitaire de 50% ---
      final baseMicro =
          input.loyersAnnuels * (1 - AdvancedTaxConstants.lmnpMicroBicAbattement);
      final impotMicro = baseMicro * tauxGlobal;
      impotTotalMicro += impotMicro;

      // --- Reel : charges + amortissements ---
      // Le mobilier n'est amortissable que pendant sa duree de vie.
      final amortMobilier =
          annee <= AdvancedTaxConstants.lmnpFurnitureAmortizationYears
              ? amortMobilierAnnuel
              : 0.0;
      final chargesTotales =
          input.chargesAnnuelles + amortBatimentAnnuel + amortMobilier;
      final resultatAvantPlafonnement = input.loyersAnnuels - chargesTotales;

      double baseReel;
      double amortUtiliseBatiment;
      double amortUtiliseMobilier;
      if (resultatAvantPlafonnement >= 0) {
        baseReel = resultatAvantPlafonnement;
        amortUtiliseBatiment = amortBatimentAnnuel;
        amortUtiliseMobilier = amortMobilier;
      } else {
        // L'amortissement ne peut pas creer de deficit : on limite la
        // deduction au montant qui ramene le resultat a zero et on reporte
        // l'excedent (Art. 39 C, alinea 2 CGI).
        baseReel = 0;
        final excedent = -resultatAvantPlafonnement;
        amortissementsReportes += excedent;
        final amortAdmis = amortBatimentAnnuel + amortMobilier - excedent;
        // On affecte le plafonnement d'abord au batiment (duree la plus longue).
        amortUtiliseBatiment =
            amortAdmis >= amortMobilier ? amortAdmis - amortMobilier : 0.0;
        amortUtiliseMobilier =
            amortAdmis >= amortMobilier ? amortMobilier : amortAdmis;
      }

      final impotReel = baseReel * tauxGlobal;
      impotTotalReel += impotReel;

      projection.add(
        LmnpComparaisonAnnuelle(
          annee: annee,
          baseImposableMicro: baseMicro,
          impotMicro: impotMicro,
          amortissementBatiment: amortUtiliseBatiment,
          amortissementMobilier: amortUtiliseMobilier,
          resultatFonctionnel: input.loyersAnnuels - input.chargesAnnuelles,
          baseImposableReel: baseReel,
          impotReel: impotReel,
          amortissementsReportes: amortissementsReportes,
          economieReel: impotMicro - impotReel,
        ),
      );
    }

    final economieTotale = impotTotalMicro - impotTotalReel;
    final loyersTotaux = input.loyersAnnuels * input.dureeAnnees;
    final tauxFiscalite = loyersTotaux > 0 ? impotTotalReel / loyersTotaux : 0.0;

    final recommandations = <String>[];
    if (economieTotale > 0) {
      recommandations.add(
        'Le regime reel vous fait economiser '
        '${economieTotale.toStringAsFixed(0)} EUR sur ${input.dureeAnnees} '
        'ans par rapport au micro-BIC.',
      );
    }
    if (tauxFiscalite < 0.05) {
      recommandations.add(
        'Grace a l\'amortissement, vos loyers sont quasiment non imposables '
        '(taux effectif : ${(tauxFiscalite * 100).toStringAsFixed(1)}%).',
      );
    }
    if (input.loyersAnnuels > AdvancedTaxConstants.lmnpMicroBicCeiling) {
      recommandations.add(
        'Vos recettes depassent le plafond du micro-BIC '
        '(${AdvancedTaxConstants.lmnpMicroBicCeiling.toStringAsFixed(0)} EUR) '
        ': le regime reel est obligatoire.',
      );
    }
    recommandations.add(
      'Le passage au reel impose une comptabilite et un depot de liasse '
      'fiscale (2031) : un expert-comptable est recommande (honoraires '
      'deductibles).',
    );

    return LmnpSimulationResult(
      projection: projection,
      economieTotaleReel: economieTotale,
      impotTotalMicro: impotTotalMicro,
      impotTotalReel: impotTotalReel,
      tauxFiscaliteReel: tauxFiscalite,
      recommandations: recommandations,
    );
  }
}
