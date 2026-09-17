# LegalLens AI — Understand Before You Sign

**PromptWars Hackathon Challenge Submission: AI for Legal Assistance & Access**

> **Official Product Mission:**  
> Making legal information and basic legal assistance universally accessible, understandable, and actionable—empowering individuals and small business owners to understand what they are agreeing to before they sign, without replacing qualified legal counsel.

---

## ⚖️ Problem Statement

Legal contracts govern virtually every major milestone in life: employment, housing, freelancing, software licensing, commercial partnerships, and intellectual property. Yet legal text is notoriously opaque, full of archaic jargon, buried liabilities, unilateral indemnifications, and aggressive restrictive covenants.

Most people face an impossible choice:
1. **Sign blindly** without understanding the risks, exposure, or obligations.
2. **Hire a lawyer for hundreds of dollars per hour** for basic document orientation and routine questions.

Furthermore, traditional generic LLMs (ChatGPT, general chat interfaces) frequently **hallucinate**, fabricate non-existent dates, misstate legal conclusions, or give unauthorized and misleading "legal advice" that exposes users to severe liability.

---

## 🚀 The Solution: LegalLens AI

**LegalLens AI** is a personal, client-side, privacy-first legal document intelligence assistant. Instead of confronting a dense wall of text, LegalLens AI transforms legal agreements into:

1. **Executive Legal Snapshot** — Document categorization, complexity score, and attention hotspots.
2. **Plain-Language Explanations** — Clause-by-clause translation paired side-by-side with *"Why It Matters"* and verbatim original text.
3. **Deep Clause Intelligence (15 Categories)** — Automated detection across Payment, Termination, Notice, Confidentiality, IP, Liability, Indemnity, Non-Compete, Non-Solicitation, Dispute Resolution, Governing Law, Renewal, Penalties, Refunds, and Data Privacy.
4. **Tri-Partitioned Obligation Extractor** — Segregates covenants into *Your Responsibilities*, *Other Party Responsibilities*, and *Shared Duties*.
5. **Milestone Date Extractor & Timeline** — Extracts probation, notice, and expiration dates with a strict anti-hallucination policy (*"Not detected."* when absent).
6. **6-Category Risk & Attention Radar** — Evaluates Financial, Employment, Privacy, Liability, IP, and Restrictions using safe, non-definitive advisory language.
7. **Document-Grounded Q&A** — Conversational assistant answering strictly from the provided contract with exact section citations and refusal of unmentioned topics.
8. **Side-by-Side Contract Comparison** — Diffs two contract versions to expose added, removed, or changed obligations, financial terms, and high-attention differences.
9. **Action Center & "Before You Sign" Checklist** — Interactive, locally persistent preparation checklist with custom tasks.
10. **Questions for a Lawyer** — Personalized questions tailored to detected concerns to maximize professional consultation value.

---

## 🏛️ GenAI & System Architecture

LegalLens AI adheres strictly to **Clean Architecture** and **Domain-Driven Design**, decoupling user interface widgets from business logic and AI engines.

```
                    ┌──────────────────────────────────────────────┐
                    │               Presentation                   │
                    │   (Pages, Widgets, Shell, Riverpod States)   │
                    └──────────────────────┬───────────────────────┘
                                           │
                    ┌──────────────────────▼───────────────────────┐
                    │                  Domain                      │
                    │      (Entities, Value Objects, Enums)        │
                    └──────────────────────┬───────────────────────┘
                                           │
                    ┌──────────────────────▼───────────────────────┐
                    │                 Services                     │
                    │  ┌────────────────────┐ ┌──────────────────┐ │
                    │  │DocumentParserService│ │    AIService     │ │
                    │  └────────────────────┘ └────────┬─────────┘ │
                    └──────────────────────────────────┼───────────┘
                                                       │
                           ┌───────────────────────────┴──────────────────────────┐
                           ▼                                                      ▼
             ┌───────────────────────────┐                          ┌───────────────────────────┐
             │      DemoAIProvider       │                          │      GeminiAIProvider     │
             │ (Local Heuristic Engine)  │                          │  (Optional Google Gemini) │
             │  • Zero API Key Required  │                          │  • Runtime Config Only    │
             │  • 100% Client-Side NLP   │                          │  • Never Commit Secrets   │
             │  • Deterministic Output   │                          │  • Grounded System Prompt │
             └───────────────────────────┘                          └───────────────────────────┘
```

### Document Intelligence Pipeline

```
Legal Document (PDF/TXT/MD)
           │
           ▼
[DocumentParserService] ───► Structure & Section Indexing
           │
           ▼
[AIService / AIProvider] ───► 15-Category Clause Extraction
           │                 Obligation Tri-Partitioning
           │                 Date & Milestone Parsing
           │                 Risk & Attention Scoring
           │
           ▼
[Validation Layer] ────────► Sanitize defamatory words (never "illegal" / "unlawful")
           │                 Enforce "Not detected." on missing dates
           │                 Enforce exact refusal on ungrounded queries
           │
           ▼
[User Interface] ──────────► Plain-Language Explanations + Citations + Actions
```

---

## 🛡️ Safety & Anti-Hallucination Safeguards

### Strict Legal Information Boundary
* LegalLens AI provides **legal information and document assistance only**, explicitly disclaiming legal advice or enforceable outcome determination.
* Prominent, non-intrusive legal disclaimer banners are present across all primary views, the header bar, and in settings.

### Safe Advisory Phrasing
* Absolute legal declarations (e.g. *"This clause is illegal"*, *"This contract is unlawful"*, *"You will definitely lose"*) are strictly prohibited and scrubbed by the validation layer.
* Safe, non-definitive language is enforced:
  - *"Requires attention"*
  - *"Potential concern"*
  - *"Unclear wording"*
  - *"Consider professional review"*

