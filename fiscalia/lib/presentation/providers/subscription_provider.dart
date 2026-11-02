import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Niveaux d'abonnement FiscalIA (Story 9.2).
enum NiveauAbonnement { gratuit, pro, expert }

/// Etat de l'abonnement utilisateur.
class SubscriptionState {
  final NiveauAbonnement niveau;

  /// RevenueCat est configure et operationnel.
  final bool revenueCatDisponible;

  /// Offres commerciales chargees depuis les stores.
  final List<Package> offres;

  /// Une transaction est en cours.
  final bool achatEnCours;

  const SubscriptionState({
    this.niveau = NiveauAbonnement.gratuit,
    this.revenueCatDisponible = false,
    this.offres = const [],
    this.achatEnCours = false,
  });

  bool get estPremium => niveau != NiveauAbonnement.gratuit;

  /// Acces aux dispositifs avances (LMNP, PER avance, SOFICA...).
  bool get accesAvance => estPremium;

  /// Acces aux dispositifs experts (SCI, demembrement, Dutreil, IFI).
  bool get accesExpert => niveau == NiveauAbonnement.expert;

  SubscriptionState copyWith({
    NiveauAbonnement? niveau,
    bool? revenueCatDisponible,
    List<Package>? offres,
    bool? achatEnCours,
  }) {
    return SubscriptionState(
      niveau: niveau ?? this.niveau,
      revenueCatDisponible: revenueCatDisponible ?? this.revenueCatDisponible,
      offres: offres ?? this.offres,
      achatEnCours: achatEnCours ?? this.achatEnCours,
    );
  }
}

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
      return SubscriptionNotifier();
    });

/// Gere les abonnements via RevenueCat (Story 9.2).
///
/// Configuration requise avant mise en production :
/// - Renseigner [cleApiAndroid] / [cleApiIos] avec les cles publiques
///   RevenueCat du projet.
/// - Creer dans le dashboard RevenueCat l'offering "default" avec les
///   produits : fiscalia_pro_monthly, fiscalia_pro_yearly,
///   fiscalia_expert_monthly, fiscalia_expert_yearly,
///   fiscalia_pro_lifetime, fiscalia_expert_lifetime.
/// - Creer les entitlements "pro" et "expert" rattaches aux produits.
class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  // TODO(production) : remplacer par les cles RevenueCat du projet.
  static const String cleApiAndroid = 'goog_VOTRE_CLE_REVENUECAT';
  static const String cleApiIos = 'appl_VOTRE_CLE_REVENUECAT';

  static const String entitlementPro = 'pro';
  static const String entitlementExpert = 'expert';

  SubscriptionNotifier() : super(const SubscriptionState());

  /// Initialise RevenueCat. Sans cles valides, l'app reste fonctionnelle
  /// en mode gratuit (degradation gracieuse).
  Future<void> initialiser() async {
    final cle = defaultTargetPlatform == TargetPlatform.iOS
        ? cleApiIos
        : cleApiAndroid;
    if (cle.contains('VOTRE_CLE')) {
      debugPrint('RevenueCat non configure : mode gratuit actif.');
      return;
    }
    try {
      await Purchases.configure(PurchasesConfiguration(cle));
      state = state.copyWith(revenueCatDisponible: true);
      await rafraichirStatut();
      await chargerOffres();
    } catch (e) {
      debugPrint('Echec initialisation RevenueCat : $e');
    }
  }

  /// Rafraichit le statut d'abonnement depuis les entitlements.
  Future<void> rafraichirStatut() async {
    if (!state.revenueCatDisponible) return;
    try {
      final info = await Purchases.getCustomerInfo();
      state = state.copyWith(niveau: _niveauDepuisEntitlements(info));
    } catch (e) {
      debugPrint('Echec lecture CustomerInfo : $e');
    }
  }

  NiveauAbonnement _niveauDepuisEntitlements(CustomerInfo info) {
    final actifs = info.entitlements.active;
    if (actifs.containsKey(entitlementExpert)) {
      return NiveauAbonnement.expert;
    }
    if (actifs.containsKey(entitlementPro)) return NiveauAbonnement.pro;
    return NiveauAbonnement.gratuit;
  }

  /// Charge les offres commerciales (offering "default").
  Future<void> chargerOffres() async {
    if (!state.revenueCatDisponible) return;
    try {
      final offerings = await Purchases.getOfferings();
      final packages = offerings.current?.availablePackages ?? [];
      state = state.copyWith(offres: packages);
    } catch (e) {
      debugPrint('Echec chargement offres : $e');
    }
  }

  /// Lance l'achat d'un package. Retourne true si l'achat a abouti.
  Future<bool> acheter(Package package) async {
    if (!state.revenueCatDisponible) return false;
    state = state.copyWith(achatEnCours: true);
    try {
      final result = await Purchases.purchase(
        PurchaseParams.package(package),
      );
      state = state.copyWith(
        niveau: _niveauDepuisEntitlements(result.customerInfo),
        achatEnCours: false,
      );
      return state.estPremium;
    } catch (e) {
      state = state.copyWith(achatEnCours: false);
      debugPrint('Achat annule ou echoue : $e');
      return false;
    }
  }

  /// Restaure les achats precedents (obligatoire pour l'App Store).
  Future<bool> restaurerAchats() async {
    if (!state.revenueCatDisponible) return false;
    try {
      final info = await Purchases.restorePurchases();
      state = state.copyWith(niveau: _niveauDepuisEntitlements(info));
      return state.estPremium;
    } catch (e) {
      debugPrint('Echec restauration : $e');
      return false;
    }
  }
}
