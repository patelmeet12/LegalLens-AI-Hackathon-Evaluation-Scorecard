# LegalLens AI — Accessibility Compliance & Audit (WCAG 2.1 AA)

**LegalLens AI** is engineered from the ground up to satisfy and exceed **Web Content Accessibility Guidelines (WCAG) 2.1 Level AA** standards. In legal technology, document comprehension must be universally accessible to every user, including those relying on screen readers, keyboard-only navigation, and high-contrast assistive configurations.

---

## ♿ Multi-Factor Non-Color Accessibility Architecture

A primary violation in legal-tech dashboards is relying solely on color (e.g., green vs. red dots) to communicate risk or attention tiers. LegalLens AI strictly enforces **Triple-Indicator Multi-Factor Encoding**:

| Tier | Visual Color | Icon Cue | Plain-Text Label | Accessible Screen Reader Tag |
| :--- | :---: | :---: | :---: | :--- |
| **Informational** | Emerald (`#10B981`) | `check_circle_outline_rounded` | "Informational" | `Semantics(label: "Attention level: Informational")` |
| **Requires Review** | Amber (`#F59E0B`) | `help_outline_rounded` | "Requires Review" | `Semantics(label: "Attention level: Requires Review")` |
| **High Attention** | Rose (`#F43F5E`) | `warning_amber_rounded` | "High Attention" | `Semantics(label: "Attention level: High Attention")` |

No information or advisory state is ever communicated via color alone.

---

## 🎙️ Screen Reader Compatibility (VoiceOver, TalkBack, NVDA)

All custom UI components are wrapped in Flutter's `Semantics` framework:

1. **Semantic Headers & Landmarks (`Semantics(header: true)`):**
   - Page titles, section headers (`SectionHeader`), and strategic option headings are tagged as semantic headings, allowing screen reader users to jump quickly between sections using heading navigation keys (`H` key).
2. **Interactive Controls (`Semantics(button: true, selected: ...)`):**
   - Navigation rail tiles, choice chips, filter pills, and expandable cards include semantic button roles and live selection status.
3. **Checkable Steps (`Semantics(checked: isDone)`):**
   - "Before You Sign" and "Actionable Next Steps" checkboxes declare their checked state explicitly, announcing *"Checked, [Task Name]"* or *"Unchecked, [Task Name]"*.
4. **Live Regions & Alerts (`Semantics(liveRegion: true)`):**
   - Low confidence warnings and legal information disclaimer banners are announced proactively upon page transition.

---

## 🎨 Contrast Ratio Conformance Matrix

All color tokens in `AppColors` (`lib/core/theme/app_theme.dart`) have been audited against WCAG 2.1 AA contrast minimums (minimum **4.5:1** for normal text, **3:1** for large text / UI components, and **7:1** for enhanced contrast):

| UI Element | Foreground Color | Background Color | Contrast Ratio | Conformance |
| :--- | :---: | :---: | :---: | :---: |
| **Dark Mode Primary Text** | `#F8FAFC` | `#090D16` | **18.2 : 1** | ✅ WCAG AAA Pass |
| **Dark Mode Secondary Text** | `#94A3B8` | `#131C2E` | **6.4 : 1** | ✅ WCAG AA Pass |
| **Light Mode Primary Text** | `#0F172A` | `#FFFFFF` | **18.5 : 1** | ✅ WCAG AAA Pass |
| **Light Mode Secondary Text** | `#475569` | `#FFFFFF` | **7.1 : 1** | ✅ WCAG AAA Pass |
| **Emerald Indicator** | `#10B981` | `#090D16` | **8.1 : 1** | ✅ WCAG AAA Pass |
| **Amber Indicator** | `#F59E0B` | `#090D16` | **9.6 : 1** | ✅ WCAG AAA Pass |
| **Rose Attention Indicator** | `#F43F5E` | `#090D16` | **5.3 : 1** | ✅ WCAG AA Pass |

---

## ⌨️ Keyboard Navigation & Focus Management

1. **Logical Focus Traversal:** All interactive elements (`ChoiceChip`, `ElevatedButton`, `OutlinedButton`, `ListTile`, `Checkbox`) follow a logical left-to-right, top-to-bottom tab order via Flutter's `FocusTraversalGroup`.
2. **Visible Focus Rings:** Focused buttons and form fields display an unmistakable focus outline (`AppColors.primaryLight`), ensuring keyboard-only users always know their cursor position.
3. **Shortcut Accessibility:**
   - `Tab` / `Shift+Tab`: Traverse controls forward and backward.
   - `Enter` / `Space`: Activate buttons, expand clause details, toggle checkboxes.
   - `Esc`: Close modal dialogs (such as the Export Report dialog).

---

## 🔍 Dynamic Text Scaling Support

The entire application layout is built with flexible constraints (`SingleChildScrollView`, `ConstrainedBox`, `Wrap`, `Expanded`, `Flexible`). Testing verifies that text can be scaled up to **200%** via browser zoom or OS accessibility settings without:
- Clipping or truncation of legal clauses or explanations.
- Overlapping text layers.
- Broken responsive grid layouts.

---

## 🧪 Automated Accessibility Testing

The automated test suite includes dedicated accessibility verification tests (`test/widget/accessibility_semantics_test.dart`):
- `PriorityBadge renders explicit semantic labels for screen readers` ✅
- `ConfidenceBadge renders explicit semantic confidence label` ✅
- `MetricCard provides semantic accessibility node for metrics` ✅
- `LegalDisclaimerBanner provides semantic landmark label` ✅
- `OptionsPage choice chips and step checkboxes provide accessible roles` ✅
