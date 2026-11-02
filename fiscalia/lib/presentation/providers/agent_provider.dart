import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../agents/agent_orchestrator.dart';
import '../../agents/models/agent_models.dart';
import '../../agents/profile/profile_agent.dart';
import '../../data/models/foyer_fiscal_model.dart';
import 'monitoring_providers.dart';

final agentOrchestratorProvider = Provider<AgentOrchestrator>((ref) {
  // Le ProfileAgent recoit la configuration fiscale courante (Remote Config
  // si disponible) pour que le TMI du profil suive les baremes a jour.
  return AgentOrchestrator(
    profileAgent: ProfileAgent(config: ref.watch(taxConfigProvider)),
  );
});

final agentAnalysisProvider =
    FutureProvider.family<AgentAnalysisResult, FoyerFiscalModel>((ref, foyer) {
      return ref.read(agentOrchestratorProvider).analyser(foyer);
    });
