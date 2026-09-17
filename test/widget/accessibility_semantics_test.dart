import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:legallens_ai/core/theme/app_theme.dart';
import 'package:legallens_ai/domain/entities/enums.dart';
import 'package:legallens_ai/domain/entities/legal_entities.dart';
import 'package:legallens_ai/presentation/pages/options_page.dart';
import 'package:legallens_ai/presentation/providers/app_providers.dart';
import 'package:legallens_ai/presentation/widgets/shared_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestable(Widget child, {List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: child,
      ),
    );
  }

  group('Accessibility & Semantics Widget Verification Tests', () {
    testWidgets('PriorityBadge renders explicit semantic labels for screen readers', (tester) async {
      await tester.pumpWidget(
        buildTestable(
          const PriorityBadge(tier: AttentionTier.highAttention),
        ),
      );

      final semantics = tester.getSemantics(find.byType(PriorityBadge));
      expect(semantics.label, contains('Attention level: High Attention'));
    });

    testWidgets('ConfidenceBadge renders explicit semantic confidence label', (tester) async {
      await tester.pumpWidget(
        buildTestable(
          const ConfidenceBadge(confidence: ConfidenceLevel.high),
        ),
      );

      final semantics = tester.getSemantics(find.byType(ConfidenceBadge));
      expect(semantics.label, contains('Confidence level: High Confidence'));
    });

    testWidgets('MetricCard provides semantic accessibility node for metrics', (tester) async {
      await tester.pumpWidget(
        buildTestable(
          const MetricCard(
            title: 'High Attention Items',
            value: '3',
            icon: Icons.warning_amber_rounded,
            color: AppColors.error,
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(MetricCard));
      expect(semantics.label, contains('High Attention Items: 3'));
    });

    testWidgets('LegalDisclaimerBanner provides semantic landmark label', (tester) async {
      await tester.pumpWidget(
        buildTestable(
          const LegalDisclaimerBanner(),
        ),
      );

      final semantics = tester.getSemantics(find.byType(LegalDisclaimerBanner));
      expect(semantics.label, contains('Notice:'));
    });

    testWidgets('OptionsPage renders empty placeholder when no document is loaded', (tester) async {
      await tester.pumpWidget(buildTestable(const OptionsPage()));
      await tester.pumpAndSettle();

      expect(find.text('No Document Loaded'), findsOneWidget);
      expect(find.text('Upload Document'), findsOneWidget);
    });

    testWidgets('OptionsPage renders options, choice chips, and actionable steps', (tester) async {
      final mockDoc = LegalDocument(
        id: 'doc_123',
        fileName: 'test_agreement.txt',
        documentType: 'Employment Agreement',
        rawText: 'Employment agreement text...',
        charCount: 200,
        createdAt: DateTime.now(),
        snapshot: const LegalSnapshot(
          documentType: 'Employment Agreement',
          complexity: DocumentComplexity.moderate,
          attentionLevel: AttentionTier.review,
          executiveSummary: 'Executive summary text for test',
          keyAreas: ['Compensation', 'IP'],
          totalClauses: 5,
          highAttentionCount: 1,
          reviewCount: 2,
          informationalCount: 2,
        ),
        clauses: const [],
        obligations: const [],
        dates: const [],
        risks: const [],
        lawyerQuestions: const [],
        checklist: const [],
        options: [
          const LegalOption(
            id: 'opt_1',
            title: 'Sign As-Is',
            category: 'Acceptance',
            summary: 'Accept without modifications.',
            pros: ['Fast'],
            cons: ['High liability'],
            riskProfile: AttentionTier.highAttention,
            actionableSteps: [
              NextStep(
                id: 's1',
                title: 'Review termination dates',
                description: 'Check 30 days notice',
                priority: 'Immediate',
              ),
            ],
            suggestedDraftLanguage: 'I agree to the terms.',
          ),
          const LegalOption(
            id: 'opt_2',
            title: 'Propose Redlines',
            category: 'Negotiation',
            summary: 'Propose standard adjustments.',
            pros: ['Better terms'],
            cons: ['Takes 2 days'],
            riskProfile: AttentionTier.review,
            actionableSteps: [
              NextStep(
                id: 's2',
                title: 'Request 15-day cure',
                description: 'Insert cure period',
                priority: 'Before Signing',
              ),
            ],
            suggestedDraftLanguage: 'Please add a cure period.',
          ),
        ],
      );

      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            documentNotifierProvider.overrideWith((ref) {
              final notifier = DocumentNotifier(
                ref.watch(aiServiceProvider),
                ref.watch(documentRepositoryProvider),
              );
              notifier.setDocument(mockDoc);
              return notifier;
            }),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const OptionsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify header and options
      expect(find.text('Possible Options & Next Steps'), findsOneWidget);
      expect(find.text('Available Options'), findsOneWidget);
      expect(find.text('Option 1: Sign As-Is'), findsOneWidget);
      expect(find.text('Option 2: Propose Redlines'), findsOneWidget);

      // Verify actionable steps checkbox exists
      expect(find.byType(Checkbox), findsWidgets);
    });
  });
}
