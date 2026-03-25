---
stepsCompleted: ["step-01-init", "step-02-discovery", "step-03-core-experience", "step-04-emotional-response", "step-05-inspiration", "step-06-design-system", "step-07-defining-experience"]
inputDocuments: ["PRD_FiscalIA.md", "PRD_FiscalIA_Agent_IA.md", "_bmad-output/planning-artifacts/epics.md"]
project_name: 'fiscaliA'
user_name: 'Hemko'
date: '2026-03-25'
---

# UX Design Specification - fiscaliA

## 1. Project Overview

**Project Name:** fiscaliA
**Type:** Mobile Application (Flutter - iOS & Android)
**Core Functionality:** Simulateur & Optimisateur d'Impôts sur le Revenu pour les salariés français
**Target Users:** Particuliers salariés français

---

## 2. User Personas

### Persona 1: Marie, 32 ans
- **Revenu:** 42,000 €/an, célibataire
- **Douleur:** Remplit sa déclaration à la hâte, ne sait pas qu'elle peut déduire ses frais réels ou son PER
- **Besoin:** Comprendre en 5 minutes combien elle peut économiser
- **Niveau:** Basique → Intermédiaire

### Persona 2: Thomas & Julie, 40 ans
- **Revenus:** 95,000 €/an (combinés), propriétaires avec 2 enfants
- **Douleur:** Paient 8,500 € d'IR, n'optimisent pas leur quotient familial
- **Besoin:** Voir l'impact de chaque dispositif et optimiser le plafond de 10,000 €
- **Niveau:** Intermédiaire → Avancé

### Persona 3: Patrick, 55 ans
- **Revenu:** 180,000 €/an, TMI 41%, patrimoine immobilier via SCI
- **Douleur:** Paie 35,000 € d'IR + IFI, cherche à structurer sa transmission
- **Besoin:** Stratégies Dutreil, démembrement de parts SCI, PER cadre supérieur
- **Niveau:** Expert

---

## 3. Design System

### 3.1 Color Palette

```dart
// Primary Colors
const primaryBlue = Color(0xFF1E3A5F);      // Deep navy - trust, authority
const primaryBlueLight = Color(0xFF2E5A8F); // Lighter navy
const accentGreen = Color(0xFF27AE60);       // Success, savings
const accentOrange = Color(0xFFF39C12);      // Warnings, attention
const accentRed = Color(0xFFE74C3C);         // Errors, high risk

// Neutral Colors
const backgroundLight = Color(0xFFF8F9FA);
const backgroundDark = Color(0xFF1A1A2E);
const surfaceLight = Color(0xFFFFFFFF);
const surfaceDark = Color(0xFF2D2D44);
const textPrimaryLight = Color(0xFF2C3E50);
const textPrimaryDark = Color(0xFFECF0F1);
const textSecondary = Color(0xFF7F8C8D);

// Semantic Colors
const taxBracket0 = Color(0xFF27AE60);    // 0% - Green
const taxBracket11 = Color(0xFF2ECC71);   // 11% - Light green
const taxBracket30 = Color(0xFFF1C40F);  // 30% - Yellow
const taxBracket41 = Color(0xFFE67E22);  // 41% - Orange
const taxBracket45 = Color(0xFFE74C3C);   // 45% - Red

// Risk Score Colors
const riskLow = Color(0xFF27AE60);        // Score 1-2
const riskMedium = Color(0xFFF39C12);     // Score 3
const riskHigh = Color(0xFFE74C3C);        // Score 4-5
```

### 3.2 Typography

```dart
// Font Family
const fontFamily = 'Inter'; // Use system font or Google Fonts Inter

// Type Scale
const displayLarge = TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.w700,
  letterSpacing: -0.5,
);

const displayMedium = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.w600,
  letterSpacing: -0.25,
);

const headlineLarge = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w600,
);

const headlineMedium = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w600,
);

const titleLarge = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w500,
);

const bodyLarge = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  height: 1.5,
);

const bodyMedium = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  height: 1.4,
);

const labelLarge = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w500,
);

const caption = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w400,
  color: textSecondary,
);
```

