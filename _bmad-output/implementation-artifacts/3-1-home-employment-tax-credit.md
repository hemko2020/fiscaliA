# Story 3.1: Home Employment Tax Credit

Status: ready-for-dev

## Story

As a user,
I want to calculate my home employment tax credit,
So that I know how much I can save on childcare/household help.

## Acceptance Criteria

1. **Given** User employs a nanny at home
   **When** I calculate credit: 50% of expenses
   **And** Apply ceiling: 12,000€ + 1,500€ per child/elderly person (max 15,000€)
   **Then** Maximum credit = 7,500€
   **And** First year ceiling is 15,000€ (18,000€ with majorations)

2. **Given** Home employment credit calculated
   **When** I check against tax niche ceiling
   **Then** This credit counts toward 10,000€ niche ceiling
   **And** Remaining niche space is updated

3. **Given** User has multiple qualifying persons (children, elderly)
   **When** I calculate the ceiling adjustment
   **Then** Each child under 18 adds 1,500€ to ceiling
   **And** Each elderly dependent adds 1,500€ to ceiling
   **And** Maximum ceiling is 15,000€ (18,000€ first year)

4. **Given** User enters home employment expenses
   **When** I validate the input
   **Then** Amount must be positive
   **And** Amount cannot exceed reasonable limits
   **And** Error messages are clear in French

## Tasks / Subtasks

- [ ] Task 1: Create HomeEmploymentCredit model (AC: #1, #3)
  - [ ] Create model with fields: expenses, numberOfChildren, numberOfElderly, isFirstYear
  - [ ] Add ceiling calculation logic (base + majorations)
  - [ ] Add JSON serialization for Hive storage
  - [ ] Write unit tests for ceiling calculation

- [ ] Task 2: Implement credit calculation service (AC: #1, #2)
  - [ ] Create HomeEmploymentCreditService
  - [ ] Implement 50% credit calculation
  - [ ] Apply ceiling constraints
  - [ ] Integrate with NicheCeilingTracker
  - [ ] Write unit tests for credit calculation

- [ ] Task 3: Create UI for home employment input (AC: #4)
  - [ ] Create HomeEmploymentCreditScreen widget
  - [ ] Add expense input field with validation
  - [ ] Add children/elderly count selectors
  - [ ] Add first year checkbox
  - [ ] Display calculated credit and ceiling

- [ ] Task 4: Integrate with simulation flow (AC: #2)
  - [ ] Add to optimization devices list
  - [ ] Connect to main simulation state
  - [ ] Update niche ceiling display
  - [ ] Add to results breakdown

- [ ] Task 5: Add tests and validation (AC: All)
  - [ ] Unit tests for all calculation scenarios
  - [ ] Widget tests for UI components
  - [ ] Integration test with full simulation

## Dev Notes

### Architecture Patterns

- Follow existing Riverpod state management pattern from Sprint 1.1/1.2
- Use Hive for local storage of credit data
- Integrate with existing FoyerFiscal and Simulation models

### Tax Calculation Rules (French Tax Law 2026)

**Base Ceiling:** 12,000€
**Majorations:**
- +1,500€ per child under 18
- +1,500€ per elderly dependent (65+)
- Maximum: 15,000€ (standard), 18,000€ (first year of employment)

**Credit Rate:** 50% of actual expenses

**Niche Ceiling:** Counts toward 10,000€ annual limit

### Source Tree Components

```
lib/
├── data/
│   └── models/
│       └── home_employment_credit_model.dart (NEW)
├── domain/
│   └── services/
│       └── home_employment_credit_service.dart (NEW)
├── presentation/
│   └── screens/
│       └── home_employment_credit_screen.dart (NEW)
└── providers/
    └── home_employment_credit_provider.dart (NEW)
```

### Testing Standards

- Unit tests must cover edge cases (zero expenses, maximum ceiling, first year)
- Widget tests for form validation
- Integration tests with simulation flow

### References

- [Source: PRD_FiscalIA.md - FR16: Calculate tax credit for home employment]
- [Source: epics.md - Story 3.1]
- [Source: architecture.md - State Management patterns]

## Dev Agent Record

### Agent Model Used

(To be filled during implementation)

### Debug Log References

(To be filled during implementation)

### Completion Notes List

(To be filled during implementation)

### File List

(To be filled during implementation)

## Change Log

| Date | Change | Author |
|------|--------|--------|
| 2026-03-28 | Story created for Sprint 1.3 | SM Agent |
