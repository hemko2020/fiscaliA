import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/union_dues_credit_model.dart';
import '../providers/union_dues_credit_provider.dart';

class UnionDuesCreditScreen extends ConsumerStatefulWidget {
  const UnionDuesCreditScreen({super.key});

  @override
  ConsumerState<UnionDuesCreditScreen> createState() =>
      _UnionDuesCreditScreenState();
}

class _UnionDuesCreditScreenState extends ConsumerState<UnionDuesCreditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _unionDuesController = TextEditingController();
  final _grossIncomeController = TextEditingController();

  @override
  void dispose() {
    _unionDuesController.dispose();
    _grossIncomeController.dispose();
    super.dispose();
  }

  void _calculateCredit() {
    if (_formKey.currentState!.validate()) {
      final unionDues =
          double.tryParse(
            _unionDuesController.text.replaceAll(' ', '').replaceAll('€', ''),
          ) ??
          0;
      final grossIncome =
          double.tryParse(
            _grossIncomeController.text.replaceAll(' ', '').replaceAll('€', ''),
          ) ??
          0;

      final model = UnionDuesCreditModel(
        unionDues: unionDues,
        grossIncome: grossIncome,
      );

      ref.read(unionDuesCreditProvider.notifier).state = model;
    }
  }

  @override
  Widget build(BuildContext context) {
    final creditModel = ref.watch(unionDuesCreditProvider);
    final service = ref.watch(unionDuesCreditServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotisations syndicales'),
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
                Icon(Icons.groups, color: AppColors.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  'Crédit d\'impôt cotisations syndicales',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Bénéficiez d\'un crédit d\'impôt de 66% de vos cotisations syndicales.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            _buildRateInfo(context, 'Taux du crédit', '66%', 'des cotisations'),
            _buildRateInfo(context, 'Plafond', '1%', 'du revenu brut'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.accentOrange.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.accentOrange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '⚠️ 90% des contribuables oublient de réclamer ce crédit d\'impôt !',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.accentOrange,
                        fontWeight: FontWeight.bold,
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

  Widget _buildRateInfo(
    BuildContext context,
    String title,
    String rate,
    String limit,
  ) {
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
                'Vos cotisations syndicales',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _unionDuesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Montant des cotisations (€)',
                  hintText: 'Ex: 300',
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
              TextFormField(
                controller: _grossIncomeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Revenu brut annuel (€)',
                  hintText: 'Ex: 50000',
                  prefixIcon: const Icon(Icons.account_balance_wallet),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre revenu brut';
                  }
                  final amount = double.tryParse(
                    value.replaceAll(' ', '').replaceAll('€', ''),
                  );
                  if (amount == null) {
                    return 'Montant invalide';
                  }
                  if (amount < 0) {
                    return 'Le revenu ne peut pas être négatif';
                  }
                  return null;
                },
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

  Widget _buildResultCard(
    BuildContext context,
    UnionDuesCreditModel model,
    UnionDuesCreditService service,
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
              label: 'Cotisations déclarées',
              value: '${(details['unionDues'] as double).toStringAsFixed(0)} €',
            ),
            _buildResultRow(
              context,
              label: 'Revenu brut',
              value:
                  '${(details['grossIncome'] as double).toStringAsFixed(0)} €',
            ),
            _buildResultRow(
              context,
              label: 'Plafond applicable (1%)',
              value: '${(details['ceiling'] as double).toStringAsFixed(0)} €',
            ),
            const Divider(height: 24),
            _buildResultRow(
              context,
              label: 'Crédit d\'impôt (66%)',
              value: '${(details['credit'] as double).toStringAsFixed(0)} €',
              isHighlighted: true,
            ),
            if (details['excessDues'] > 0) ...[
              const SizedBox(height: 8),
              Text(
                '⚠️ Cotisations non prises en compte : ${(details['excessDues'] as double).toStringAsFixed(0)} €',
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
