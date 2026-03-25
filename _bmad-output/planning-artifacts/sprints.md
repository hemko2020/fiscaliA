---
stepsCompleted: ["step-01", "step-02", "step-03"]
inputDocuments: ["PRD_FiscalIA.md", "PRD_FiscalIA_Agent_IA.md", "_bmad-output/planning-artifacts/epics.md"]
---

# fiscaliA - Sprint Planning

## Overview

This document maps Epics and Stories from the Requirements Inventory into Sprint-based delivery phases. Time constraints from PRD are excluded - prioritization is based on dependencies, value, and risk.

---

## Phase 1: MVP - Core Foundation

**Goal:** Launch a functional tax simulator with basic optimization devices.

### Sprint 1.1: Project Setup

| Epic | Story | Team | Priority |
|------|-------|------|----------|
| Epic 1 | Story 1.1: Initialize Flutter Project | Dev | P0 |
| Epic 1 | Story 1.2: Setup Riverpod State Management | Dev | P0 |
| Epic 1 | Story 1.3: Setup Local Storage with Hive | Dev | P0 |
| Epic 1 | Story 1.4: Create Data Models | Dev | P0 |
| Epic 1 | Story 1.5: Setup Firebase Configuration | Dev | P1 |
| Epic 1 | Story 1.6: Setup CI/CD Pipeline | Dev | P1 |

**Definition of Done:**
- Flutter project builds for iOS and Android
- State management functional
- Local storage persists data
- CI/CD pipeline runs builds

---

### Sprint 1.2: Core Tax Calculator

| Epic | Story | Team | Priority |
|------|-------|------|----------|
| Epic 2 | Story 2.1: Implement Tax Bracket Calculator | Dev | P0 |
| Epic 2 | Story 2.2: Implement Family Quotient System | Dev | P0 |
| Epic 2 | Story 2.3: Implement Decote Calculation | Dev | P0 |
| Epic 2 | Story 2.4: Implement CEHR Calculation | Dev | P1 |
| Epic 2 | Story 2.5: Implement Real Expenses vs 10% Deduction | Dev | P0 |
| Epic 2 | Story 2.6: Create Tax Visualization Charts | Dev | P1 |
| Epic 2 | Story 2.7: Create Guided Input Flow | Dev | P1 |

**Definition of Done:**
- Tax calculation matches official simulator within 1€ precision
- All 5 brackets correctly applied
- Family quotient calculation verified
- Decote calculation matches official formulas

---

### Sprint 1.3: Basic Optimizations + Dashboard

| Epic | Story | Team | Priority |
|------|-------|------|----------|
| Epic 3 | Story 3.1: Implement Home Employment Tax Credit | Dev | P0 |
| Epic 3 | Story 3.2: Implement Child Care Tax Credit | Dev | P0 |
| Epic 3 | Story 3.3: Implement Donation Tax Reduction | Dev | P0 |
| Epic 3 | Story 3.4: Implement School Fees Tax Credit | Dev | P1 |
| Epic 3 | Story 3.5: Implement Union Dues Tax Credit | Dev | P1 |
| Epic 3 | Story 3.6: Implement Alimony Tax Deduction | Dev | P1 |
| Epic 4 | Story 4.1: Implement Niche Ceiling Tracker | Dev | P0 |
| Epic 4 | Story 4.2: Implement Device Distribution Visualization | Dev | P1 |
| Epic 4 | Story 4.3: Implement Ceiling Alert System | Dev | P1 |
| Epic 4 | Story 4.4: Implement Outside-Ceiling Suggestions | Dev | P2 |

**Definition of Done:**
- All basic tax credits calculated correctly
- Niche ceiling tracking functional
- Visual charts display properly
- Alerts trigger at correct thresholds

---

## Phase 2: Growth - Premium Features

**Goal:** Add premium optimizations, calendar, educational content, and monetization.

### Sprint 2.1: Premium Optimizations (Advanced)

| Epic | Story | Team | Priority |
|------|-------|------|----------|
| Epic 8 | Story 8.1: Implement PER Advanced Strategies | Dev | P0 |
| Epic 8 | Story 8.2: Implement LMNP Amortization Simulation | Dev | P1 |
| Epic 8 | Story 8.3: Implement SCI IR vs IS Comparison | Dev | P1 |
| Epic 8 | Story 8.7: Implement SOFICA & Girardin Calculations | Dev | P2 |

**Definition of Done:**
- PER calculation includes 3-year carryover
- LMNP amortization generates correct schedule
- SCI comparison shows break-even analysis
- Premium subscription gates functional

---

### Sprint 2.2: Expert Optimizations

| Epic | Story | Team | Priority |
|------|-------|------|----------|
| Epic 8 | Story 8.4: Implement Property Demembrement Calculator | Dev | P0 |
| Epic 8 | Story 8.5: Implement Pacte Dutreil Calculator | Dev | P1 |
| Epic 8 | Story 8.6: Implement IFI Calculator & Strategies | Dev | P1 |
| Epic 8 | Story 8.8: Implement Full Action Plan Export | Dev | P1 |

