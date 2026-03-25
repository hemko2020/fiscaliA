
FiscalIA
Addendum PRD — Agent IA Fiscal
Module 6 : Intelligence Artificielle d’Optimisation Fiscale
Version 1.0 — Mars 2026

Confidentiel
 
1. Vision de l’Agent IA
L’Agent IA Fiscal est le cœur différenciant de FiscalIA. Contrairement aux simulateurs existants qui se contentent de calculer l’impôt, cet agent analyse activement la situation de l’utilisateur pour détecter et exploiter chaque levier d’optimisation autorisé par le droit fiscal français — y compris les zones grises, les dispositifs méconnus, et les combinaisons de niches fiscales que même un conseiller humain pourrait négliger.
Philosophie : L’agent se positionne comme un « avocat fiscaliste de poche » qui connaît chaque faille, chaque exception, chaque combinaison possible du Code Général des Impôts pour maximiser les économies de l’utilisateur, tout en restant strictement dans le cadre légal.
Limite légale claire : L’agent ne recommande JAMAIS de montages constituant un abus de droit au sens de l’article L.64 du Livre des procédures fiscales (actes fictifs ou motivés principalement par l’évasion fiscale). Chaque recommandation est accompagnée de sa base légale (article du CGI, BOFiP, jurisprudence).
2. Architecture Technique de l’Agent
2.1 Approche Multi-Agent (inspirée du framework Synedrion, Stanford/arxiv)
L’agent IA utilise une architecture multi-agent spécialisée :
Agent 1 — Profilage Fiscal (ProfilerAgent) :
•	Analyse la situation complète de l’utilisateur (revenus, famille, patrimoine, charges)
•	Identifie le TMI (Taux Marginal d’Imposition) et le RFR (Revenu Fiscal de Référence)
•	Détecte les signaux d’alerte (revenus exceptionnels, changement de situation familiale, primo-accédant)
•	Construit un « profil fiscal » structuré en JSON

Agent 2 — Scanner de Failles (LoopholeAgent) :
•	Parcourt la base de connaissances fiscales (CGI, BOFiP, jurisprudences)
•	Identifie TOUS les dispositifs applicables au profil de l’utilisateur
•	Classe les dispositifs par potentiel d’économie, risque de contrôle, et complexité de mise en œuvre
•	Détecte les « combinaisons gagnantes » (dispositifs cumulables qui contournent légalement le plafond de 10K€)

Agent 3 — Stratège Fiscal (StrategyAgent) :
•	Construit des scénarios d’optimisation multi-dispositifs
•	Calcule l’économie nette après prise en compte des coûts d’entrée (frais de notaire, gestion, etc.)
•	Génère un plan d’action étape par étape avec calendrier
•	Vérifie la conformité anti-abus de droit pour chaque recommandation

Agent 4 — Vérificateur Juridique (ComplianceAgent) :
•	Valide que chaque recommandation ne constitue pas un abus de droit (art. L.64 LPF)
•	Vérifie le « motif non exclusivement fiscal » de chaque montage
•	Attribue un score de risque (1 à 5) à chaque stratégie
•	Génère le disclaimer légal approprié
2.2 Base de Connaissances Fiscales
La base de connaissances embarquée contient :
•	Le Code Général des Impôts (articles pertinents, mis à jour annuellement)
•	Les Instructions BOFiP (Bulletin Officiel des Finances Publiques)
•	Les rescrits fiscaux publiés
•	Les jurisprudences clés du Conseil d’État et de la Cour de cassation
•	Le barème fiscal mis à jour via Firebase Remote Config

Format : fichiers JSON structurés par thème, embarqués dans l’app (pas de serveur requis).
Taille estimée : 15-25 MB compressés.
Mise à jour : via Firebase Remote Config + releases annuelles post loi de finances.
2.3 Modèle d’IA
Option A — On-Device (recommandé pour la V1) :
•	Moteur de règles expert (rule-based engine) codé en Dart
•	Arbre de décision multi-critères pour le matching dispositifs/profil
•	Pas de dépendance à un serveur, confidentialité totale
•	Temps de réponse < 1 seconde

Option B — LLM Cloud (V2+) :
•	API vers un LLM fine-tuné sur le droit fiscal français
•	Capacité de conversation en langage naturel (« Comment réduire mon impôt de 35 000€ ? »)
•	RAG (Retrieval-Augmented Generation) sur la base BOFiP/CGI
•	Coût estimé : 0,02-0,05€ par requête

