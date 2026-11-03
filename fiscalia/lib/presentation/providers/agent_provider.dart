import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../agents/agent_orchestrator.dart';
import '../../agents/models/agent_models.dart';
import '../../data/models/foyer_fiscal_model.dart';

final agentOrchestratorProvider = Provider<AgentOrchestrator>((ref) {
  return const AgentOrchestrator();
});

final agentAnalysisProvider =
    FutureProvider.family<AgentAnalysisResult, FoyerFiscalModel>((ref, foyer) {
      return ref.read(agentOrchestratorProvider).analyser(foyer);
    });
