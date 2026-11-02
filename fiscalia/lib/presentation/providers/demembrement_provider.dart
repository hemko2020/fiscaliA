import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/advanced_tax_constants.dart';
import '../../data/models/demembrement_model.dart';

final demembrementServiceProvider = Provider(
  (ref) => DemembrementService(),
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
  /// Calcule les droits selon le bareme progressif en ligne directe
  /// (Art. 777 CGI), par tranches successives.
  static double calculerDroitsLigneDirecte(double assietteTaxable) {
    if (assietteTaxable <= 0) return 0;
    var droits = 0.0;
    var seuilPrecedent = 0.0;
    for (final (seuil, taux) in AdvancedTaxConstants.baremeLigneDirecte) {
      if (assietteTaxable <= seuilPrecedent) break;
      final trancheHaute =
          assietteTaxable < seuil ? assietteTaxable : seuil;
      droits += (trancheHaute - seuilPrecedent) * taux;
      seuilPrecedent = seuil;
    }
    return droits;
  }

  DemembrementResult calculer(DemembrementModel input) {
    final ratio = AdvancedTaxConstants.usufruitRatioPourAge(
      input.ageUsufruitier,
    );
    final usufruit = input.valeurBien * ratio;
    final nuePropriete = input.valeurBien - usufruit;

    // Chaque parent dispose d'un abattement de 100 000 EUR par enfant,
    // renouvelable tous les 15 ans (Art. 779 CGI).
    final abattementTotal = AdvancedTaxConstants.abattementLigneDirecte *
        input.nbParents *
        input.nbEnfants;

    final assietteNP = nuePropriete - abattementTotal;
    final assietteTaxableNP = assietteNP > 0 ? assietteNP : 0.0;
    final droitsNP = calculerDroitsLigneDirecte(assietteTaxableNP);

    final assiettePP = input.valeurBien - abattementTotal;
    final assietteTaxablePP = assiettePP > 0 ? assiettePP : 0.0;
    final droitsPP = calculerDroitsLigneDirecte(assietteTaxablePP);

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
