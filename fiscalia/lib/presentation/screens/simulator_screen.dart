import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/foyer_fiscal_model.dart';
import '../providers/fiscal_provider.dart';

class SimulatorScreen extends ConsumerStatefulWidget {
  const SimulatorScreen({super.key});

  @override
  ConsumerState<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends ConsumerState<SimulatorScreen> {
  final _incomeController = TextEditingController();
  final _expensesController = TextEditingController();
  SituationFamiliale _situation = SituationFamiliale.celibataire;
  int _nbEnfants = 0;
  bool _useRealExpenses = false;

  double? _impotBrut;
  double? _decote;
  double? _impotNet;
  double? _cehr;
  double? _tauxMarginal;
  double? _tauxMoyen;
  double? _parts;
  Map<int, double>? _detailsParTranche;
  double? _reductionQuotientFamilial;
  Map<String, dynamic>? _expensesComparison;

  int _currentStep = 0;

  @override
  void dispose() {
    _incomeController.dispose();
    _expensesController.dispose();
    super.dispose();
  }

  void _calculer() {
    final revenu = double.tryParse(_incomeController.text.replaceAll(' ', ''));
    if (revenu == null) return;

    final depensesReelles = _useRealExpenses
        ? double.tryParse(_expensesController.text.replaceAll(' ', '')) ?? 0
        : 0.0;

    final foyer = FoyerFiscalModel(
      situationFamiliale: _situation,
      nbEnfants: _nbEnfants,
      revenuNetImposable: revenu,
    );

    final result = ref
        .read(taxCalculatorProvider)
        .calculerImpotComplet(
          foyer,
          depensesReelles: depensesReelles,
          useRealExpenses: _useRealExpenses,
        );

    setState(() {
      _impotBrut = result['impotBrut'];
      _decote = result['decote'];
      _impotNet = result['impotNet'];
      _cehr = result['cehr'];
      _tauxMarginal = result['tauxMarginal'];
      _tauxMoyen = result['tauxMoyen'];
      _parts = result['parts'];
      _detailsParTranche = result['detailsParTranche']?.cast<int, double>();
      _reductionQuotientFamilial = result['reductionQuotientFamilial'];
      _expensesComparison =
          result['expensesComparison'] as Map<String, dynamic>?;
    });
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
    } else {
      _calculer();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulateur IR'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildCurrentStep(),
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.backgroundLight,
      child: Row(
        children: [
          _buildStepDot(0, 'Situation'),
          _buildStepLine(0),
          _buildStepDot(1, 'Revenus'),
          _buildStepLine(1),
          _buildStepDot(2, 'Enfants'),
          _buildStepLine(2),
          _buildStepDot(3, 'Depenses'),
          _buildStepLine(3),
          _buildStepDot(4, 'Resultat'),
        ],
      ),
    );
  }