Recommandation : V1 en moteur de règles (fiabilité + confidentialité + zéro coût serveur), V2 en hybride (règles + LLM pour les cas complexes et le chat).
3. Les 25 Failles & Leviers Fiscaux Exploités par l’Agent
Voici la base de connaissances « offensive » de l’agent. Chaque levier est classé par niveau (Basique/Avancé/Expert), par type (Déduction/Réduction/Crédit/Exonération), et accompagné de sa base légale.
PARTIE A — Leviers méconnus sur les revenus
Réduction de la base imposable.

Levier 1 : Frais réels vs abattement 10% — Le piège des 10% automatiques
•	Faille exploitée : 12 millions de foyers oublient de déclarer leurs frais réels. L’agent compare automatiquement les deux options.
•	Ce que l’agent détecte : km domicile-travail (barème officiel), repas hors domicile (5,45€/jour), local professionnel (prorata surface), matériel informatique (amortissement 3 ans), double résidence, frais de formation, vêtements professionnels, frais de recherche d’emploi
•	Plafond : AUCUN plafond sur les frais réels (vs 14 556€ max pour les 10%)
•	Impact typique : 500 à 3 000€ d’économie pour un salarié à 30-50 km de son travail
•	Base légale : Art. 83-3° CGI, BOFiP BOI-RSA-BASE-30-50
•	Niveau : Basique

Levier 2 : Cotisations syndicales — Le crédit d’impôt de 66% que personne ne réclame
•	Faille exploitée : 90% des syndiqués oublient de le déclarer. Case 7AC de la déclaration.
•	Impact : 66% du montant versé en crédit d’impôt (plafond 1% du revenu)
•	Base légale : Art. 199 quater C du CGI
•	Niveau : Basique

Levier 3 : Frais de scolarité — Les 61€ à 183€ oubliés par enfant
•	Faille exploitée : Simple case à cocher mais largement oubliée
•	Montants : 61€ (collège), 153€ (lycée), 183€ (supérieur) par enfant
•	Base légale : Art. 199 quater F du CGI
•	Niveau : Basique

Levier 4 : Pension alimentaire vs rattachement — Le calcul que personne ne fait
•	Faille exploitée : L’agent simule les deux options (rattacher l’enfant majeur vs verser une pension déductible de 6 674€) et recommande la plus avantageuse selon le TMI
•	Impact : Jusqu’à 2 500€ d’économie pour un TMI à 41%
•	Base légale : Art. 156 II 2° CGI (pension), Art. 196 bis CGI (rattachement)
•	Niveau : Avancé

Levier 5 : PER — L’arme ultime hors plafond des niches fiscales
•	Faille exploitée : Le PER échappe au plafond de 10 000€ des niches fiscales. Plafond propre de 37 094€/an + cumul 3 ans non utilisés. L’agent détecte le plafond disponible sur l’avis d’imposition.
•	Impact : Économie = montant versé x TMI. Pour 10 000€ versés à TMI 30% = 3 000€ d’économie immédiate
•	Combinaison détectée : PER couple (mutualisation des plafonds) = jusqu’à 74 188€/an de déduction
•	Base légale : Art. 163 quatervicies CGI
•	Niveau : Avancé

Levier 6 : Déficit foncier — Créer du déficit pour effacer l’impôt
•	Faille exploitée : Les travaux sur un bien locatif nu créent un déficit imputable sur le revenu global (10 700€/an) + report illimité sur les revenus fonciers pendant 10 ans. HORS plafond des niches fiscales.
•	Impact : Jusqu’à 10 700€ de déduction du revenu global + effacement total des revenus fonciers
•	Base légale : Art. 156 I 3° CGI
•	Niveau : Avancé
PARTIE B — Leviers sur les réductions/crédits d’impôt
Diminution directe de l’impôt.

Levier 7 : Dons aux organismes d’aide — La réduction à 75% plafonnée à 1 000€
•	Faille exploitée : Les dons aux associations d’aide aux personnes en difficulté bénéficient de 75% de réduction (vs 66% pour les dons classiques). L’agent recommande de ventiler les dons.
•	Stratégie de l’agent : Donner 1 000€ aux organismes d’aide (75% = 750€ de réduction) + le surplus aux associations classiques (66%)
•	Base légale : Art. 200 CGI, Loi n°2023-1322 du 29/12/2023
•	Niveau : Basique