### 3.3 Spacing System (8pt Grid)

```dart
const spacing4 = 4.0;
const spacing8 = 8.0;
const spacing12 = 12.0;
const spacing16 = 16.0;
const spacing24 = 24.0;
const spacing32 = 32.0;
const spacing48 = 48.0;
const spacing64 = 64.0;

const radiusSmall = 8.0;
const radiusMedium = 12.0;
const radiusLarge = 16.0;
const radiusXLarge = 24.0;
```

### 3.4 Component Library

#### Buttons
- `PrimaryButton` - Main CTA (filled, primaryBlue)
- `SecondaryButton` - Secondary actions (outlined)
- `TextButton` - Tertiary actions (text only)
- `IconButton` - Icon actions

#### Cards
- `SimulationResultCard` - Tax calculation results
- `DeviceCard` - Tax optimization device
- `AlertCard` - Risk warning or info
- `ActionPlanCard` - AI recommendation

#### Inputs
- `CurrencyInput` - Money input with formatting
- `DropdownSelector` - Enum selection (family situation)
- `SliderInput` - For adjustments (children count)
- `SegmentedControl` - Toggle options

#### Charts
- `TaxBracketPieChart` - Bracket breakdown
- `SavingsBarChart` - Current vs optimized
- `NicheProgressBar` - Ceiling usage
- `RadarFiscalChart` - AI agent visualization

---

## 4. Screen Structure

### 4.1 Navigation

```
BottomNavigationBar (5 tabs)
├── Accueil (Home)
├── Simulateur (Calculator)
├── Optimiser (AI Agent)
├── Niches (Dashboard)
└── Plus (Calendar, Education, Settings)
```

### 4.2 Screen Specifications

---

#### Screen 1: Onboarding / Splash

**Purpose:** First launch, explain value proposition

**Flow:**
1. Logo animation (2s)
2. Value proposition slides (3 slides)
3. Family situation selection
4. Quick tax estimate input
5. "Commencer" CTA

**Key Elements:**
- Illustration: Tax savings visualization
- Progress indicator (step X of 5)
- Skip option on slides

---

#### Screen 2: Home (Accueil)

**Purpose:** Dashboard overview

**Layout:**
```
┌────────────────────────────────┐
│ Header: "FiscalIA" + Avatar    │
├────────────────────────────────┤
│ Welcome message + Last sim date│
├────────────────────────────────┤
│ ┌────────────────────────────┐  │
│ │ Quick Tax Summary Card     │  │
│ │ - Current estimated tax    │  │
│ │ - Potential savings        │  │
│ │ - "Simuler" CTA button    │  │
│ └────────────────────────────┘  │
├────────────────────────────────┤
│ Recent Simulations (3 max)     │
│ - Date + Tax amount + Diff     │
├────────────────────────────────┤
│ Quick Actions                  │
│ - [Frais réels] [PER] [Dons]   │
├────────────────────────────────┤
│ Banner Ad (if free user)       │
├────────────────────────────────┤
│ [Nav Bar]                      │
└────────────────────────────────┘
```

**States:**
- Empty (no simulations yet)
- With data (1+ simulations)
- Premium badge visible

---

#### Screen 3: Simulator (Simulateur)

**Purpose:** Core tax calculator

**Layout:**
```
┌────────────────────────────────┐
│ Header: "Simulateur IR"        │
├────────────────────────────────┤
│ Step Indicator ● ○ ○ ○        │
├────────────────────────────────┤
│ Step 1: Situation familiale     │
│ ┌────────────────────────────┐  │
│ │ [Célibataire] [Marié/Pacsé]│  │
│ │ [Divorcé] [Veuf]           │  │
│ └────────────────────────────┘  │
│                                │
│ Step 2: Revenu imposable       │
│ ┌────────────────────────────┐  │
│ │ [Currency Input: 42,000 €] │  │
│ └────────────────────────────┘  │
│                                │
│ Step 3: Parts fiscales         │
│ │ Adults: 2  Children: [2][+] │
│                                │
│ Step 4: Results                │
│ ┌────────────────────────────┐  │
│ │ [Tax Bracket Pie Chart]     │  │
│ └────────────────────────────┘  │
│                                │
│ ┌────────────────────────────┐  │
│ │ Impôt net: 5,703 €         │  │
│ │ Taux marginal: 30%         │  │
│ │ Taux moyen: 13.6%          │  │
│ └────────────────────────────┘  │
│                                │
│ [Optimiser mon impôt →]        │
└────────────────────────────────┘
```