**Definition of Done:**
- Demembrement calculation matches Article 669 CGI
- Dutreil savings displayed accurately
- IFI calculation verified
- PDF export generates complete plan

---

### Sprint 2.3: Calendar & Notifications

| Epic | Story | Team | Priority |
|------|-------|------|----------|
| Epic 5 | Story 5.1: Display Key Fiscal Dates | Dev | P0 |
| Epic 5 | Story 5.2: Implement Department-Based Reminders | Dev | P1 |
| Epic 5 | Story 5.3: Implement Push Notifications | Dev | P1 |
| Epic 5 | Story 5.4: Implement PER Deadline Tracker | Dev | P1 |

**Definition of Done:**
- Calendar displays correct dates for 2026
- Department-specific deadlines accurate
- Notifications send at correct times
- User can customize notification preferences

---

### Sprint 2.4: Educational Center

| Epic | Story | Team | Priority |
|------|-------|------|----------|
| Epic 6 | Story 6.1: Create Educational Content Sheets | Content | P0 |
| Epic 6 | Story 6.2: Build Interactive FAQ | Dev | P1 |
| Epic 6 | Story 6.3: Create Tax Glossary | Content | P1 |

**Definition of Done:**
- Content sheets cover all 25 devices
- FAQ search returns relevant results
- Glossary terms have cross-references

---

### Sprint 2.5: Monetization Setup

| Epic | Story | Team | Priority |
|------|-------|------|----------|
| Epic 9 | Story 9.1: Integrate Google AdMob | Dev | P0 |
| Epic 9 | Story 9.2: Integrate RevenueCat for Subscriptions | Dev | P0 |
| Epic 9 | Story 9.3: Implement Paywall for Premium Content | Dev | P0 |
| Epic 9 | Story 9.4: Implement Lifetime Purchase Option | Dev | P1 |

**Definition of Done:**
- Banner and interstitial ads display correctly
- Subscription flow completes successfully
- Premium features unlock after purchase
- Restore purchases works

---

### Sprint 2.6: Document Analysis (OCR)

| Epic | Story | Team | Priority |
|------|-------|------|----------|
| Epic 6B | Story 6B.1: Document Upload System | Dev | P0 |
| Epic 6B | Story 6B.2: OCR Engine for French Pay Slips | Dev | P0 |
| Epic 6B | Story 6B.3: Income Aggregation | Dev | P0 |
| Epic 6B | Story 6B.4: Ticket Restaurant Analysis | Dev | P1 |
| Epic 6B | Story 6B.5: Work Days and Vacation Tracking | Dev | P1 |
| Epic 6B | Story 6B.6: Document Classification | Dev | P1 |

**Definition of Done:**
- PDF upload supports up to 14 files
- Camera capture with auto-crop works
- Local OCR extracts pay slip data
- Income aggregation from 12 months complete
- Ticket restaurant analysis functional
- Work days tracking accurate

---

## Phase 3: Expert - AI Agent

**Goal:** Launch the AI Agent with multi-agent architecture and all 25 fiscal levers.

### Sprint 3.1: AI Agent Core (MVP)

| Epic | Story | Team | Priority |
|------|-------|------|----------|
| Epic 7 | Story 7.1: Build ProfilerAgent - User Analysis | Dev | P0 |
| Epic 7 | Story 7.2: Build LoopholeAgent - Device Matching | Dev | P0 |
| Epic 7 | Story 7.3: Build StrategyAgent - Action Planning | Dev | P0 |
| Epic 7 | Story 7.4: Build ComplianceAgent - Risk Validation | Dev | P0 |

**Definition of Done:**
- ProfilerAgent builds accurate fiscal profile JSON
- LoopholeAgent matches devices to profile
- StrategyAgent generates action plans
- ComplianceAgent validates against L.64

---

### Sprint 3.2: AI Agent UI & Basic Levers

| Epic | Story | Team | Priority |
|------|-------|------|----------|
| Epic 7 | Story 7.5: Implement Radar Fiscal Display | Dev | P0 |
| Epic 7 | Story 7.6: Implement 10 Basic Levers | Dev | P0 |

**Definition of Done:**
- Radar visualization animates smoothly
- All 10 basic levers functional
- Recommendations ordered by impact
- Risk scores displayed (1-5)

---

### Sprint 3.3: Knowledge Base & Expert Levers

| Epic | Story | Team | Priority |
|------|-------|------|----------|
| Epic 7 | FR35: 25 fiscal levers database embedded | Dev | P0 |
| Epic 8 | All remaining Expert stories | Dev | P1 |
| Epic 6B | Story 6B.7: Expense Receipt Analysis | Dev | P1 |
| Epic 6B | Story 6B.8: Integration with ProfilerAgent | Dev | P1 |

