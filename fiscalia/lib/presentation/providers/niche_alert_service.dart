import '../../core/constants/tax_brackets.dart';
import '../../data/models/niche_ceiling_tracker_model.dart';

/// Niveau d'alerte du plafond des niches fiscales (Story 4.3).
enum NicheAlertLevel { ok, approche, depasse }

/// Alerte affichee a l'utilisateur sur son plafond de niches.
class NicheAlert {
  final NicheAlertLevel niveau;
  final String titre;
  final String message;
  final List<String> recommandations;

  /// Montant de depassement (0 si sous le plafond).
  final double montantDepassement;

  const NicheAlert({
    required this.niveau,
    required this.titre,
    required this.message,
    this.recommandations = const [],
    this.montantDepassement = 0,
  });
}

/// Suggestion de dispositif hors plafond global des niches (Story 4.4).
class SuggestionHorsPlafond {
  final String id;
  final String nom;
  final String description;

  /// Economie d'impot estimee pour l'utilisateur (selon sa TMI).
  final double economieEstimee;

  /// Score de risque 1-5 (UX-DR5).
  final int risqueScore;
  final String baseLegale;

  const SuggestionHorsPlafond({
    required this.id,
    required this.nom,
    required this.description,
    required this.economieEstimee,
    required this.risqueScore,
    required this.baseLegale,
  });
}

/// Service d'alertes et de suggestions pour le plafond des niches
/// fiscales (Stories 4.3 et 4.4).
///
/// Reference : Art. 200-0 A CGI - plafonnement global des avantages
/// fiscaux a 10 000 EUR (18 000 EUR avec dispositifs outre-mer et SOFICA).
class NicheAlertService {
  /// Seuil d'alerte preventive : 90% du plafond (Story 4.3).
  static const double seuilApproche = 0.90;

  const NicheAlertService();

  /// Evalue l'etat du tracker et produit l'alerte correspondante.
  NicheAlert evaluer(NicheCeilingTrackerModel tracker) {
    final taux = tracker.utilizationRate;

    if (tracker.isOverCeiling) {
      final depassement = tracker.usedCeiling - tracker.totalCeiling;
      return NicheAlert(
        niveau: NicheAlertLevel.depasse,
        titre: 'Plafond depasse',
        message:
            'Vous avez depasse votre plafond de niches fiscales de '
            '${depassement.toStringAsFixed(0)} EUR. Les avantages au-dela '
            'de ${tracker.totalCeiling.toStringAsFixed(0)} EUR seront perdus.',
        montantDepassement: depassement,
        recommandations: const [
          'Priorisez les dispositifs a plus fort impact avant d\'en ajouter.',
          'Reduisez ou etalez certains avantages sur l\'annee prochaine '
              'quand c\'est possible (ex: dons, travaux).',
          'Basculer le reste de votre optimisation vers des dispositifs '
              'HORS plafond : PER, deficit foncier, Malraux.',
        ],
      );
    }

    if (taux >= seuilApproche) {
      return NicheAlert(
        niveau: NicheAlertLevel.approche,
        titre: 'Plafond bientot atteint',
        message:
            'Vous avez utilise ${(taux * 100).toStringAsFixed(0)}% de votre '
            'plafond de niches fiscales. Il ne reste que '
            '${tracker.remainingCeiling.toStringAsFixed(0)} EUR disponibles.',
        recommandations: const [
          'Verifiez l\'impact marginal de tout nouveau dispositif avant de '
              'souscrire.',
          'Pensez aux dispositifs HORS plafond (PER, deficit foncier, '
              'Malraux) pour continuer a optimiser sans risque de perte.',
        ],
      );
    }

    return const NicheAlert(
      niveau: NicheAlertLevel.ok,
      titre: 'Dans la limite',
      message: 'Votre utilisation des niches fiscales est sous controle.',
    );
  }

  /// Suggestions de dispositifs HORS plafond global, classees par impact
  /// decroissant (Story 4.4 / FR22).
  ///
  /// [tmi] : taux marginal d'imposition du foyer (ex: 0.30).
  /// [revenuFiscalReference] : pour calibrer la suggestion PER.
  List<SuggestionHorsPlafond> suggererHorsPlafond({
    required double tmi,
    double revenuFiscalReference = 0,
  }) {
    // Suggestion PER : deduction de 10% du revenu (bornee au plafond
    // legal), economie = deduction x TMI. A defaut de revenu connu, on
    // illustre avec un versement de 10 000 EUR.
    final deductionPer = revenuFiscalReference > 0
        ? (revenuFiscalReference * 0.10 > TaxBrackets2026.perAnnualCeiling
              ? TaxBrackets2026.perAnnualCeiling
              : revenuFiscalReference * 0.10)
        : 10000.0;

    final suggestions = <SuggestionHorsPlafond>[
      SuggestionHorsPlafond(
        id: 'per',
        nom: 'PER (Plan Epargne Retraite)',
        description:
            'Versez ${deductionPer.toStringAsFixed(0)} EUR sur votre PER : '
            'deduction hors plafond des niches, reportable 3 ans si non '
            'utilisee.',
        economieEstimee: deductionPer * tmi,
        risqueScore: 1,
        baseLegale: 'Art. 163 quatervicies CGI',
      ),
      SuggestionHorsPlafond(
        id: 'deficit_foncier',
        nom: 'Deficit foncier',
        description:
            'Jusqu\'a 10 700 EUR de travaux deductibles de votre revenu '
            'global chaque annee (location nue), hors plafond des niches.',
        economieEstimee: TaxBrackets2026.propertyDeficitCeiling * tmi,
        risqueScore: 2,
        baseLegale: 'Art. 156 I 3 CGI',
      ),
      SuggestionHorsPlafond(
        id: 'malraux',
        nom: 'Loi Malraux',
        description:
            'Travaux de restauration en secteur sauvegarde : reduction de '
            '22 a 30% sans plafonnement global (dans la limite de 400 000 '
            'EUR de travaux sur 4 ans).',
        economieEstimee: 30000 * 0.30,
        risqueScore: 3,
        baseLegale: 'Art. 199 tervicies CGI',
      ),
      SuggestionHorsPlafond(
        id: 'monuments_historiques',
        nom: 'Monuments historiques',
        description:
            'Deduction integrale des travaux sur votre revenu global, sans '
            'plafond ni condition de location.',
        economieEstimee: 20000 * tmi,
        risqueScore: 3,
        baseLegale: 'Art. 156 I 1 CGI',
      ),
    ];

    // Classement par impact decroissant (Story 4.4).
    suggestions.sort((a, b) => b.economieEstimee.compareTo(a.economieEstimee));
    return suggestions;
  }
}