**Features:**
- Guided flow with back/next
- Real-time calculation
- Family quotient preview
- CEHR warning for high incomes

---

#### Screen 4: Optimizer (AI Agent)

**Purpose:** AI-powered tax optimization

**Layout:**
```
┌────────────────────────────────┐
│ Header: "Optimisez" + [🤖]    │
├────────────────────────────────┤
│ ┌────────────────────────────┐  │
│ │ [Radar Fiscal Chart]       │  │
│ │ Center: 5,703 € (current)  │  │
│ │ Edge: 2,500 € (optimized) │  │
│ │ Gap: 3,203 € savings      │  │
│ └────────────────────────────┘  │
├────────────────────────────────┤
│ Your Recommendations          │
│ ┌────────────────────────────┐  │
│ │ 📊 Frais réels              │  │
│ │ +1,800 € d'économie        │  │
│ │ Risque: ● (1/5)            │  │
│ │ [Appliquer] [En savoir +]  │  │
│ └────────────────────────────┘  │
│ ┌────────────────────────────┐  │
│ │ 🏠 Emploi à domicile       │  │
│ │ +750 € d'économie          │  │
│ │ Risque: ● (1/5)            │  │
│ │ [Appliquer] [En savoir +]  │  │
│ └────────────────────────────┘  │
│ ... (scrollable list)          │
├────────────────────────────────┤
│ Niche ceiling: 4,200 € restants│
│ [Voir tout]                    │
└────────────────────────────────┘
```

**Features:**
- Radar fiscal visualization
- Risk score indicators (color-coded 1-5)
- Premium content locked (blur + paywall)
- "En savoir +" expands details

---

#### Screen 5: Tax Niche Dashboard (Nich(es)

**Purpose:** Track tax niche ceiling usage

**Layout:**
```
┌────────────────────────────────┐
│ Header: "Mes Niches"           │
├────────────────────────────────┤
│ ┌────────────────────────────┐  │
│ │ [======|----] 6,800€/10K€  │  │
│ │ Remaining: 3,200€          │  │
│ └────────────────────────────┘  │
├────────────────────────────────┤
│ By Category                    │
│ ┌────────────────────────────┐  │
│ │ 🏠 Emploi domicile   2,000€ │  │
│ │ 👶 Garde d'enfants  1,500€ │  │
│ │ 🎁 Dons              500€ │  │
│ │ 📚 Frais scolarité    183€ │  │
│ │ ...                        │  │
│ └────────────────────────────┘  │
├────────────────────────────────┤
│ Suggestions (outside ceiling)  │
│ ┌────────────────────────────┐  │
│ │ 💰 PER         → 3,000€   │  │
│ │ 🏚️ Déficit foncier → 1,000€│  │
│ └────────────────────────────┘  │
└────────────────────────────────┘
```

**Features:**
- Progress bar with color coding
- Category breakdown
- Alert when >90% used
- Suggestions for outside-ceiling devices

---

#### Screen 6: Calendar (Calendrier)

**Purpose:** Fiscal key dates and reminders

**Layout:**
```
┌────────────────────────────────┐
│ Header: "Calendrier Fiscal"    │
├────────────────────────────────┤
│ March 2026                     │
│ ┌────────────────────────────┐  │
│ │ [Calendar Grid]             │  │
│ │ • March 15: Receipts deadline│ │
│ │ • April 1: Declaration open │ │
│ │ • May 27: Deadline (75)    │ │
│ │ • Dec 31: PER deadline     │ │
│ └────────────────────────────┘  │
├────────────────────────────────┤
│ Upcoming Reminders             │
│ ┌────────────────────────────┐  │
│ │ 🔔 PER: 45 jours restants  │  │
│ │ [Configurer les rappels]   │  │
│ └────────────────────────────┘  │
└────────────────────────────────┘
```

