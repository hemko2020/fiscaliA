import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/niche_ceiling_tracker_model.dart';
import '../providers/niche_alert_service.dart';
import '../providers/niche_ceiling_tracker_provider.dart';

class NicheCeilingTrackerScreen extends ConsumerWidget {
  const NicheCeilingTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracker = ref.watch(nicheCeilingTrackerProvider);
    final notifier = ref.read(nicheCeilingTrackerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plafond des niches fiscales'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.clearAll(),
            tooltip: 'Réinitialiser',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCeilingOverview(context, tracker),
            const SizedBox(height: 16),
            _buildAlertBanner(context, ref),
            const SizedBox(height: 24),
            _buildCreditBreakdown(context, tracker),
            const SizedBox(height: 24),
            _buildSuggestionsHorsPlafond(context, ref),
            const SizedBox(height: 24),
            _buildCreditList(context, tracker, notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildCeilingOverview(
    BuildContext context,
    NicheCeilingTrackerModel tracker,
  ) {
    final utilizationRate = tracker.utilizationRate;
    final isOverCeiling = tracker.isOverCeiling;
    final isNearCeiling = tracker.isNearCeiling;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isOverCeiling) {
      statusColor = AppColors.accentOrange;
      statusText = 'Dépassement';
      statusIcon = Icons.warning;
    } else if (isNearCeiling) {
      statusColor = AppColors.accentOrange;
      statusText = 'Proche du plafond';
      statusIcon = Icons.warning_amber;
    } else {
      statusColor = AppColors.accentGreen;
      statusText = 'Dans la limite';
      statusIcon = Icons.check_circle;
    }

    return Card(
      color: statusColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'État du plafond',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        statusText,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildProgressBar(context, utilizationRate, statusColor),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard(
                  context,
                  label: 'Plafond total',
                  value: '${tracker.totalCeiling.toStringAsFixed(0)} €',
                  icon: Icons.account_balance,
                ),
                _buildStatCard(
                  context,
                  label: 'Utilisé',
                  value: '${tracker.usedCeiling.toStringAsFixed(0)} €',
                  icon: Icons.trending_up,
                ),
                _buildStatCard(
                  context,
                  label: 'Restant',
                  value: '${tracker.remainingCeiling.toStringAsFixed(0)} €',
                  icon: Icons.trending_down,
                  color: statusColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(
    BuildContext context,
    double utilizationRate,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Taux d\'utilisation',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '${(utilizationRate * 100).toStringAsFixed(1)}%',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: utilizationRate.clamp(0, 1),
            backgroundColor: AppColors.backgroundLight,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    Color? color,
  }) {
    return Expanded(
      child: Card(
        color: (color ?? AppColors.primaryBlue).withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color ?? AppColors.primaryBlue, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color ?? AppColors.primaryBlue,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Banniere d'alerte plafond (Story 4.3) : avertissement jaune a 90%,
  /// alerte rouge en cas de depassement avec le montant perdu.
  Widget _buildAlertBanner(BuildContext context, WidgetRef ref) {
    final alerte = ref.watch(nicheAlertProvider);
    if (alerte.niveau == NicheAlertLevel.ok) {
      return const SizedBox.shrink();
    }

    final estDepasse = alerte.niveau == NicheAlertLevel.depasse;
    final couleur = estDepasse ? AppColors.accentRed : AppColors.accentOrange;
    final icone = estDepasse ? Icons.error : Icons.warning_amber;

    return Card(
      color: couleur.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: couleur, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icone, color: couleur),
                const SizedBox(width: 8),
                Text(
                  alerte.titre,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: couleur,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(alerte.message, style: Theme.of(context).textTheme.bodyMedium),
            if (alerte.recommandations.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...alerte.recommandations.map(
                (reco) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.arrow_right, size: 18, color: couleur),
                      Expanded(
                        child: Text(
                          reco,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Suggestions de dispositifs hors plafond, classees par impact avec
  /// score de risque (Story 4.4).
  Widget _buildSuggestionsHorsPlafond(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(suggestionsHorsPlafondProvider);
    final tmi = ref.watch(nicheSuggestionTmiProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Optimiser au-dela du plafond',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Ces dispositifs sont HORS plafond des niches fiscales : '
              'ils restent pleinement efficaces meme a 100% d\'utilisation.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Votre TMI : ${(tmi * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Expanded(
                  child: Slider(
                    value: tmi,
                    min: 0,
                    max: 0.45,
                    divisions: 4,
                    label: '${(tmi * 100).toStringAsFixed(0)}%',
                    onChanged: (v) => ref
                        .read(nicheSuggestionTmiProvider.notifier)
                        .state = v,
                  ),
                ),
              ],
            ),
            const Divider(),
            ...suggestions.map((s) => _buildSuggestionItem(context, s)),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(
    BuildContext context,
    SuggestionHorsPlafond suggestion,
  ) {
    final couleurRisque = suggestion.risqueScore <= 2
        ? AppColors.riskLow
        : suggestion.risqueScore == 3
            ? AppColors.riskMedium
            : AppColors.riskHigh;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        suggestion.nom,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: couleurRisque.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Risque ${suggestion.risqueScore}/5',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: couleurRisque,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  suggestion.description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  suggestion.baseLegale,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${suggestion.economieEstimee.toStringAsFixed(0)} €',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.accentGreen,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'd\'économie',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreditBreakdown(
    BuildContext context,
    NicheCeilingTrackerModel tracker,
  ) {
    final breakdown = tracker.getCreditBreakdown();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Répartition par type',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (breakdown.isEmpty)
              Text(
                'Aucun crédit enregistré',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            else
              ...breakdown.entries.map((entry) {
                final percentage = (entry.value / tracker.usedCeiling * 100)
                    .toStringAsFixed(1);
                return _buildBreakdownItem(
                  context,
                  type: entry.key,
                  amount: entry.value,
                  percentage: percentage,
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownItem(
    BuildContext context, {
    required String type,
    required double amount,
    required String percentage,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(type, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(
            '$percentage%',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(width: 8),
          Text(
            '${amount.toStringAsFixed(0)} €',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditList(
    BuildContext context,
    NicheCeilingTrackerModel tracker,
    NicheCeilingTrackerNotifier notifier,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Historique des crédits',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (tracker.creditEntries.isEmpty)
              Text(
                'Aucun crédit enregistré',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            else
              ...tracker.creditEntries.map((entry) {
                return _buildCreditListItem(context, entry, notifier);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditListItem(
    BuildContext context,
    NicheCreditEntry entry,
    NicheCeilingTrackerNotifier notifier,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.receipt_long,
            color: AppColors.primaryBlue,
            size: 20,
          ),
        ),
        title: Text(
          entry.creditType,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry.description != null)
              Text(
                entry.description!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            Text(
              '${entry.dateAdded.day}/${entry.dateAdded.month}/${entry.dateAdded.year}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${entry.amount.toStringAsFixed(0)} €',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.accentGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => notifier.removeCredit(entry.id),
              color: AppColors.accentOrange,
              tooltip: 'Supprimer',
            ),
          ],
        ),
      ),
    );
  }
}
