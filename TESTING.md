# LegalLens AI — Testing & Verification Guide

LegalLens AI features a multi-tiered automated test suite covering unit tests, service tests, anti-hallucination safeguards, performance memoization benchmarks, and accessibility widget tests.

---

## 📊 Test Suite Summary

- **Total Test Cases:** **42 tests**
- **Test Pass Rate:** **100% (42 / 42 passed)**
- **Coverage Report:** Generated at `coverage/lcov.info`
- **Execution Time:** ~8 seconds across all suites

---

## 🧪 Test Architecture & Category Breakdown

```
test/
├── unit/
│   ├── document_parser_test.dart          # Section extraction & structure indexing
│   ├── clause_and_intelligence_test.dart  # 15 clause categories, obligations, risks, Q&A, diffs
│   ├── options_and_next_steps_test.dart   # Strategic negotiation options, pros, cons, steps
│   ├── cache_and_performance_test.dart    # SHA-256 memoization, O(1) retrieval, invalidation
│   ├── export_service_test.dart           # Complete Markdown & JSON intelligence exports
│   └── security_sanitization_test.dart    # Defamatory word scrubbing & non-definitive phrasing
└── widget/
    ├── widget_flows_test.dart             # Page rendering, inputs, preset selections, state flows
    └── accessibility_semantics_test.dart  # WCAG 2.1 AA Semantics tags, badges, metrics, OptionsPage
```

### Detailed Test Specifications

| Test Suite File | Test Count | Key Invariants Tested |
| :--- | :---: | :--- |
| **`options_and_next_steps_test.dart`** | 6 | • 4 distinct strategic options generated<br>• Option 1: As-Is pros/cons and calendar reminders<br>• Option 2: Balanced redlines (15-day cure period, bilateral terms)<br>• Option 3: Targeted carve-outs (pre-existing IP exhibit, liability cap)<br>• Option 4: Legal counsel briefing and questions export<br>• NextStep copyWith and completion toggle<br>• LegalOption JSON round-trip serialization |
| **`cache_and_performance_test.dart`** | 4 | • First analysis warms SHA-256 in-memory cache<br>• Subsequent call returns in O(1) time (< 15ms)<br>• `clearCache()` purges memoized results<br>• Mode switch automatically invalidates cache |
| **`export_service_test.dart`** | 2 | • `generateMarkdownReport` bundles all 8 PromptWars deliverables<br>• `generateJsonReport` outputs valid JSON with full schema parity |
| **`security_sanitization_test.dart`** | 3 | • Scrubs defamatory terms ("illegal", "unlawful", "you will lose")<br>• Anti-hallucination: missing dates return *"Not detected."*<br>• Risk recommendations enforce safe non-definitive advisory phrasing |
| **`accessibility_semantics_test.dart`** | 6 | • `PriorityBadge` renders explicit `Semantics(label: ...)`<br>• `ConfidenceBadge` renders confidence level semantics<br>• `MetricCard` provides screen reader nodes<br>• `LegalDisclaimerBanner` landmark semantics<br>• `OptionsPage` empty placeholder & full option cards |
| **`clause_and_intelligence_test.dart`** | 10 | • 15 clause category detections<br>• Original verbatim clause retention<br>• Obligation tri-partitioning (Your, Other, Shared)<br>• Stated vs absent date detection<br>• Grounded Q&A with section citations<br>• Strict Q&A refusal on unmentioned queries<br>• Contract comparison diffing<br>• Action checklist & lawyer questions |
| **`document_parser_test.dart`** | 4 | • Section header detection & Roman numeral splitting<br>• Whitespace trimming & preamble detection<br>• Empty document error handling |
| **`widget_flows_test.dart`** | 7 | • `LandingPage` headline and presets<br>• `UploadPage` paste and sample contract interactions<br>• `SnapshotPage` overview and metric counters<br>• `ClausesPage` search and category filtering<br>• `ActionCenterPage` checklist toggles<br>• `QAPage` prompt pills and grounded assistant |

---

## 🚀 Running Tests Locally

```bash
# 1. Run full test suite
flutter test

# 2. Run with coverage report generation
flutter test --coverage

# 3. Inspect coverage report
head -n 30 coverage/lcov.info

# 4. Run static analysis
flutter analyze
```

---

## 🔄 CI/CD Pipeline Automation

All tests are executed on every push and pull request to `main` via GitHub Actions (`.github/workflows/ci.yml`). Pull requests must pass all 42 tests and static analysis with zero errors, zero warnings, and zero lints.
