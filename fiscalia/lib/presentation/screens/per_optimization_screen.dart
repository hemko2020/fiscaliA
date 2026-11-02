import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/per_optimization_model.dart';
import '../providers/per_optimization_provider.dart';
import '../widgets/premium_form_widgets.dart';

/// Ecran des strategies PER avancees (Story 8.1) : reports 3 ans et
/// mutualisation couple (Art. 163 quatervicies CGI).
class PerOptimizationScreen extends ConsumerStatefulWidget {
  const PerOptimizationScreen({super.key});

  @override
  ConsumerState<PerOptimizationScreen> createState() =>
      _PerOptimizationScreenState();
}

class _PerOptimizationScreenState extends ConsumerState<PerOptimizationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _revenu1Controller = TextEditingController();
  final _revenu2Controller = TextEditingController();
  final _reports1Controller = TextEditingController();
  final _reports2Controller = TextEditingController();
  final _versementController = TextEditingController();
  double _tmi = 0.30;
  final _fmt = NumberFormat('#,##0', 'fr_FR');

  @override
  void dispose() {
    _revenu1Controller.dispose();
    _revenu2Controller.dispose();
    _reports1Controller.dispose();
    _reports2Controller.dispose();
    _versementController.dispose();
    super.dispose();
  }

  void _calculer() {
    if (!_formKey.currentState!.validate()) return;
    final parse = PremiumFormWidgets.parseMontant;
    final resultat = ref.read(perOptimizationServiceProvider).optimiser(
          PerOptimizationModel(
            revenuDeclarant1: parse(_revenu1Controller.text),
            revenuDeclarant2: parse(_revenu2Controller.text),
            tmi: _tmi,
            reportsDeclarant1: [parse(_reports1Controller.text), 0, 0],
            reportsDeclarant2: [parse(_reports2Controller.text), 0, 0],
            versementEnvisage: parse(_versementController.text),
          ),
        );
    ref.read(perOptimizationProvider.notifier).state = resultat;
  }

  @override
  Widget build(BuildContext context) {
    final resultat = ref.watch(perOptimizationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PER - Strategie avancee'),
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
              PremiumFormWidgets.champMontant(
                controller: _revenu1Controller,
                label: 'Revenu net imposable (declarant 1)',
              ),
              PremiumFormWidgets.champMontant(
                controller: _revenu2Controller,
                label: 'Revenu net imposable (declarant 2)',
                hint: '0 si celibataire',
              ),
              PremiumFormWidgets.champMontant(
                controller: _reports1Controller,
                label: 'Plafonds non utilises des 3 dernieres annees (D1)',
              ),
              PremiumFormWidgets.champMontant(
                controller: _reports2Controller,
                label: 'Plafonds non utilises (D2)',
              ),
              PremiumFormWidgets.champMontant(
                controller: _versementController,
                label: 'Versement PER envisage cette annee',
              ),
              Text(
                'Taux marginal d\'imposition : '
                '${(_tmi * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Slider(
                value: _tmi,
                min: 0,
                max: 0.45,
                divisions: 4,
                label: '${(_tmi * 100).toStringAsFixed(0)}%',
                onChanged: (v) => setState(() => _tmi = v),
              ),
              const SizedBox(height: 8),
              PremiumFormWidgets.boutonCalculer(_calculer),
              if (resultat != null) ...[
                PremiumFormWidgets.carteResultats(
                  context: context,
                  titre: 'Plafonds disponibles',
                  enfants: [
                    PremiumFormWidgets.ligneResultat(
                      context,
                      'Declarant 1',
                      '${_fmt.format(resultat.plafondDisponibleDeclarant1)} EUR',
                    ),
                    if (resultat.plafondDisponibleDeclarant2 > 0)
                      PremiumFormWidgets.ligneResultat(
                        context,
                        'Declarant 2',
                        '${_fmt.format(resultat.plafondDisponibleDeclarant2)} EUR',
                      ),
                    PremiumFormWidgets.ligneResultat(
                      context,
                      'Plafond mutualise',
                      '${_fmt.format(resultat.plafondMutualise)} EUR',
                      gras: true,
                    ),
                  ],
                ),
                PremiumFormWidgets.carteResultats(
                  context: context,
                  titre: 'Optimisation',
                  enfants: [
                    PremiumFormWidgets.ligneResultat(
                      context,
                      'Versement deductible optimal',
                      '${_fmt.format(resultat.versementOptimal)} EUR',
                    ),
                    PremiumFormWidgets.ligneResultat(
                      context,
                      'Economie d\'impot estimee',
                      '${_fmt.format(resultat.economieImpot)} EUR',
                      couleur: AppColors.accentGreen,
                      gras: true,
                    ),
                    if (resultat.excedentNonDeductible > 0)
                      PremiumFormWidgets.ligneResultat(
                        context,
                        'Excedent non deductible',
                        '${_fmt.format(resultat.excedentNonDeductible)} EUR',
                        couleur: AppColors.accentRed,
                      ),
                    if (resultat.reportsExpirants > 0)
                      PremiumFormWidgets.ligneResultat(
                        context,
                        'Reports expirant au 31/12',
                        '${_fmt.format(resultat.reportsExpirants)} EUR',
                        couleur: AppColors.accentOrange,
                      ),
                  ],
                ),
                PremiumFormWidgets.encartRecommandations(
                  context,
                  resultat.recommandations,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
