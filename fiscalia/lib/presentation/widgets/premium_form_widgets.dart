import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Widgets partages pour les ecrans des dispositifs avances/experts.
class PremiumFormWidgets {
  PremiumFormWidgets._();

  /// Champ de saisie numerique standardise (montants en EUR).
  static Widget champMontant({
    required TextEditingController controller,
    required String label,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixText: 'EUR',
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return null;
          final nombre =
              double.tryParse(value.replaceAll(' ', '').replaceAll(',', '.'));
          if (nombre == null || nombre < 0) {
            return 'Montant invalide';
          }
          return null;
        },
      ),
    );
  }

  /// Parse un champ montant en double (0 si vide/invalide).
  static double parseMontant(String texte) {
    return double.tryParse(
          texte.replaceAll(' ', '').replaceAll('€', '').replaceAll(',', '.'),
        ) ??
        0;
  }

  /// Ligne de resultat label/valeur.
  static Widget ligneResultat(
    BuildContext context,
    String label,
    String valeur, {
    Color? couleur,
    bool gras = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            valeur,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: gras ? FontWeight.bold : FontWeight.normal,
                  color: couleur,
                ),
          ),
        ],
      ),
    );
  }

  /// Carte de resultats standardisee.
  static Widget carteResultats({
    required BuildContext context,
    required String titre,
    required List<Widget> enfants,
  }) {
    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titre,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
            ),
            const Divider(height: 20),
            ...enfants,
          ],
        ),
      ),
    );
  }

  /// Encart de recommandations/avertissements.
  static Widget encartRecommandations(
    BuildContext context,
    List<String> messages, {
    Color couleur = AppColors.accentOrange,
  }) {
    if (messages.isEmpty) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(top: 16),
      color: couleur.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: messages
              .map(
                (m) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: 16, color: couleur),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          m,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  /// Bouton de calcul pleine largeur.
  static Widget boutonCalculer(VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.calculate),
        label: const Text('Calculer'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  /// Badge de risque 1-5 code couleur (UX-DR5).
  static Widget badgeRisque(BuildContext context, int score) {
    final couleur = score <= 2
        ? AppColors.riskLow
        : score == 3
            ? AppColors.riskMedium
            : AppColors.riskHigh;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Risque $score/5',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: couleur,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
