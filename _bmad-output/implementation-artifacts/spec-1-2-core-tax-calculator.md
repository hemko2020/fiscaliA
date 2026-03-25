---
stepsCompleted: []
inputDocuments: ["_bmad-output/planning-artifacts/sprints.md", "_bmad-output/planning-artifacts/epics.md", "_bmad-output/planning-artifacts/architecture.md"]
status: 'in-progress'
slug: '1-2-core-tax-calculator'
sprint: '1.2'
epic: 'Epic 2: Simulateur IR - Basic Tax Calculator'
team: Dev
priority: P0
date: '2026-03-25'
---

# Spec: 1-2 Core Tax Calculator

## Stories (7 total)

### Story 2.1: Implement Tax Bracket Calculator (P0)
### Story 2.2: Implement Family Quotient System (P0)
### Story 2.3: Implement Decote Calculation (P0)
### Story 2.4: Implement CEHR Calculation (P1)
### Story 2.5: Implement Real Expenses vs 10% Deduction (P0)
### Story 2.6: Create Tax Visualization Charts (P1)
### Story 2.7: Create Guided Input Flow (P1)

## Definition of Done

- Tax calculation matches official simulator within 1€ precision
- All 5 brackets correctly applied
- Family quotient calculation verified
- Decote calculation matches official formulas

## Technical Notes

- TaxCalculator already exists in fiscal_provider.dart
- Need to verify calculation accuracy
- Need to add CEHR calculation
- Need to add real expenses comparison
- Need to enhance visualization
