import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Service de monitoring (Story 10.4) : rapports de crash et analytics.
///
/// Toutes les methodes sont no-op tant que [initialise] n'a pas ete appele
/// avec succes, ce qui permet a l'app de fonctionner sans Firebase
/// (tests, builds sans configuration).
class MonitoringService {
  FirebaseCrashlytics? _crashlytics;
  FirebaseAnalytics? _analytics;
  bool _actif = false;

  bool get estActif => _actif;

  /// Initialise Crashlytics et Analytics. Les erreurs Flutter et les
  /// erreurs de zone non capturees sont redirigees vers Crashlytics.
  Future<void> initialiser({
    FirebaseCrashlytics? crashlytics,
    FirebaseAnalytics? analytics,
  }) async {
    try {
      _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;
      _analytics = analytics ?? FirebaseAnalytics.instance;

      FlutterError.onError = (details) {
        _crashlytics?.recordFlutterFatalError(details);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlytics?.recordError(error, stack, fatal: true);
        return true;
      };

      _actif = true;
    } catch (e) {
      // Firebase non configure : monitoring desactive, l'app continue.
      debugPrint('MonitoringService: initialisation impossible ($e)');
      _actif = false;
    }
  }

  /// Enregistre une erreur non fatale (ex : echec de sauvegarde Hive).
  void enregistrerErreur(Object erreur, StackTrace? stack,
      {String? contexte}) {
    _crashlytics?.recordError(erreur, stack, reason: contexte);
  }

  /// Journalise un evenement analytique (ex : simulation_completee).
  Future<void> journaliserEvenement(String nom,
      [Map<String, Object>? parametres]) async {
    await _analytics?.logEvent(name: nom, parameters: parametres);
  }

  /// Identifiant anonymise pour regrouper les crashes par utilisateur.
  Future<void> definirIdentifiantUtilisateur(String id) async {
    await _crashlytics?.setUserIdentifier(id);
    await _analytics?.setUserId(id: id);
  }

  /// Observateur de navigation pour le suivi des ecrans (top screens).
  NavigatorObserver? observateurNavigation() {
    final analytics = _analytics;
    if (!_actif || analytics == null) return null;
    return FirebaseAnalyticsObserver(analytics: analytics);
  }
}
