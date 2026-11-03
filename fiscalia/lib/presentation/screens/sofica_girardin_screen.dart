import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/sofica_girardin_model.dart';
import '../providers/sofica_girardin_provider.dart';
import '../widgets/premium_form_widgets.dart';

/// Ecran de calcul SOFICA & Girardin industriel (Story 8.7).
class SoficaGirardinScreen extends ConsumerStatefulWidget {
  const SoficaGirardinScreen({super.key});

  @override
  ConsumerState<SoficaGirardinScreen> createState() =>
      _SoficaGirardinScreenState();
}

class _SoficaGirardinScreenState extends ConsumerState<SoficaGirardinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _soficaController = TextEditingController();
  final _girardinController = TextEditingController();
  final _impotController = TextEditingController();
  bool _tauxMajore = false;
  final _fmt = NumberFormat('#,##0', 'fr_FR');

  @override
  void dispose() {
    _soficaController.dispose();
    _girardinController.dispose();
    _impotController.dispose();
    super.dispose();
  }

  void _calculer() {
    if (!_formKey.currentState!.validate()) return;
    final parse = PremiumFormWidgets.parseMontant;
    final resultat = ref.read(soficaGirardinServiceProvider).calculer(
          SoficaGirardinModel(
            investissementSofica: parse(_soficaController.text),
            soficaTauxMajore: _tauxMajore,
            investissementGirardin: parse(_girardinController.text),
            impotAvantReductions: parse(_impotController.text),
          ),
        );
    ref.read(soficaGirardinProvider.notifier).state = resultat;
  }

  @override
  Widget build(BuildContext context) {
    final resultat = ref.watch(soficaGirardinProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SOFICA & Girardin'),
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
                controller: _impotController,
                label: 'Votre impot avant reductions',
              ),
              PremiumFormWidgets.champMontant(
                controller: _soficaController,
                label: 'Investissement SOFICA',
                hint: 'Plafond 18 000 EUR',
              ),
              SwitchListTile(
                title: const Text('Taux majore 48%'),
                subtitle: const Text(
                  'SOFICA investissant >= 10% en PME de production',
                ),
                value: _tauxMajore,
                onChanged: (v) => setState(() => _tauxMajore = v),
              ),
              PremiumFormWidgets.champMontant(
                controller: _girardinController,
                label: 'Investissement Girardin industriel',
              ),
              const SizedBox(height: 8),
              PremiumFormWidgets.boutonCalculer(_calculer),
              if (resultat != null) ...[
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: PremiumFormWidgets.badgeRisque(
                    context,
                    resultat.risqueScore,
                  ),
                ),
                PremiumFormWidgets.carteResultats(
                  context: context,
                  titre: 'Reductions calculees',
                  enfants: [
                    PremiumFormWidgets.ligneResultat(
                      context,
                      'Reduction SOFICA',
                      '${_fmt.format(resultat.reductionSofica)} EUR',
                    ),
                    PremiumFormWidgets.ligneResultat(
                      context,
                      'Reduction Girardin (one-shot)',
                      '${_fmt.format(resultat.reductionGirardin)} EUR',
                    ),
                    if (resultat.gainNetGirardin > 0)
                      PremiumFormWidgets.ligneResultat(
                        context,
                        'Gain net Girardin',
                        '${_fmt.format(resultat.gainNetGirardin)} EUR',
                        couleur: AppColors.accentGreen,
                      ),
                    PremiumFormWidgets.ligneResultat(
                      context,
                      'Total imputable cette annee',
                      '${_fmt.format(resultat.reductionImputable)} EUR',
                      gras: true,
                    ),
                    if (resultat.reductionNonImputable > 0)
                      PremiumFormWidgets.ligneResultat(
                        context,
                        'Non imputable (excedent)',
                        '${_fmt.format(resultat.reductionNonImputable)} EUR',
                        couleur: AppColors.accentRed,
                      ),
                  ],
                ),
                PremiumFormWidgets.encartRecommandations(
                  context,
                  resultat.avertissements,
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
