import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/advanced_tax_config.dart';
import 'monitoring_providers.dart';
import '../../data/models/pacte_dutreil_model.dart';
import 'demembrement_provider.dart';

final pacteDutreilServiceProvider = Provider(
  (ref) => PacteDutreilService(config: ref.watch(advancedTaxConfigProvider)),
);

final pacteDutreilProvider = StateProvider<PacteDutreilResult?>(
  (ref) => null,
);

/// Service de calcul du Pacte Dutreil (Story 8.5).
///
/// Reference : Art. 787 B CGI (societes) et 787 C CGI (entreprise
/// individuelle). L'abattement de 75% s'applique sur la valeur transmise
/// sous conditions :
/// - engagement collectif de conservation de 2 ans (titres),
/// - engagement individuel de conservation de 4 ans par chaque heritier,
/// - detention d'au moins 10% des droits financiers et 17% des droits de
///   vote (cas general), activite operationnelle de la societe.
class PacteDutreilService {
  /// Configuration des dispositifs avances (distante si disponible,
  /// embarquee 2026 sinon).
  final AdvancedTaxConfig config;

  PacteDutreilService({this.config = const AdvancedTaxConfig.embedded()});

  PacteDutreilResult calculer(PacteDutreilModel input) {
    final abattementFamilial = config.abattementLigneDirecte *
        input.nbParents *
        input.nbEnfants;

    // Droits calcules par part (parent x enfant) : chaque beneficiaire a
    // son propre abattement de 100 000 EUR et sa propre progression.
    final droitsSans = DemembrementService.calculerDroitsParPart(
      valeurTransmise: input.valeurEntreprise,
      nbParents: input.nbParents,
      nbEnfants: input.nbEnfants,
      config: config,
    );

    // Avec Dutreil : abattement de 75% sur la valeur, puis droits sur
    // les 25% restants (les abattements personnels restent applicables).
    final valeurApresDutreil =
        input.valeurEntreprise * (1 - config.dutreilAbattement);
    final droitsAvec = DemembrementService.calculerDroitsParPart(
      valeurTransmise: valeurApresDutreil,
      nbParents: input.nbParents,
      nbEnfants: input.nbEnfants,
      config: config,
    );
    final assietteAvec = _assiette(valeurApresDutreil, abattementFamilial);

    const conditions = [
      'Engagement collectif de conservation des titres d\'au moins 2 ans '
          '(pris par les associes, avant la transmission).',
      'Engagement individuel de conservation de 4 ans pour chaque '
          'beneficiaire de la transmission.',
      'Detention d\'au moins 10% des droits financiers et 17% des droits '
          'de vote pendant l\'engagement collectif.',
      'La societe doit exercer une activite industrielle, commerciale, '
          'artisanale, agricole ou liberale (pas de gestion de patrimoine).',
      'Un des beneficiaires doit exercer une fonction de direction pendant '
          '3 ans (cas des societes par actions).',
      'Le non-respect des engagements entraine la reprise de l\'abattement '
          'avec interets de retard.',
    ];

    return PacteDutreilResult(
      droitsSansDutreil: droitsSans,
      droitsAvecDutreil: droitsAvec,
      economie: droitsSans - droitsAvec,
      assietteAvecDutreil: assietteAvec,
      conditions: conditions,
    );
  }

  double _assiette(double valeur, double abattement) {
    final assiette = valeur - abattement;
    return assiette > 0 ? assiette : 0;
  }
}
