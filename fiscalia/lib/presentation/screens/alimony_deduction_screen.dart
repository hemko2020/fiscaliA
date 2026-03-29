import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/alimony_deduction_model.dart';
import '../providers/alimony_deduction_provider.dart';

class AlimonyDeductionScreen extends ConsumerStatefulWidget {
  const AlimonyDeductionScreen({super.key});

  @override
  ConsumerState<AlimonyDeductionScreen> createState() =>
      _AlimonyDeductionScreenState();
}

class _AlimonyDeductionScreenState
    extends ConsumerState<AlimonyDeductionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _alimonyAmountController = TextEditingController();
  bool _isSpousalSupport = false;
  bool _isChildSupport = false;

  @override
  void dispose() {
    _alimonyAmountController.dispose();
    super.dispose();
  }

  void _calculateDeduction() {
    if (_formKey.currentState!.validate()) {
      final alimonyAmount =
          double.tryParse(
            _alimonyAmountController.text
                .replaceAll(' ', '')
                .replaceAll('€', ''),
          ) ??
          0;

      final model = AlimonyDeductionModel(
        alimonyAmount: alimonyAmount,
        isSpousalSupport: _isSpousalSupport,
        isChildSupport: _isChildSupport,
      );

      ref.read(alimonyDeductionProvider.notifier).state = model;
    }
  }

  @override
  Widget build(BuildContext context) {
    final deductionModel = ref.watch(alimonyDeductionProvider);
    final service = ref.watch(alimonyDeductionServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pension alimentaire'),
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
            if (deductionModel != null) ...[
              const SizedBox(height: 20),
              _buildResultCard(context, deductionModel, service),
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
                Icon(Icons.family_restroom, color: AppColors.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  'Déduction pension alimentaire',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Déduisez vos pensions alimentaires de vos revenus imposables.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            _buildRateInfo(
              context,
              'Plafond annuel',
              '6 674 €',
              'Article 156 II 2°',
            ),
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
                    Icons.info_outline,
                    color: AppColors.accentOrange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '⚠️ Le bénéficiaire doit déclarer ces sommes comme revenus imposables.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.accentOrange,
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
                'Votre pension alimentaire',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _alimonyAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Montant annuel versé (€)',
                  hintText: 'Ex: 5000',
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
                'Type de pension',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                title: const Text('Pension alimentaire (ex-conjoint)'),
                subtitle: const Text('Versement suite à divorce ou séparation'),
                value: _isSpousalSupport,
                onChanged: (value) {
                  setState(() {
                    _isSpousalSupport = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.platform,
              ),
              CheckboxListTile(
                title: const Text('Pension pour enfants'),
                subtitle: const Text('Versement pour l\'entretien des enfants'),
                value: _isChildSupport,
                onChanged: (value) {
                  setState(() {
                    _isChildSupport = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.platform,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _calculateDeduction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Calculer ma déduction'),
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
    AlimonyDeductionModel model,
    AlimonyDeductionService service,
  ) {
    final details = service.calculateFullDeductionDetails(model);

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
                  'Votre déduction fiscale',
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
              label: 'Montant versé',
              value:
                  '${(details['alimonyAmount'] as double).toStringAsFixed(0)} €',
            ),
            _buildResultRow(
              context,
              label: 'Type de pension',
              value: details['deductionType'] as String,
            ),
            _buildResultRow(
              context,
              label: 'Plafond annuel',
              value:
                  '${(details['maxDeduction'] as double).toStringAsFixed(0)} €',
            ),
            const Divider(height: 24),
            _buildResultRow(
              context,
              label: 'Déduction',
              value: '${(details['deduction'] as double).toStringAsFixed(0)} €',
              isHighlighted: true,
            ),
            if (details['excessAmount'] > 0) ...[
              const SizedBox(height: 8),
              Text(
                '⚠️ Montant non déductible : ${(details['excessAmount'] as double).toStringAsFixed(0)} €',
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
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          service.getLegalReference(
                            model.isSpousalSupport,
                            model.isChildSupport,
                          ),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.primaryBlue),
                        ),
                      ),
                    ],
                  ),
                  if (service
                      .getRecipientObligation(
                        model.isSpousalSupport,
                        model.isChildSupport,
                      )
                      .isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: AppColors.accentOrange,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            service.getRecipientObligation(
                              model.isSpousalSupport,
                              model.isChildSupport,
                            ),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.accentOrange),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance,
                    size: 16,
                    color: AppColors.accentGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cette déduction compte dans le plafond des niches fiscales (10 000€)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.accentGreen,
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
