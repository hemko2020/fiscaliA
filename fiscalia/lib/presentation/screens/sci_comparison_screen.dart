import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/sci_comparison_model.dart';
import '../providers/sci_comparison_provider.dart';
import '../widgets/premium_form_widgets.dart';

/// Ecran de comparaison SCI a l'IR vs SCI a l'IS (Story 8.3).
class SciComparisonScreen extends ConsumerStatefulWidget {
  const SciComparisonScreen({super.key});

  @override
  ConsumerState<SciComparisonScreen> createState() =>
      _SciComparisonScreenState();
}

class _SciComparisonScreenState extends ConsumerState<SciComparisonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loyersController = TextEditingController();
  final _chargesController = TextEditingController();
  final _valeurController = TextEditingController();
  final _deficitController = TextEditingController();
  double _tmi = 0.30;
  double _tauxDistribution = 0;
  final _fmt = NumberFormat('#,##0', 'fr_FR');

  @override
  void dispose() {
    _loyersController.dispose();
    _chargesController.dispose();
    _valeurController.dispose();
    _deficitController.dispose();
    super.dispose();
  }

  void _calculer() {
    if (!_formKey.currentState!.validate()) return;
    final parse = PremiumFormWidgets.parseMontant;
    final resultat = ref
        .read(sciComparisonServiceProvider)
        .comparer(
          SciComparisonModel(
            loyersAnnuels: parse(_loyersController.text),
            chargesAnnuelles: parse(_chargesController.text),
            valeurAmortissable: parse(_valeurController.text),
            tmi: _tmi,
            tauxDistribution: _tauxDistribution,
            deficitFoncierAnnuel: parse(_deficitController.text),
          ),
        );
    ref.read(sciComparisonProvider.notifier).state = resultat;
  }

  @override
  Widget build(BuildContext context) {
    final resultat = ref.watch(sciComparisonProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SCI - IR ou IS ?'),
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
                controller: _loyersController,
                label: 'Loyers annuels',
              ),
              PremiumFormWidgets.champMontant(
                controller: _chargesController,
                label: 'Charges deductibles annuelles',
              ),
              PremiumFormWidgets.champMontant(
                controller: _valeurController,
                label: 'Valeur amortissable du bien (IS)',
                hint: 'Prix - environ 15% de terrain',
              ),
              PremiumFormWidgets.champMontant(
                controller: _deficitController,
                label: 'Deficit foncier annuel (travaux)',
              ),
              Text(
                'TMI : ${(_tmi * 100).toStringAsFixed(0)}%',
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
              Text(
                'Distribution de dividendes : '
                '${(_tauxDistribution * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Slider(
                value: _tauxDistribution,
                min: 0,
                max: 1,
                divisions: 10,
                label: '${(_tauxDistribution * 100).toStringAsFixed(0)}%',
                onChanged: (v) => setState(() => _tauxDistribution = v),
              ),
              const SizedBox(height: 8),
              PremiumFormWidgets.boutonCalculer(_calculer),
              if (resultat != null) ...[
                Card(
                  margin: const EdgeInsets.only(top: 16),
                  color: AppColors.accentGreen.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          color: AppColors.accentGreen,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Regime recommande : ${resultat.regimeRecommande} '
                            '(${_fmt.format(resultat.avantageAnnuel)} EUR/an '
                            'd\'avantage)',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                PremiumFormWidgets.carteResultats(
                  context: context,
                  titre: 'SCI a l\'IR',
                  enfants: [
                    PremiumFormWidgets.ligneResultat(
                      context,
                      'Revenu foncier net',
                      '${_fmt.format(resultat.regimeIR.resultat)} EUR',
                    ),
                    PremiumFormWidgets.ligneResultat(
                      context,
                      'Impot (TMI + 17.2% PS)',
                      '${_fmt.format(resultat.regimeIR.impotSurResultat)} EUR',
                    ),
                    PremiumFormWidgets.ligneResultat(
                      context,
                      'Economie deficit foncier',
                      '-${_fmt.format(resultat.regimeIR.economieDeficitFoncier)} EUR',
                      couleur: AppColors.accentGreen,
                    ),
                    PremiumFormWidgets.ligneResultat(
                      context,
                      'Fiscalite nette',
                      '${_fmt.format(resultat.regimeIR.fiscaliteTotale)} EUR',
                      gras: true,
                    ),
                  ],
                ),
                PremiumFormWidgets.carteResultats(
                  context: context,
                  titre: 'SCI a l\'IS',
                  enfants: [
                    PremiumFormWidgets.ligneResultat(
                      context,
                      'Resultat apres amortissement',
                      '${_fmt.format(resultat.regimeIS.resultat)} EUR',
                    ),
                    PremiumFormWidgets.ligneResultat(
                      context,
                      'IS (15% / 25%)',
                      '${_fmt.format(resultat.regimeIS.impotSurResultat)} EUR',
                    ),
                    PremiumFormWidgets.ligneResultat(
                      context,
                      'PFU sur dividendes (30%)',
                      '${_fmt.format(resultat.regimeIS.fiscaliteDistribution)} EUR',
                    ),
                    PremiumFormWidgets.ligneResultat(
                      context,
                      'Fiscalite totale',
                      '${_fmt.format(resultat.regimeIS.fiscaliteTotale)} EUR',
                      gras: true,
                    ),
                  ],
                ),
                PremiumFormWidgets.encartRecommandations(
                  context,
                  resultat.pointsVigilance,
                  couleur: AppColors.accentRed,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
