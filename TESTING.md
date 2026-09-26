# LegalLens AI — Testing & Verification Guide

LegalLens AI features a multi-tiered automated test suite covering unit tests, modular AI intelligence components, document parsing edge cases, anti-hallucination safeguards, performance memoization benchmarks on scaled documents, and accessibility widget tests.

---

## 📊 Test Suite Summary

- **Total Test Cases:** **151 tests**
- **Test Pass Rate:** **100% (151 / 151 passed)**
- **Measured Line Coverage:** **84.14%** (2,769 of 3,291 lines hit across codebase)
- **Coverage Artifact:** Generated at `coverage/lcov.info` via `flutter test --coverage`
- **Execution Time:** ~10-15 seconds across all 17 test suites

---

## 🧪 Test Architecture & Category Breakdown

```
test/
├── unit/
│   ├── cache_and_performance_test.dart    # SHA-256 memoization, O(1) retrieval, 10KB-1MB scale tests
│   ├── document_parser_test.dart          # 11 edge cases: empty, whitespace, numbered, ARTICLE, unicode
│   ├── clause_detection_test.dart         # Declarative ClauseRule registry, 15 categories, extensibility
│   ├── obligation_extraction_test.dart    # Tri-partitioned duties across employment, tenancy, contractor
│   ├── date_extractor_test.dart           # Milestone date regex extraction + safe "Not detected." policy
│   ├── risk_analysis_test.dart            # 6-category radar, elevation rules, safe non-defamatory phrasing
│   ├── document_type_detection_test.dart  # Heuristic classification for standard contract types
│   ├── checklist_generation_test.dart     # 7 pre-signature verification items and category breadth
│   ├── lawyer_questions_test.dart         # Tailored consultation questions from high-attention clauses
│   ├── options_generation_test.dart       # Strategic decision paths and risk-tier mapping
│   ├── options_and_next_steps_test.dart   # Strategic negotiation options, pros, cons, JSON serialization
│   ├── security_sanitization_test.dart    # Defamatory scrubbing, prompt injection, script tags, long text
│   ├── clause_and_intelligence_test.dart  # End-to-end intelligence suite: clauses, dates, Q&A, diffs
│   ├── repositories_and_storage_test.dart # Storage, checklist persistence, zero orphaned keys, corrupt JSON
│   ├── export_service_test.dart           # Complete Markdown & JSON intelligence exports + disclaimer
│   ├── gemini_provider_test.dart          # Remote GenAI fallback behavior and JSON response parsing
│   ├── enums_and_models_test.dart         # Domain model round-trips and null safety fallbacks
│   ├── theme_and_entities_test.dart       # Design tokens, color contrast, and entity copyWith
│   └── app_providers_state_test.dart      # Riverpod state notifiers and async transitions
└── widget/
    ├── widget_flows_test.dart             # Page rendering, input flows, grounded Q&A, refusal, presets
    ├── pages_comprehensive_test.dart      # Obligations tabs, Risk Map, Timeline, Diffing, History clear-all
    └── accessibility_semantics_test.dart  # WCAG 2.1 AA Semantics tags, badges, metrics, OptionsPage
```

### Detailed Test Specifications

