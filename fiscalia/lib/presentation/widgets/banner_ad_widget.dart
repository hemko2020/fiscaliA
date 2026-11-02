import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../providers/ads_provider.dart';
import '../providers/subscription_provider.dart';

/// Banniere publicitaire AdMob affichee uniquement pour les utilisateurs
/// gratuits (Story 9.1 / FR41).
class BannerAdWidget extends ConsumerStatefulWidget {
  const BannerAdWidget({super.key});

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> {
  BannerAd? _banniere;
  bool _chargee = false;

  @override
  void initState() {
    super.initState();
    _banniere = ref.read(adMobServiceProvider).creerBanniere(
          onChargee: () => setState(() => _chargee = true),
        )..load();
  }

  @override
  void dispose() {
    _banniere?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Aucune publicite pour les abonnes premium (FR41).
    final abonnement = ref.watch(subscriptionProvider);
    if (abonnement.estPremium) return const SizedBox.shrink();

    final banniere = _banniere;
    if (!_chargee || banniere == null) return const SizedBox.shrink();

    return SizedBox(
      width: banniere.size.width.toDouble(),
      height: banniere.size.height.toDouble(),
      child: AdWidget(ad: banniere),
    );
  }
}
