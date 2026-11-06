import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/lmnp_simulation_model.dart';
import '../providers/lmnp_provider.dart';
import '../widgets/premium_form_widgets.dart';

/// Ecran de simulation LMNP avec amortissement (Story 8.2).
class LmnpSimulationScreen extends ConsumerStatefulWidget {
  const LmnpSimulationScreen({super.key});

  @override
  ConsumerState<LmnpSimulationScreen> createState() =>
      _LmnpSimulationScreenState();
}

class _LmnpSimulationScreenState extends ConsumerState<LmnpSimulationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _prixController = TextEditingController();
  final _mobilierController = TextEditingController();
  final _loyersController = TextEditingController();
  final _chargesController = TextEditingController();
  double _tmi = 0.30;
  int _duree = 10;
  final _fmt = NumberFormat('#,##0', 'fr_FR');

  @override
  void dispose() {
    _prixController.dispose();
    _mobilierController.dispose();
    _loyersController.dispose();
    _chargesController.dispose();
    super.dispose();
  }

  void _calculer() {
    if (!_formKey.currentState!.validate()) return;
    final parse = PremiumFormWidgets.parseMontant;
    final resultat = ref
        .read(lmnpServiceProvider)
        .simuler(
          LmnpSimulationModel(
            prixAcquisition: parse(_prixController.text),
            valeurMobilier: parse(_mobilierController.text),
            loyersAnnuels: parse(_loyersController.text),
            chargesAnnuelles: parse(_chargesController.text),
            tmi: _tmi,
            dureeAnnees: _duree,
          ),
        );
    ref.read(lmnpSimulationProvider.notifier).state = resultat;
  }

  @override
  Widget build(BuildContext context) {
    final resultat = ref.watch(lmnpSimulationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LMNP - Amortissement'),
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
                controller: _prixController,
                label: 'Prix d\'acquisition du bien',
              ),
              PremiumFormWidgets.champMontant(
                controller: _mobilierController,
                label: 'Valeur du mobilier',
              ),
              PremiumFormWidgets.champMontant(
                controller: _loyersController,
                label: 'Loyers annuels',
              ),
              PremiumFormWidgets.champMontant(
                controller: _chargesController,
                label: 'Charges annuelles (taxe fonciere, interets...)',
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
                'Projection : $_duree ans',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Slider(
                value: _duree.toDouble(),
                min: 5,
                max: 20,
                divisions: 15,
                label: '$_duree ans',
                onChanged: (v) => setState(() => _duree = v.round()),
              ),
              const SizedBox(height: 8),
              PremiumFormWidgets.boutonCalculer(_calculer),
              if (resultat != null) ...[
                PremiumFormWidgets.carteResultats(
                  context: context,
                  titre: 'Comparaison sur $_duree ans',
                  enfants: [
                    PremiumFormWidgets.ligneResultat(
                      context,
                      'Fiscalite totale micro-BIC',
                      '${_fmt.format(resultat.impotTotalMicro)} EUR',
                    ),
                    PremiumFormWidgets.ligneResultat(
                      context,
                      'Fiscalite totale regime reel',
                      '${_fmt.format(resultat.impotTotalReel)} EUR',
                    ),
                    PremiumFormWidgets.ligneResultat(
                      context,
                      'Economie avec le reel',
                      '${_fmt.format(resultat.economieTotaleReel)} EUR',
                      couleur: AppColors.accentGreen,
                      gras: true,
                    ),
                    PremiumFormWidgets.ligneResultat(
                      context,
                      'Taux de fiscalite effectif des loyers (reel)',
                      '${(resultat.tauxFiscaliteReel * 100).toStringAsFixed(1)}%',
                    ),
                  ],
                ),
                PremiumFormWidgets.carteResultats(
                  context: context,
                  titre: 'Detail par annee',
                  enfants: resultat.projection
                      .map(
                        (a) => PremiumFormWidgets.ligneResultat(
                          context,
                          'Annee ${a.annee} - base reel '
                              '${_fmt.format(a.baseImposableReel)} EUR',
                          'impot ${_fmt.format(a.impotReel)} EUR',
                        ),
                      )
                      .toList(),
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
