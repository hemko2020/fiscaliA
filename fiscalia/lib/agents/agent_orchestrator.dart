import '../data/models/foyer_fiscal_model.dart';
import 'compliance/compliance_agent.dart';
import 'loophole/loophole_agent.dart';
import 'models/agent_models.dart';
import 'profile/profile_agent.dart';
import 'strategy/strategy_agent.dart';

class AgentOrchestrator {
  final ProfileAgent profileAgent;
  final LoopholeAgent loopholeAgent;
  final StrategyAgent strategyAgent;
  final ComplianceAgent complianceAgent;

  const AgentOrchestrator({
    this.profileAgent = const ProfileAgent(),
    this.loopholeAgent = const LoopholeAgent(),
    this.strategyAgent = const StrategyAgent(),
    this.complianceAgent = const ComplianceAgent(),
  });

  Future<AgentAnalysisResult> analyser(FoyerFiscalModel foyerFiscal) async {
    final profile = await profileAgent.execute(foyerFiscal);
    final opportunites = await loopholeAgent.execute(profile);
    final scenarios = await strategyAgent.execute(opportunites);
    final avisConformite = await complianceAgent.execute(scenarios);

    return AgentAnalysisResult(
      profile: profile,
      opportunites: opportunites,
      scenarios: scenarios,
      avisConformite: avisConformite,
    );
  }
}