Levier 8 : Emploi à domicile — Maximiser le crédit de 50% avec les plafonds spécifiques
•	Faille exploitée : Plafond de 12 000€ majoré de 1 500€ par enfant à charge ou personne de +65 ans (max 15 000€). Première année d’emploi : plafond relevé à 15 000€ (18 000€ avec majorations).
•	L’agent détecte : nounou, ménage, jardinage (5 000€ max), bricolage (500€ max), cours particuliers, aide informatique (3 000€ max)
•	Base légale : Art. 199 sexdecies CGI
•	Niveau : Basique

Levier 9 : FCPI/FIP — La réduction de 25% sans effort
•	Faille exploitée : 25% du montant investi en réduction d’impôt, plafond 12 000€ (célibataire) ou 24 000€ (couple), dans le plafond des 10K€ mais cumulable avec d’autres dispositifs
•	Base légale : Art. 199 terdecies-0 A CGI
•	Niveau : Avancé

Levier 10 : Girardin Industriel — Le « one-shot » hors plafond 10K€ (plafond 18K€)
•	Faille exploitée : Réduction d’impôt pouvant atteindre 110-120% du montant investi (on récupère PLUS que ce qu’on investit). Plafond de 18 000€ au lieu de 10 000€.
•	Risque : Score 3/5 (risque de requalification si l’opérateur n’est pas sérieux)
•	Base légale : Art. 199 undecies B CGI
•	Niveau : Expert
PARTIE C — Stratégies de contournement du plafond des 10 000€

Levier 11 : La combinaison PER + Déficit foncier + Malraux — Triple contournement légal
•	Faille exploitée : Ces 3 dispositifs sont HORS du plafond de 10 000€. Un utilisateur peut cumuler :
◦	PER : déduction de 37 094€ du revenu imposable
◦	Déficit foncier : 10 700€ de déduction du revenu global
◦	Loi Malraux : réduction d’impôt jusqu’à 30 000€/an (30% de 100K€ de travaux)
•	Total potentiel : 77 794€ de déduction + 30 000€ de réduction, HORS plafond
•	Base légale : Art. 199 tervicies CGI (Malraux), Art. 156 I 3° CGI (déficit foncier), Art. 163 quatervicies CGI (PER)
•	Niveau : Expert

Levier 12 : Monuments Historiques — La niche sans plafond
•	Faille exploitée : Déduction TOTALE des travaux de restauration sur un monument classé, sans aucun plafond, imputable sur le revenu global sans limitation
•	Impact : Peut effacer intégralement l’impôt d’un cadre supérieur
•	Base légale : Art. 156 I 3° ter et Art. 156 bis CGI
•	Niveau : Expert

Levier 13 : SOFICA — Le plafond à 18K€ avec réduction à 48%
•	Faille exploitée : Réduction d’impôt de 30% à 48% du montant investi dans le cinéma français. Plafond de 18 000€ (pas 10 000€).
•	Base légale : Art. 199 unvicies CGI
•	Niveau : Expert
PARTIE D — Stratégies patrimoniales
Transmission et restructuration.

Levier 14 : Démembrement de propriété — Donner en payant moins de droits
•	Faille exploitée : En donnant la nue-propriété d’un bien, les droits sont calculés sur la valeur de la nue-propriété uniquement (40% à 90% de la valeur selon l’âge). Au décès, reconstitution de la pleine propriété SANS droits supplémentaires.
•	Combinaison détectée : Donation nue-propriété + abattement 100K€/enfant/15 ans = transmission quasi-gratuite
•	Base légale : Art. 669 CGI (barème usufruit/nue-propriété), Art. 779 CGI (abattement 100K€)
•	Niveau : Expert

Levier 15 : Donation temporaire d’usufruit — Réduire l’IFI légalement
•	Faille exploitée : Donner l’usufruit temporaire d’un bien immobilier (ex: 10 ans) à un enfant étudiant ou une association. Le bien sort du patrimoine IFI du donateur. Les droits sont calculés sur 23% de la valeur seulement.
•	Impact : Le bien sort de l’IFI pendant toute la durée de la donation
•	Base légale : Art. 669 CGI, Art. 965 CGI (IFI), BOFiP BOI-PAT-IFI-20-30
•	Niveau : Expert

