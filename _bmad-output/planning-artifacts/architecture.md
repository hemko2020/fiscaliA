---
stepsCompleted: ["step-01-init", "step-02-context", "step-03-starter", "step-04-decisions", "step-05-patterns", "step-06-structure", "step-07-validation"]
inputDocuments: ["PRD_FiscalIA.md", "PRD_FiscalIA_Agent_IA.md", "_bmad-output/planning-artifacts/epics.md"]
workflowType: 'architecture'
project_name: 'fiscaliA'
user_name: 'Hemko'
date: '2026-03-25'
---

# Architecture Decision Document - fiscaliA

## 1. Project Overview

**Project Name:** fiscaliA
**Type:** Mobile Application (Flutter - iOS & Android)
**Core Functionality:** Simulateur & Optimisateur d'Impôts sur le Revenu pour les salariés français
**Target Users:** Particuliers salariés français (39M foyers fiscaux, 18.6M imposables)

## 2. Technical Stack

### 2.1 Frontend
| Technology | Version | Purpose |
|------------|---------|---------|
| Flutter | 3.x | Cross-platform iOS + Android |
| Dart | 3.x | Programming language |
| Riverpod | 2.0+ | State management |
| Flutter Charts | latest | Data visualization |
| fl_chart | ^0.66+ | Pie charts, bar charts |

### 2.2 Local Storage
| Technology | Version | Purpose |
|------------|---------|---------|
| Hive | 2.2.3+ | NoSQL local database |
| Hive Flutter | 1.1.0+ | Flutter integration |
| Isar | 3.0+ | Alternative for complex queries |

### 2.3 Backend Services
| Service | Provider | Purpose |
|---------|----------|---------|
| Firebase Core | Google | App initialization |
| Firebase Analytics | Google | Usage tracking (anonymized) |
| Firebase Remote Config | Google | Tax bracket updates |
| Google AdMob | Google | Advertising revenue |
| RevenueCat | RevenueCat | In-app subscriptions |

## 3. Architecture Pattern

### 3.1 Clean Architecture Layers

```
lib/
├── core/                      # Shared utilities
│   ├── constants/              # App constants, tax brackets
│   ├── theme/                 # App theme, colors, typography
│   ├── utils/                 # Utility functions
│   └── errors/                # Error handling
├── data/                      # Data layer
│   ├── models/                # Data models (JSON serializable)
│   ├── repositories/          # Repository implementations
│   └── datasources/           # Local (Hive) data sources
├── domain/                    # Business logic layer
│   ├── entities/              # Business entities
│   ├── repositories/          # Repository interfaces
│   └── usecases/              # Business use cases
├── presentation/              # UI layer
│   ├── providers/             # Riverpod providers
│   ├── screens/              # Full screens
│   ├── widgets/               # Reusable widgets
│   └── controllers/           # State controllers
├── agents/                    # AI Agent layer
│   ├── profiler/              # ProfilerAgent
│   ├── loophole/              # LoopholeAgent
│   ├── strategy/              # StrategyAgent
│   └── compliance/            # ComplianceAgent
└── main.dart                  # App entry point
```

### 3.2 State Management (Riverpod 2.0)

```dart
// Provider structure
providers/
├── fiscal_profile_provider.dart    # User fiscal profile state
├── simulation_provider.dart       # Tax calculation state
├── niche_tracker_provider.dart    # Tax niche ceiling tracking
├── calendar_provider.dart         # Fiscal calendar state
├── agent_provider.dart            # AI agent state
└── subscription_provider.dart      # Premium status
```

### 3.3 Data Flow

```
User Input → Provider (StateNotifier) → UseCase → Repository → DataSource (Hive)
                ↓
            State Update → UI Rebuild
```

## 4. Data Models

### 4.1 Core Entities

```dart
// FoyerFiscal - User's fiscal household
class FoyerFiscal {
  SituationFamiliale situationFamiliale;
  int nbEnfants;
  double nbPartsSupplementaires;
  double revenuNetImposable;
  List<Revenu> autresRevenus;
}

// Simulation - Tax calculation result
class Simulation {
  FoyerFiscal foyerFiscal;
  double impotBrut;
  double decote;
  List<Reduction> reductions;
  List<Credit> credits;
  double impotNet;
  double tauxMoyen;
  double tauxMarginal;
}

// Dispositif - Tax optimization device
class Dispositif {
  String id;
  String nom;
  CategorieDispositif categorie; // BASIQUE, AVANCE, EXPERT
  TypeDispositif type; // REDUCTION, CREDIT, DEDUCTION
  double tauxAvantage;
  double? plafond;
  List<Condition> conditionsEligibilite;
  bool horsNicheFiscale;
}
```

### 4.2 Enums

