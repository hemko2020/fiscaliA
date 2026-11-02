import '../fiscal_agent.dart';
import '../models/agent_models.dart';

class ComplianceAgent
    extends FiscalAgent<List<StrategyScenario>, List<ComplianceResult>> {
  const ComplianceAgent();

  @override
  String get id => 'compliance';

  @override
  String get nom => 'ComplianceAgent';

  @override
  String get description =>
      'Controle l exposition au risque fiscal et formalise les points de vigilance avant execution.';

  @override
  Future<List<ComplianceResult>> execute(
    List<StrategyScenario> scenarios,
  ) async {
    return scenarios.map(_evaluerScenario).toList();
  }

  ComplianceResult _evaluerScenario(StrategyScenario scenario) {
    final scoreRisque = scenario.risqueGlobal;
    final pointsVigilance = <String>[];
    var conforme = true;
    var motif =
        'Scenario conforme sous reserve de justificatifs et d une execution documentee.';

    if (scoreRisque >= 4) {
      conforme = false;
      motif =
          'Scenario a risque eleve necessitant une revue humaine avant execution.';
      pointsVigilance.add('Verifier l absence de motif exclusivement fiscal.');
      pointsVigilance.add(
        'Documenter la substance economique et patrimoniale.',
      );
    } else if (scoreRisque == 3) {
      pointsVigilance.add(
        'Conserver les justificatifs et la chronologie de decision.',
      );
      pointsVigilance.add(
        'Controler les plafonds et les obligations declaratives.',
      );
    } else {
      pointsVigilance.add(
        'Verifier les cases de declaration et les pieces justificatives.',
      );
    }

    final disclaimerLegal = scoreRisque >= 4
        ? 'Avis de vigilance renforcee : cette strategie doit etre revue par un professionnel avant mise en oeuvre.'
        : 'Recommandation fournie a titre d optimisation legale, sous reserve de la situation complete et des justificatifs.';

    return ComplianceResult(
      scenario: scenario,
      scoreRisque: scoreRisque,
      conforme: conforme,
      motif: motif,
      disclaimerLegal: disclaimerLegal,
      pointsVigilance: pointsVigilance,
    );
  }
}