**Definition of Done:**
- CGI articles embedded in app
- BOFiP references accessible
- All 25 levers implementable
- Knowledge base updates via Remote Config

---

## Phase 4: Expansion

**Goal:** Advanced features, localization, and platform extensions.

### Sprint 4.1: Enhanced AI Capabilities

| Epic | Story | Team | Priority |
|------|-------|------|----------|
| Epic 7 | LLM Cloud integration (V2) | Dev | P0 |
| Epic 7 | RAG on CGI/BOFiP | Dev | P0 |
| Epic 7 | Chat interface | Dev | P1 |

**Definition of Done:**
- Natural language queries processed
- RAG provides accurate responses
- Chat interface intuitive

---

### Sprint 4.2: Platform Extensions

| Epic | Story | Team | Priority |
|------|-------|------|----------|
| Epic 10 | iOS Widget | Dev | P0 |
| Epic 10 | English localization | Dev | P1 |
| Epic 10 | Open Banking integration (future) | Dev | P2 |

**Definition of Done:**
- iOS widget shows tax summary
- English UI complete
- Expatriate market addressed

---

### Sprint 4.3: Independent Support (Year 2)

| Epic | Story | Team | Priority |
|------|-------|------|----------|
| - | BIC/BNC support | Dev | P0 |
| - | Micro-enterprise support | Dev | P1 |

**Definition of Done:**
- Self-employed can use app
- Business income calculations accurate

---

## Story Point Estimates

### Complexity Rating Guide

| Rating | Points | Description |
|--------|--------|-------------|
| XS | 1 | Trivial change, copy/edit |
| S | 2 | Small, isolated change |
| M | 3 | Medium complexity, single feature |
| L | 5 | Large, multiple components |
| XL | 8 | Very large, complex feature |
| XXL | 13 | Requires significant architecture |

### Sprint Capacity

- Team: 1-2 developers
- Velocity: 13-21 points/sprint (adjust based on team)

---

## Sprint Summary Table

| Phase | Sprint | Focus | Points | Stories |
|-------|--------|-------|--------|---------|
| 1 | 1.1 | Project Setup | 13 | 6 |
| 1 | 1.2 | Core Tax Calculator | 21 | 7 |
| 1 | 1.3 | Basic Optimizations | 21 | 10 |
| 2 | 2.1 | Premium Optimizations | 13 | 4 |
| 2 | 2.2 | Expert Optimizations | 13 | 4 |
| 2 | 2.3 | Calendar & Notifications | 13 | 4 |
| 2 | 2.4 | Educational Center | 8 | 3 |
| 2 | 2.5 | Monetization | 13 | 4 |
| 3 | 3.1 | AI Agent Core | 13 | 4 |
| 3 | 3.2 | AI Agent UI | 8 | 2 |
| 3 | 3.3 | Knowledge Base | 13 | 2 |
| 4 | 4.1 | Enhanced AI | 13 | 3 |
| 4 | 4.2 | Platform Extensions | 8 | 3 |
| 4 | 4.3 | Independent Support | 8 | 2 |

**Total: 14 sprints, ~170 story points, 52 stories**

---

## Dependencies

### Blocked By

| Story | Blocked By |
|-------|------------|
| Any Epic 3-10 | Epic 1 (Setup) |
| Epic 4 (Dashboard) | Epic 2 (Calculator) |
| Epic 5 (Calendar) | Epic 1 |
| Epic 6 (Education) | Epic 3 (Basic Optimizations) |
| Epic 7 (AI Agent) | Epic 1, Epic 4 |
| Epic 8 (Expert) | Epic 3, Epic 7 |
| Epic 9 (Monetization) | Epic 1 |

### Parallelization Opportunities

| Sprint Group | Can Run In Parallel |
|--------------|---------------------|
| Sprint 1.2, Sprint 1.3 | Yes (different features) |
| Sprint 2.1, Sprint 2.2, Sprint 2.3 | Yes (different modules) |
| Sprint 2.4, Sprint 2.5 | Yes (Content + Dev) |
| Sprint 3.1, Sprint 3.2 | Yes (Core + UI) |

---

## Risk Mitigation

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Tax calculation errors | Critical | Medium | Unit tests vs official simulator |
| Firebase Remote Config complexity | Medium | Low | Embed defaults first |
| App Store rejection | High | Medium | Follow guidelines closely |
| Firebase dependency | Medium | Low | App works offline with cached data |
| Knowledge base size (15-25MB) | Low | Low | Lazy loading, compression |

---

## Next Steps

1. **Refine estimates** with actual team velocity
2. **Assign stories** to team members based on skills
3. **Plan first sprint** (1.1: Project Setup)
4. **Setup tracking** in project management tool
5. **Review and iterate** after each sprint