Levier 16 : SCI à l’IR — Le déficit foncier amplifié
•	Faille exploitée : Via une SCI à l’IR, les travaux réalisés sur les biens de la SCI génèrent un déficit foncier imputable par chaque associé au prorata de ses parts. Deux conjoints associés doublent potentiellement la capacité de déduction.
•	Base légale : Art. 8 CGI (transparence fiscale SCI), Art. 156 I 3° CGI
•	Niveau : Expert

Levier 17 : SCI à l’IS — L’amortissement invisible
•	Faille exploitée : En optant pour l’IS, la SCI peut amortir le bien immobilier (hors terrain), réduisant le bénéfice imposable à zéro pendant des années. Inconvénient : imposition des plus-values pro à la revente.
•	L’agent calcule : le point de bascule IR/IS selon la durée de détention et le TMI
•	Base légale : Art. 206-2 CGI, Art. 39-1-2° CGI (amortissement)
•	Niveau : Expert

Levier 18 : Pacte Dutreil — 75% d’exonération sur la transmission d’entreprise
•	Faille exploitée : Exonération de 75% de la valeur des parts transmises par donation ou succession. Combinable avec la réduction de 50% pour donation avant 70 ans.
•	Impact : Transmission de 1M€ d’entreprise avec seulement ~33K€ de droits (au lieu de ~200K€)
•	Base légale : Art. 787 B CGI
•	Niveau : Expert

Levier 19 : PEA — L’enveloppe exonérée après 5 ans
•	Faille exploitée : Après 5 ans, les plus-values du PEA sont exonérées d’impôt (seuls les prélèvements sociaux de 17,2% s’appliquent). L’agent recommande d’ouvrir un PEA le plus tôt possible pour « prendre date ».
•	Base légale : Art. 157-5° bis CGI
•	Niveau : Avancé

Levier 20 : Assurance-vie — Le double abattement après 8 ans
•	Faille exploitée : Après 8 ans, abattement de 4 600€ (célibataire) ou 9 200€ (couple) sur les gains. Les rachats partiels annuels sous ces seuils sont exonérés d’IR.
•	Stratégie de l’agent : rachats partiels calibrés chaque année pour rester sous le seuil
•	Base légale : Art. 125-0 A CGI
•	Niveau : Avancé
PARTIE E — Failles procédurales et astuces déclaratives

Levier 21 : La déclaration séparée l’année du mariage/PACS — Simuler les deux options
•	Faille exploitée : L’année du mariage ou du PACS, les époux peuvent choisir entre déclaration commune ou séparée. L’agent simule les deux scénarios et recommande le plus avantageux.
•	Impact : Jusqu’à plusieurs milliers d’euros d’économie selon les écarts de revenus
•	Base légale : Art. 6-5 CGI

Levier 22 : Le quotient pour revenus exceptionnels — Étaler l’impôt
•	Faille exploitée : Les revenus exceptionnels (prime de départ, indemnité de licenciement, rappel de salaire) peuvent être imposés au système du quotient (diviser par 4, calculer l’impôt, multiplier par 4). Réduit l’effet progressif du barème.
•	Base légale : Art. 163-0 A CGI

Levier 23 : La réclamation contentieuse — Corriger les 3 dernières années
•	Faille exploitée : L’utilisateur peut rectifier ses déclarations des 3 années précédentes pour récupérer des avantages oubliés. L’agent détecte les oublis potentiels et guide la réclamation.
•	Base légale : Art. R*196-1 LPF (délai de réclamation)

Levier 24 : L’option pour le barème sur les dividendes — Quand la flat tax perd
•	Faille exploitée : La flat tax (30%) n’est pas toujours optimale. Pour un TMI de 0% ou 11%, l’option pour le barème progressif + abattement de 40% est plus avantageuse. L’agent calcule le point de bascule.
•	Base légale : Art. 200 A CGI (PFU), Art. 158-3-2° CGI (abattement 40%)

