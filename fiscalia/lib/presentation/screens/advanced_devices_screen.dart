import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../providers/subscription_provider.dart';
import '../widgets/premium_form_widgets.dart';
import 'demembrement_screen.dart';
import 'ifi_calculator_screen.dart';
import 'lmnp_simulation_screen.dart';
import 'pacte_dutreil_screen.dart';
import 'paywall_screen.dart';
import 'per_optimization_screen.dart';
import 'sci_comparison_screen.dart';
import 'sofica_girardin_screen.dart';

/// Hub des dispositifs avances et experts (Epic 8 - contenu premium).
///
/// Gating (Story 9.3) : niveau Avance = FiscalIA Pro, niveau Expert =
/// FiscalIA Expert. Les utilisateurs gratuits voient le paywall.
class AdvancedDevicesScreen extends ConsumerWidget {
  const AdvancedDevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final abonnement = ref.watch(subscriptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispositifs premium'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          if (!abonnement.estPremium)
            IconButton(
              icon: const Icon(Icons.workspace_premium),
              tooltip: 'Passer premium',
              onPressed: () => PaywallScreen.ouvrir(context),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _titreSection(context, 'Niveau Avance - FiscalIA Pro'),
          _carteDispositif(
            context,
            ref,
            titre: 'PER - Strategie avancee',
            sousTitre: 'Reports 3 ans, mutualisation couple',
            icone: Icons.savings,
            risque: 1,
            niveauRequis: NiveauAbonnement.pro,
            destination: const PerOptimizationScreen(),
          ),
          _carteDispositif(
            context,
            ref,
            titre: 'LMNP - Amortissement',
            sousTitre: 'Loyers quasi non imposables au regime reel',
            icone: Icons.apartment,
            risque: 2,
            niveauRequis: NiveauAbonnement.pro,
            destination: const LmnpSimulationScreen(),
          ),
          _carteDispositif(
            context,
            ref,
            titre: 'SOFICA & Girardin',
            sousTitre: 'Reductions one-shot, plafond 18 000 EUR',
            icone: Icons.movie,
            risque: 4,
            niveauRequis: NiveauAbonnement.pro,
            destination: const SoficaGirardinScreen(),
          ),
          const SizedBox(height: 16),
          _titreSection(context, 'Niveau Expert - FiscalIA Expert'),
          _carteDispositif(
            context,
            ref,
            titre: 'SCI - IR ou IS ?',
            sousTitre: 'Comparateur de regimes fiscaux',
            icone: Icons.domain,
            risque: 3,
            niveauRequis: NiveauAbonnement.expert,
            destination: const SciComparisonScreen(),
          ),
          _carteDispositif(
            context,
            ref,
            titre: 'Demembrement de propriete',
            sousTitre: 'Transmission optimisee (Art. 669 CGI)',
            icone: Icons.family_restroom,
            risque: 3,
            niveauRequis: NiveauAbonnement.expert,
            destination: const DemembrementScreen(),
          ),
          _carteDispositif(
            context,
            ref,
            titre: 'Pacte Dutreil',
            sousTitre: 'Transmettre son entreprise (-75% de droits)',
            icone: Icons.business,
            risque: 3,
            niveauRequis: NiveauAbonnement.expert,
            destination: const PacteDutreilScreen(),
          ),
          _carteDispositif(
            context,
            ref,
            titre: 'IFI - Calculateur',
            sousTitre: 'Impot sur la fortune immobiliere et strategies',
            icone: Icons.account_balance,
            risque: 2,
            niveauRequis: NiveauAbonnement.expert,
            destination: const IfiCalculatorScreen(),
          ),
          const SizedBox(height: 24),
          Card(
            color: AppColors.accentRed.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.gavel, color: AppColors.accentRed),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Les strategies expertes doivent etre validees par un '
                      'avocat fiscaliste ou un notaire avant mise en oeuvre '
                      '(Art. L64 LPF - abus de droit).',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _titreSection(BuildContext context, String titre) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        titre,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _carteDispositif(
    BuildContext context,
    WidgetRef ref, {
    required String titre,
    required String sousTitre,
    required IconData icone,
    required int risque,
    required NiveauAbonnement niveauRequis,
    required Widget destination,
  }) {
    final abonnement = ref.watch(subscriptionProvider);
    final deverrouille = niveauRequis == NiveauAbonnement.expert
        ? abonnement.accesExpert
        : abonnement.accesAvance;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
          child: Icon(
            deverrouille ? icone : Icons.lock_outline,
            color: AppColors.primaryBlue,
          ),
        ),
        title: Text(titre),
        subtitle: Text(sousTitre),
        trailing: deverrouille
            ? PremiumFormWidgets.badgeRisque(context, risque)
            : const Chip(
                label: Text('Premium', style: TextStyle(fontSize: 11)),
                backgroundColor: AppColors.accentOrange,
                labelStyle: TextStyle(color: Colors.white),
                padding: EdgeInsets.zero,
              ),
        onTap: () async {
          if (deverrouille) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destination),
            );
          } else {
            // Apercu du benefice puis paywall plein ecran (Story 9.3).
            await PaywallScreen.ouvrir(context, fonctionnalite: titre);
          }
        },
      ),
    );
  }
}
