import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:legallens_ai/domain/entities/enums.dart';
import 'package:legallens_ai/domain/entities/legal_entities.dart';
import 'package:legallens_ai/presentation/pages/landing_page.dart';
import 'package:legallens_ai/presentation/pages/upload_page.dart';
import 'package:legallens_ai/presentation/pages/snapshot_page.dart';
import 'package:legallens_ai/presentation/pages/clauses_page.dart';
import 'package:legallens_ai/presentation/pages/action_center_page.dart';
import 'package:legallens_ai/presentation/pages/qa_page.dart';
import 'package:legallens_ai/presentation/providers/app_providers.dart';

LegalDocument _createMockDocument() {
  return LegalDocument(
    id: 'mock_doc_1',
    fileName: 'Tech_Employment_Agreement.txt',
    documentType: 'Employment Agreement',
    rawText: 'Full contract text for testing.',
    charCount: 1500,
    createdAt: DateTime.now(),
    snapshot: const LegalSnapshot(
      documentType: 'Employment Agreement',
      complexity: DocumentComplexity.moderate,
      attentionLevel: AttentionTier.highAttention,
      executiveSummary: 'This agreement contains 2 high attention clauses.',
      keyAreas: ['Compensation', 'Termination', 'Non-Compete', 'Intellectual Property'],
      totalClauses: 4,
      highAttentionCount: 2,
      reviewCount: 1,
      informationalCount: 1,
    ),
    clauses: const [
      LegalClause(
        id: 'c1',
        title: 'Compensation & Payment Structure',
        category: 'Payment',
        importance: AttentionTier.informational,
        originalText: 'Base salary of \$185,000 per annum.',
        plainLanguageExplanation: 'Annual salary disbursed semi-monthly.',
        whyItMatters: 'Guarantees regular compensation.',
        potentialConcern: 'Bonus discretion.',
        recommendedReview: 'Verify payment frequency.',
      ),
      LegalClause(
        id: 'c2',
        title: 'Post-Termination Non-Compete Restriction',
        category: 'Non-Compete',
        importance: AttentionTier.highAttention,
        originalText: '12 months non-compete.',
        plainLanguageExplanation: 'Restricts competing work for 12 months.',
        whyItMatters: 'Limits future job prospects.',
        potentialConcern: 'Requires attention: broad scope.',
        recommendedReview: 'Consult legal counsel regarding enforceability.',
      ),
    ],
    obligations: const [
      Obligation(
        id: 'o1',
        party: ObligationParty.your,
        description: 'Provide 90 days notice prior to resignation',
        sourceClause: 'Section 3 Termination',
      ),
      Obligation(
        id: 'o2',
        party: ObligationParty.otherParty,
        description: 'Disburse base salary semi-monthly',
        sourceClause: 'Section 2 Compensation',
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
        relevantClause: 'Non-Compete Section',
        explanation: 'Requires attention: 12-month post-employment ban.',
        recommendedAction: 'Verify enforceability.',
      ),
    ],
    lawyerQuestions: const [
      LawyerQuestion(
        id: 'q1',
        question: 'Is the 12-month non-compete enforceable in my state?',
        category: 'Non-Compete Scope',
        contextReason: 'Statutory limitations may apply.',
        sourceClause: 'Section 6 Restrictive Covenants',
      ),
    ],
    checklist: const [
      ChecklistItem(
        id: 'ck1',
        title: 'Verify compensation terms and bonus discretion',
        category: 'Compensation',
      ),
      ChecklistItem(
        id: 'ck2',
        title: 'Review non-compete geographic restrictions',
        category: 'Restrictions',
      ),
    ],
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('LandingPage displays brand headline and quick sample presets', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: LandingPage()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Understand Before You Sign.'), findsOneWidget);
    expect(find.text('Analyze a Document Now'), findsOneWidget);
    expect(find.text('Tech Employment Agreement'), findsOneWidget);
    expect(find.text('Residential Lease Agreement'), findsOneWidget);
  });

  testWidgets('UploadPage renders category picker, paste field, and sample presets', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: UploadPage()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Upload or Paste Legal Document'), findsOneWidget);
    expect(find.text('Tech Employment'), findsOneWidget);
    expect(find.text('Run LegalLens AI Analysis'), findsOneWidget);

    // Tap sample preset
    await tester.tap(find.text('Tech Employment'));
    await tester.pumpAndSettle();

    // Verify text is populated
    expect(find.textContaining('EMPLOYMENT AGREEMENT'), findsOneWidget);
  });

  testWidgets('SnapshotPage displays summary and metrics when document is loaded', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final container = ProviderContainer();
    final mockDoc = _createMockDocument();
    container.read(documentNotifierProvider.notifier).setDocument(mockDoc);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: SnapshotPage()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Legal Snapshot Overview'), findsOneWidget);
    expect(find.text('Employment Agreement'), findsOneWidget);
    expect(find.text('Total Clauses'), findsOneWidget);
    expect(find.text('High Attention'), findsWidgets);
  });

  testWidgets('ClausesPage renders and filters clauses', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final container = ProviderContainer();
    final mockDoc = _createMockDocument();
    container.read(documentNotifierProvider.notifier).setDocument(mockDoc);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: ClausesPage()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Clause Intelligence & Plain-Language Explanations'), findsOneWidget);
    expect(find.text('Compensation & Payment Structure'), findsOneWidget);
    expect(find.text('Post-Termination Non-Compete Restriction'), findsOneWidget);
  });

  testWidgets('ActionCenterPage displays checklist items and questions for lawyer', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final container = ProviderContainer();
    final mockDoc = _createMockDocument();
    container.read(documentNotifierProvider.notifier).setDocument(mockDoc);
    await container.read(checklistNotifierProvider.notifier).loadForDocument(mockDoc);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: ActionCenterPage()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Before You Sign Checklist'), findsOneWidget);
    expect(find.text('Questions for a Legal Professional'), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsWidgets);
    expect(find.textContaining('Is the 12-month non-compete enforceable'), findsOneWidget);
  });

  testWidgets('QAPage renders chat interface with grounding notice and quick questions', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final container = ProviderContainer();
    final mockDoc = _createMockDocument();
    container.read(documentNotifierProvider.notifier).setDocument(mockDoc);
    container.read(qaNotifierProvider.notifier).initForDocument(mockDoc);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: QAPage()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Document Grounded AI Q&A'), findsOneWidget);
    expect(find.text('What happens if I resign?'), findsOneWidget);
    expect(find.text('Who owns the work I create?'), findsOneWidget);
  });
}
