import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/donation_credit_model.dart';
import '../providers/donation_credit_provider.dart';

class DonationCreditScreen extends ConsumerStatefulWidget {
  const DonationCreditScreen({super.key});

  @override
  ConsumerState<DonationCreditScreen> createState() =>
      _DonationCreditScreenState();
}

class _DonationCreditScreenState extends ConsumerState<DonationCreditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _incomeController = TextEditingController();
  DonationType _donationType = DonationType.generalInterest;

  @override
  void dispose() {
    _amountController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  void _calculateReduction() {
    if (_formKey.currentState!.validate()) {
      final amount =
          double.tryParse(
            _amountController.text.replaceAll(' ', '').replaceAll('€', ''),
          ) ??
          0;
      final income =
          double.tryParse(
            _incomeController.text.replaceAll(' ', '').replaceAll('€', ''),
          ) ??
          0;

      final model = DonationCreditModel(
        amount: amount,
        donationType: _donationType,
        taxableIncome: income,
      );

      ref.read(donationCreditProvider.notifier).state = model;
    }
  }

  @override
  Widget build(BuildContext context) {
    final creditModel = ref.watch(donationCreditProvider);
    final service = ref.watch(donationCreditServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dons aux associations'),
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
                Icon(Icons.favorite, color: AppColors.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  'Réduction d\'impôt pour dons',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Bénéficiez d\'une réduction d\'impôt pour vos dons aux œuvres caritatives.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            _buildRateInfo(
              context,
              'Intérêt général',
              '66%',
              'jusqu\'à 20% du revenu imposable',
            ),
            _buildRateInfo(
              context,
              'Personnes en difficulté',
              '75%',
              'jusqu\'à 1 000€',
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
                'Type de don',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SegmentedButton<DonationType>(
                segments: const [
                  ButtonSegment(
                    value: DonationType.generalInterest,
                    label: Text('Intérêt général'),
                    icon: Icon(Icons.public),
                  ),
                  ButtonSegment(
                    value: DonationType.peopleInNeed,
                    label: Text('Personnes en difficulté'),
                    icon: Icon(Icons.volunteer_activism),
                  ),
                ],
                selected: {_donationType},
                onSelectionChanged: (Set<DonationType> selection) {
                  setState(() => _donationType = selection.first);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.primaryBlue;
                    }
                    return null;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return null;
                  }),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Montant du don (€)',
                  hintText: 'Ex: 500',
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
              if (_donationType == DonationType.generalInterest) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _incomeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Revenu imposable (€)',
                    hintText: 'Ex: 50000',
                    prefixIcon: const Icon(Icons.account_balance_wallet),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre revenu imposable';
                    }
                    final income = double.tryParse(
                      value.replaceAll(' ', '').replaceAll('€', ''),
                    );
                    if (income == null) {
                      return 'Montant invalide';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _calculateReduction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Calculer ma réduction'),
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
    DonationCreditModel model,
    DonationCreditService service,
  ) {
    final details = service.calculateFullReductionDetails(model);

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
                  'Votre réduction d\'impôt',
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
              label: 'Montant du don',
              value: '${(details['amount'] as double).toStringAsFixed(0)} €',
            ),
            _buildResultRow(
              context,
              label: 'Taux de réduction',
              value:
                  '${((details['reductionRate'] as double) * 100).toStringAsFixed(0)}%',
            ),
            _buildResultRow(
              context,
              label: 'Plafond applicable',
              value:
                  '${(details['maxDeduction'] as double).toStringAsFixed(0)} €',
            ),
            const Divider(height: 24),
            _buildResultRow(
              context,
              label: 'Réduction d\'impôt',
              value: '${(details['reduction'] as double).toStringAsFixed(0)} €',
              isHighlighted: true,
            ),
            if (details['excessDonation'] > 0) ...[
              const SizedBox(height: 8),
              Text(
                '⚠️ Don non déductible : ${(details['excessDonation'] as double).toStringAsFixed(0)} €',
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
                      'Cette réduction ne compte pas dans le plafond des niches fiscales',
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
