import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/home_employment_credit_model.dart';
import '../providers/home_employment_credit_provider.dart';

class HomeEmploymentCreditScreen extends ConsumerStatefulWidget {
  const HomeEmploymentCreditScreen({super.key});

  @override
  ConsumerState<HomeEmploymentCreditScreen> createState() =>
      _HomeEmploymentCreditScreenState();
}

class _HomeEmploymentCreditScreenState
    extends ConsumerState<HomeEmploymentCreditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _expensesController = TextEditingController();
  int _numberOfChildren = 0;
  int _numberOfElderly = 0;
  bool _isFirstYear = false;

  @override
  void dispose() {
    _expensesController.dispose();
    super.dispose();
  }

  void _calculateCredit() {
    if (_formKey.currentState!.validate()) {
      final expenses =
          double.tryParse(
            _expensesController.text.replaceAll(' ', '').replaceAll('€', ''),
          ) ??
          0;

      final model = HomeEmploymentCreditModel(
        expenses: expenses,
        numberOfChildren: _numberOfChildren,
        numberOfElderly: _numberOfElderly,
        isFirstYear: _isFirstYear,
      );

      ref.read(homeEmploymentCreditProvider.notifier).state = model;
    }
  }

  @override
  Widget build(BuildContext context) {
    final creditModel = ref.watch(homeEmploymentCreditProvider);
    final service = ref.watch(homeEmploymentCreditServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emploi à domicile'),
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
                Icon(Icons.info_outline, color: AppColors.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  'Crédit d\'impôt emploi à domicile',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Bénéficiez d\'un crédit d\'impôt de 50% de vos dépenses pour l\'emploi d\'un salarié à domicile (garde d\'enfants, ménage, jardinage...).',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Plafond de base : 12 000€ (+ 1 500€ par enfant ou personne âgée)',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
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
                'Vos dépenses',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _expensesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Montant des dépenses (€)',
                  hintText: 'Ex: 8000',
                  prefixIcon: const Icon(Icons.euro),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un montant';
                  }
                  final amount = double.tryParse(
                    value.replaceAll(' ', '').replaceAll('€', ''),
                  );
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
                'Majorations du plafond',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildCounter(
                      context,
                      label: 'Enfants',
                      value: _numberOfChildren,
                      onChanged: (value) =>
                          setState(() => _numberOfChildren = value),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCounter(
                      context,
                      label: 'Personnes âgées',
                      value: _numberOfElderly,
                      onChanged: (value) =>
                          setState(() => _numberOfElderly = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Première année d\'emploi'),
                subtitle: const Text('Plafond majoré de 3 000€'),
                value: _isFirstYear,
                onChanged: (value) => setState(() => _isFirstYear = value),
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
                  onPressed: value > 0 ? () => onChanged(value - 1) : null,
                  color: AppColors.primaryBlue,
                ),
                Text(
                  '$value',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
    HomeEmploymentCreditModel model,
    HomeEmploymentCreditService service,
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
                Icon(
                  Icons.check_circle,
                  color: AppColors.accentGreen,
                  size: 28,
                ),
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
              label: 'Dépenses déclarées',
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
                '⚠️ Dépenses non prises en compte : ${(details['excessExpenses'] as double).toStringAsFixed(0)} €',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.accentOrange),
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
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.primaryBlue,
                  ),
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
