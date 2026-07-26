# FiscalIA

Simulateur & Optimisateur d'Impôt sur le Revenu — France.

Application Flutter (iOS / Android) qui aide les contribuables français à
estimer leur impôt, identifier les crédits et réductions d'impôt
applicables à leur situation, et dialoguer avec un copilote fiscal
alimenté par un RAG sur les sources officielles (BOFiP, DGFiP,
service-public.fr).

> ⚠️ **Avertissement légal** : FiscalIA est un outil de simulation à visée
> pédagogique. Les résultats sont des estimations et ne se substituent ni
> au simulateur officiel de la DGFiP ni à un conseil fiscal professionnel.

## Fonctionnalités

- **Simulateur IR complet** : barème progressif, quotient familial avec
  plafonnement (BOFiP BOI-IR-LIQ-10), décote, CEHR, parent isolé (case T),
  comparaison frais réelles / abattement 10 %
- **Crédits & réductions d'impôt** : emploi à domicile, garde d'enfants,
  dons, frais de scolarité, cotisations syndicales, pension alimentaire
- **Plafond des niches fiscales** : suivi et visualisation de la répartition
- **Suivi PER** : plafonds annuels et report des plafonds non utilisés
- **Calendrier fiscal** : échéances et notifications locales paramétrables
- **Scanner de documents** : OCR (ML Kit) et analyse de fiches de paie
- **Copilote Fiscal (chat IA)** : Cloud Function + Genkit / Vertex AI avec
  RAG (Firestore vector search) sur un corpus de sources officielles
- **Centre éducatif** : guides, FAQ, glossaire fiscal

## Stack technique

| Domaine | Technologie |
| --- | --- |
| UI / state | Flutter (Dart ^3.11), Riverpod 2.4 |
| Persistance locale | Hive (offline-first) |
| Backend | Firebase Cloud Functions (`europe-west1`), Genkit + Vertex AI (Gemini 1.5 Flash) |
| RAG | Firestore vector search, embeddings `textMultilingualEmbedding002` |
| OCR | Google ML Kit (forks locaux dans `packages/`), Syncfusion PDF |
| Divers | fl_chart, pdf, share_plus, flutter_local_notifications |

## Architecture

```
lib/
├── main.dart                      # Init Firebase (fallback gracieux) + Hive
├── app.dart                       # MaterialApp, navigation par onglets
├── core/
│   ├── constants/tax_brackets.dart  # Barème IR, plafonds, décote (références légales)
│   └── theme/
├── data/models/                   # Modèles métier (foyer fiscal, crédits, PER...)
├── presentation/
│   ├── providers/                 # Riverpod + moteur de calcul (TaxCalculator)
│   └── screens/                   # ~20 écrans (simulateur, niches, scanner, chat...)
└── agents/                        # Orchestrateur multi-agents (Phase 3)

functions/                         # Cloud Functions TypeScript (Genkit, seed RAG)
assets/knowledge/                  # Corpus RAG (sources officielles + manifeste)
test/                              # Tests unitaires (calculs fiscaux, modèles)
```

Les calculs fiscaux sont documentés avec leurs références légales (CGI,
BOFiP) directement dans le code.

## Démarrage

### Prérequis

- Flutter SDK stable (Dart ^3.11.1)
- Un projet Firebase + FlutterFire CLI

### Installation

```bash
cd fiscalia
flutter pub get

# Configuration Firebase (génère lib/firebase_options.dart)
flutterfire configure
```

L'application démarre **sans Firebase configuré** (fallback gracieux) :
seules les fonctions IA/OCR cloud sont désactivées.

### Lancer l'application

```bash
flutter run                # appareil par défaut
flutter run -d ios         # simulateur iOS
flutter run -d android     # émulateur Android
```

### Tests et analyse

```bash
flutter test               # suite complète
flutter analyze
```

## Backend (Cloud Functions)

```bash
cd functions
npm install
npm run build              # compile TypeScript
npm run serve              # émulateur local
npm run deploy             # déploiement
npm run seed:rag           # ingestion du corpus RAG (assets/knowledge)
```

## Documentation projet

- [PRD principal](../PRD_FiscalIA.md)
- [PRD Agent IA](../PRD_FiscalIA_Agent_IA.md)
- Planning BMAD : [`_bmad-output/`](../_bmad-output/) (architecture,
  epics, sprints)
- Stratégie & RAG : [`documentations/`](documentations/)