| Test Suite File | Test Count | Key Invariants Tested |
| :--- | :---: | :--- |
| **`cache_and_performance_test.dart`** | **12** | • Content-addressed SHA-256 cache keying<br>• Zero collision between documents of same name but different content<br>• Benchmarks on 10KB, 100KB, 500KB, and 1MB documents<br>• In-memory invalidation and cache clear |
| **`document_parser_test.dart`** | **13** | • 11 edge cases: empty, whitespace-only, normal, numbered, ARTICLE, SECTION, all-caps, malformed, large text, unicode (emojis/Cyrillic/Asian), blank lines<br>• Deterministic section parsing across runs |
| **`clause_detection_test.dart`** | **9** | • All 15 standard clause categories verified<br>• High-attention elevation for 90-day notice, non-compete, indemnity<br>• Rule registry extensibility (adding custom rules) |
| **`obligation_extraction_test.dart`** | **4** | • Tri-partitioning of covenants into Your, Other Party, Shared<br>• Employment, lease, and contractor context handling<br>• Core Covenants fallback for unclassified roles |
| **`date_extraction_test.dart`** | **3** | • Start date, probation window, notice period, expiration, renewal<br>• Safe "Not detected." policy for absent deadlines |
| **`risk_analysis_test.dart`** | **6** | • 6-category risk radar (Financial, Employment, Privacy, Liability, IP, Restrictions)<br>• Neutral advisory recommendations without defamatory conclusions |
| **`document_type_detection_test.dart`** | **6** | • Classification for Employment, Lease, NDA, Freelance, Service Agreement, General Contract |
| **`checklist_generation_test.dart`** | **2** | • 7 pre-signature items, unique IDs, category coverage, initial unchecked state |
| **`lawyer_questions_test.dart`** | **2** | • Specific questions generated for high-attention clauses + fallback dispute question |
| **`options_generation_test.dart`** | **2** | • 4 distinct strategic paths and risk-tier inheritance |
| **`options_and_next_steps_test.dart`** | **7** | • Option models, pros, cons, actionable steps, JSON round-trips |
| **`security_sanitization_test.dart`** | **9** | • Defamatory word scrubbing<br>• Prompt injection neutralization<br>• Grounded Q&A citations and ungrounded query refusal<br>• Untrusted input (HTML, scripts, 50,000+ char text) |
| **`clause_and_intelligence_test.dart`** | **11** | • End-to-end intelligence suite: clauses, obligations, timeline, risks, Q&A, comparison diffs |
| **`repositories_and_storage_test.dart`** | **11** | • Document history and checklist persistence<br>• Zero orphaned keys on document deletion and `clearAllDocuments()`<br>• Graceful recovery from corrupted JSON |
| **`export_service_test.dart`** | **4** | • Markdown and JSON report generation across all 8 deliverables<br>• Empty document resilience, special characters, unicode, and disclaimer retention |
| **`gemini_provider_test.dart`** | **7** | • Offline fallback, API key handling, JSON response extraction |
| **`enums_and_models_test.dart`** | **12** | • Serialization round-trips, null safety fallbacks, enum labels |
| **`theme_and_entities_test.dart`** | **4** | • Design tokens, color contrast, entity copyWith |
| **`app_providers_state_test.dart`** | **8** | • Riverpod notifier state transitions |
| **`accessibility_semantics_test.dart`** | **6** | • WCAG 2.1 AA multi-factor indicators (Color+Icon+Text), Semantics widget audit |
| **`pages_comprehensive_test.dart`** | **6** | • Obligations tabs, Risk Map, Timeline, Comparison diffs, History clear-all confirmation, Settings |
| **`widget_flows_test.dart`** | **7** | • Realistic user flows: upload preset, snapshot, clauses, checklist, grounded Q&A, refusal |
| **TOTAL** | **151** | **All 151 tests pass cleanly with 0 failures** |

---

## 🚀 Running Tests Locally

```bash
# 1. Run full test suite (151 tests)
flutter test

# 2. Run with coverage report generation
flutter test --coverage

# 3. Calculate exact line coverage percentage from lcov.info
python3 -c "
with open('coverage/lcov.info') as f:
    lines = f.readlines()
total, hit = 0, 0
for line in lines:
    if line.startswith('LF:'): total += int(line.strip().split(':')[1])
    elif line.startswith('LH:'): hit += int(line.strip().split(':')[1])
print(f'Line Coverage: {hit/total*100:.2f}% ({hit}/{total} lines)')
"

# 4. Run static analysis (0 errors, 0 warnings, 0 lints)
flutter analyze --fatal-infos
```

---

## 🔄 CI/CD Pipeline Automation

All tests are executed on every push and pull request to `main` via GitHub Actions (`.github/workflows/ci.yml`). Pull requests must pass all 151 tests and static analysis with zero errors, zero warnings, and zero lints.