**Features:**
- Department-specific deadlines
- Push notification settings
- PER contribution tracker

---

#### Screen 7: Educational Center (Centre Éducatif)

**Purpose:** Tax education and glossary

**Layout:**
```
┌────────────────────────────────┐
│ Header: "Apprendre" + Search   │
├────────────────────────────────┤
│ [Search: "PER", " SCI"... ]   │
├────────────────────────────────┤
│ Categories                     │
│ ┌──────────┐ ┌──────────┐     │
│ │Retraite  │ │Immobilier │     │
│ │ 12 docs  │ │ 18 docs  │     │
│ └──────────┘ └──────────┘     │
│ ┌──────────┐ ┌──────────┐     │
│ │Famille   │ │Patrimoine │     │
│ │ 8 docs   │ │ 15 docs  │     │
│ └──────────┘ └──────────┘     │
├────────────────────────────────┤
│ Popular                        │
│ - "Comprendre le PER"          │
│ - "SCI: IR vs IS"             │
│ - "Quotient familial"         │
└────────────────────────────────┘
```

**Features:**
- Category browsing
- Search functionality
- Bookmarking
- FAQ accordion

---

#### Screen 8: Settings (Paramètres)

**Purpose:** App configuration

**Layout:**
```
┌────────────────────────────────┐
│ Header: "Paramètres"          │
├────────────────────────────────┤
│ Profile                        │
│ ├── Situation familiale        │
│ ├── Département                │
│ └── Notifications [Toggle]     │
├────────────────────────────────┤
│ Subscriptions                  │
│ ├── FiscalIA Pro: Active      │
│ ├── Renouvellement: Jan 2027  │
│ └── [Gérer l'abonnement]     │
├────────────────────────────────┤
│ About                          │
│ ├── Version: 1.0.0            │
│ ├── Barème: 2026              │
│ ├── [CGU] [Privacy] [Contact] │
└────────────────────────────────┘
```

---

#### Screen 9: Premium Paywall

**Purpose:** Convert free to paying users

**Layout:**
```
┌────────────────────────────────┐
│ Header: [X]                    │
├────────────────────────────────┤
│        🎯                       │
│   Débloquez todo le potentiel   │
│       fiscal de la France       │
├────────────────────────────────┤
│ ┌────────────────────────────┐  │
│ │ FiscalIA Pro               │  │
│ │ ○ 4.99€/mois               │  │
│ │ ● 29.99€/an (-50%)         │  │
│ │                             │  │
│ │ ✓ 20+ stratégies avancées  │  │
│ │ ✓ Simulateur SCI/Demembrement│  │
│ │ ✓ Plan d'action PDF        │  │
│ │                             │  │
│ │ [S'abonner]                │  │
│ └────────────────────────────┘  │
├────────────────────────────────┤
│ ┌────────────────────────────┐  │
│ │ FiscalIA Expert            │  │
│ │   9.99€/mois ou 59.99€/an  │  │
│ │                             │  │
│ │ ✓ Tout Pro +               │  │
│ │ ✓ IFI + Pacte Dutreil     │  │
│ │ ✓ Agent IA complet        │  │
│ └────────────────────────────┘  │
└────────────────────────────────┘
```

---

## 5. User Flows

### 5.1 First Launch Flow

```
Splash → Onboarding (3 slides) → Family Situation →
Quick Estimate → Home (empty state) → First Simulation
```

### 5.2 Tax Simulation Flow

```
Home → Simulateur → Step 1 (Family) → Step 2 (Income) →
Step 3 (Parts) → Results → [Optimize] → AI Agent
```

### 5.3 AI Optimization Flow

```
AI Agent (Profiler) → Questions (8-12) →
Radar Fiscal → Recommendations → Action Plan →
[Export PDF] or [Subscribe Premium]
```

