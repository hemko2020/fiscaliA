import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Service publicitaire AdMob (Story 9.1).
///
/// Freemium : banniere en bas des ecrans de resultats + interstitiel
/// toutes les 3 simulations (FR41). Les utilisateurs premium ne voient
/// aucune publicite.
///
/// Configuration requise avant production :
/// - Remplacer les identifiants de test par les blocs d'annonces reels
///   (console AdMob).
/// - Renseigner GADApplicationIdentifier (iOS Info.plist) et
///   com.google.android.gms.ads.APPLICATION_ID (AndroidManifest).
final adMobServiceProvider = Provider<AdMobService>((ref) => AdMobService());

class AdMobService {
  // Blocs d'annonces de test officiels Google - A REMPLACER en production.
  static String get bannerAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  static String get interstitialAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

  /// Nombre de simulations entre deux interstitiels (FR41).
  static const int simulationsEntreInterstitiels = 3;

  int _compteurSimulations = 0;
  InterstitialAd? _interstitiel;
  bool _initialise = false;

  /// Initialise le SDK AdMob.
  Future<void> initialiser() async {
    if (_initialise) return;
    try {
      await MobileAds.instance.initialize();
      _initialise = true;
      _prechargerInterstitiel();
    } catch (e) {
      debugPrint('Echec initialisation AdMob : $e');
    }
  }

  /// Cree une banniere prete a l'affichage (a appeler depuis le widget).
  BannerAd creerBanniere({required void Function() onChargee}) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onChargee(),
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banniere non chargee : $error');
          ad.dispose();
        },
      ),
    );
  }

  /// A appeler a chaque simulation terminee. Affiche l'interstitiel
  /// toutes les [simulationsEntreInterstitiels] simulations.
  void notifierSimulationTerminee() {
    if (!_initialise) return;
    _compteurSimulations++;
    if (_compteurSimulations >= simulationsEntreInterstitiels) {
      _compteurSimulations = 0;
      _afficherInterstitiel();
    }
  }

  void _prechargerInterstitiel() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitiel = ad,
        onAdFailedToLoad: (error) {
          debugPrint('Interstitiel non charge : $error');
          _interstitiel = null;
        },
      ),
    );
  }

  void _afficherInterstitiel() {
    final ad = _interstitiel;
    if (ad == null) {
      _prechargerInterstitiel();
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _prechargerInterstitiel();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _prechargerInterstitiel();
      },
    );
    ad.show();
    _interstitiel = null;
  }
}
