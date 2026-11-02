import '../../core/constants/tax_brackets.dart';
import '../../data/models/foyer_fiscal_model.dart';
import '../fiscal_agent.dart';
import '../models/agent_models.dart';

class ProfileAgent extends FiscalAgent<FoyerFiscalModel, FiscalProfile> {
  const ProfileAgent();

  @override
  String get id => 'profile';

  @override
  String get nom => 'ProfilerAgent';

  @override
  String get description =>
      'Construit un profil fiscal a partir du foyer, du TMI, du RFR et des signaux d\'alerte.';

  @override
  Future<FiscalProfile> execute(FoyerFiscalModel foyer) async {
    final tauxMarginalImposition = _calculerTmi(foyer);
    final revenuFiscalReference = foyer.revenuNetImposable;
    final signauxAlerte = <String>[];
    final leviersPrioritaires = <String>[];
    final estEnCouple =
        foyer.situationFamiliale == SituationFamiliale.marie ||
        foyer.situationFamiliale == SituationFamiliale.pacse;
    final aEnfants = foyer.nbEnfants > 0;
    final aRevenusFonciers =
        foyer.autresRevenus?.any(
          (revenu) => revenu.type.toLowerCase().contains('foncier'),
        ) ??
        false;
    final aRevenusExceptionnels =
        foyer.autresRevenus?.any((revenu) => revenu.montant > 10000) ?? false;
    final estPrimoAccedantPotentiel =
        !aRevenusFonciers &&
        revenuFiscalReference > 35000 &&
        revenuFiscalReference < 120000;

    if (tauxMarginalImposition >= 0.30) {
      signauxAlerte.add(
        'TMI eleve, les arbitrages de deduction sont prioritaires.',
      );
      leviersPrioritaires.addAll(['PER', 'Frais reels']);
    }
    if (aEnfants) {
      signauxAlerte.add(
        'Presence d\'enfants a charge, credits et reductions familiales a verifier.',
      );
      leviersPrioritaires.addAll(['Emploi a domicile', 'Frais de scolarite']);
    }
    if (aRevenusFonciers) {
      signauxAlerte.add(
        'Revenus fonciers detectes, le deficit foncier devient un axe prioritaire.',
      );
      leviersPrioritaires.add('Deficit foncier');
    }
    if (aRevenusExceptionnels) {
      signauxAlerte.add(
        'Revenus complementaires significatifs, verifier les impacts sur TMI et plafonds.',
      );
    }
    if (estPrimoAccedantPotentiel) {
      signauxAlerte.add(
        'Profil patrimonial compatible avec une optimisation a moyen terme.',
      );
    }
    if (estEnCouple) {
      leviersPrioritaires.add('Mutualisation des plafonds PER');
    }

    return FiscalProfile(
      foyerFiscal: foyer,
      tauxMarginalImposition: tauxMarginalImposition,
      revenuFiscalReference: revenuFiscalReference,
      partsFiscales: foyer.partsFiscales,
      signauxAlerte: signauxAlerte,
      leviersPrioritaires: leviersPrioritaires.toSet().toList(),
      aEnfants: aEnfants,
      estEnCouple: estEnCouple,
      aRevenusFonciers: aRevenusFonciers,
      aRevenusExceptionnels: aRevenusExceptionnels,
      estPrimoAccedantPotentiel: estPrimoAccedantPotentiel,
    );
  }

  double _calculerTmi(FoyerFiscalModel foyer) {
    final revenuQuotient = foyer.revenuNetImposable / foyer.partsFiscales;
    double tmi = 0;
    for (final tranche in TaxBrackets2026.ir2026) {
      if (revenuQuotient > tranche.minIncome) {
        tmi = tranche.rate;
      }
    }
    return tmi;
  }
}
