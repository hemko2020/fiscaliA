import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../providers/subscription_provider.dart';

/// Paywall plein ecran pour les contenus premium (Stories 9.3 et 9.4).
///
/// Affiche les offres chargees depuis RevenueCat quand elles sont
/// disponibles ; sinon, une presentation statique des tarifs (FR42-FR44).
class PaywallScreen extends ConsumerWidget {
  /// Contexte d'affichage (ex: nom du dispositif bloque).
  final String? fonctionnalite;

  const PaywallScreen({super.key, this.fonctionnalite});

  /// Ouvre le paywall et retourne true si l'utilisateur est devenu premium.
  static Future<bool> ouvrir(BuildContext context, {String? fonctionnalite}) async {
    final resultat = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => PaywallScreen(fonctionnalite: fonctionnalite),
      ),
    );
    return resultat ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final abonnement = ref.watch(subscriptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FiscalIA Premium'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (fonctionnalite != null)
              Card(
                color: AppColors.accentOrange.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.lock, color: AppColors.accentOrange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '« $fonctionnalite » est une fonctionnalite premium.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Passez au niveau superieur',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _carteOffre(
              context,
              ref,
              titre: 'FiscalIA Pro',
              prixMensuel: '4,99 EUR/mois',
              prixAnnuel: '29,99 EUR/an',
              avantages: const [
                'Tous les dispositifs avances (PER, LMNP, SOFICA...)',
                'Aucune publicite',
                'Export PDF du plan d\'optimisation',
                'Simulations illimitees',
              ],
              identifiantsProduits: const [
                'fiscalia_pro_yearly',
                'fiscalia_pro_monthly',
              ],
            ),
            const SizedBox(height: 12),
            _carteOffre(
              context,
              ref,
              titre: 'FiscalIA Expert',
              prixMensuel: '9,99 EUR/mois',
              prixAnnuel: '59,99 EUR/an',
              avantages: const [
                'Tout FiscalIA Pro',
                'Dispositifs experts (SCI, demembrement, Dutreil, IFI)',
                'Agent IA - scenarios multi-dispositifs',
                'Radar Fiscal et scores de risque',
              ],
              identifiantsProduits: const [
                'fiscalia_expert_yearly',
                'fiscalia_expert_monthly',
              ],
              misEnAvant: true,
            ),
            const SizedBox(height: 16),
            // Story 9.4 : achat a vie.
            _carteLifetime(context, ref, abonnement),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: abonnement.achatEnCours
                  ? null
                  : () async {
                      final ok = await ref
                          .read(subscriptionProvider.notifier)
                          .restaurerAchats();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                  ? 'Achats restaures avec succes.'
                                  : 'Aucun achat a restaurer.',
                            ),
                          ),
                        );
                        if (ok) Navigator.of(context).pop(true);
                      }
                    },
              icon: const Icon(Icons.restore),
              label: const Text('Restaurer mes achats'),
            ),
            const SizedBox(height: 8),
            Text(
              'Paiement securise via votre compte store. Resiliable a tout '
              'moment. Calculs indicatifs, ne constituent pas un conseil fiscal.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _carteOffre(
    BuildContext context,
    WidgetRef ref, {
    required String titre,
    required String prixMensuel,
    required String prixAnnuel,
    required List<String> avantages,
    required List<String> identifiantsProduits,
    bool misEnAvant = false,
  }) {
    final abonnement = ref.watch(subscriptionProvider);
    final package = _trouverPackage(abonnement.offres, identifiantsProduits);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: misEnAvant
            ? const BorderSide(color: AppColors.accentGreen, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  titre,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (misEnAvant)
                  const Chip(
                    label: Text('Recommande'),
                    backgroundColor: AppColors.accentGreen,
                    labelStyle: TextStyle(color: Colors.white, fontSize: 11),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              package != null
                  ? package.storeProduct.priceString
                  : '$prixMensuel ou $prixAnnuel',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...avantages.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppColors.accentGreen,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        a,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: abonnement.achatEnCours || package == null
                    ? null
                    : () async {
                        final ok = await ref
                            .read(subscriptionProvider.notifier)
                            .acheter(package);
                        if (ok && context.mounted) {
                          Navigator.of(context).pop(true);
                        }
                      },
                child: Text(
                  package == null && abonnement.revenueCatDisponible
                      ? 'Offre indisponible'
                      : 'S\'abonner',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Story 9.4 : section achat a vie, mise en avant pendant la periode de
  /// declaration (avril-juin).
  Widget _carteLifetime(
    BuildContext context,
    WidgetRef ref,
    SubscriptionState abonnement,
  ) {
    final periodeDeclaration =
        DateTime.now().month >= 4 && DateTime.now().month <= 6;
    final package = _trouverPackage(
      abonnement.offres,
      const ['fiscalia_expert_lifetime', 'fiscalia_pro_lifetime'],
    );

    return Card(
      color: AppColors.primaryBlue.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.all_inclusive, color: AppColors.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  'Acces a vie',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Pro : 79,99 EUR - Expert : 149,99 EUR\n'
              'Rentabilise en 2,5 ans par rapport a l\'abonnement annuel.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (periodeDeclaration) ...[
              const SizedBox(height: 8),
              Text(
                'Periode de declaration : offre a vie disponible jusqu\'au '
                '30 juin.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.accentRed,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
            if (package != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: abonnement.achatEnCours
                      ? null
                      : () async {
                          final ok = await ref
                              .read(subscriptionProvider.notifier)
                              .acheter(package);
                          if (ok && context.mounted) {
                            Navigator.of(context).pop(true);
                          }
                        },
                  child: Text('Acheter ${package.storeProduct.priceString}'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Package? _trouverPackage(List<Package> offres, List<String> identifiants) {
    for (final id in identifiants) {
      for (final p in offres) {
        if (p.storeProduct.identifier == id) return p;
      }
    }
    return null;
  }
}
