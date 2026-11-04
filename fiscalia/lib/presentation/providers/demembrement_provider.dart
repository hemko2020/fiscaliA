import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/advanced_tax_config.dart';
import 'monitoring_providers.dart';
import '../../data/models/demembrement_model.dart';

final demembrementServiceProvider = Provider(
  (ref) => DemembrementService(config: ref.watch(advancedTaxConfigProvider)),
);

final demembrementProvider = StateProvider<DemembrementResult?>(
  (ref) => null,
);

/// Service de calcul du demembrement de propriete (Story 8.4).
///
/// Le bareme de l'Art. 669 CGI valorise l'usufruit en fonction de l'age
/// de l'usufruitier. Donner la nue-propriete permet de transmettre a
/// moindre cout : les droits sont calcules sur la seule nue-propriete,
/// et au deces de l'usufruitier le nu-proprietaire recupere la pleine
/// propriete sans aucun droit supplementaire (Art. 1133 CGI).
class DemembrementService {
  /// Configuration des dispositifs avances (distante si disponible,
  /// embarquee 2026 sinon).
  final AdvancedTaxConfig config;

  DemembrementService({this.config = const AdvancedTaxConfig.embedded()});

  /// Calcule les droits selon le bareme progressif en ligne directe
  /// (Art. 777 CGI), par tranches successives.
  static double calculerDroitsLigneDirecte(
    double assietteTaxable, {
    AdvancedTaxConfig config = const AdvancedTaxConfig.embedded(),
  }) {
    if (assietteTaxable <= 0) return 0;
    var droits = 0.0;
    var seuilPrecedent = 0.0;
    for (final (seuil, taux) in config.baremeLigneDirecte) {
      if (assietteTaxable <= seuilPrecedent) break;
      final trancheHaute =
          assietteTaxable < seuil ? assietteTaxable : seuil;
      droits += (trancheHaute - seuilPrecedent) * taux;
      seuilPrecedent = seuil;
    }
    return droits;
  }

  /// Calcule les droits totaux en appliquant le bareme par part de
  /// (parent x enfant), comme le fait l'administration : chaque part
  /// beneficie de son propre abattement de 100 000 EUR et de sa propre
  /// progression de tranches (Art. 779 et 777 CGI).
  static double calculerDroitsParPart({
    required double valeurTransmise,
    required int nbParents,
    required int nbEnfants,
    AdvancedTaxConfig config = const AdvancedTaxConfig.embedded(),
  }) {
    if (valeurTransmise <= 0 || nbParents < 1 || nbEnfants < 1) return 0;
    final nbParts = nbParents * nbEnfants;
    final partParBeneficiaire = valeurTransmise / nbParts;
    final assietteParPart =
        partParBeneficiaire - config.abattementLigneDirecte;
    if (assietteParPart <= 0) return 0;
    return nbParts *
        calculerDroitsLigneDirecte(assietteParPart, config: config);
  }

  DemembrementResult calculer(DemembrementModel input) {
    final ratio = config.usufruitRatioPourAge(
      input.ageUsufruitier,
    );
    final usufruit = input.valeurBien * ratio;
    final nuePropriete = input.valeurBien - usufruit;

    // Chaque parent dispose d'un abattement de 100 000 EUR par enfant,
    // renouvelable tous les 15 ans (Art. 779 CGI).
    final abattementTotal = config.abattementLigneDirecte *
        input.nbParents *
        input.nbEnfants;

    // Droits calcules par part (parent x enfant) : chaque beneficiaire a
    // son propre abattement et sa propre progression de tranches.
    final droitsNP = calculerDroitsParPart(
      valeurTransmise: nuePropriete,
      nbParents: input.nbParents,
      nbEnfants: input.nbEnfants,
    );
    final droitsPP = calculerDroitsParPart(
      valeurTransmise: input.valeurBien,
      nbParents: input.nbParents,
      nbEnfants: input.nbEnfants,
    );

    // Assiette taxable totale (apres abattements) a titre indicatif.
    final assietteNP = nuePropriete - abattementTotal;
    final assietteTaxableNP = assietteNP > 0 ? assietteNP : 0.0;

    final explications = <String>[
      'A ${input.ageUsufruitier} ans, l\'usufruit est valorise a '
          '${(ratio * 100).toStringAsFixed(0)}% de la pleine propriete '
          '(Art. 669 CGI) : la nue-propriete ne vaut que '
          '${nuePropriete.toStringAsFixed(0)} EUR.',
      'Au deces de l\'usufruitier, le nu-proprietaire devient plein '
          'proprietaire sans aucun droit a payer (Art. 1133 CGI).',
      'L\'abattement de 100 000 EUR par parent et par enfant se renouvelle '
          'tous les 15 ans : anticipez les donations par etapes.',
    ];
    if (droitsNP == 0) {
      explications.add(
        'Transmission integralement couverte par les abattements : '
        'aucun droit de donation a payer.',
      );
    }

    return DemembrementResult(
      valeurUsufruit: usufruit,
      valeurNuePropriete: nuePropriete,
      ratioUsufruit: ratio,
      abattementTotal: abattementTotal,
      assietteTaxable: assietteTaxableNP,
      droitsDonation: droitsNP,
      droitsPleinePropriete: droitsPP,
      economie: droitsPP - droitsNP,
      explications: explications,
    );
  }
}
