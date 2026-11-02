import '../../data/models/dispositif_model.dart';
import '../catalogs/dispositifs_fiscaux_catalog.dart';
import '../fiscal_agent.dart';
import '../models/agent_models.dart';

class LoopholeAgent extends FiscalAgent<FiscalProfile, List<AgentOpportunity>> {
  const LoopholeAgent();

  @override
  String get id => 'loophole';

  @override
  String get nom => 'LoopholeAgent';

  @override
  String get description =>
      'Identifie les dispositifs fiscaux applicables et les classe par economie potentielle, risque et complexite.';

  @override
  Future<List<AgentOpportunity>> execute(FiscalProfile profile) async {
    final opportunites = <AgentOpportunity>[];

    for (final dispositif in DispositifsFiscauxCatalog.dispositifs) {
      final analyse = _evaluerEligibilite(profile, dispositif);
      if (!analyse.estEligible) continue;

      opportunites.add(
        AgentOpportunity(
          dispositif: dispositif,
          scorePertinence: analyse.score,
          economieEstimee: _estimerEconomie(profile, dispositif),
          justification: analyse.justification,
          conditionsRestantes: analyse.conditionsRestantes,
        ),
      );
    }

    opportunites.sort((a, b) {
      final scoreCompare = b.scorePertinence.compareTo(a.scorePertinence);
      if (scoreCompare != 0) return scoreCompare;
      return b.economieEstimee.compareTo(a.economieEstimee);
    });

    return opportunites;
  }

  _EligibiliteResult _evaluerEligibilite(
    FiscalProfile profile,
    DispositifModel dispositif,
  ) {
    switch (dispositif.id) {
      case 'frais_reels':
        return const _EligibiliteResult(
          estEligible: true,
          score: 0.82,
          justification:
              'Le profil justifie une comparaison systematique entre forfait 10% et frais reels.',
          conditionsRestantes: [
            'Centraliser les justificatifs de transport, repas et materiel',
          ],
        );
      case 'cotisations_syndicales':
        return const _EligibiliteResult(
          estEligible: true,
          score: 0.45,
          justification:
              'Le credit est simple a activer si des cotisations syndicales ont ete versees.',
          conditionsRestantes: ['Verifier la realite des cotisations versees'],
        );
      case 'frais_scolarite':
        return _EligibiliteResult(
          estEligible: profile.aEnfants,
          score: profile.aEnfants ? 0.78 : 0,
          justification:
              'Le foyer comporte des enfants a charge, la reduction forfaitaire doit etre controlee.',
          conditionsRestantes: const ['Verifier le niveau de scolarisation'],
        );
      case 'pension_ou_rattachement':
        return _EligibiliteResult(
          estEligible: profile.aEnfants,
          score: profile.aEnfants ? 0.65 : 0,
          justification:
              'Le foyer peut beneficier d\'un arbitrage entre rattachement et pension deductible.',
          conditionsRestantes: const [
            'Comparer les deux simulations avec l\'enfant majeur',
          ],
        );
      case 'per':
        return _EligibiliteResult(
          estEligible: profile.tauxMarginalImposition >= 0.30,
          score: profile.tauxMarginalImposition >= 0.41 ? 0.96 : 0.84,
          justification:
              'Le TMI eleve rend la deduction PER particulierement performante.',
          conditionsRestantes: const [
            'Confirmer le plafond PER disponible sur l\'avis d\'imposition',
          ],
        );
      case 'deficit_foncier':
        return _EligibiliteResult(
          estEligible: profile.aRevenusFonciers,
          score: profile.aRevenusFonciers ? 0.88 : 0,
          justification:
              'Des revenus fonciers sont presents, le deficit foncier est un axe prioritaire.',
          conditionsRestantes: const [
            'Lister les travaux eligibles et la nature de la location',
          ],
        );
      case 'dons':
        return const _EligibiliteResult(
          estEligible: true,
          score: 0.58,
          justification:
              'Le foyer peut optimiser la ventilation entre organismes a 75% et organismes a 66%.',
          conditionsRestantes: ['Verifier l\'historique des dons'],
        );
      case 'emploi_domicile':
        return _EligibiliteResult(
          estEligible:
              profile.aEnfants || profile.revenuFiscalReference > 25000,
          score: profile.aEnfants ? 0.83 : 0.60,
          justification:
              'Le credit emploi a domicile est souvent mobilisable pour les foyers actifs.',
          conditionsRestantes: const [
            'Qualifier les depenses de services a la personne',
          ],
        );
      case 'fcpi_fip':
        return _EligibiliteResult(
          estEligible: profile.tauxMarginalImposition >= 0.30,
          score: 0.57,
          justification:
              'Le profil supporte une immobilisation de capital et peut arbitrer une reduction sous plafond.',
          conditionsRestantes: const [
            'Valider l\'horizon d\'investissement et la tolerance au risque',
          ],
        );
      case 'girardin_industriel':
        return _EligibiliteResult(
          estEligible: profile.tauxMarginalImposition >= 0.41,
          score: 0.52,
          justification:
              'Ce levier n\'a de sens que pour les foyers tres imposes avec forte tolerance au risque.',
          conditionsRestantes: const [
            'Due diligence de l\'operateur',
            'Verification juridique renforcee',
          ],
        );
      case 'combinaison_hors_plafond':
        return _EligibiliteResult(
          estEligible: profile.tauxMarginalImposition >= 0.30,
          score: profile.aRevenusFonciers ? 0.90 : 0.72,
          justification:
              'Le profil est compatible avec une strategie hors plafond des niches via deductions et immobilier.',
          conditionsRestantes: const [
            'Verifier la capacite d\'epargne',
            'Valider l\'horizon patrimonial',
          ],
        );
      default:
        return const _EligibiliteResult(
          estEligible: false,
          score: 0,
          justification: '',
          conditionsRestantes: [],
        );
    }
  }

  double _estimerEconomie(FiscalProfile profile, DispositifModel dispositif) {
    switch (dispositif.id) {
      case 'per':
        return 10000 * profile.tauxMarginalImposition;
      case 'deficit_foncier':
        return 10700 * profile.tauxMarginalImposition;
      case 'frais_reels':
        return 1800 * profile.tauxMarginalImposition;
      case 'emploi_domicile':
        return 6000 * dispositif.tauxAvantage;
      case 'girardin_industriel':
        return 10000 * dispositif.tauxAvantage;
      case 'combinaison_hors_plafond':
        return (10000 * profile.tauxMarginalImposition) +
            (10700 * profile.tauxMarginalImposition) +
            8000;
      default:
        final base = dispositif.plafond ?? 1000;
        return base * dispositif.tauxAvantage;
    }
  }
}

class _EligibiliteResult {
  final bool estEligible;
  final double score;
  final String justification;
  final List<String> conditionsRestantes;

  const _EligibiliteResult({
    required this.estEligible,
    required this.score,
    required this.justification,
    required this.conditionsRestantes,
  });
}
