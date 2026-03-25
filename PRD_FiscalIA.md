
FiscalIA
Simulateur & Optimisateur d'Impôts sur le Revenu — France

Product Requirements Document (PRD)
Version 1.0 — Mars 2026

Confidentiel
 
1. Résumé Exécutif
FiscalIA est une application mobile (Flutter, iOS & Android) destinée aux particuliers salariés français. Elle permet de :
•	Calculer précisément l'impôt sur le revenu selon le barème officiel 2026
•	Identifier et simuler toutes les stratégies légales de réduction d'impôt
•	Accompagner l'utilisateur dans l'optimisation de sa déclaration, du niveau basique (emploi à domicile, dons) au niveau expert (SCI, démembrement, holding, Pacte Dutreil, IFI)

Modèle économique : Publicité + achats in-app. Distribution via les stores (App Store, Google Play), revenus encaissés par une OÜ estonienne.
Marché cible : 39 millions de foyers fiscaux en France, dont 18,6 millions imposables. Les concurrents actuels (Climb/ex-Tacotax, Simul'Impôt, impots.gouv.fr, Clickimpôts) se concentrent sur la simulation sans proposer de recommandations personnalisées d'optimisation de niveau expert.
2. Problème
2.1 Constat
•	40% des contribuables français ne savent pas remplir correctement leur déclaration (source : Climb/Tacotax)
•	Le simulateur officiel impots.gouv.fr ne fournit aucun conseil d'optimisation
•	Les apps existantes (Simul'Impôt, Impôt Calcul) se limitent au calcul sans guidance
•	Les services de conseil (Climb, CGP) monétisent via la mise en relation avec des partenaires financiers (conflits d'intérêt potentiels)
•	Aucune app mobile ne couvre les stratégies expertes (SCI, démembrement, Dutreil, IFI) de manière accessible

2.2 Coût de l'inaction
•	Les contribuables paient en moyenne 675 € de trop par an (estimation Tacotax)
•	Le plafond des niches fiscales (10 000 €/an) est largement sous-utilisé par la majorité des foyers
3. Objectifs
Objectifs Utilisateur
•	Connaître son impôt exact en moins de 2 minutes
•	Découvrir toutes les réductions/crédits d'impôt auxquels il est éligible
•	Comprendre les stratégies patrimoniales avancées (SCI, PER, LMNP, démembrement)
•	Estimer les économies réalisables avant d'agir

Objectifs Business
•	50 000 téléchargements dans les 6 premiers mois
•	5% de taux de conversion gratuit → premium
•	Revenu publicitaire mensuel de 2 000 €+ à partir du mois 4
•	Note moyenne 4.5+ sur les stores
4. Non-Objectifs (Hors Périmètre V1)
•	Télédéclaration directe vers impots.gouv.fr (complexité EDI, agrément DGFiP requis)
•	Gestion de patrimoine ou conseils d'investissement personnalisés (réglementation CIF/AMF)
•	Fiscalité des non-résidents ou des couples mixtes transfrontaliers
•	Optimisation fiscale pour les professionnels (BIC, BNC, IS) — focus V1 = salariés
•	Intégration bancaire (open banking) pour import automatique des revenus
5. Analyse Concurrentielle
Fonctionnalité	impots.gouv.fr	Simul'Impôt	Impôt Calcul	Climb (ex-Tacotax)	Clickimpôts	FiscalIA
Simulation IR	Oui	Oui	Oui	Oui	Oui	Oui
App mobile native	Non (web)	iOS	Android	Non (web)	Non (logiciel)	iOS + Android
Recommandations d'optimisation	Non	Non	Non	Basique	Basique	Expert (3 niveaux)
Stratégies patrimoniales (SCI, LMNP...)	Non	Non	Non	Non	Non	Oui
Simulateur niches fiscales	Non	Non	Non	Non	Non	Oui (plafond 10K€)
Mode hors-ligne	Non	Limité	Oui	Non	Oui	Oui
Gratuit	Oui	Freemium	Pub	Gratuit (CGP)	Payant (56-119€)	Freemium + Pub
Mise à jour barème annuelle	Oui	Variable	Variable	Oui	Oui	Automatique
Confidentialité données	Serveur État	Tiers	Local	Tiers + partenaires	Local	Local (aucune donnée)

Avantage différenciant FiscalIA : Seule app mobile combinant simulation précise + recommandations d'optimisation multi-niveaux + stratégies patrimoniales expertes, le tout en local sans transmission de données personnelles.
6. Personas Utilisateurs
Persona 1 : Marie, 32 ans, Cadre salariée
•	Revenu : 42 000 €/an, célibataire
•	Douleur : Remplit sa déclaration à la hâte, ne sait pas qu'elle peut déduire ses frais réels ou son PER
•	Besoin : Comprendre en 5 minutes combien elle peut économiser
•	Niveau FiscalIA : Basique → Intermédiaire

Persona 2 : Thomas & Julie, 40 ans, Couple avec 2 enfants
•	Revenus : 95 000 €/an (combinés), propriétaires
•	Douleur : Paient 8 500 € d'IR, emploient une nounou, font des dons, ne maximisent pas leur quotient familial
•	Besoin : Voir l'impact de chaque dispositif et optimiser le plafond de 10 000 €
•	Niveau FiscalIA : Intermédiaire → Avancé

Persona 3 : Patrick, 55 ans, Cadre supérieur investisseur
•	Revenu : 180 000 €/an, TMI 41%, patrimoine immobilier via SCI
•	Douleur : Paie 35 000 € d'IR + IFI, cherche à structurer sa transmission
•	Besoin : Stratégies Dutreil, démembrement de parts SCI, PER cadre supérieur
•	Niveau FiscalIA : Expert
7. User Stories
P0 — Must Have
•	"En tant que salarié, je veux saisir mon revenu net imposable et ma situation familiale pour obtenir mon impôt estimé en moins de 30 secondes"
•	"En tant que contribuable, je veux voir le détail du calcul par tranches (0%, 11%, 30%, 41%, 45%) pour comprendre comment mon impôt est calculé"
•	"En tant que parent, je veux ajuster mon nombre de parts (quotient familial) et voir immédiatement l'impact sur mon impôt"
•	"En tant qu'utilisateur, je veux voir une liste personnalisée des réductions et crédits d'impôt auxquels je suis éligible selon ma situation"
•	"En tant que contribuable, je veux simuler l'impact d'un versement PER sur mon impôt pour décider combien verser avant le 31 décembre"
•	"En tant qu'employeur à domicile, je veux calculer mon crédit d'impôt de 50% (plafond 12 000 €) pour vérifier que je ne dépasse pas le plafond des niches fiscales"

P1 — Should Have
•	"En tant qu'utilisateur avancé, je veux un tableau de bord montrant mon plafond de niches fiscales restant (10 000 € ou 18 000 € outre-mer) après cumul de mes dispositifs"
•	"En tant qu'investisseur, je veux simuler un investissement LMNP avec amortissement pour voir l'impact sur mes revenus fonciers"
•	"En tant que contribuable, je veux recevoir une notification avant la date limite de déclaration avec un rappel des actions d'optimisation"
•	"En tant qu'utilisateur, je veux exporter un récapitulatif PDF de ma simulation pour le transmettre à mon conseiller"
•	"En tant que donateur, je veux calculer ma réduction d'impôt (66% ou 75% selon l'organisme) et voir le plafond applicable"

P2 — Future / Expert
•	"En tant que détenteur de SCI, je veux comparer la fiscalité IR vs IS pour mes revenus fonciers"
•	"En tant que cadre supérieur, je veux simuler un démembrement de parts (nue-propriété / usufruit) pour préparer ma succession"
•	"En tant que chef d'entreprise, je veux estimer l'économie d'un Pacte Dutreil (exonération 75% des droits de mutation)"
•	"En tant que contribuable IFI, je veux calculer mon Impôt sur la Fortune Immobilière et simuler des stratégies de réduction (dons IFI 75%, investissement PME)"
•	"En tant qu'utilisateur, je veux un mode 'année suivante' pour projeter mon impôt N+1 et planifier mes investissements"
8. Architecture Fonctionnelle
8.1 Modules Principaux

Module 1 — Simulateur IR
•	Saisie guidée : revenu net imposable, situation familiale, nombre de parts
Calcul par tranches avec le barème 2026 (revenus 2025) :
◦	Jusqu'à 11 600 € : 0%
◦	11 601 € à 29 579 € : 11%
◦	29 580 € à 84 577 € : 30%
◦	84 578 € à 181 917 € : 41%
◦	Plus de 181 917 € : 45%
•	Décote pour les faibles revenus
•	Plafonnement du quotient familial (1 807 € par demi-part en 2026)
•	Contribution exceptionnelle sur les hauts revenus (CEHR)
•	Visualisation graphique des tranches (camembert + barres)

Module 2 — Optimisateur Fiscal (3 niveaux)

Niveau Basique (gratuit) :
•	Frais réels vs abattement 10%
•	Emploi à domicile (crédit 50%, plafond 12 000 €)
•	Frais de garde (crédit 50%, plafond 3 500 €/enfant)
•	Dons aux associations (réduction 66%, plafond 20% du revenu)
•	Dons aux organismes d'aide (réduction 75%, plafond 1 000 €)
•	Frais de scolarité (collège 61 €, lycée 153 €, supérieur 183 €)
•	Cotisations syndicales (crédit 66%)
•	Pension alimentaire versée

Niveau Avancé (premium) :
•	PER (Plan Épargne Retraite) : déduction jusqu'à 10% des revenus, plafond 37 094 €/an pour 2025, cumul sur 3 ans
•	LMNP (Loueur Meublé Non Professionnel) : simulation amortissement
•	Déficit foncier (imputable jusqu'à 10 700 €/an)
•	Loi Denormandie : réduction 12%/18%/21% selon durée
•	Loc'Avantages : déduction 15% à 65% des loyers
•	FCPI/FIP : réduction 25% du montant investi
•	Investissement forêt/GFI : réduction 25%
•	SOFICA : réduction 30% à 48%, plafond 18 000 €
•	Investissement outre-mer (Girardin) : plafond 18 000 €

Niveau Expert (premium) :
•	SCI : comparaison IR vs IS, simulation revenus fonciers
•	Démembrement de parts : calcul usufruit/nue-propriété selon barème fiscal
•	Holding : structuration et remontée de dividendes
•	Pacte Dutreil : exonération 75% droits de mutation (estimation)
•	IFI : calcul et stratégies de réduction (dons IFI 75%, investissement PME)
•	Assurance-vie : abattement 4 600 €/9 200 € après 8 ans
•	PEA : exonération après 5 ans

Module 3 — Tableau de Bord Niches Fiscales
•	Suivi en temps réel du plafond 10 000 € (ou 18 000 €)
•	Répartition visuelle par dispositif
•	Alerte quand le plafond est atteint
•	Suggestions de dispositifs hors plafond (PER, déficit foncier, Malraux, Monuments Historiques)

Module 4 — Calendrier Fiscal
•	Dates clés de la déclaration (avril-juin)
•	Rappels personnalisés (date limite selon département)
•	Échéancier des versements PER (avant 31 décembre)
•	Notifications push configurables

Module 5 — Centre Éducatif
•	Fiches pédagogiques sur chaque dispositif
•	Vidéos courtes explicatives
•	FAQ interactive
•	Glossaire fiscal
9. Architecture Technique
9.1 Stack Technologique
•	Frontend : Flutter (Dart) — iOS + Android depuis un seul codebase
•	State Management : Riverpod 2.0
•	Local Storage : Hive / Isar (base NoSQL embarquée)
•	Backend : Aucun serveur requis pour la V1 (calcul 100% local)
•	Ads SDK : Google AdMob
•	Analytics : Firebase Analytics (anonymisé)
•	In-App Purchase : RevenueCat (iOS + Android)
•	CI/CD : Codemagic ou GitHub Actions
•	Remote Config : Firebase Remote Config (pour mise à jour des barèmes sans release)

9.2 Principes de Confidentialité
•	Aucune donnée personnelle transmise à un serveur
•	Calculs réalisés intégralement sur l'appareil
•	Aucun compte utilisateur requis
•	Export PDF généré localement
•	Conformité RGPD by design

9.3 Mise à jour des barèmes
•	Firebase Remote Config pour pousser les nouveaux barèmes dès publication au Journal Officiel
•	Fallback : barème embarqué dans l'app comme baseline
•	Versioning des barèmes (2025, 2026, ...) pour permettre la comparaison inter-années

9.4 Structure des données (modèle simplifié)

FoyerFiscal
situationFamiliale (enum), nbEnfants (int), nbPartsSupplementaires (double), revenuNetImposable (double), autresRevenus (List<Revenu>)

Simulation
foyerFiscal (FoyerFiscal), impotBrut (double), decote (double), reductions (List<Reduction>), credits (List<Credit>), impotNet (double), tauxMoyen (double), tauxMarginal (double)

Dispositif
id (String), nom (String), categorie (enum: BASIQUE/AVANCE/EXPERT), type (enum: REDUCTION/CREDIT/DEDUCTION), tauxAvantage (double), plafond (double), conditionsEligibilite (List<Condition>), horsNicheFiscale (bool)
10. Monétisation
10.1 Modèle Freemium + Publicité

Gratuit :
•	Simulateur IR complet (toutes les tranches, quotient familial, décote)
•	Optimisation niveau Basique (7 dispositifs courants)
•	Tableau de bord niches fiscales (lecture seule)
•	Calendrier fiscal
•	Publicités bannière (bas d'écran) + interstitielles (toutes les 3 simulations)

Premium "FiscalIA Pro" (abonnement) :
•	Optimisation niveaux Avancé + Expert (20+ dispositifs)
•	Tableau de bord niches fiscales interactif
•	Export PDF personnalisé
•	Mode comparaison année N vs N-1
•	Suppression des publicités
•	Notifications push personnalisées

Tarification suggérée :
•	Mensuel : 4,99 €/mois
•	Annuel : 29,99 €/an (économie de 50%)
•	Achat unique lifetime : 79,99 € (upsell lors des pics déclaration)

10.2 Revenus publicitaires estimés
•	eCPM estimé France : 3-8 € (finance = niche premium)
•	Avec 10 000 DAU et 3 impressions/session : 900-2 400 €/mois
•	Avec 50 000 DAU : 4 500-12 000 €/mois
11. Métriques de Succès
Métriques d'Adoption (1-4 semaines)
•	Téléchargements : 10 000 le 1er mois, 50 000 à 6 mois
•	Taux d'activation (1ère simulation complétée) : > 60%
•	Temps moyen première simulation : < 2 minutes
•	DAU/MAU ratio : > 25%

Métriques de Rétention (1-3 mois)
•	Rétention J7 : > 30%
•	Rétention J30 : > 15%
•	Sessions par utilisateur/mois : > 3

Métriques de Monétisation (3-6 mois)
•	Taux de conversion premium : > 5%
•	ARPU (revenu moyen par utilisateur) : > 0,50 €/mois
•	LTV (valeur vie) : > 12 €
•	Note stores : > 4.5
12. Risques et Mitigations
Risque	Impact	Probabilité	Mitigation
Erreur de calcul fiscal	Critique	Moyenne	Tests unitaires exhaustifs vs simulateur officiel impots.gouv.fr. Disclaimer légal "à titre indicatif"
Changement de barème en cours d'année	Moyen	Élevée	Firebase Remote Config pour mise à jour instantanée sans nouvelle release
Requalification en conseil fiscal (AMF/ACPR)	Critique	Faible	Limiter aux informations publiques. Aucun conseil personnalisé d'investissement. Mentions légales claires
Concurrence d'impots.gouv.fr (ajout de recommandations)	Moyen	Faible	Différenciation par l'UX mobile-first, les niveaux experts et la pédagogie
Faible adoption hors période déclaration (avril-juin)	Élevé	Élevée	Pousser le PER (investir avant 31 déc), le calendrier fiscal, les alertes proactives
Réglementation RGPD	Faible	Faible	Architecture 100% locale, aucune donnée personnelle collectée
13. Roadmap
Phase 1 — MVP (Mois 1-3)
•	Simulateur IR complet (barème 2026)
•	Optimisation niveau Basique (7 dispositifs)
•	Publicité AdMob
•	Publication App Store + Google Play

Phase 2 — Croissance (Mois 4-6)
•	Optimisation niveau Avancé (PER, LMNP, Denormandie, etc.)
•	Tableau de bord niches fiscales
•	Abonnement premium via RevenueCat
•	Export PDF
•	Calendrier fiscal + notifications

Phase 3 — Expert (Mois 7-12)
•	Optimisation niveau Expert (SCI, démembrement, Dutreil, IFI)
•	Centre éducatif (fiches + vidéos)
•	Mode comparaison inter-années
•	Localisation anglais (expatriés)
•	Widget iOS (résumé fiscal)

Phase 4 — Expansion (Année 2)
•	Ouverture aux indépendants (BIC, BNC, micro)
•	IA conversationnelle (chatbot fiscal)
•	Intégration open banking (import revenus)
•	Extension à d'autres pays européens
14. Questions Ouvertes
•	[Juridique] Faut-il un disclaimer spécifique pour éviter la requalification en conseil en investissement ? Vérifier avec un avocat fiscaliste
•	[Design] Quel onboarding pour les utilisateurs non-initiés à la fiscalité ? User testing requis
•	[Technique] Firebase Remote Config est-il suffisant pour gérer la complexité des barèmes multi-années, ou faut-il un micro-service dédié ?
•	[Business] Faut-il proposer un partenariat avec des CGP/fiscalistes pour le niveau Expert (apport d'affaires) ? Risque de conflit d'intérêt vs revenu additionnel
•	[Réglementaire] La OÜ estonienne peut-elle être éditeur d'une app de conseil fiscal français sans agrément local ?
15. Annexe : Barème IR 2026 (Revenus 2025)
Tranche	Revenus	Taux
Tranche 1	Jusqu'à 11 600 €	0%
Tranche 2	11 601 € à 29 579 €	11%
Tranche 3	29 580 € à 84 577 €	30%
Tranche 4	84 578 € à 181 917 €	41%
Tranche 5	Plus de 181 917 €	45%

•	Revalorisation : +0,9% (loi de finances 2026, publiée au JO le 20 février 2026)
•	Plafond quotient familial : 1 807 € par demi-part supplémentaire
•	Plafond niches fiscales : 10 000 € (cas général) / 18 000 € (outre-mer, SOFICA)
•	PER : déduction jusqu'à 10% des revenus, plafond 37 094 € (2025), report sur 3 ans

Sources
Service-public.fr — Barème IR 2026 : https://www.service-public.gouv.fr/particuliers/actualites/A18045
Service-public.fr — Plafonnement niches fiscales : https://www.service-public.gouv.fr/particuliers/vosdroits/F31179
impots.gouv.fr — Simulateur officiel : https://www.impots.gouv.fr/simulateurs
Meilleurtaux — PER plafonds 2025-2026 : https://placement.meilleurtaux.com/retraite/actualites/2025-novembre/per-plafonds-2025-deduction-relevee-2026.html
Expert Impôts — Plafonnement niches fiscales 2026 : https://expertimpots.com/articles/plafonnement-niche-fiscale
LMNP.AI — 7 dispositifs de défiscalisation 2025 : https://lmnp.ai/ressources/les-7-dispositifs-de-defiscalisation-immobiliere-en-2025