  Widget _buildStepDot(int step, String label) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.primaryBlue : Colors.grey.shade300,
            border: isCurrent
                ? Border.all(color: AppColors.accentOrange, width: 3)
                : null,
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? AppColors.primaryBlue : Colors.grey,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int step) {
    final isActive = _currentStep > step;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isActive ? AppColors.primaryBlue : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      case 3:
        return _buildStep4();
      case 4:
        return _buildResults();
      default:
        return _buildStep1();
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Etape 1 : Situation familiale',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selectionnez votre situation familiale',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        ...SituationFamiliale.values.map((sit) {
          final isSelected = _situation == sit;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                width: 2,
              ),
            ),
            child: ListTile(
              leading: Icon(
                _getSituationIcon(sit),
                color: isSelected
                    ? AppColors.primaryBlue
                    : AppColors.textSecondary,
              ),
              title: Text(
                _getSituationLabel(sit),
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primaryBlue : null,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: AppColors.primaryBlue)
                  : null,
              onTap: () => setState(() => _situation = sit),
            ),
          );
        }),
      ],
    );
  }

  IconData _getSituationIcon(SituationFamiliale sit) {
    switch (sit) {
      case SituationFamiliale.celibataire:
        return Icons.person;
      case SituationFamiliale.marie:
        return Icons.people;
      case SituationFamiliale.pacse:
        return Icons.people_outline;
      case SituationFamiliale.divorce:
        return Icons.person_remove;
      case SituationFamiliale.veuf:
        return Icons.person_outline;
    }
  }

  String _getSituationLabel(SituationFamiliale sit) {
    switch (sit) {
      case SituationFamiliale.celibataire:
        return 'Celibataire';
      case SituationFamiliale.marie:
        return 'Marie(e)';
      case SituationFamiliale.pacse:
        return 'Pacse(e)';
      case SituationFamiliale.divorce:
        return 'Divorce(e)';
      case SituationFamiliale.veuf:
        return 'Veuf/Veuve';
    }
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Etape 2 : Revenu imposable',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Entrez votre revenu net imposable',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _incomeController,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixText: 'EUR ',
            prefixStyle: const TextStyle(
              fontSize: 24,
              color: AppColors.primaryBlue,
            ),
            suffixText: ',00',
            suffixStyle: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.primaryBlue,
                width: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: AppColors.accentOrange.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.accentOrange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Revenu net = salaire net + revenus fonciers + autres revenus',
                    style: TextStyle(
                      color: AppColors.accentOrange.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Etape 3 : Nombre d\'enfants',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ajoutez vos enfants a charge',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCounterButton(
                Icons.remove_circle_outline,
                _nbEnfants > 0 ? () => setState(() => _nbEnfants--) : null,
              ),
              Container(
                width: 100,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$_nbEnfants',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              _buildCounterButton(
                Icons.add_circle_outline,
                () => setState(() => _nbEnfants++),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Card(
          color: AppColors.accentGreen.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.calculate, color: AppColors.accentGreen),
                    const SizedBox(width: 12),
                    Text(
                      'Parts fiscales',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Base', '${_getBaseParts()} parts'),
                _buildInfoRow(
                  'Enfants ($_nbEnfants)',
                  '+ ${(_nbEnfants * 0.5).toStringAsFixed(1)} parts',
                ),
                const Divider(),
                _buildInfoRow(
                  'Total',
                  '${(_getBaseParts() + _nbEnfants * 0.5).toStringAsFixed(1)} parts',
                  isBold: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback? onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 40),
      color: onPressed != null ? AppColors.primaryBlue : Colors.grey,
    );
  }

  double _getBaseParts() {
    switch (_situation) {
      case SituationFamiliale.celibataire:
      case SituationFamiliale.divorce:
      case SituationFamiliale.veuf:
        return 1;
      case SituationFamiliale.marie:
      case SituationFamiliale.pacse:
        return 2;
    }
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? AppColors.primaryBlue : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Etape 4 : Depenses professionnelles',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Optionnel : comparez les deux options',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        SwitchListTile(
          title: const Text('Utiliser les depenses reelles'),
          subtitle: const Text(
            'Cochez si vous avez des frais professionnels eleves',
          ),
          value: _useRealExpenses,
          onChanged: (value) => setState(() => _useRealExpenses = value),
          activeTrackColor: AppColors.primaryBlue.withValues(alpha: 0.5),
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primaryBlue;
            }
            return null;
          }),
        ),
        if (_useRealExpenses) ...[
          const SizedBox(height: 16),
          TextField(
            controller: _expensesController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Depenses reelles (EUR)',
              hintText: 'Ex: 5000',
              prefixIcon: const Icon(Icons.receipt_long),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Abattement 10%',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Forfait automatique de 10% du revenu (plafond: 14 556 EUR)',
                    style: TextStyle(color: Colors.blue.shade700, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        Card(
          color: Colors.orange.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'A savoir',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Les depenses reelles sont recommandees si vos frais depassent 10% de votre revenu (transport, equipement, missions...)',
                  style: TextStyle(color: Colors.orange.shade700, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            TextButton(
              onPressed: _previousStep,
              child: const Row(
                children: [
                  Icon(Icons.arrow_back),
                  SizedBox(width: 8),
                  Text('Retour'),
                ],
              ),
            )
          else
            const SizedBox(width: 100),
          const Spacer(),
          ElevatedButton(
            onPressed: _currentStep < 4 ? _nextStep : _calculer,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Row(
              children: [
                Text(_currentStep < 4 ? 'Suivant' : 'Calculer'),
                const SizedBox(width: 8),
                Icon(_currentStep < 4 ? Icons.arrow_forward : Icons.calculate),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_impotNet == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resultats de votre simulation',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 24),

        // Main results card
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildResultRow(
                  'Impots net',
                  'EUR${_impotNet!.toStringAsFixed(0)}',
                  isHighlighted: true,
                ),
                const Divider(height: 24),
                _buildResultRow(
                  'Taux marginal',
                  '${(_tauxMarginal! * 100).toStringAsFixed(0)}%',
                ),
                _buildResultRow(
                  'Taux moyen',
                  '${(_tauxMoyen! * 100).toStringAsFixed(1)}%',
                ),
                _buildResultRow('Parts fiscales', _parts!.toStringAsFixed(1)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Details card
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail du calcul',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  'Impots brut',
                  'EUR${_impotBrut!.toStringAsFixed(0)}',
                ),
                if (_decote! > 0)
                  _buildDetailRow(
                    'Decote',
                    '- EUR${_decote!.toStringAsFixed(0)}',
                  ),
                if (_reductionQuotientFamilial! > 0)
                  _buildDetailRow(
                    'Plafond quotient familial',
                    '- EUR${_reductionQuotientFamilial!.toStringAsFixed(0)}',
                  ),
                if (_cehr! > 0)
                  _buildDetailRow('CEHR', '+ EUR${_cehr!.toStringAsFixed(0)}'),
              ],
            ),
          ),
        ),

        // Expenses comparison
        if (_expensesComparison != null) ...[
          const SizedBox(height: 16),
          Card(
            color: AppColors.accentGreen.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb, color: AppColors.accentGreen),
                      const SizedBox(width: 8),
                      Text(
                        'Comparaison des depenses',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentGreen,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    'Option 10%',
                    'EUR${(_expensesComparison!['deduction10Pourcent'] as double).toStringAsFixed(0)}',
                  ),
                  if (_useRealExpenses)
                    _buildDetailRow(
                      'Option reelles',
                      'EUR${(_expensesComparison!['depensesReelles'] as double).toStringAsFixed(0)}',
                    ),
                  const SizedBox(height: 8),
                  Text(
                    _expensesComparison!['meilleurOption'] == 'reelles'
                        ? 'L\'option depenses reelles est plus avantageuse!'
                        : 'L\'abattement 10% est recommende pour vous.',
                    style: TextStyle(
                      color: AppColors.accentGreen.withValues(alpha: 0.8),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 16),

        // CEHR info
        if (_cehr! > 0) ...[
          Card(
            color: Colors.red.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Contribution Exceptionnelle',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vous etes soumis a la CEHR car votre revenu depasse 250 000 EUR (seuil 2026).',
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'CEHR: EUR${_cehr!.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Bracket chart
        if (_detailsParTranche != null) _buildBracketChart(context),

        const SizedBox(height: 16),

        // Disclaimer
        Card(
          color: Colors.grey.shade100,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Calculs indicatifs bases sur les tranches 2026. Consulter un professionnel pour une analyse personnalisee.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultRow(
    String label,
    String value, {
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isHighlighted ? AppColors.primaryBlue : null,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isHighlighted ? 24 : 16,
              color: isHighlighted ? AppColors.primaryBlue : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildBracketChart(BuildContext context) {
    final sections = <PieChartSectionData>[];
    final colors = [
      AppColors.taxBracket0,
      AppColors.taxBracket11,
      AppColors.taxBracket30,
      AppColors.taxBracket41,
      AppColors.taxBracket45,
    ];
    final labels = ['0%', '11%', '30%', '41%', '45%'];

    for (int i = 0; i < 5; i++) {
      final montant = _detailsParTranche![i] ?? 0;
      if (montant > 0) {
        sections.add(
          PieChartSectionData(
            value: montant,
            title: labels[i],
            color: colors[i],
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }
    }

    if (sections.isEmpty) return const SizedBox.shrink();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Repartition par tranche',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 50,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildLegendItem('0%', AppColors.taxBracket0),
                _buildLegendItem('11%', AppColors.taxBracket11),
                _buildLegendItem('30%', AppColors.taxBracket30),
                _buildLegendItem('41%', AppColors.taxBracket41),
                _buildLegendItem('45%', AppColors.taxBracket45),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
