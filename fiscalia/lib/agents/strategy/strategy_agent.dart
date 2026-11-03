import '../fiscal_agent.dart';
import '../models/agent_models.dart';

class StrategyAgent
    extends FiscalAgent<List<AgentOpportunity>, List<StrategyScenario>> {
  const StrategyAgent();

  @override
  String get id => 'strategy';

  @override
  String get nom => 'StrategyAgent';

  @override
  String get description =>
      'Assemble les opportunites en scenarios d execution court terme, patrimonial et combine.';

  @override
  Future<List<StrategyScenario>> execute(
    List<AgentOpportunity> opportunites,
  ) async {
    if (opportunites.isEmpty) {
      return const [];
    }

    final top = opportunites.take(5).toList();
    final scenarioRapide = top.take(2).toList();
    final scenarioPatrimonial = top
        .where(
          (item) =>
              item.dispositif.id == 'per' ||
              item.dispositif.id == 'deficit_foncier' ||
              item.dispositif.id == 'fcpi_fip' ||
              item.dispositif.id == 'girardin_industriel' ||
              item.dispositif.id == 'combinaison_hors_plafond',
        )
        .take(3)
        .toList();
    final scenarioCombine = top.take(3).toList();

    final scenarios = <StrategyScenario>[];
    if (scenarioRapide.isNotEmpty) {
      scenarios.add(
        _buildScenario(
          id: 'scenario_rapide',
          titre: 'Scenario rapide de declaration',
          resume:
              'Optimisations simples a activer des la prochaine declaration.',
          opportunites: scenarioRapide,
        ),
      );
    }
    if (scenarioPatrimonial.isNotEmpty) {
      scenarios.add(
        _buildScenario(
          id: 'scenario_patrimonial',
          titre: 'Scenario patrimonial',
          resume:
              'Optimisations structurelles avec impact durable sur plusieurs exercices.',
          opportunites: scenarioPatrimonial,
        ),
      );
    }
    if (scenarioCombine.length >= 2) {
      scenarios.add(
        _buildScenario(
          id: 'scenario_combine',
          titre: 'Scenario combine a forte economie',
          resume:
              'Combinaison des leviers les plus rentables avec suivi de calendrier.',
          opportunites: scenarioCombine,
        ),
      );
    }

    return scenarios;
  }

  StrategyScenario _buildScenario({
    required String id,
    required String titre,
    required String resume,
    required List<AgentOpportunity> opportunites,
  }) {
    final economieTotaleEstimee = opportunites.fold<double>(
      0,
      (total, opportunite) => total + opportunite.economieEstimee,
    );
    final risqueGlobal = opportunites.fold<int>(
      1,
      (maxRisque, opportunite) => opportunite.dispositif.risqueScore > maxRisque
          ? opportunite.dispositif.risqueScore
          : maxRisque,
    );

    final planAction = opportunites
        .map(
          (opportunite) => ActionStep(
            titre: opportunite.dispositif.nom,
            description:
                'Activer ${opportunite.dispositif.nom.toLowerCase()} puis verifier ${opportunite.conditionsRestantes.join(', ').toLowerCase()}.',
            echeance: opportunite.dispositif.risqueScore >= 3
                ? 'Avant engagement definitif'
                : 'Avant la prochaine declaration',
          ),
        )
        .toList();

    return StrategyScenario(
      id: id,
      titre: titre,
      resume: resume,
      opportunites: opportunites,
      planAction: planAction,
      economieTotaleEstimee: economieTotaleEstimee,
      risqueGlobal: risqueGlobal,
    );
  }
}
