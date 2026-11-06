import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/demembrement_model.dart';
import '../providers/demembrement_provider.dart';
import '../widgets/premium_form_widgets.dart';

/// Ecran du calculateur de demembrement (Story 8.4, Art. 669 CGI).
class DemembrementScreen extends ConsumerStatefulWidget {
  const DemembrementScreen({super.key});

  @override
  ConsumerState<DemembrementScreen> createState() => _DemembrementScreenState();
}

class _DemembrementScreenState extends ConsumerState<DemembrementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valeurController = TextEditingController();
  int _age = 55;
  int _nbEnfants = 1;
  int _nbParents = 1;
  final _fmt = NumberFormat('#,##0', 'fr_FR');

  @override
  void dispose() {
    _valeurController.dispose();
    super.dispose();
  }

  void _calculer() {
    if (!_formKey.currentState!.validate()) return;
    final resultat = ref
        .read(demembrementServiceProvider)
        .calculer(
          DemembrementModel(
            ageUsufruitier: _age,
            valeurBien: PremiumFormWidgets.parseMontant(_valeurController.text),
            nbEnfants: _nbEnfants,
            nbParents: _nbParents,
          ),
        );
    ref.read(demembrementProvider.notifier).state = resultat;
  }

  @override
  Widget build(BuildContext context) {
    final resultat = ref.watch(demembrementProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demembrement de propriete'),
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
                label: 'Valeur du bien en pleine propriete',
              ),
              Text(
                'Age de l\'usufruitier : $_age ans',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Slider(
                value: _age.toDouble(),
                min: 18,
                max: 95,
                divisions: 77,
                label: '$_age ans',
                onChanged: (v) => setState(() => _age = v.round()),
              ),
              Row(
                children: [
                  Expanded(
                    child: _selecteurNombre(
                      'Enfants',
                      _nbEnfants,
                      (v) => setState(() => _nbEnfants = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _selecteurNombre(
                      'Parents donateurs',
                      _nbParents,
                      (v) => setState(() => _nbParents = v),
                      max: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              PremiumFormWidgets.boutonCalculer(_calculer),
              if (resultat != null) ...[
                PremiumFormWidgets.carteResultats(
                  context: context,
                  titre: 'Valorisation (Art. 669 CGI)',
                  enfants: [
                    PremiumFormWidgets.ligneResultat(
                      context,
                      'Usufruit (${(resultat.ratioUsufruit * 100).toStringAsFixed(0)}%)',
                      '${_fmt.format(resultat.valeurUsufruit)} EUR',
                    ),
                    PremiumFormWidgets.ligneResultat(
                      context,
                      'Nue-propriete transmissible',
                      '${_fmt.format(resultat.valeurNuePropriete)} EUR',
                      gras: true,
                    ),
                    PremiumFormWidgets.ligneResultat(
                      context,
                      'Abattements disponibles',
                      '${_fmt.format(resultat.abattementTotal)} EUR',
                    ),
                  ],
                ),
                PremiumFormWidgets.carteResultats(
                  context: context,
                  titre: 'Droits de donation',
                  enfants: [
                    PremiumFormWidgets.ligneResultat(
                      context,
                      'Sans demembrement',
                      '${_fmt.format(resultat.droitsPleinePropriete)} EUR',
                      couleur: AppColors.accentRed,
                    ),
                    PremiumFormWidgets.ligneResultat(
                      context,
                      'Avec demembrement',
                      '${_fmt.format(resultat.droitsDonation)} EUR',
                    ),
                    PremiumFormWidgets.ligneResultat(
                      context,
                      'Economie',
                      '${_fmt.format(resultat.economie)} EUR',
                      couleur: AppColors.accentGreen,
                      gras: true,
                    ),
                  ],
                ),
                PremiumFormWidgets.encartRecommandations(
                  context,
                  resultat.explications,
                  couleur: AppColors.primaryBlue,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _selecteurNombre(
    String label,
    int valeur,
    ValueChanged<int> onChanged, {
    int max = 6,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: valeur > 1 ? () => onChanged(valeur - 1) : null,
            ),
            Text('$valeur', style: Theme.of(context).textTheme.titleMedium),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: valeur < max ? () => onChanged(valeur + 1) : null,
            ),
          ],
        ),
      ],
    );
  }
}
