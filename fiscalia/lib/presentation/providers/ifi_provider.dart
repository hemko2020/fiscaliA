import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/advanced_tax_constants.dart';
import '../../data/models/ifi_model.dart';

final ifiServiceProvider = Provider((ref) => IfiService());

final ifiProvider = StateProvider<IfiResult?>((ref) => null);

/// Service de calcul de l'IFI (Story 8.6).
///
/// Reference : Art. 964 a 983 CGI.
/// - Assujettissement si patrimoine immobilier net taxable > 1 300 000 EUR.
/// - Le bareme s'applique alors a partir de 800 000 EUR (0.5% a 1.5%).
/// - Decote pour les patrimoines entre 1.3M et 1.4M :
///   IFI = 17 500 - 1.25% x patrimoine (Art. 980 CGI).
/// - Reduction de 75% pour les dons IFI, plafonnee a 50 000 EUR
///   (Art. 885-0 V bis A CGI).
class IfiService {
  IfiResult calculer(IfiModel input) {
    final net = input.patrimoineNetTaxable;
    final assujetti = net > AdvancedTaxConstants.ifiSeuilImposition;

    final tranches = <IfiTranche>[];
    var ifiBrut = 0.0;

    if (assujetti) {
      var borneBasse = 0.0;
      for (final (borneHaute, taux) in AdvancedTaxConstants.baremeIFI) {
        if (net <= borneBasse) break;
        final haut = net < borneHaute ? net : borneHaute;
        final montant = (haut - borneBasse) * taux;
        tranches.add(
          IfiTranche(
            borneBasse: borneBasse,
            borneHaute: haut,
            taux: taux,
            montantTaxe: montant,
          ),
        );
        ifiBrut += montant;
        borneBasse = borneHaute;
      }
    }

    // Decote (Art. 980 CGI) : si l'IFI brut depasse le resultat de la
    // formule 17 500 - 1.25% x P, on retient la formule.
    var decote = 0.0;
    var ifiApresDecote = ifiBrut;
    if (assujetti &&
        net <= AdvancedTaxConstants.ifiDecotePlafond &&
        ifiBrut > 0) {
      final ifiDecote = AdvancedTaxConstants.ifiDecoteBase -
          AdvancedTaxConstants.ifiDecoteTaux * net;
      if (ifiDecote < ifiBrut) {
        decote = ifiBrut - ifiDecote;
        ifiApresDecote = ifiDecote;
      }
    }

    // Reduction dons IFI : 75% plafonnee a 50 000 EUR, non restituable
    // (ne peut pas generer de credit).
    final reductionDons = input.donsIfi * AdvancedTaxConstants.ifiDonReductionTaux >
            AdvancedTaxConstants.ifiDonReductionPlafond
        ? AdvancedTaxConstants.ifiDonReductionPlafond
        : input.donsIfi * AdvancedTaxConstants.ifiDonReductionTaux;
    final reductionAppliquee =
        reductionDons > ifiApresDecote ? ifiApresDecote : reductionDons;

    final ifiFinal = ifiApresDecote - reductionAppliquee;

    final strategies = _construireStrategies(input, net, assujetti);

    return IfiResult(
      patrimoineNetTaxable: net,
      assujetti: assujetti,
      tranches: tranches,
      ifiBrut: ifiBrut,
      decote: decote,
      ifiApresDecote: ifiApresDecote,
      reductionDons: reductionAppliquee,
      ifiFinal: ifiFinal > 0 ? ifiFinal : 0,
      strategies: strategies,
    );
  }

  List<String> _construireStrategies(
    IfiModel input,
    double net,
    bool assujetti,
  ) {
    final strategies = <String>[];
    if (!assujetti) {
      strategies.add(
        'Votre patrimoine immobilier net est sous le seuil d\'assujettissement '
        'de 1 300 000 EUR : pas d\'IFI a payer.',
      );
      return strategies;
    }

    strategies.add(
      'Dons IFI : 75% de vos dons a des organismes d\'interet general sont '
      'deductibles de l\'IFI, dans la limite de 50 000 EUR (Art. 885-0 V '
      'bis A CGI). Plus efficace que le don IR si vous etes assujetti.',
    );
    if (input.ageUsufruitier > 0) {
      final ratio =
          AdvancedTaxConstants.usufruitRatioPourAge(input.ageUsufruitier);
      strategies.add(
        'Demembrement : donner la nue-propriete reduit l\'assiette IFI. '
        'Attention : l\'usufruitier doit declarer le bien en pleine '
        'propriete depuis la loi de finances 2023, sauf exceptions '
        '(demembrement legal ou conventionnel familial).',
      );
      if (ratio <= 0.40) {
        strategies.add(
          'A ${input.ageUsufruitier} ans, la nue-propriete represente '
          '${((1 - ratio) * 100).toStringAsFixed(0)}% de la valeur : '
          'transmission particulierement efficace.',
        );
      }
    }
    strategies.add(
      'Les biens professionnels necessaires a l\'activite principale sont '
      'exoneres d\'IFI (Art. 975 CGI).',
    );
    strategies.add(
      'Les dettes contractees pour l\'acquisition ou les travaux des biens '
      'taxables sont deductibles, sous reserve du plafonnement pour les '
      'patrimoines > 5 M EUR.',
    );
    return strategies;
  }
}
