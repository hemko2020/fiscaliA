import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/tax_brackets.dart';
import 'niche_ceiling_tracker_screen.dart';

class NichesScreen extends ConsumerStatefulWidget {
  const NichesScreen({super.key});

  @override
  ConsumerState<NichesScreen> createState() => _NichesScreenState();
}

class _NichesScreenState extends ConsumerState<NichesScreen> {
  final double _usedNiche = 2500;

  double get _remainingNiche =>
      TaxBrackets2026.nicheCeilingGeneral - _usedNiche;
  double get _percentageUsed =>
      (_usedNiche / TaxBrackets2026.nicheCeilingGeneral) * 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Niches Fiscales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NicheCeilingTrackerScreen(),
                ),
              );
            },
            tooltip: 'Suivi du plafond',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCeilingCard(context),
            const SizedBox(height: 24),
            _buildDevicesList(context),
            const SizedBox(height: 24),
            _buildSuggestions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCeilingCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Plafond des niches',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 150,
                  width: 150,
                  child: CircularProgressIndicator(
                    value: _percentageUsed / 100,
                    strokeWidth: 15,
                    backgroundColor: AppColors.textSecondary.withValues(
                      alpha: 0.2,
                    ),
                    valueColor: AlwaysStoppedAnimation(
                      _percentageUsed > 90
                          ? AppColors.accentRed
                          : _percentageUsed > 70
                          ? AppColors.accentOrange
                          : AppColors.accentGreen,
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${_percentageUsed.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'utilisé',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  context,
                  'Utilisé',
                  '${_usedNiche.toStringAsFixed(0)} €',
                  AppColors.accentOrange,
                ),
                _buildStatItem(
                  context,
                  'Restant',
                  '${_remainingNiche.toStringAsFixed(0)} €',
                  AppColors.accentGreen,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDevicesList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dispositifs utilisés',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildDeviceItem(context, 'Emploi à domicile', 2000, Icons.home),
        _buildDeviceItem(context, 'Garde d\'enfants', 350, Icons.child_care),
        _buildDeviceItem(context, 'Dons', 150, Icons.favorite),
      ],
    );
  }

  Widget _buildDeviceItem(
    BuildContext context,
    String name,
    double amount,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryBlue),
        title: Text(name),
        trailing: Text(
          '${amount.toStringAsFixed(0)} €',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggestions (hors plafond)',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          color: AppColors.accentGreen.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.savings, color: AppColors.accentGreen),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PER (Plan Épargne Retraite)',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Jusqu\'à 37,094 €/an déductible',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const Text('→', style: TextStyle(fontSize: 20)),
                  ],
                ),
              ],
            ),
          ),
        ),
        Card(
          color: AppColors.accentGreen.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.house, color: AppColors.accentGreen),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Déficit foncier',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Jusqu\'à 10,700 €/an déductible',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const Text('→', style: TextStyle(fontSize: 20)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
