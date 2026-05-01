import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/per_tracker_model.dart';
import '../providers/per_tracker_provider.dart';
import '../providers/fiscal_provider.dart';

import '../../data/models/foyer_fiscal_model.dart';

class PerTrackerScreen extends ConsumerStatefulWidget {
  const PerTrackerScreen({super.key});

  @override
  ConsumerState<PerTrackerScreen> createState() => _PerTrackerScreenState();
}

class _PerTrackerScreenState extends ConsumerState<PerTrackerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCeilingController = TextEditingController();
  final _carryover1Controller = TextEditingController();
  final _carryover2Controller = TextEditingController();
  final _carryover3Controller = TextEditingController();
  final _contributionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingData();
    });
  }

  void _loadExistingData() {
    final per = ref.read(perTrackerProvider);
    if (per != null) {
      _currentCeilingController.text = per.currentYearCeiling.toStringAsFixed(0);
      _carryover1Controller.text = per.carryoverYear1.toStringAsFixed(0);
      _carryover2Controller.text = per.carryoverYear2.toStringAsFixed(0);
      _carryover3Controller.text = per.carryoverYear3.toStringAsFixed(0);
      _contributionController.text = per.totalContributedThisYear.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _currentCeilingController.dispose();
    _carryover1Controller.dispose();
    _carryover2Controller.dispose();
    _carryover3Controller.dispose();
    _contributionController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      ref.read(perTrackerProvider.notifier).savePerData(
        currentYearCeiling: double.tryParse(_currentCeilingController.text) ?? 0,
        carryoverYear1: double.tryParse(_carryover1Controller.text) ?? 0,
        carryoverYear2: double.tryParse(_carryover2Controller.text) ?? 0,
        carryoverYear3: double.tryParse(_carryover3Controller.text) ?? 0,
      );
      
      final contribution = double.tryParse(_contributionController.text) ?? 0;
      ref.read(perTrackerProvider.notifier).updateContributions(contribution);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Données PER enregistrées avec succès')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final per = ref.watch(perTrackerProvider);
    
    // Calculate TMI for savings projection (Using default FoyerFiscal for now, as it's not globally provided)
    final taxCalculator = ref.read(taxCalculatorProvider);
    final defaultFoyer = FoyerFiscalModel(
      revenuNetImposable: 50000,
      situationFamiliale: SituationFamiliale.celibataire,
      nbEnfants: 0,
    ); // Placeholder
    final tmi = taxCalculator.getTMI(defaultFoyer);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi PER'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderInfo(),
              const SizedBox(height: 24),
              
              if (per != null) ...[
                _buildDashboard(per, tmi),
                const SizedBox(height: 24),
                _buildExpirationWarning(per),
                const SizedBox(height: 24),
              ],
              
              _buildInputSection(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveSettings,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.save),
        label: const Text('Enregistrer'),
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              const Text(
                'Plan d\'Épargne Retraite (PER)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Les versements sur un PER sont déductibles de vos revenus imposables. '
            'Vous pouvez retrouver vos plafonds sur votre dernier avis d\'imposition.',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(PerTrackerModel per, double tmi) {
    final calcService = ref.read(perCalculationServiceProvider);
    final potentialSavings = calcService.calculatePotentialSavings(per.remainingCeiling, tmi);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tableau de bord PER',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // Progress Bar
            LinearProgressIndicator(
              value: per.totalAvailableCeiling > 0 
                  ? per.totalContributedThisYear / per.totalAvailableCeiling 
                  : 0,
              backgroundColor: Colors.grey.shade200,
              color: AppColors.accentGreen,
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatColumn('Versé', '${per.totalContributedThisYear.toStringAsFixed(0)} €', AppColors.accentGreen),
                _buildStatColumn('Plafond Total', '${per.totalAvailableCeiling.toStringAsFixed(0)} €', AppColors.primaryBlue),
                _buildStatColumn('Reste', '${per.remainingCeiling.toStringAsFixed(0)} €', AppColors.accentOrange),
              ],
            ),
            
            const Divider(height: 32),
            
            // Projection
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.savings, color: AppColors.accentGreen, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Économie d\'impôt potentielle maximale', 
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(
                          '+ ${potentialSavings.toStringAsFixed(0)} €',
                          style: TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentGreen,
                          ),
                        ),
                        Text('Si vous versez les ${per.remainingCeiling.toStringAsFixed(0)} € restants avant le 31 décembre (TMI: ${tmi.toStringAsFixed(0)}%)',
                          style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildExpirationWarning(PerTrackerModel per) {
    if (!per.isApproachingExpiration) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentOrange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentOrange),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.accentOrange, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Attention : Plafond expirant',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentOrange),
                ),
                const SizedBox(height: 4),
                Text(
                  'Vous avez ${per.expiringAmount.toStringAsFixed(0)} € de plafond de l\'année N-3 qui expireront définitivement au 31 décembre si vous ne les utilisez pas.',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vos données PER',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _currentCeilingController,
              decoration: const InputDecoration(
                labelText: 'Plafond de l\'année en cours (€)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            const Text('Plafonds non utilisés des années précédentes :', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            
            TextFormField(
              controller: _carryover1Controller,
              decoration: const InputDecoration(
                labelText: 'Année N-1 (€)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            
            TextFormField(
              controller: _carryover2Controller,
              decoration: const InputDecoration(
                labelText: 'Année N-2 (€)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            
            TextFormField(
              controller: _carryover3Controller,
              decoration: const InputDecoration(
                labelText: 'Année N-3 (Expire cette année) (€)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            
            const Divider(height: 32),
            
            TextFormField(
              controller: _contributionController,
              decoration: const InputDecoration(
                labelText: 'Total déjà versé cette année (€)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance_wallet),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }
}