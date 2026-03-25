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
  SituationFamiliale _situation = SituationFamiliale.celibataire;
  int _nbEnfants = 0;
  double? _impotNet;
  double? _tauxMarginal;
  double? _tauxMoyen;
  Map<int, double>? _detailsParTranche;

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }

  void _calculer() {
    final revenu = double.tryParse(_incomeController.text.replaceAll(' ', ''));
    if (revenu == null) return;

    final foyer = FoyerFiscalModel(
      situationFamiliale: _situation,
      nbEnfants: _nbEnfants,
      revenuNetImposable: revenu,
    );

    final result = ref.read(taxCalculatorProvider).calculerImpot(foyer);

    setState(() {
      _impotNet = result['impotNet'];
      _tauxMarginal = result['tauxMarginal'];
      _tauxMoyen = result['tauxMoyen'];
      _detailsParTranche = result['detailsParTranche']?.cast<int, double>();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simulateur IR')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStep1(context),
            const SizedBox(height: 24),
            _buildStep2(context),
            const SizedBox(height: 24),
            _buildStep3(context),
            const SizedBox(height: 24),
            _buildResults(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Etape 1 : Situation familiale',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: SituationFamiliale.values.map((sit) {
            final isSelected = _situation == sit;
            return ChoiceChip(
              label: Text(_getSituationLabel(sit)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _situation = sit);
              },
            );
          }).toList(),
        ),
      ],
    );
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

  Widget _buildStep2(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Etape 2 : Revenu imposable',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _incomeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Revenu net imposable (EUR)',
            hintText: 'Ex: 42000',
            prefixIcon: Icon(Icons.euro),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Etape 3 : Nombre d\'enfants',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton(
              onPressed: _nbEnfants > 0
                  ? () => setState(() => _nbEnfants--)
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryBlue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_nbEnfants',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _nbEnfants++),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _calculer,
            child: const Text('Calculer'),
          ),
        ),
      ],
    );
  }

  Widget _buildResults(BuildContext context) {
    if (_impotNet == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resultats',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildResultRow(
                  'Impots net',
                  'EUR${_impotNet!.toStringAsFixed(0)}',
                ),
                _buildResultRow(
                  'Taux marginal',
                  '${(_tauxMarginal! * 100).toStringAsFixed(0)}%',
                ),
                _buildResultRow(
                  'Taux moyen',
                  '${(_tauxMoyen! * 100).toStringAsFixed(1)}%',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_detailsParTranche != null) _buildBracketChart(context),
      ],
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
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

    for (int i = 0; i < 5; i++) {
      final montant = _detailsParTranche![i] ?? 0;
      if (montant > 0) {
        sections.add(
          PieChartSectionData(
            value: montant,
            title: '',
            color: colors[i],
            radius: 60,
          ),
        );
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