### Multi-Factor Accessibility
* Indicators **never rely on color alone** (WCAG AA compliant):
  - 🟢 **Informational** (Emerald + Checkmark icon + Text label)
  - 🟡 **Requires Review** (Amber + Help icon + Text label)
  - 🔴 **High Attention** (Rose + Warning icon + Text label)

### Anti-Hallucination Date Guarantee
* If an expiration, renewal, or probation date is not explicitly present in the document, it renders **"Not detected."** — never inventing hypothetical dates.

### Strict Grounded Q&A Refusal
* When asked about ungrounded or non-contract topics (e.g. unrelated subjects or unmentioned benefits), the engine responds strictly:
  > *"I couldn't find this information in the provided document."*

---

## 🔒 Privacy-First Architecture

LegalLens AI is built on a **zero-backend, local-first philosophy**:
* **No Cloud Storage**: Contracts and documents are never uploaded to Firebase, Supabase, Firestore, or custom databases.
* **In-Browser Processing**: PDF text extraction is performed via pure Dart (`syncfusion_flutter_pdf`) directly in the client browser session.
* **Local Persistence**: Document metadata and checklist state are stored solely in browser `SharedPreferences`.
* **One-Click Purge**: Users can permanently erase all local storage and history at any time from the Settings screen.
* **Zero Telemetry**: No document contents or PII are logged.

---

## 💻 Tech Stack

* **Framework:** Flutter Web (Dart 3.10+, Flutter 3.38+)
* **State Management:** Riverpod 2.6 (`StateNotifierProvider`)
* **Routing:** GoRouter 14.8 (Declarative routing with `ShellRoute` and persistent responsive navigation)
* **Design & Typography:** Material 3, Google Fonts (`Outfit`, `Plus Jakarta Sans`, `JetBrains Mono`)
* **Local Storage:** `shared_preferences`
* **PDF Extraction:** `syncfusion_flutter_pdf` (100% pure Dart, client-side on Web)
* **File Uploads:** `file_picker`
* **Networking (Optional Real GenAI):** `dio`

---

## 🧪 Testing & Quality Assurance

LegalLens AI includes a comprehensive, automated test suite:

* **Unit Tests (`test/unit/`):**
  - `document_parser_test.dart`: Section header splitting, whitespace handling, preamble detection.
  - `clause_and_intelligence_test.dart`:
    - Detection of 15 clause categories (Payment, Termination, Notice, IP, Non-Compete, Indemnity, etc.).
    - Obligation tri-partitioning (Your, Other, Shared).
    - Date extraction and absent date safety (*"Not detected."*).
    - Risk classification without defamatory terms.
    - Grounded Q&A with section citations.
    - Strict anti-hallucination refusal.
    - Contract comparison diffing.
    - Action checklist generation and lawyer questions.

* **Widget Tests (`test/widget/`):**
  - `widget_flows_test.dart`:
    - `LandingPage`: Brand headline, presets, responsive action buttons.
    - `UploadPage`: Preset selection, category dropdown, paste interaction.
    - `SnapshotPage`: Overview rendering, complexity badges, metric counters.
    - `ClausesPage`: Priority chip filters, category selection, search filtering.
    - `ActionCenterPage`: Interactive checklist toggles, lawyer questions.
    - `QAPage`: Chat interface, suggested prompt pills, grounding notice.

### Running Tests
```bash
# Run all unit and widget tests
flutter test

# Run static analysis
flutter analyze
```

---

## 🚀 Setup & Local Execution

### Prerequisites
* Flutter SDK (3.24+ recommended, tested on Flutter 3.38.5 / Dart 3.10.4)
* Google Chrome

### Quick Start
```bash
# 1. Clone or navigate to the repository
cd legallens_ai

# 2. Get dependencies
flutter pub get

# 3. Run on Chrome
flutter run -d chrome

# 4. Or build and serve the production web release
flutter build web --release
python3 -m http.server 8080 --directory build/web
# Open http://localhost:8080/
```

---

## ⚙️ AI Configuration: Demo Mode vs Real GenAI

| Feature | Demo Mode (Default) | Real GenAI Mode (Optional) |
| :--- | :--- | :--- |
| **Setup Required** | None (Runs immediately) | Enter Google Gemini API key in Settings |
| **Network Latency** | Instant (~300ms simulated NLP) | Network-dependent |
| **Privacy** | 100% in-browser processing | Sends prompt directly to Google Generative AI |
| **API Costs** | Free ($0) | Uses user's personal quota |
| **Reliability** | Deterministic & zero downtime | Dependent on external API availability |

*Note: In compliance with security standards, no API keys are hardcoded, and secrets are never committed to git.*

---

## 📄 Pre-Packaged Evaluation Presets

For instant 1-click evaluation without searching for sample contracts:
1. **Tech Employment Agreement** — Contains 90-day termination notice, comprehensive IP assignment (including home inventions), and a 12-month post-employment non-compete.
2. **Residential Lease Agreement** — Features strict per-day late fees, automatic evergreen renewal, and security deposit withholding terms.
3. **Mutual NDA** — Outlines indefinite trade secret survival, material return obligations, and immediate injunctive relief.
4. **Offer Letter Option A vs Option B** — Side-by-side comparison illustrating equity vesting vs extended clawback, 30 vs 90 days notice, and California-only vs nationwide non-compete.

---

## ⚖️ Legal Disclaimer

*LegalLens AI provides general legal information and document assistance, not legal advice. AI-generated results may be incomplete or inaccurate. For decisions involving your legal rights, obligations, or specific circumstances, consult a qualified legal professional.*
