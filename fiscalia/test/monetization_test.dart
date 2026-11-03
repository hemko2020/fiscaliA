import 'package:flutter_test/flutter_test.dart';
import 'package:fiscalia/presentation/providers/subscription_provider.dart';

void main() {
  group('SubscriptionState', () {
    test('etat par defaut : gratuit, sans RevenueCat', () {
      const state = SubscriptionState();
      expect(state.niveau, NiveauAbonnement.gratuit);
      expect(state.estPremium, isFalse);
      expect(state.accesAvance, isFalse);
      expect(state.accesExpert, isFalse);
    });

    test('Pro : acces avance mais pas expert', () {
      const state = SubscriptionState(niveau: NiveauAbonnement.pro);
      expect(state.estPremium, isTrue);
      expect(state.accesAvance, isTrue);
      expect(state.accesExpert, isFalse);
    });

    test('Expert : acces avance et expert', () {
      const state = SubscriptionState(niveau: NiveauAbonnement.expert);
      expect(state.estPremium, isTrue);
      expect(state.accesAvance, isTrue);
      expect(state.accesExpert, isTrue);
    });

    test('copyWith preserve les champs non modifies', () {
      const state = SubscriptionState(niveau: NiveauAbonnement.pro);
      final copie = state.copyWith(achatEnCours: true);
      expect(copie.niveau, NiveauAbonnement.pro);
      expect(copie.achatEnCours, isTrue);
    });
  });

  group('SubscriptionNotifier - degradation gracieuse', () {
    test('sans cles RevenueCat, initialiser() reste en mode gratuit', () async {
      final notifier = SubscriptionNotifier();
      await notifier.initialiser();
      expect(notifier.state.revenueCatDisponible, isFalse);
      expect(notifier.state.niveau, NiveauAbonnement.gratuit);
    });

    test('achat impossible sans RevenueCat configure', () async {
      final notifier = SubscriptionNotifier();
      final resultat = await notifier.restaurerAchats();
      expect(resultat, isFalse);
    });
  });
}
