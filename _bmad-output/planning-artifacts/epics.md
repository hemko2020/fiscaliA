---
stepsCompleted: ["step-01", "step-02"]
inputDocuments: ["PRD_FiscalIA.md", "PRD_FiscalIA_Agent_IA.md"]
---

# fiscaliA - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for fiscaliA, decomposing the requirements from the PRD, UX Design if it exists, and Architecture requirements into implementable stories.

## Requirements Inventory

### Functional Requirements

**Module 1 — Simulateur IR (Core)**

FR1: Calculate income tax using official 2026 brackets (0%, 11%, 30%, 41%, 45%)
FR2: Apply family quotient system with parts calculation
FR3: Calculate discount (decote) for low incomes
FR4: Apply family quotient ceiling (1,807€ per half-part in 2026)
FR5: Calculate CEHR (Contribution Exceptionnelle sur les Hauts Revenus)
FR6: Display tax calculation breakdown by bracket
FR7: Support guided input: taxable income, family situation, number of parts
FR8: Calculate real expenses vs 10% standard deduction
FR9: Display graphical visualization of brackets (pie chart + bars)

**Module 2 — Optimisateur Fiscal (3 niveaux)**

FR10: Provide Basic level optimizations (free): real expenses, home employment, child care, donations, school fees, union dues, alimony
FR11: Provide Advanced level optimizations (premium): PER, LMNP, property deficit, Denormandie, Loc'Avantages, FCPI/FIP, Forest/GFI, SOFICA, Girardin
FR12: Provide Expert level optimizations (premium): SCI IR vs IS comparison, property split calculation, holding structure, Pacte Dutreil, IFI calculation, life insurance, PEA
FR13: Calculate PER contribution optimization with 37,094€/year ceiling and 3-year carryover
FR14: Calculate LMNP amortization simulation for rental income
FR15: Calculate property deficit imputation up to 10,700€/year
FR16: Calculate tax credit for home employment (50%, ceiling 12,000€)
FR17: Calculate donations reduction (66% or 75% depending on organization)
FR18: Calculate child care tax credit (50%, ceiling 3,500€/child)

**Module 3 — Tableau de Bord Niches Fiscales**

FR19: Real-time tracking of 10,000€ tax niche ceiling (or 18,000€ overseas)
FR20: Visual distribution by device
FR21: Alert when ceiling is reached
FR22: Suggest devices outside ceiling (PER, property deficit, Malraux, Historic Monuments)

**Module 4 — Calendrier Fiscal**

FR23: Display key dates for declaration period (April-June)
FR24: Personalized reminders based on department deadline
FR25: PER contribution deadline reminders (before December 31)
FR26: Configurable push notifications

**Module 5 — Centre Éducatif**

FR27: Educational sheets on each device
FR28: Short explanatory videos
FR29: Interactive FAQ
FR30: Tax glossary

**Module 6 — Agent IA Fiscal (Addendum PRD)**

FR31: ProfilerAgent - Analyze user situation and build fiscal profile JSON
FR32: LoopholeAgent - Scan fiscal knowledge base and identify applicable devices
FR33: StrategyAgent - Build multi-device optimization scenarios with action plan
FR34: ComplianceAgent - Validate recommendations against art. L.64 abuse of rights
FR35: 25 fiscal levers database embedded (CGI, BOFiP, jurisprudence)
FR36: Radar Fiscal display showing current vs optimized tax
FR37: Personalized recommendations ordered by impact with risk score
FR38: Custom action plan with calendar and checklist
FR39: PDF export of optimization plan
FR40: Compliance scoring 1-5 for each strategy

**Module 6B — Analyse Documentaire IA (NEW)**

FR51: Document upload system supporting PDF (up to 14 files) and camera capture
FR52: Local OCR engine for French pay slips (fiche de paie)
FR53: Income aggregation from multiple pay slips
FR54: Ticket restaurant analysis and tax impact calculation
FR55: Work days and vacation tracking from pay slips
FR56: Automatic document classification (pay slip, tax notice, bank statement, certificate)
FR57: Expense receipt OCR and category extraction
FR58: Integration with ProfilerAgent for automatic profile population

**Monetization Features**

FR41: Freemium model with banner ads + interstitial ads (every 3 simulations)
FR42: Premium subscription "FiscalIA Pro" (4.99€/month or 29.99€/year)
FR43: Premium subscription "FiscalIA Expert" (9.99€/month or 59.99€/year)
FR44: Lifetime purchase option (79.99€ Pro, 149.99€ Expert)

**Data & Privacy**

FR45: All calculations performed locally on device
FR46: No personal data transmitted to server
FR47: No user account required
FR48: Firebase Remote Config for tax bracket updates
FR49: Local PDF generation
FR50: RGPD compliance by design

### NonFunctional Requirements

NFR1: App must work offline (100% local calculations)
NFR2: First simulation must complete in under 2 minutes
NFR3: Tax calculation must be accurate vs official simulator impots.gouv.fr
NFR4: Target: 10,000 downloads in month 1, 50,000 in 6 months
NFR5: Premium conversion rate target: >5%
NFR6: Store rating target: 4.5+
NFR7: Revenue target: 2,000€/month advertising from month 4
NFR8: Privacy: Zero data transmission, no account required
NFR9: Disclaimer required: "Calculations are indicative only"
NFR10: Expert strategies must warn: "Consult a tax lawyer/notary"
NFR11: Response time for recommendations: <1 second
NFR12: Legal disclaimer for AMF/ACPR compliance

### Additional Requirements

**Technical Architecture:**

- Flutter (Dart) for iOS + Android
- Riverpod 2.0 for state management
- Hive/Isar for local NoSQL storage
- Google AdMob for advertising
- Firebase Analytics (anonymized)
- RevenueCat for in-app purchases
- Firebase Remote Config for tax bracket updates
- CI/CD via Codemagic or GitHub Actions