```dart
enum SituationFamiliale { celibataire, marie, pacse, divorce, veuf }
enum CategorieDispositif { basique, avance, expert }
enum TypeDispositif { reduction, credit, deduction }
```

## 5. Tax Calculation Engine

### 5.1 Barème IR 2026 (Revenus 2025)

| Tranche | Revenus | Taux |
|---------|---------|------|
| 1 | Jusqu'à 11 600 € | 0% |
| 2 | 11 601 € à 29 579 € | 11% |
| 3 | 29 580 € à 84 577 € | 30% |
| 4 | 84 578 € à 181 917 € | 41% |
| 5 | Plus de 181 917 € | 45% |

### 5.2 Calculation Flow

```
1. Apply family quotient (quotient familial)
2. Calculate gross tax per bracket
3. Apply decote if eligible
4. Apply family quotient ceiling (1,807€/half-part)
5. Calculate CEHR if applicable
6. Apply reductions and credits
7. Final tax = impotNet
```

## 6. AI Agent Architecture

### 6.1 Multi-Agent System

```dart
// Agent interface
abstract class FiscalAgent {
  Future<FiscalProfile> analyze(FoyerFiscal foyer);
  Future<List<Dispositif>> matchDevices(FiscalProfile profile);
  Future<ActionPlan> buildStrategy(List<Dispositif> devices);
  Future<ComplianceResult> validate(Dispositif device);
}
```

### 6.2 Knowledge Base Structure

```
assets/
├── knowledge/
│   ├── cgi_articles.json      # CGI articles (15-25MB)
│   ├── bofip_instructions.json
│   ├── jurisprudence.json
│   └── tax_brackets.json      # Yearly tax brackets
```

### 6.3 Agent Workflow

```
1. ProfilerAgent: Build user fiscal profile (TMI, RFR, signals)
2. LoopholeAgent: Match 25 fiscal levers to profile
3. StrategyAgent: Build multi-device scenarios with action plan
4. ComplianceAgent: Validate against L.64 abuse of rights
```

## 7. Security & Privacy

### 7.1 Data Privacy

| Requirement | Implementation |
|-------------|----------------|
| No data transmission | All calculations local (Hive) |
| No user account | Anonymous usage |
| RGPD compliance | Local-only data, no PII |
| Legal disclaimers | Displayed on all screens |

### 7.2 Disclaimer Text

```
"FiscalIA fournit des informations à caractère général basées sur la
législation en vigueur. Ces informations ne constituent pas un conseil
fiscal personnalisé au sens de la réglementation AMF/ACPR."
```

## 8. CI/CD Pipeline

### 8.1 GitHub Actions

```yaml
# Workflow structure
.github/workflows/
├── analyze.yml       # flutter analyze on PR
├── build-android.yml  # Android APK on merge
└── build-ios.yml      # iOS IPA on merge (macOS)
```

### 8.2 Build Artifacts

- Android: `build/app/outputs/flutter-apk/`
- iOS: `build/ios/iphoneos/`

## 9. Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_riverpod: ^2.4.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  firebase_core: latest
  firebase_analytics: latest
  firebase_remote_config: latest
  google_mobile_ads: latest
  revenuecat_flutter: latest
  fl_chart: ^0.66.0
  intl: ^0.18.0
  pdf: ^3.10.0
  share_plus: ^7.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  hive_generator: ^2.0.0
  build_runner: ^2.4.0
```

## 10. Architecture Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| State Management | Riverpod 2.0 | Type-safe, testable, official Flutter recommendation |
| Local Storage | Hive | Fast, encrypted, works offline |
| Charts | fl_chart | Customizable, performant |
| PDF | pdf + printing | Local generation |
| Architecture | Clean Architecture | Separation of concerns, testability |

## 11. File Structure

```
fiscalia/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── constants/
│   │   │   ├── tax_brackets.dart
│   │   │   └── app_constants.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   └── app_colors.dart
│   │   └── utils/
│   │       └── formatters.dart
│   ├── data/
│   │   ├── models/
│   │   │   ├── foyer_fiscal_model.dart
│   │   │   ├── simulation_model.dart
│   │   │   └── dispositid_model.dart
│   │   └── repositories/
│   │       └── fiscal_repository_impl.dart
│   ├── domain/
│   │   ├── entities/
│   │   ├── repositories/
│   │   └── usecases/
│   │       ├── calculate_tax.dart
│   │       └── apply_optimization.dart
│   ├── presentation/
│   │   ├── providers/
│   │   ├── screens/
│   │   └── widgets/
│   └── agents/
│       ├── profiler_agent.dart
│       ├── loophole_agent.dart
│       ├── strategy_agent.dart
│       └── compliance_agent.dart
├── assets/
│   └── knowledge/
├── test/
└── pubspec.yaml
```
