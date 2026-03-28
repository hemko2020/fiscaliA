import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/school_fees_credit_model.dart';
import '../providers/school_fees_credit_provider.dart';

class SchoolFeesCreditScreen extends ConsumerStatefulWidget {
  const SchoolFeesCreditScreen({super.key});

  @override
  ConsumerState<SchoolFeesCreditScreen> createState() => _SchoolFeesCreditScreenState();
}

class _SchoolFeesCreditScreenState extends ConsumerState<SchoolFeesCreditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _expensesController = TextEditingController();
  int _numberOfChildren = 1;
  bool _isSecondaryEducation = false;

  @override
  void dispose() {
    _expensesController.dispose();
    super.dispose();
  }

  void _calculateCredit() {
    if (_formKey.currentState!.validate()) {
      final expenses = double.tryParse(_expensesController.text.replaceAll(' ', '').replaceAll('€', '')) ?? 0;
      
      final model = SchoolFeesCreditModel(
        expenses: expenses,
        numberOfChildren: _numberOfChildren,
        isSecondaryEducation: _isSecondaryEducation,
      );
      
      ref.read(schoolFeesCreditProvider.notifier).state = model;
    }
  }

  @override
  Widget build(BuildContext context) {
    final creditModel = ref.watch(schoolFeesCreditProvider);
    final service = ref.watch(schoolFeesCreditServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Frais de scolarité'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(context),
            const SizedBox(height: 20),
            _buildForm(context),
            if (creditModel != null) ...[
              const SizedBox(height: 20),
              _buildResultCard(context, creditModel, service),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      color: AppColors.primaryBlue.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school, color: AppColors.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  'Crédit d\'impôt frais de scolarité',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Bénéficiez d\'un crédit d\'impôt de 50% de vos frais de scolarité pour vos enfants.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            _buildRateInfo(context, 'Enseignement secondaire', '153€', 'par enfant'),
            _buildRateInfo(context, 'Enseignement supérieur', '100€', 'par enfant'),
          ],
        ),
      ),
    );
  }

  Widget _buildRateInfo(BuildContext context, String title, String rate, String limit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              rate,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.accentGreen,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$title ($limit)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vos frais de scolarité',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _expensesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Montant des frais (€)',
                  hintText: 'Ex: 2000',
                  prefixIcon: const Icon(Icons.euro),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un montant';
                  }
                  final amount = double.tryParse(value.replaceAll(' ', '').replaceAll('€', ''));
                  if (amount == null) {
                    return 'Montant invalide';
                  }
                  if (amount < 0) {
                    return 'Le montant ne peut pas être négatif';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Nombre d\'enfants',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              _buildCounter(
                context,
                label: 'Enfants scolarisés',
                value: _numberOfChildren,
                onChanged: (value) => setState(() => _numberOfChildren = value),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Enseignement secondaire'),
                subtitle: const Text('Plafond majoré à 153€ par enfant'),
                value: _isSecondaryEducation,
                onChanged: (value) => setState(() => _isSecondaryEducation = value),
                activeTrackColor: AppColors.accentGreen.withValues(alpha: 0.5),
                activeThumbColor: AppColors.accentGreen,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _calculateCredit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Calculer mon crédit d\'impôt'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounter(
    BuildContext context, {
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Card(
      color: AppColors.backgroundLight,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: value > 1 ? () => onChanged(value - 1) : null,
                  color: AppColors.primaryBlue,
                ),
                Text(
                  '$value',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: value < 10 ? () => onChanged(value + 1) : null,
                  color: AppColors.primaryBlue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(
    BuildContext context,
    SchoolFeesCreditModel model,
    SchoolFeesCreditService service,
  ) {
    final details = service.calculateFullCreditDetails(model);

    return Card(
      color: AppColors.accentGreen.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.accentGreen, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Votre crédit d\'impôt',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentGreen,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildResultRow(
              context,
              label: 'Frais déclarés',
              value: '${(details['expenses'] as double).toStringAsFixed(0)} €',
            ),
            _buildResultRow(
              context,
              label: 'Plafond applicable',
              value: '${(details['ceiling'] as double).toStringAsFixed(0)} €',
            ),
            const Divider(height: 24),
            _buildResultRow(
              context,
              label: 'Crédit d\'impôt (50%)',
              value: '${(details['credit'] as double).toStringAsFixed(0)} €',
              isHighlighted: true,
            ),
            if (details['excessExpenses'] > 0) ...[
              const SizedBox(height: 8),
              Text(
                '⚠️ Frais non pris en compte : ${(details['excessExpenses'] as double).toStringAsFixed(0)} €',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.accentOrange,
                    ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppColors.primaryBlue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ce crédit compte dans le plafond des niches fiscales (10 000€)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primaryBlue,
                          ),
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

  Widget _buildResultRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isHighlighted ? AppColors.accentGreen : null,
                  fontWeight: isHighlighted ? FontWeight.bold : null,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isHighlighted ? AppColors.accentGreen : null,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