**Fiscal Knowledge Base (15-25 MB compressed):**

- CGI articles (annual update)
- BOFiP Instructions
- Published tax rulings
- Key jurisprudence (Conseil d'État, Cour de Cassation)
- Tax brackets via Firebase Remote Config

### UX Design Requirements

UX-DR1: Mobile-first design (iOS + Android native)
UX-DR2: Guided input flow for tax data entry
UX-DR3: Graphical visualization (pie chart for brackets, bars for comparison)
UX-DR4: Radar Fiscal visualization for AI agent
UX-DR5: Risk score indicators (color-coded 1-5)
UX-DR6: Push notification system for reminders
UX-DR7: PDF export for optimization plan
UX-DR8: Dark/Light mode support
UX-DR9: Offline-first UX with sync indicators
UX-DR10: Family-friendly design (simple language for complex fiscal topics)

## FR Coverage Map

| Module | FRs | Coverage |
|--------|-----|----------|
| Simulateur IR | FR1-FR9 | Core calculator with brackets, quotient, decote |
| Optimisateur Fiscal | FR10-FR18 | 3 levels of optimization devices |
| Tableau de Bord | FR19-FR22 | Tax niche ceiling tracking |
| Calendrier Fiscal | FR23-FR26 | Key dates and reminders |
| Centre Éducatif | FR27-FR30 | Educational content |
| Agent IA | FR31-FR40 | Multi-agent fiscal optimization |
| Analyse Documentaire | FR51-FR58 | OCR, document upload, income aggregation |
| Monétisation | FR41-FR44 | Freemium + Premium subscriptions |
| Data/Privacy | FR45-FR50 | Local-first, RGPD compliant |

## Epic List

1. **Epic 1: Setup & Core Infrastructure** - Flutter project, architecture, CI/CD
2. **Epic 2: Simulateur IR - Basic Tax Calculator** - Core tax calculation engine
3. **Epic 3: Optimisateur Fiscal - Basic Level (Free)** - Free optimization devices
4. **Epic 4: Tableau de Bord Niches Fiscales** - Tax niche ceiling dashboard
5. **Epic 5: Calendrier Fiscal & Notifications** - Key dates and reminders
6. **Epic 6: Centre Éducatif** - Educational content
6B. **Epic 6B: Analyse Documentaire IA** - OCR, pay slip analysis, income aggregation (NEW)
7. **Epic 7: Agent IA - Profiler & Basic Levers** - AI agent MVP
8. **Epic 8: Agent IA - Advanced & Expert Levers** - Full AI capabilities
9. **Epic 9: Monétisation - Ads & Subscriptions** - Freemium + Premium
10. **Epic 10: CI/CD & App Store Deployment** - Release pipeline

---

## Epic 1: Setup & Core Infrastructure

**Goal:** Initialize Flutter project with proper architecture, state management, local storage, and CI/CD pipeline.

### Story 1.1: Initialize Flutter Project

As a developer,
I want to initialize a Flutter project with iOS and Android platforms,
So that I have a solid foundation for building FiscalIA.

**Acceptance Criteria:**

**Given** Flutter SDK is installed
**When** I run `flutter create fiscalla --org com.fiscalia --platforms ios,android`
**Then** A new Flutter project is created with proper structure
**And** iOS and Android platforms are enabled
**And** Dart 3.x is configured

**Given** Project created
**When** I verify the project structure
**Then** Standard Flutter directory layout exists (lib/, test/, ios/, android/)

---

### Story 1.2: Setup Riverpod State Management

As a developer,
I want to configure Riverpod 2.0 for state management,
So that I can manage app state efficiently with providers.

**Acceptance Criteria:**

**Given** Flutter project exists
**When** I add `flutter_riverpod: ^2.4.0` to pubspec.yaml
**Then** Riverpod is integrated
**And** I can create StateNotifierProvider for tax calculation state
**And** I can create FutureProvider for async data loading

**Given** Riverpod configured
**When** I create a simple counter provider to test
**Then** The provider works correctly
**And** Hot reload reflects changes

---

### Story 1.3: Setup Local Storage with Hive

As a developer,
I want to configure Hive for local NoSQL storage,
So that user data persists offline without server dependency.

**Acceptance Criteria:**

**Given** Flutter project exists
**When** I add `hive: ^2.2.3` and `hive_flutter: ^1.1.0` to pubspec.yaml
**Then** Hive is integrated
**And** I can initialize Hive in main.dart
**And** I can open a box for storing fiscal profiles

**Given** Hive initialized
**When** I save a fiscal profile object
**Then** Data persists across app restarts
**And** Data is stored locally only (no network calls)

---

### Story 1.4: Create Data Models

As a developer,
I want to create data models for FoyerFiscal, Simulation, and Dispositif,
So that I have type-safe structures for the app.

**Acceptance Criteria:**

**Given** Project setup complete
**When** I create FoyerFiscal model with fields: situationFamiliale, nbEnfants, nbPartsSupplementaires, revenuNetImposable
**Then** Model has proper Dart types and JSON serialization
**And** I can create instances with various family situations

**Given** FoyerFiscal model
**When** I create Simulation model with fields: foyerFiscal, impotBrut, decote, reductions, credits, impotNet, tauxMoyen, tauxMarginal
**Then** Simulation links to FoyerFiscal
**And** Supports list of Reduction/Credit objects

**Given** Models created
**When** I create Dispositif model with fields: id, nom, categorie, type, tauxAvantage, plafond, conditionsEligibilite, horsNicheFiscale
**Then** Enum types exist for categorie (BASIQUE/AVANCE/EXPERT) and type (REDUCTION/CREDIT/DEDUCTION)

---

### Story 1.5: Setup Firebase Configuration

As a developer,
I want to setup Firebase for Analytics and Remote Config,
So that I can track usage and push tax bracket updates.

**Acceptance Criteria:**

**Given** Flutter project exists
**When** I add firebase_core, firebase_analytics, firebase_remote_config packages
**Then** Firebase is configured for both iOS and Android
**And** I can initialize Firebase in main.dart

**Given** Firebase configured
**When** I setup Remote Config with tax bracket defaults
**Then** App can fetch latest brackets from Firebase
**And** Falls back to embedded brackets if network unavailable

**Given** Analytics configured
**When** I log a simulation event
**Then** Event appears in Firebase console (anonymized)
**And** No personal user data is transmitted

---

### Story 1.6: Setup CI/CD Pipeline

As a developer,
I want to setup GitHub Actions for CI/CD,
So that builds are automated for iOS and Android.

**Acceptance Criteria:**

**Given** Project in GitHub
**When** I create `.github/workflows/build.yml`
**Then** Flutter analyze runs on pull requests
**And** Android APK builds on merge to main
**And** iOS build succeeds (if on macOS runner)

**Given** CI/CD configured
**When** I push a commit to main
**Then** Both platform builds complete
**And** Artifacts are available for testing

---

## Epic 2: Simulateur IR - Basic Tax Calculator

**Goal:** Build the core income tax calculation engine with official 2026 brackets, family quotient, decote, and CEHR.

### Story 2.1: Implement Tax Bracket Calculator

As a user,
I want to enter my taxable income and see my tax calculated by bracket,
So that I understand how my income is taxed.

**Acceptance Criteria:**

**Given** User enters taxable income of 42,000€
**When** I apply 2026 brackets:
- 0% up to 11,600€
- 11% from 11,601€ to 29,579€
- 30% from 29,580€ to 84,577€
- 41% from 84,578€ to 181,917€
- 45% above 181,917€
**Then** Tax is calculated correctly:
- Tranche 1: 0€
- Tranche 2: (29,579 - 11,600) × 11% = 1,977.69€
- Tranche 3: (42,000 - 29,580) × 30% = 3,726€
- Total: 5,703.69€

**Given** Bracket calculator implemented
**When** I display results
**Then** I see breakdown by tranche
**And** I see the marginal rate applied to next euro

---

### Story 2.2: Implement Family Quotient System

As a user,
I want to adjust my number of shares (parts) based on my family situation,
So that I can see how children affect my tax.

**Acceptance Criteria:**

**Given** User with 2 children (1 part base, +0.5 per child)
**When** I calculate shares
**Then** Total parts = 2.0 (1 + 0.5 + 0.5)

**Given** User with 95,000€ combined income, married with 2 children (3 parts)
**When** I apply quotient: 95,000 / 3 = 31,667€
**Then** Tax calculated on 31,667€ then multiplied by 3
**And** Result shows family quotient benefit

**Given** Family quotient calculated
**When** I check ceiling (1,807€ per half-part)
**Then** Maximum reduction from quotient is capped

---

### Story 2.3: Implement Decote Calculation

As a user,
I want to see if I qualify for the decote (discount for low incomes),
So that I understand additional tax relief.

**Acceptance Criteria:**

**Given** Single person with 18,000€ taxable income
**When** I calculate decote
**Then** Decote = 1,927€ - (0.75 × tax)
**And** If resulting decote is positive, it's subtracted from tax

**Given** Couple with 32,000€ combined, 2 children
**When** I calculate decote for couple
**Then** Different threshold applied (couple threshold = single × 2)

**Given** Decote logic implemented
**When** I verify against official calculations
**Then** Results match within 1€ precision

---

### Story 2.4: Implement CEHR Calculation

As a user,
I want to see if I'm subject to CEHR (high income contribution),
So that I understand additional taxes on high earners.

**Acceptance Criteria:**

**Given** Single person with 280,000€ taxable income
**When** I check CEHR eligibility
**Then** CEHR applies if income > 250,000€ (single)
**And** CEHR = 3% × (income - 250,000) up to 4% for >500,000€

**Given** Couple with 500,000€ combined income
**When** I check CEHR
**Then** CEHR threshold for couple is 500,000€
**And** Calculation follows CEHR formula

**Given** CEHR calculated
**When** I display results
**Then** CEHR is shown separately from regular IR
**And** Combined total (IR + CEHR) is displayed

---

### Story 2.5: Implement Real Expenses vs 10% Deduction

As a user,
I want to compare real expenses vs standard 10% deduction,
So that I can choose the most beneficial option.

**Acceptance Criteria:**

**Given** User with 45,000€ income, real expenses of 4,500€
**When** I calculate 10% deduction
**Then** 10% = 4,500€ (ceiling at 14,556€)
**And** 10% option is more beneficial for most employees

**Given** User with high real expenses (commute 50km/day, equipment, training)
**When** I calculate real expenses:
- KM: 50km × 2 × 220 days × 0.575€/km = 12,650€
- Equipment: 2,000€
- Training: 3,000€
**Then** Total real expenses = 17,650€
**And** Real expenses option saves more than 10% deduction

**Given** Comparison calculated
**When** I display to user
**Then** Both options shown side by side
**And** Recommended option is highlighted

---

### Story 2.6: Create Tax Visualization Charts

As a user,
I want to see graphical visualization of my tax breakdown,
So that I can understand my taxes intuitively.

**Acceptance Criteria:**

**Given** Tax calculation complete
**When** I display pie chart
**Then** Each bracket shows as proportion of total tax
**And** Colors are consistent across views

**Given** Bracket visualization exists
**When** I display bar comparison
**Then** Current tax vs optimized tax shown as bars
**And** Savings amount displayed prominently

**Given** Charts implemented
**When** I test on different screen sizes
**Then** Charts are responsive
**And** Maintain readability on small screens

---

### Story 2.7: Create Guided Input Flow

As a user,
I want to be guided through tax data entry,
So that I can complete my simulation quickly.

**Acceptance Criteria:**

**Given** User opens app
**When** I display onboarding flow
**Then** Step 1: Select family situation (single, couple, with children)
**And** Step 2: Enter taxable income
**And** Step 3: Confirm number of parts
**And** Step 4: Show results

**Given** Guided flow implemented
**When** User completes each step
**Then** Progress indicator shows current step
**And** Back navigation works
**And** Data persists if user exits

---

## Epic 3: Optimisateur Fiscal - Basic Level (Free)

**Goal:** Implement free optimization devices: real expenses, home employment, child care, donations, school fees, union dues, alimony.

### Story 3.1: Implement Home Employment Tax Credit

As a user,
I want to calculate my home employment tax credit,
So that I know how much I can save on childcare/household help.

**Acceptance Criteria:**

**Given** User employs a nanny at home
**When** I calculate credit: 50% of expenses
**And** Apply ceiling: 12,000€ + 1,500€ per child/elderly person (max 15,000€)
**Then** Maximum credit = 7,500€
**And** First year ceiling is 15,000€ (18,000€ with majorations)

**Given** Home employment credit calculated
**When** I check against tax niche ceiling
**Then** This credit counts toward 10,000€ niche ceiling
**And** Remaining niche space is updated

---

### Story 3.2: Implement Child Care Tax Credit

As a user,
I want to calculate my child care tax credit,
So that I know my savings from childcare expenses.

**Acceptance Criteria:**

**Given** User has 2 children in nursery
**When** I calculate credit: 50% of childcare expenses
**And** Apply ceiling: 3,500€ per child under 6
**Then** Maximum credit = 3,500€ × 2 = 7,000€
**And** Amount within niche ceiling calculated

**Given** Child care credit implemented
**When** I display to user
**Then** Both credits (home employment + child care) shown separately
**And** Combined impact on tax displayed

---

### Story 3.3: Implement Donation Tax Reduction

As a user,
I want to calculate my donation tax reduction,
So that I know how much I save by giving to charities.

**Acceptance Criteria:**

**Given** User donates 500€ to standard charity (66% reduction)
**When** I calculate reduction
**Then** Reduction = 500 × 66% = 330€
**And** Ceiling = 20% of taxable income
**And** Excess carries forward 5 years

**Given** User donates 1,000€ to aid organization (75% reduction)
**When** I calculate reduction
**Then** Reduction = 1,000 × 75% = 750€
**And** Ceiling = 1,000€ (hard ceiling)

**Given** Multiple donations
**When** I optimize allocation
**Then** First 1,000€ to 75% organizations
**Then** Remainder to 66% organizations
**And** Maximum reduction calculated

---

### Story 3.4: Implement School Fees Tax Credit

As a user,
I want to calculate tax credit for children's school fees,
So that I claim this commonly forgotten deduction.

**Acceptance Criteria:**

**Given** User has child in college
**When** I calculate credit: 61€ per child in college
**Then** Credit = 61€ (100% credit, no ceiling)

**Given** User has child in high school
**When** I calculate credit: 153€ per child in high school
**Then** Credit = 153€

**Given** User has child in higher education
**When** I calculate credit: 183€ per child
**Then** Credit = 183€

**Given** School fees credit implemented
**When** I remind user
**Then** This is highlighted as "commonly forgotten" credit

---

### Story 3.5: Implement Union Dues Tax Credit

As a user,
I want to calculate my union dues tax credit,
So that I claim 66% of my syndicate fees.

**Acceptance Criteria:**

**Given** User pays 300€ in union dues
**When** I calculate credit: 66% × 300€ = 198€
**Then** Credit = 198€
**And** Ceiling = 1% of gross income

**Given** Union dues credit implemented
**When** I remind user
**Then** This is highlighted as "90% forget to claim"

---

### Story 3.6: Implement Alimony Tax Deduction

As a user,
I want to calculate alimony deduction,
So that I understand the tax impact of divorce payments.

**Acceptance Criteria:**

**Given** User pays pension to ex-spouse
**When** I check if deductible: Yes, under Article 156 II 2°
**Then** Maximum deduction = 6,674€ per year
**And** Counts toward niche ceiling

**Given** User has child support arrangement
**When** I calculate deduction
**Then** Child support is deductible for donor
**And** Recipient must declare as income

---

## Epic 4: Tableau de Bord Niches Fiscales

**Goal:** Build real-time tracking of tax niche ceiling with visual distribution and smart suggestions.

### Story 4.1: Implement Niche Ceiling Tracker

As a user,
I want to see my remaining tax niche ceiling,
So that I know how much more I can save before hitting the 10,000€ limit.

**Acceptance Criteria:**

**Given** User has used 6,000€ of niche devices
**When** I calculate remaining
**Then** Remaining = 10,000€ - 6,000€ = 4,000€
**And** Visual progress bar shows usage

**Given** User is overseas (DOM-TOM)
**When** I check eligibility
**Then** Ceiling = 18,000€ applies
**And** SOFICA and Girardin count toward 18K ceiling

---

### Story 4.2: Implement Device Distribution Visualization

As a user,
I want to see how my niche devices are distributed,
So that I understand my tax optimization strategy.

**Acceptance Criteria:**

**Given** User has multiple niche devices
**When** I display pie chart
**Then** Each device category shown with percentage
**And** Amount in euros displayed for each
**And** Legend clearly labels each device

**Given** Distribution visualized
**When** I show over-time view
**Then** User sees which devices contribute most

---

### Story 4.3: Implement Ceiling Alert System

As a user,
I want to be alerted when I reach my niche ceiling,
So that I don't waste money on devices that won't help.

**Acceptance Criteria:**

**Given** User adds a device that pushes total to 10,500€
**When** I detect ceiling exceeded
**Then** Warning displayed: "You have exceeded your niche ceiling by 500€"
**And** Suggestion to prioritize high-impact devices

**Given** Alert system implemented
**When** User is at 90% of ceiling
**Then** Yellow warning shows "Approaching ceiling"
**And** Recommendation to check PER/deficit foncier (outside ceiling)

---

### Story 4.4: Implement Outside-Ceiling Suggestions

As a user,
I want to be told about devices outside the niche ceiling,
So that I can maximize savings beyond the 10,000€ limit.

**Acceptance Criteria:**

**Given** User has used 9,500€ of niche devices
**When** I suggest outside-ceiling options
**Then** PER shown: "Invest 10,000€ in PER to save 3,000€ (outside ceiling)"
**And** Property deficit shown: "Claim 10,700€ property deficit (outside ceiling)"
**And** Malraux shown: "Restoration work (unlimited, outside ceiling)"

**Given** Suggestions implemented
**When** I rank by impact
**Then** Highest savings shown first
**And** Complexity/risk score displayed

---

## Epic 5: Calendrier Fiscal & Notifications

**Goal:** Build fiscal calendar with key dates, personalized reminders, and push notifications.

### Story 5.1: Display Key Fiscal Dates

As a user,
I want to see key tax dates for the year,
So that I don't miss important deadlines.

**Acceptance Criteria:**

**Given** Current year is 2026
**When** I display calendar
**Then** April-May: Income tax declaration period
**And** December 31: PER contribution deadline
**And** Various device-specific deadlines shown

**Given** Calendar implemented
**When** I show declaration period
**Then** Department-specific dates displayed
**And** Countdown timers shown

---

### Story 5.2: Implement Department-Based Reminders

As a user,
I want reminders based on my department's deadline,
So that I get accurate timing information.

**Acceptance Criteria:**

**Given** User selects department 75 (Paris)
**When** I fetch deadline
**Then** Deadline shown: May 27 (typically)
**And** Reminder set 7 days before

**Given** Department deadlines implemented
**When** User enters ZIP code
**Then** Correct deadline auto-populated
**And** Reminders adjust accordingly

---

### Story 5.3: Implement Push Notifications

As a user,
I want push notifications for key deadlines,
So that I remember to take tax actions.

**Acceptance Criteria:**

**Given** User enables notifications
**When** December 1 arrives
**Then** Notification: "PER contribution deadline in 30 days"
**And** Notification: "December 31: Last day for 2026 PER contributions"

**Given** Notification system implemented
**When** User opts in
**Then** Permission requested properly
**And** User can customize notification types
**And** User can disable specific reminders

---

### Story 5.4: Implement PER Deadline Tracker

As a user,
I want to track my PER contributions and deadlines,
So that I maximize my retirement savings before year-end.

**Acceptance Criteria:**

**Given** User has PER with 37,094€ annual ceiling
**When** I track contributions
**Then** Remaining deductible amount displayed
**And** Warning if approaching carryover limit (3-year)

**Given** PER tracker implemented
**When** December arrives
**Then** Aggressive reminder campaign
**And** Calculation of potential tax savings if max contribution made

---

## Epic 6: Centre Éducatif

**Goal:** Build educational content library with sheets, videos, FAQ, and glossary.

### Story 6.1: Create Educational Content Sheets

As a user,
I want to read clear explanations of each tax device,
So that I understand what I'm implementing.

**Acceptance Criteria:**

**Given** User browses educational section
**When** I display content sheet for PER
**Then** Sheet explains: What is PER, how it works, ceilings, benefits
**And** Language is accessible (no jargon without explanation)
**And** Examples provided with real numbers

**Given** Content sheets implemented
**When** I display sheet for LMNP
**Then** Technical details available but separated
**And** "Learn more" expands additional details

---

### Story 6.2: Build Interactive FAQ

As a user,
I want to search the FAQ for quick answers,
So that I resolve questions without deep research.

**Acceptance Criteria:**

**Given** User types "PER" in FAQ search
**When** I search FAQ content
**Then** Relevant Q&A displayed
**And** Multiple related questions shown

**Given** FAQ search implemented
**When** User asks question not in FAQ
**Then** Prompt suggests contacting support or using Agent IA

---

### Story 6.3: Create Tax Glossary

As a user,
I want to look up tax terms,
So that I understand the vocabulary.

**Acceptance Criteria:**

**Given** User browses glossary
**When** I display alphabetical list
**Then** Terms like TMI, quotient familial, decote defined
**And** Cross-references link to related terms

**Given** Glossary implemented
**When** User taps term in any screen
**Then** Popup shows definition
**And** Link to glossary entry provided

---

## Epic 6B: Analyse Documentaire IA

**Goal:** Allow users to upload or photograph their pay slips (fiches de paie) and other tax documents to automatically extract income data, work days, vacation days, meal vouchers, and calculate potential deductions.

### Story 6B.1: Implement Document Upload System

As a user,
I want to upload my pay slips and tax documents (PDF or images),
So that the app can automatically extract relevant fiscal data.

**Acceptance Criteria:**

**Given** User is on the document upload screen
**When** I support PDF upload (up to 14 files)
**Then** User can select files from device
**And** File picker shows file size and type
**And** Progress indicator during upload

**Given** User prefers camera capture
**When** I open camera interface
**Then** User can take photo of document
**And** Image is cropped and enhanced automatically
**And** Multiple photos can be taken (up to 14 total)

**Given** Document uploaded
**When** I process the file
**Then** Local OCR extracts text (no cloud processing)
**And** Data is stored in Hive immediately
**And** Privacy is maintained (no external transmission)

---

### Story 6B.2: Implement OCR Engine for French Pay Slips

As an AI agent,
I want to extract structured data from French pay slips,
So that I can automatically populate the user's fiscal profile.

**Acceptance Criteria:**

**Given** User uploads a fiche de paie (pay slip)
**When** I run local OCR
**Then** I extract:
- Salaire brut
- Salaire net imposable
- Cotisations sociales
- Cotisations retraite
- Chèques déjeuner / Ticket restaurant
- Jours travaillés
- Jours de congés
- Jours de RTT
- Heures supplémentaires

**Given** OCR extracts data
**When** I validate against expected format
**Then** Extracted data is shown to user for confirmation
**And** User can correct any errors
**And** Corrections are remembered for future uploads

---

### Story 6B.3: Implement Income Aggregation

As a user,
I want the app to aggregate all my income from uploaded pay slips,
So that I get a complete picture of my annual income.

**Acceptance Criteria:**

**Given** User uploads 12 monthly pay slips
**When** I aggregate income data
**Then** I calculate:
- Total annual gross salary
- Total annual net imposable
- Average monthly income
- Total meal vouchers
- Total work days
- Total vacation days
- Total RTT days
- Total overtime hours

**Given** Aggregation complete
**When** I compare with manual entry
**Then** Discrepancies are highlighted
**And** User can investigate differences

---

### Story 6B.4: Implement Ticket Restaurant Analysis

As a user,
I want the app to analyze my meal voucher contributions,
So that I can understand their tax impact.

**Acceptance Criteria:**

**Given** User has ticket restaurant on pay slip
**When** I extract ticket restaurant data
**Then** I calculate:
- Annual amount of contributions
- Employer contribution (excluded from tax)
- Employee contribution ( taxable)
- Potential savings if using meal expenses

**Given** Ticket restaurant analysis
**When** I display results
**Then** I show tax-efficient meal expense strategies
**And** I explain the 2026 rules for meal deductions

---

### Story 6B.5: Implement Work Days and Vacation Tracking

As a user,
I want to track my work days and vacation from pay slips,
So that I can plan my tax optimization.

**Acceptance Criteria:**

**Given** User uploads pay slips throughout the year
**When** I track work days
**Then** I show:
- Days worked vs contractual days
- Vacation days accumulated
- RTT balance
- Overtime hours

**Given** Work tracking implemented
**When** I calculate vacation pay impact
**Then** I show potential tax savings from:
- Taking vacation (lower monthly income)
- Converting overtime to RTT
- Using DIF hours

---

### Story 6B.6: Implement Document Classification

As an AI agent,
I want to automatically classify uploaded documents,
So that the right parser processes each document.

**Acceptance Criteria:**

**Given** User uploads random documents
**When** I run classification
**Then** I identify:
- Fiche de paie (pay slip) → Use payroll parser
- Avis d'imposition (tax notice) → Use tax notice parser
- Relevé de compte (bank statement) → Use bank parser
- Attestation fiscale (tax certificate) → Use certificate parser
- Other → Flag for manual review

**Given** Classification complete
**When** I show document list
**Then** Each document has:
- Type icon
- Processing status
- Extracted data preview
- Edit/Delete options

---

### Story 6B.7: Implement Expense Receipt Analysis

As a user,
I want to photograph my expense receipts,
So that the app can calculate my real expenses deduction.

**Acceptance Criteria:**

**Given** User photographs expense receipts
**When** I run OCR on receipts
**Then** I extract:
- Vendor name
- Date
- Amount
- Category (transport, equipment, training, etc.)

**Given** Receipt data extracted
**When** I aggregate expenses
**Then** I calculate:
- Total by category
- Total for real expenses option
- Comparison with 10% standard deduction
- Recommendation on which option is better

**Given** Expense analysis complete
**When** I show results
**Then** I display:
- Expense breakdown chart
- Tax savings potential
- Export to PDF for employer/URSSAF

---

### Story 6B.8: Implement Integration with ProfilerAgent

As an AI agent,
I want to pass extracted document data to ProfilerAgent,
So that the fiscal profile is automatically populated.

**Acceptance Criteria:**

**Given** Document analysis is complete
**When** I pass data to ProfilerAgent
**Then** ProfilerAgent receives:
- Aggregated income data
- Work patterns
- Expense summaries
- Meal voucher contributions

**Given** ProfilerAgent receives document data
**When** I build fiscal profile
**Then** Profile includes:
- Verified income (vs estimated)
- Work activity signals
- Expense deduction estimates
- Confidence score for each data point

---

## Epic 7: Agent IA - Profiler & Basic Levers

**Goal:** Build multi-agent AI system with ProfilerAgent, LoopholeAgent, StrategyAgent, ComplianceAgent. MVP with 10 basic levers.

### Story 7.1: Build ProfilerAgent - User Analysis

As an AI agent,
I want to analyze the user's complete fiscal situation,
So that I can build an accurate profile for recommendations.

**Acceptance Criteria:**

**Given** User answers 8-12 questions:
- Family situation
- Income (salaries, rental, financial, exceptional)
- Heritage (real estate, financial, PEA, life insurance)
- Current charges (home employment, donations, PER, alimony)
- Objectives (reduce IR, prepare retirement, transmit, reduce IFI)
**When** I build fiscal profile JSON
**Then** Profile contains TMI, RFR, signals of alert
**And** Profile ready for LoopholeAgent

---

### Story 7.2: Build LoopholeAgent - Device Matching

As an AI agent,
I want to scan the fiscal knowledge base and match devices to user profile,
So that I identify all applicable optimization opportunities.

**Acceptance Criteria:**

**Given** User profile with TMI = 30%, 2 children, 85,000€ income
**When** I scan 25-device knowledge base
**Then** Matched devices: Real expenses, home employment, PER, donations, school fees
**And** Each device tagged with potential savings
**And** Devices sorted by impact

**Given** LoopholeAgent implemented
**When** I detect combination opportunities
**Then** "Winning combinations" flagged
**And** Special display for ceiling-bypassing strategies

---

### Story 7.3: Build StrategyAgent - Action Planning

As an AI agent,
I want to build multi-device optimization scenarios with action plan,
So that user knows exactly what to do and when.

**Acceptance Criteria:**

**Given** User wants to minimize tax
**When** I build strategy combining PER + donations + real expenses
**Then** Action plan shows:
- Step 1: Gather expense receipts (by March 15)
- Step 2: Contribute to PER (by December 31)
- Step 3: Make charity donations (by December 31)
**And** Calendar integration
**And** Document checklist

---

### Story 7.4: Build ComplianceAgent - Risk Validation

As an AI agent,
I want to validate recommendations against abuse of rights rules,
So that all advice is legal and defensible.

**Acceptance Criteria:**

**Given** Recommendation for aggressive tax scheme
**When** I validate against Article L.64 LPF
**Then** Red flag raised if "primarily tax-motivated"
**And** Score 1-5 assigned based on risk
**And** Appropriate disclaimer added

**Given** ComplianceAgent implemented
**When** I show risky strategies
**Then** Warning displayed: "Consult a tax lawyer"
**And** Legal basis cited (CGI article, BOFiP reference)

---

### Story 7.5: Implement Radar Fiscal Display

As a user,
I want to see my fiscal situation on a radar chart,
So that I understand my optimization potential visually.

**Acceptance Criteria:**

**Given** User completes analysis
**When** I display radar fiscal
**Then** Center shows current estimated tax
**Then** Edge shows optimized tax
**Then** Gap shows potential savings
**And** Category breakdown displayed

**Given** Radar implemented
**When** I animate the visualization
**Then** Smooth transition between current and optimized
**And** Color coding shows effort vs reward

---

### Story 7.6: Implement 10 Basic Levers

As a user,
I want access to 10 basic fiscal levers,
So that I can optimize without premium subscription.

**Acceptance Criteria:**

**Given** Free user completes profile
**When** I recommend devices
**Then** These basic levers shown:
1. Real expenses vs 10%
2. Home employment credit
3. Child care credit
4. Donation reductions (66% and 75%)
5. School fees credit
6. Union dues credit
7. Alimony deduction
8. PER (outside ceiling)
9. Property deficit (outside ceiling)
10. Marriage/PACS year option

**Given** Basic levers implemented
**When** I calculate total savings
**Then** Typical savings of 1,500-5,000€ displayed
**And** Upsell to premium shown for more

---

## Epic 8: Agent IA - Advanced & Expert Levers

**Goal:** Implement all 25 fiscal levers including SCI, demembrement, Dutreil, IFI with full scenario planning.

### Story 8.1: Implement PER Advanced Strategies

As a user,
I want to maximize my PER contributions with 3-year carryover,
So that I optimize retirement savings and tax deductions.

**Acceptance Criteria:**

**Given** User has 75,000€ income, TMI 30%
**When** I calculate PER optimization
**Then** Maximum deduction = 37,094€
**And** Potential savings = 37,094 × 30% = 11,128€
**And** Carryover unused from last 3 years shown

**Given** User is couple with 150,000€ combined
**When** I calculate couple PER
**Then** Combined ceiling = 74,188€
**And** Mutualization strategy shown
**And** Significant tax savings demonstrated

---

### Story 8.2: Implement LMNP Amortization Simulation

As a user,
I want to simulate LMNP with amortization,
So that I understand the tax benefits of furnished rental.

**Acceptance Criteria:**

**Given** User owns rental property, 200,000€ value, rents 12,000€/year
**When** I calculate LMNP amortization
**Then** Building amortized over 20-30 years
**And** Most rental income becomes tax-free
**And** Only land value taxed

**Given** LMNP simulation complete
**When** I compare with standard rental
**Then** Significant tax savings shown
**And** Conditions for professional status explained

---

### Story 8.3: Implement SCI IR vs IS Comparison

As a user,
I want to compare SCI with IR vs IS taxation,
So that I choose the optimal structure for my rental property.

**Acceptance Criteria:**

**Given** User has 2 rental properties in SCI
**When** I compare IR vs IS
**Then** IR: Property deficit offsets other income
**And** IS: Amortization creates tax-free cash flow
**And** Break-even point calculated

**Given** SCI comparison complete
**When** I show expert recommendation
**Then** Decision tree provided
**And** Based on income level, property value, holding period

---

### Story 8.4: Implement Property Demembrement Calculator

As a user,
I want to calculate usufruct vs nue-propriety split,
So that I understand transmission planning.

**Acceptance Criteria:**

**Given** User age 55, property value 500,000€
**When** I calculate demembrement (Article 669 CGI)
**Then** Usufruct value = 60% at age 55
**Then** Nue-propriety = 40%
**And** Donation of nue-propriety dramatically reduces taxes

**Given** Demembrement calculated
**When** I show combination with 100K€/child abatement
**Then** Nearly tax-free transmission possible
**And** Timeline to full ownership shown

---

### Story 8.5: Implement Pacte Dutreil Calculator

As a user,
I want to estimate Dutreil tax savings on business transmission,
So that I understand succession planning benefits.

**Acceptance Criteria:**

**Given** User owns business worth 1,000,000€
**When** I calculate standard transmission taxes
**Then** Without Dutreil: ~200,000€ in taxes
**And** With Dutreil: ~33,000€ in taxes (75% reduction)
**And** Conditions explained (5-year commitment, 10% minimum holding)

---

### Story 8.6: Implement IFI Calculator & Strategies

As a user,
I want to calculate my IFI and explore reduction strategies,
So that I minimize wealth tax on real estate.

**Acceptance Criteria:**

**Given** User has 2,500,000€ net assets, 2,000,000€ real estate
**When** I calculate IFI
**Then** Taxable base = 2,000,000€
**Then** IFI = 17,500€ (2026 rates)
**And** Demembrement strategy shown

**Given** IFI calculated
**When** I suggest reduction strategies
**Then** Donation of usufruct shown (75% reduction up to 50,000€)
**And** IFI donations to charities explained
**And** Donation IFI vs IR donations comparison

---

### Story 8.7: Implement SOFICA & Girardin Calculations

As a user,
I want to calculate SOFICA and Girardin investments,
So that I understand these high-yield overseas investments.

**Acceptance Criteria:**

**Given** User invests 10,000€ in SOFICA
**When** I calculate return (30-48% reduction)
**Then** Maximum reduction = 4,800€
**And** 18,000€ ceiling applies
**And** Risk score 4/5 displayed

**Given** User considers Girardin (18,000€ ceiling)
**When** I calculate return
**Then** Potential 110-120% return (legitimate under CGI)
**And** Risk score 3/5
**And** Warning about operator selection

---

### Story 8.8: Implement Full Action Plan Export

As a user,
I want to export my complete optimization plan as PDF,
So that I can share it with my advisor.

**Acceptance Criteria:**

**Given** User completes optimization
**When** I generate PDF
**Then** Includes all recommended devices
**And** Estimated savings per device
**And** Action calendar with deadlines
**And** Document checklist
**And** Legal disclaimers

---

## Epic 9: Monétisation - Ads & Subscriptions

**Goal:** Implement freemium model with AdMob ads and RevenueCat premium subscriptions.

### Story 9.1: Integrate Google AdMob

As a product owner,
I want to display banner and interstitial ads,
So that I generate advertising revenue from free users.

**Acceptance Criteria:**

**Given** Free user completes simulation
**When** I display results
**Then** Banner ad shown at bottom
**And** Interstitial shown every 3 simulations

**Given** AdMob integrated
**When** I track ad revenue
**Then** eCPM of 3-8€ for French users
**And** Analytics show ad impressions

---

### Story 9.2: Integrate RevenueCat for Subscriptions

As a product owner,
I want to offer FiscalIA Pro and Expert subscriptions,
So that I convert free users to paying customers.

**Acceptance Criteria:**

**Given** User views premium features
**When** I display subscription options
**Then** FiscalIA Pro: 4.99€/month or 29.99€/year
**And** FiscalIA Expert: 9.99€/month or 59.99€/year
**And** Lifetime options shown (79.99€, 149.99€)

**Given** RevenueCat integrated
**When** User subscribes
**Then** Premium features unlocked immediately
**And** Cross-platform sync via RevenueCat
**And** Restore purchases works

---

### Story 9.3: Implement Paywall for Premium Content

As a user,
I want to see which features require premium,
So that I understand the upgrade value.

**Acceptance Criteria:**

**Given** Free user browses Advanced devices
**When** I display PER optimization
**Then** "Premium Feature" badge shown
**And** Paywall prompts upgrade
**And** Limited preview of benefit amount

**Given** Paywall implemented
**When** User taps premium feature
**Then** Full-screen paywall displayed
**And** Benefits clearly listed
**And** Easy upgrade flow

---

### Story 9.4: Implement Lifetime Purchase Option

As a product owner,
I want to offer lifetime purchases during peak declaration,
So that I maximize revenue during high-traffic periods.

**Acceptance Criteria:**

**Given** It's April (declaration period)
**When** I display subscription options
**Then** Lifetime Expert shown at 149.99€
**And** Urgency message: "Offer ends June 30"
**And** Compared to 59.99€/year, payback in 2.5 years

---

## Epic 10: CI/CD & App Store Deployment

**Goal:** Setup complete deployment pipeline for App Store and Google Play.

### Story 10.1: Setup Android Release Pipeline

As a developer,
I want to build and release Android APK to Google Play,
So that users can install FiscalIA on Android.

**Acceptance Criteria:**

**Given** Code merged to main
**When** GitHub Actions builds Android
**Then** Debug APK generated
**And** Release APK signed with release keystore
**And** App bundle created for Play Console

**Given** Release pipeline complete
**When** I upload to Play Console
**Then** Internal testing track populated
**And** I can promote to production

---

### Story 10.2: Setup iOS Release Pipeline

As a developer,
I want to build and release iOS app to App Store,
So that users can install FiscalIA on iPhone.

**Acceptance Criteria:**

**Given** Code merged to main on macOS runner
**When** GitHub Actions builds iOS
**Then** IPA generated with proper code signing
**And** App Store Connect upload succeeds
**And** TestFlight deployment works

**Given** iOS pipeline complete
**When** I submit to App Store
**Then** Review status tracked
**And** Release automation for approved builds

---

### Story 10.3: Implement Remote Config for Tax Updates

As a product owner,
I want to update tax brackets without app release,
So that I respond quickly to law changes.

**Acceptance Criteria:**

**Given** New tax law published in February
**When** I update Firebase Remote Config
**Then** All users get new brackets on next app open
**And** No app store update required
**And** Fallback to embedded brackets if fetch fails

---

### Story 10.4: Setup Crash Reporting & Analytics

As a developer,
I want to monitor app crashes and usage,
So that I maintain high quality.

**Acceptance Criteria:**

**Given** App deployed
**When** Crash occurs
**Then** Firebase Crashlytics reports
**And** Stack trace available
**And** User-affected crashes prioritized

**Given** Analytics configured
**When** I view dashboard
**Then** DAU/MAU shown
**And** Top screens tracked
**And** Conversion funnel visible
