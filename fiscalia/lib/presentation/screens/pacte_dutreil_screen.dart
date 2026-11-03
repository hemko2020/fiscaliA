import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/pacte_dutreil_model.dart';
import '../providers/pacte_dutreil_provider.dart';
import '../widgets/premium_form_widgets.dart';

/// Ecran du calculateur Pacte Dutreil (Story 8.5, Art. 787 B CGI).
class PacteDutreilScreen extends ConsumerStatefulWidget {
  const PacteDutreilScreen({super.key});

  @override
  ConsumerState<PacteDutreilScreen> createState() => _PacteDutreilScreenState();
}

class _PacteDutreilScreenState extends ConsumerState<PacteDutreilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valeurController = TextEditingController();
  int _nbEnfants = 1;
  final _fmt = NumberFormat('#,##0', 'fr_FR');

  @override
  void dispose() {
    _valeurController.dispose();
    super.dispose();
  }

  void _calculer() {
    if (!_formKey.currentState!.validate()) return;
    final resultat = ref.read(pacteDutreilServiceProvider).calculer(
          PacteDutreilModel(
            valeurEntreprise:
                PremiumFormWidgets.parseMontant(_valeurController.text),
            nbEnfants: _nbEnfants,
          ),
        );
    ref.read(pacteDutreilProvider.notifier).state = resultat;
  }

  @override
  Widget build(BuildContext context) {
    final resultat = ref.watch(pacteDutreilProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pacte Dutreil'),
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
                controller: _valeurController,
                label: 'Valeur de l\'entreprise / des titres',
              ),
              Text(
                'Nombre d\'enfants beneficiaires : $_nbEnfants',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Slider(
                value: _nbEnfants.toDouble(),
                min: 1,
                max: 6,
                divisions: 5,
                label: '$_nbEnfants',
                onChanged: (v) => setState(() => _nbEnfants = v.round()),
              ),
              const SizedBox(height: 8),
              PremiumFormWidgets.boutonCalculer(_calculer),
              if (resultat != null) ...[
                PremiumFormWidgets.carteResultats(
                  context: context,
                  titre: 'Droits de transmission',
                  enfants: [
                    PremiumFormWidgets.ligneResultat(
                      context,
                      'Sans Pacte Dutreil',
                      '${_fmt.format(resultat.droitsSansDutreil)} EUR',
                      couleur: AppColors.accentRed,
                    ),
                    PremiumFormWidgets.ligneResultat(
                      context,
                      'Avec Pacte Dutreil (abattement 75%)',
                      '${_fmt.format(resultat.droitsAvecDutreil)} EUR',
                    ),
                    PremiumFormWidgets.ligneResultat(
                      context,
                      'Economie',
                      '${_fmt.format(resultat.economie)} EUR',
                      couleur: AppColors.accentGreen,
                      gras: true,
                    ),
                    PremiumFormWidgets.ligneResultat(
                      context,
                      'Assiette taxable avec Dutreil',
                      '${_fmt.format(resultat.assietteAvecDutreil)} EUR',
                    ),
                  ],
                ),
                PremiumFormWidgets.encartRecommandations(
                  context,
                  resultat.conditions,
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