Levier 25 : Les dons IFI — La réduction à 75% jusqu’à 50 000€
•	Faille exploitée : Les dons à certains organismes d’intérêt général donnent droit à une réduction de 75% de l’IFI, plafonnée à 50 000€/an. Dispositif distinct de la réduction IR pour dons.
•	Base légale : Art. 978 CGI
4. Fonctionnement de l’Agent — Parcours Utilisateur
Étape 1 — Onboarding intelligent (2 minutes)
L’agent pose 8-12 questions ciblées :
•	Situation familiale (célibataire, marié/pacsé, nombre d’enfants, âges)
•	Revenus (salaires, fonciers, financiers, exceptionnels)
•	Patrimoine (immobilier, financier, PEA, assurance-vie)
•	Charges actuelles (emploi à domicile, dons, PER, pensions)
•	Objectifs (réduire l’IR, préparer la retraite, transmettre, réduire l’IFI)
Étape 2 — Analyse « Radar Fiscal »
L’agent affiche un radar/graphique montrant :
•	Impôt actuel estimé
•	Impôt optimisé (tous leviers activés)
•	Économie potentielle totale
•	Répartition par catégorie de levier
•	Score d’utilisation des niches fiscales (x% du plafond 10K€ utilisé)
Étape 3 — Recommandations personnalisées
Liste ordonnée par impact décroissant, chaque recommandation contient :
•	Nom du dispositif + icône
•	Économie estimée en euros
•	Niveau de complexité (1 à 5 étoiles)
•	Score de risque fiscal (1 à 5)
•	Étapes de mise en œuvre
•	Base légale (article CGI + lien BOFiP)
•	Bouton « Simuler » pour ajuster les paramètres
Étape 4 — Plan d’action personnalisé
•	Calendrier des actions (quand agir : avant le 31/12, avant la déclaration, etc.)
•	Checklist des documents nécessaires
•	Rappels push aux dates clés
•	Option export PDF pour transmission à un conseiller
5. Garde-fous Juridiques
5.1 Principe de conformité
L’agent applique un filtre en 3 niveaux :
•	Niveau 1 (Vert) : Dispositifs standards, risque zéro. Le simulateur officiel impots.gouv.fr les couvre.
•	Niveau 2 (Orange) : Optimisation avancée, parfaitement légale mais nécessitant une justification. L’agent fournit la base légale et le BOFiP.
•	Niveau 3 (Rouge) : Stratégies expertes proches des limites. L’agent avertit explicitement : « Cette stratégie est légale mais peut attirer l’attention du fisc. Nous recommandons de consulter un avocat fiscaliste. »
5.2 Disclaimers obligatoires
Chaque écran de recommandation affiche :
•	« FiscalIA fournit des informations à caractère général basées sur la législation en vigueur. Ces informations ne constituent pas un conseil fiscal personnalisé au sens de la réglementation AMF/ACPR. »
•	« Pour les stratégies de niveau Expert, nous recommandons la consultation d’un avocat fiscaliste ou d’un notaire. »
•	« Les calculs sont réalisés à titre indicatif et ne sauraient engager la responsabilité de l’éditeur. »
5.3 Scoring de risque
Chaque stratégie est notée :
•	Score 1 : Aucun risque (frais réels, dons, PER)
•	Score 2 : Risque négligeable (FCPI/FIP, emploi à domicile)
•	Score 3 : Risque faible (déficit foncier, Denormandie, LMNP)
•	Score 4 : Risque modéré (Girardin, SOFICA, démembrement)
•	Score 5 : Risque significatif (Monuments Historiques, holding complexe) — nécessite conseil professionnel
6. Monétisation de l’Agent IA
L’agent IA est le principal driver de conversion vers le premium :
Gratuit (inclus dans FiscalIA Free)
•	Analyse de profil basique
•	3 recommandations de niveau Basique
•	Score d’utilisation des niches fiscales
Premium « FiscalIA Pro »
•	Analyse complète avec les 25 leviers
•	Recommandations Avancées + Expert
•	Plan d’action personnalisé avec calendrier
•	Stratégies de contournement du plafond 10K€
•	Export PDF du plan d’optimisation
•	Mise à jour en temps réel post loi de finances
Premium « FiscalIA Expert » (nouvel abonnement proposé)
•	Tout FiscalIA Pro +
•	Simulateur SCI (IR vs IS)
•	Calculateur de démembrement avec barème 669 CGI
•	Simulateur Pacte Dutreil
•	Simulateur IFI + stratégies de réduction
•	Mode « année suivante » : projection N+1 pour planifier les investissements
Tarification suggérée
Offre	Mensuel	Annuel
FiscalIA Pro	4,99€/mois	29,99€/an
FiscalIA Expert	9,99€/mois	59,99€/an
Pack Lifetime Expert	—	149,99€
7. Avantage Concurrentiel
Fonctionnalité	Climb / Tacotax	PapperClass	TaxCut	impots.gouv	FiscalIA Agent IA
Analyse automatique du profil	Oui (humain)	Oui (IA)	Oui (IA+humain)	Non	Oui (IA on-device)
Détection frais réels oubliés	Non	Oui	Partiel	Non	Oui (20+ postes)
Stratégies hors plafond 10K€	Non	Non	Partiel	Non	Oui (PER+Malraux+ Déficit+MH)
Scoring de risque fiscal	Non	Non	Non	Non	Oui (1 à 5)
Base légale citée	Non	Partiel	Partiel	Non	Oui (CGI+BOFiP+ jurisprudence)
Confidentialité	Tiers + partenaires	Cloud FR	Cloud	Serveur État	100% local, zéro donnée transmise
Simulation patrimoniale (SCI, Dutreil)	Non	Non	Non	Non	Oui
Coût	Gratuit (CGP)	Inclus	Abonnement	Gratuit	Freemium 4,99-9,99€/mois