---

## 6. Component Specifications

### 6.1 TaxBracketPieChart

```dart
// Requirements
- Donut chart (not filled pie)
- Center text: Total tax amount
- Legend on right side
- Tap segment: Show tooltip with amount
- Colors: Use taxBracket0-45 palette
- Animation: 500ms ease-out on load
```

### 6.2 RadarFiscalChart

```dart
// Requirements
- Pentagon/radar shape
- 5 axes: Current Tax, Optimized Tax, Savings,
          Niche Usage, Risk Level
- Fill area between current and optimized
- Animated transition (800ms)
- Color gradient: green (good) to red (high tax)
```

### 6.3 NicheProgressBar

```dart
// Requirements
- Horizontal bar
- Fill color: gradient from green to red based on %
- Markers at 0%, 50%, 90%, 100%
- Label above: "X€/10,000€"
- Sublabel: "Restant: X€"
```

### 6.4 RiskScoreIndicator

```dart
// Requirements
- 5 circles in a row
- Filled circles = risk score
- Colors: 1-2 green, 3 orange, 4-5 red
- Tooltip on tap: Explanation
```

---

## 7. Responsive Behavior

### 7.1 Breakpoints

```dart
// Mobile (default)
maxWidth: 428px

// Tablet
minWidth: 600px
- Side margins increase
- Charts side-by-side on landscape
```

### 7.2 Orientation

- Portrait: Default layout
- Landscape: Charts expand horizontally
- Safe area handling for notch/dynamic island

---

## 8. Accessibility

### 8.1 Requirements

| Element | Standard |
|---------|----------|
| Color contrast | WCAG AA (4.5:1) |
| Touch targets | Min 44x44pt |
| Screen reader | Semantic labels |
| Font scaling | Respects system settings |

### 8.2 Implementation

```dart
// Example
Semantics(
  label: 'Tax amount',
  value: '5,703 euros',
  child: Text('5,703 €'),
)

// All images have alt text
// All buttons have labels
// Charts have data tables as alternative
```

---

## 9. Animation Specifications

### 9.1 Transitions

| Screen | Transition | Duration |
|--------|------------|----------|
| Tab change | Fade | 200ms |
| Modal open | Slide up | 300ms |
| Modal close | Slide down | 250ms |
| Card expand | Height + Fade | 300ms |

### 9.2 Micro-interactions

| Element | Animation | Trigger |
|---------|-----------|---------|
| Button press | Scale 0.95 | On tap |
| Card tap | Subtle shadow | On tap |
| Save success | Checkmark + bounce | On save |
| Pull to refresh | Custom spinner | On pull |

---

## 10. Dark Mode

### 10.1 Color Override

```dart
// In dark mode
background: backgroundDark
surface: surfaceDark
textPrimary: textPrimaryDark
// Keep semantic colors same
```

### 10.2 Implementation

```dart
// Use Theme.of(context) to access colors
// Automatic switch based on system setting
// Manual toggle in Settings
```

---

## 11. Error States

### 11.1 Network Errors

- Show cached data if available
- Banner: "Mode hors-ligne"
- Retry button when network returns

### 11.2 Calculation Errors

- Display fallback message
- "Calcul inexact - Veuillez réessayer"
- Log error for debugging

### 11.3 Empty States

- Friendly illustration
- Clear call-to-action
- Example: "Aucune simulation - Lancez votre première!"

---

## 12. Loading States

### 12.1 Skeleton Screens

```
┌────────────────────────────────┐
│ ████████████████               │
│ ████████  ████████           │
│ ████████████████████████       │
└────────────────────────────────┘
```

### 12.2 Progress Indicators

- Linear for file downloads
- Circular for calculations
- Percentage for PDF generation

---

## 13. Platform-Specific

### 13.1 iOS

- Respect safe areas (notch, home indicator)
- Use Cupertino icons where appropriate
- Support Dynamic Type
- Haptic feedback on important actions

### 13.2 Android

- Material You color theming (optional)
- Edge-to-edge display
- Back gesture handling
- Predictive back animation support
