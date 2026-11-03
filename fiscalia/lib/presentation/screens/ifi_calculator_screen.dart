import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/ifi_model.dart';
import '../providers/ifi_provider.dart';
import '../widgets/premium_form_widgets.dart';

/// Ecran du calculateur IFI et strategies de reduction (Story 8.6).
class IfiCalculatorScreen extends ConsumerStatefulWidget {
  const IfiCalculatorScreen({super.key});

  @override
  ConsumerState<IfiCalculatorScreen> createState() =>
      _IfiCalculatorScreenState();
}

class _IfiCalculatorScreenState extends ConsumerState<IfiCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patrimoineController = TextEditingController();
  final _dettesController = TextEditingController();
  final _donsController = TextEditingController();
  final _fmt = NumberFormat('#,##0', 'fr_FR');

  @override
  void dispose() {
    _patrimoineController.dispose();
    _dettesController.dispose();
    _donsController.dispose();
    super.dispose();
  }

  void _calculer() {
    if (!_formKey.currentState!.validate()) return;
    final parse = PremiumFormWidgets.parseMontant;
    final resultat = ref.read(ifiServiceProvider).calculer(
          IfiModel(
            patrimoineImmobilierBrut: parse(_patrimoineController.text),
            dettesDeductibles: parse(_dettesController.text),
            donsIfi: parse(_donsController.text),
          ),
        );
    ref.read(ifiProvider.notifier).state = resultat;
  }

  @override
  Widget build(BuildContext context) {
    final resultat = ref.watch(ifiProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('IFI - Calculateur'),
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
                controller: _patrimoineController,
                label: 'Patrimoine immobilier brut',
              ),
              PremiumFormWidgets.champMontant(
                controller: _dettesController,
                label: 'Dettes deductibles (emprunts...)',
              ),
              PremiumFormWidgets.champMontant(
                controller: _donsController,
                label: 'Dons IFI envisages (reduction 75%)',
              ),
              const SizedBox(height: 8),
              PremiumFormWidgets.boutonCalculer(_calculer),
              if (resultat != null) ...[
                if (!resultat.assujetti)
                  Card(
                    margin: const EdgeInsets.only(top: 16),
                    color: AppColors.accentGreen.withValues(alpha: 0.1),
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: AppColors.accentGreen),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Vous n\'etes pas assujetti a l\'IFI '
                              '(patrimoine net taxable sous 1 300 000 EUR).',
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  PremiumFormWidgets.carteResultats(
                    context: context,
                    titre: 'Calcul de l\'IFI',
                    enfants: [
                      PremiumFormWidgets.ligneResultat(
                        context,
                        'Patrimoine net taxable',
                        '${_fmt.format(resultat.patrimoineNetTaxable)} EUR',
                      ),
                      ...resultat.tranches
                          .where((t) => t.montantTaxe > 0)
                          .map(
                            (t) => PremiumFormWidgets.ligneResultat(
                              context,
                              'Tranche ${(t.taux * 100).toStringAsFixed(2)}% '
                              '(${_fmt.format(t.borneBasse)} - '
                              '${_fmt.format(t.borneHaute)} EUR)',
                              '${_fmt.format(t.montantTaxe)} EUR',
                            ),
                          ),
                      PremiumFormWidgets.ligneResultat(
                        context,
                        'IFI brut',
                        '${_fmt.format(resultat.ifiBrut)} EUR',
                      ),
                      if (resultat.decote > 0)
                        PremiumFormWidgets.ligneResultat(
                          context,
                          'Decote',
                          '-${_fmt.format(resultat.decote)} EUR',
                          couleur: AppColors.accentGreen,
                        ),
                      if (resultat.reductionDons > 0)
                        PremiumFormWidgets.ligneResultat(
                          context,
                          'Reduction dons IFI',
                          '-${_fmt.format(resultat.reductionDons)} EUR',
                          couleur: AppColors.accentGreen,
                        ),
                      PremiumFormWidgets.ligneResultat(
                        context,
                        'IFI a payer',
                        '${_fmt.format(resultat.ifiFinal)} EUR',
                        couleur: AppColors.accentRed,
                        gras: true,
                      ),
                    ],
                  ),
                ],
                PremiumFormWidgets.encartRecommandations(
                  context,
                  resultat.strategies,
                  couleur: AppColors.primaryBlue,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
