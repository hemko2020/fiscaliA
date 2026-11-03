import '../../data/models/dispositif_model.dart';
import '../../data/models/foyer_fiscal_model.dart';

class FiscalProfile {
  final FoyerFiscalModel foyerFiscal;
  final double tauxMarginalImposition;
  final double revenuFiscalReference;
  final double partsFiscales;
  final List<String> signauxAlerte;
  final List<String> leviersPrioritaires;
  final bool aEnfants;
  final bool estEnCouple;
  final bool aRevenusFonciers;
  final bool aRevenusExceptionnels;
  final bool estPrimoAccedantPotentiel;

  const FiscalProfile({
    required this.foyerFiscal,
    required this.tauxMarginalImposition,
    required this.revenuFiscalReference,
    required this.partsFiscales,
    required this.signauxAlerte,
    required this.leviersPrioritaires,
    required this.aEnfants,
    required this.estEnCouple,
    required this.aRevenusFonciers,
    required this.aRevenusExceptionnels,
    required this.estPrimoAccedantPotentiel,
  });
}

class AgentOpportunity {
  final DispositifModel dispositif;
  final double scorePertinence;
  final double economieEstimee;
  final String justification;
  final List<String> conditionsRestantes;

  const AgentOpportunity({
    required this.dispositif,
    required this.scorePertinence,
    required this.economieEstimee,
    required this.justification,
    this.conditionsRestantes = const [],
  });
}

class ActionStep {
  final String titre;
  final String description;
  final String echeance;

  const ActionStep({
    required this.titre,
    required this.description,
    required this.echeance,
  });
}

class StrategyScenario {
  final String id;
  final String titre;
  final String resume;
  final List<AgentOpportunity> opportunites;
  final List<ActionStep> planAction;
  final double economieTotaleEstimee;
  final int risqueGlobal;

  const StrategyScenario({
    required this.id,
    required this.titre,
    required this.resume,
    required this.opportunites,
    required this.planAction,
    required this.economieTotaleEstimee,
    required this.risqueGlobal,
  });
}

class ComplianceResult {
  final StrategyScenario scenario;
  final int scoreRisque;
  final bool conforme;
  final String motif;
  final String disclaimerLegal;
  final List<String> pointsVigilance;

  const ComplianceResult({
    required this.scenario,
    required this.scoreRisque,
    required this.conforme,
    required this.motif,
    required this.disclaimerLegal,
    this.pointsVigilance = const [],
  });
}

class AgentAnalysisResult {
  final FiscalProfile profile;
  final List<AgentOpportunity> opportunites;
  final List<StrategyScenario> scenarios;
  final List<ComplianceResult> avisConformite;

  const AgentAnalysisResult({
    required this.profile,
    required this.opportunites,
    required this.scenarios,
    required this.avisConformite,
  });
}
