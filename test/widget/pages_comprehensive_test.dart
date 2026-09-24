import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:legallens_ai/domain/entities/enums.dart';
import 'package:legallens_ai/domain/entities/legal_entities.dart';
import 'package:legallens_ai/presentation/pages/comparison_page.dart';
import 'package:legallens_ai/presentation/pages/obligations_page.dart';
import 'package:legallens_ai/presentation/pages/risk_map_page.dart';
import 'package:legallens_ai/presentation/pages/timeline_page.dart';
import 'package:legallens_ai/presentation/pages/history_page.dart';
import 'package:legallens_ai/presentation/pages/settings_page.dart';
import 'package:legallens_ai/presentation/providers/app_providers.dart';

LegalDocument _createComprehensiveMockDoc() {
  return LegalDocument(
    id: 'comp_doc_1',
    fileName: 'Tech_Employment_Agreement.txt',
    documentType: 'Employment Agreement',
    rawText: 'Section 1. Salary of \$185,000. Section 2. 12 month non-compete.',
    charCount: 2000,
    createdAt: DateTime.now(),
    snapshot: const LegalSnapshot(
      documentType: 'Employment Agreement',
      complexity: DocumentComplexity.moderate,
      attentionLevel: AttentionTier.highAttention,
      executiveSummary: 'Contains 2 high attention covenants.',
      keyAreas: ['Compensation', 'Termination', 'Non-Compete', 'Intellectual Property'],
      totalClauses: 4,
      highAttentionCount: 2,
      reviewCount: 1,
      informationalCount: 1,
    ),
    clauses: const [
      LegalClause(
        id: 'c1',
        title: 'Compensation Structure',
        category: 'Payment',
        importance: AttentionTier.informational,
        originalText: 'Base salary of \$185,000.',
        plainLanguageExplanation: 'Annual salary paid twice monthly.',
        whyItMatters: 'Guarantees income.',
        potentialConcern: 'None noted.',
        recommendedReview: 'Verify payment frequency.',
      ),
      LegalClause(
        id: 'c2',
        title: 'Non-Compete Restriction',
        category: 'Non-Compete',
        importance: AttentionTier.highAttention,
        originalText: '12 months non-compete.',
        plainLanguageExplanation: 'Restricts competing employment.',
        whyItMatters: 'Limits future mobility.',
        potentialConcern: 'Broad geographic restriction.',
        recommendedReview: 'Seek legal counsel.',
      ),
    ],
    obligations: const [
      Obligation(
        id: 'o1',
        party: ObligationParty.your,
        description: 'Provide 90 days notice before departure',
        sourceClause: 'Section 3 Termination',
      ),
      Obligation(
        id: 'o2',
        party: ObligationParty.otherParty,
        description: 'Disburse salary semi-monthly',
        sourceClause: 'Section 2 Compensation',
      ),
      Obligation(
        id: 'o3',
        party: ObligationParty.shared,
        description: 'Mediate disputes prior to arbitration',
        sourceClause: 'Section 8 Dispute Resolution',
      ),
    ],
    dates: const [
      ImportantDate(
        id: 'd1',
        title: 'Effective Date',
        dateString: 'October 1, 2025',
        type: 'Contract Start',
        sourceSnippet: 'Entered into as of October 1, 2025',
        isDetected: true,
      ),
      ImportantDate(
        id: 'd2',
        title: 'Expiration Date',
        dateString: 'Not detected.',
        type: 'Expiration',
        sourceSnippet: 'No expiration date found',
        isDetected: false,
      ),
    ],
    risks: const [
      RiskItem(
        id: 'r1',
        category: RiskCategory.restrictions,
        attentionLevel: AttentionTier.highAttention,
        relevantClause: 'Section 6 Non-Compete',
        explanation: 'Requires attention: 12-month post-employment restriction.',
        recommendedAction: 'Consult legal counsel.',
      ),
      RiskItem(
        id: 'r2',
        category: RiskCategory.financial,
        attentionLevel: AttentionTier.review,
        relevantClause: 'Section 2 Bonus',
        explanation: 'Bonus is discretionary without objective formula.',
        recommendedAction: 'Request performance milestones.',
      ),
    ],
    lawyerQuestions: const [],
    checklist: const [],
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Comprehensive Pages Widget Tests', () {
    testWidgets('ObligationsPage renders Your, Other, and Shared duties', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(documentNotifierProvider.notifier).setDocument(_createComprehensiveMockDoc());

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: ObligationsPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Obligation Extractor & Responsibility Matrix'), findsOneWidget);
      expect(find.text('Provide 90 days notice before departure'), findsOneWidget);

      // Switch to Other Party tab
      await tester.tap(find.textContaining('Other Party'));
      await tester.pumpAndSettle();
      expect(find.text('Disburse salary semi-monthly'), findsOneWidget);

      // Switch to Shared Duties tab
      await tester.tap(find.textContaining('Shared Duties'));
      await tester.pumpAndSettle();
      expect(find.text('Mediate disputes prior to arbitration'), findsOneWidget);
    });

    testWidgets('RiskMapPage renders 6-category radar and risk items', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(documentNotifierProvider.notifier).setDocument(_createComprehensiveMockDoc());

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: RiskMapPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Risk & Attention Radar'), findsOneWidget);
      expect(find.textContaining('12-month post-employment restriction'), findsOneWidget);
      expect(find.textContaining('Bonus is discretionary'), findsOneWidget);
    });

    testWidgets('TimelinePage renders milestone dates and anti-hallucination indicators', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(documentNotifierProvider.notifier).setDocument(_createComprehensiveMockDoc());

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: TimelinePage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Important Dates & Milestone Timeline'), findsOneWidget);
      expect(find.text('Effective Date'), findsOneWidget);
      expect(find.text('October 1, 2025'), findsOneWidget);
      expect(find.text('Expiration Date'), findsOneWidget);
      expect(find.text('Not detected.'), findsOneWidget);
    });

    testWidgets('ComparisonPage executes preset comparison and displays diffs', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: ComparisonPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Contract Side-by-Side Comparison'), findsOneWidget);
      expect(find.text('Run Contract Comparison'), findsOneWidget);

      // Tap compare button
      await tester.tap(find.text('Run Contract Comparison'));
      await tester.pumpAndSettle();

      expect(find.text('Potentially Important Differences Detected'), findsOneWidget);
    });

    testWidgets('HistoryPage renders document list and allows interactions', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final mockDoc = _createComprehensiveMockDoc();
      await container.read(documentRepositoryProvider).saveDocument(mockDoc);
      await container.read(historyNotifierProvider.notifier).loadHistory();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: HistoryPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(mockDoc.fileName), findsOneWidget);
      expect(find.text('Clear All'), findsOneWidget);

      // Tap Clear All to open confirmation dialog
      await tester.tap(find.text('Clear All'));
      await tester.pumpAndSettle();

      expect(find.text('Clear All Document History?'), findsOneWidget);
      // Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text(mockDoc.fileName), findsOneWidget);

      // Open Clear All again and confirm
      await tester.tap(find.text('Clear All'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Clear All'));
      await tester.pumpAndSettle();

      expect(find.text('No Document History Found'), findsOneWidget);
    });

    testWidgets('SettingsPage allows toggling demo mode, entering API key, saving, and purging data', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: SettingsPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Settings, AI Engine & Privacy'), findsOneWidget);
      expect(find.text('GenAI Engine Mode'), findsOneWidget);

      // Toggle demo mode off
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      expect(find.text('Optional Google Gemini API Key'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Enter API key
      await tester.enterText(find.byType(TextField), 'AIzaSyFakeKeyForTest123');
      await tester.pumpAndSettle();

      // Tap Save Key
      await tester.tap(find.text('Save Key'));
      await tester.pumpAndSettle();

      expect(find.text('AI Configuration updated successfully.'), findsOneWidget);

      // Tap Purge All Local Data & Reset
      final purgeBtn = find.text('Purge All Local Data & Reset');
      await tester.ensureVisible(purgeBtn);
      await tester.tap(purgeBtn);
      await tester.pumpAndSettle();

      expect(find.text('All local data and storage purged successfully.'), findsOneWidget);
    });
  });
}