Différenciation clé : FiscalIA est la seule solution qui combine IA embarquée (100% locale, zéro fuite de données) + couverture des 25 leviers fiscaux incluant les stratégies expertes + scoring de risque + base légale complète. Les concurrents soit transmettent les données à des tiers (Climb/CGP), soit ne couvrent que les dispositifs basiques.
8. Roadmap d’Intégration
Phase 1 — MVP Agent (Mois 2-3, en parallèle du simulateur)
•	ProfilerAgent (questionnaire + profil JSON)
•	10 premiers leviers (Basiques + Avancés courants)
•	Recommandations avec économie estimée
•	Score niches fiscales
Phase 2 — Agent Complet (Mois 4-6)
•	25 leviers complets
•	StrategyAgent (combinaisons multi-dispositifs)
•	ComplianceAgent (scoring de risque)
•	Plan d’action avec calendrier
•	Export PDF
Phase 3 — Agent Expert (Mois 7-12)
•	Simulateurs patrimoniaux (SCI, démembrement, Dutreil, IFI)
•	Mode projection N+1
•	Alertes proactives (loi de finances, changement de barème)
•	A/B testing des recommandations
Phase 4 — Agent Conversationnel (Année 2)
•	Chat en langage naturel (« Comment payer zéro d’impôt ? »)
•	RAG sur base CGI/BOFiP
•	Analyse de l’avis d’imposition par OCR
•	Partenariat optionnel avec des avocats fiscalistes (apport d’affaires via la OÜ)
9. Sources Juridiques
1.	Code Général des Impôts — Art. 83, 156, 163 quatervicies, 199, 200, 669, 779, 787 B, 978 : https://www.legifrance.gouv.fr/codes/id/LEGITEXT000006069577/
2.	BOFiP — Bulletin Officiel des Finances Publiques : https://bofip.impots.gouv.fr
3.	Service-public.fr — Plafonnement niches fiscales : https://www.service-public.gouv.fr/particuliers/vosdroits/F31179
4.	Loi de finances 2026 — 10 changements : https://consultation.avocat.fr/blog/emma-vignal/article-2979709-loi-de-finances-2026-10-changements-fiscaux-importants-pour-les-particuliers.html
5.	La finance pour tous — Démembrement de propriété : https://www.lafinancepourtous.com/pratique/vie-perso/transmission-donation/demembrement-de-propriete-un-outil-doptimisation-fiscale/
6.	Corrige ton impôt — Frais réels : https://www.corrigetonimpot.fr/comment-deduire-frais-reels-impots-salaire-kilometre-repas/
7.	Expert Impôts — Optimisation fiscale particulier : https://expertimpots.com/articles/optimisation-fiscale-particulier
8.	K&P Finance — Plafonnement niches 2026 : https://www.kp-finance.com/plafonnement-des-niches-fiscales-tout-ce-quil-faut-savoir-a43/
9.	MoneyVox — 7 avantages fiscaux oubliés : https://www.moneyvox.fr/impot/actualites/103720/ces-7-avantages-que-vous-oubliez-trop-souvent-de-reclamer-aux-impots
10.	Avocats Picovschi — Abus de droit fiscal : https://www.avocats-picovschi.com/nouvelle-definition-de-l-abus-de-droit-l-avocat-fiscaliste-vous-accompagne_article_1412.html
11.	Synedrion (Stanford/arxiv) — Multi-agent tax software : https://arxiv.org/html/2509.13471v1
12.	PapperClass — Assistant fiscal IA : https://www.papperclass.com/fr/assistant-fiscal-intelligent-optimisation
