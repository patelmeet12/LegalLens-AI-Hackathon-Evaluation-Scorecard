import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:legallens_ai/domain/entities/enums.dart';
import 'package:legallens_ai/domain/entities/legal_entities.dart';
import 'package:legallens_ai/presentation/providers/app_providers.dart';

LegalDocument _buildMockDoc() {
  return LegalDocument(
    id: 'test_doc_p1',
    fileName: 'Employment_Test.txt',
    documentType: 'Employment Agreement',
    rawText: 'Section 1. Compensation is \$150,000. Section 2. Non-compete for 12 months.',
    charCount: 75,
    createdAt: DateTime.now(),
    snapshot: const LegalSnapshot(
      documentType: 'Employment Agreement',
      complexity: DocumentComplexity.moderate,
      attentionLevel: AttentionTier.highAttention,
      executiveSummary: 'Executive summary text.',
      keyAreas: ['Compensation', 'Non-Compete'],
      totalClauses: 2,
      highAttentionCount: 1,
      reviewCount: 0,
      informationalCount: 1,
    ),
    clauses: const [],
    obligations: const [],
    dates: const [],
    risks: const [],
    lawyerQuestions: const [],
    checklist: const [
      ChecklistItem(id: 'c1', title: 'Verify salary', category: 'Pay'),
    ],
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ThemeModeNotifier Unit Tests', () {
    test('Toggles theme mode and respects preferences', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(themeModeProvider.notifier);
      expect(container.read(themeModeProvider), ThemeMode.dark);

      await notifier.toggleTheme();
      expect(container.read(themeModeProvider), ThemeMode.light);

      await notifier.toggleTheme();
      expect(container.read(themeModeProvider), ThemeMode.dark);
    });
  });

  group('SettingsNotifier Unit Tests', () {
    test('Updates demo mode, API key, and clears data', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(settingsNotifierProvider.notifier);
      expect(container.read(settingsNotifierProvider).isDemoMode, true);

      await notifier.setDemoMode(false);
      expect(container.read(settingsNotifierProvider).isDemoMode, false);

      await notifier.setApiKey('gemini_test_key');
      expect(container.read(settingsNotifierProvider).apiKey, 'gemini_test_key');

      await notifier.clearAllData();
      expect(container.read(settingsNotifierProvider).apiKey, isNull);
    });
  });

  group('DocumentNotifier Unit Tests', () {
    test('Sets and clears document state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(documentNotifierProvider.notifier);
      final doc = _buildMockDoc();

      notifier.setDocument(doc);
      expect(container.read(documentNotifierProvider).currentDocument?.id, 'test_doc_p1');
      expect(container.read(documentNotifierProvider).isAnalyzing, false);

      notifier.clearDocument();
      expect(container.read(documentNotifierProvider).currentDocument, isNull);
    });

    test('analyzeDocument with empty text sets error', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(documentNotifierProvider.notifier);
      await notifier.analyzeDocument(
        rawText: '   ',
        documentType: 'General Contract',
        fileName: 'empty.txt',
      );

      final state = container.read(documentNotifierProvider);
      expect(state.isAnalyzing, false);
      expect(state.errorMessage, contains('Document is empty'));
    });

    test('analyzeDocument parses valid text successfully', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(documentNotifierProvider.notifier);
      await notifier.analyzeDocument(
        rawText: 'EMPLOYMENT AGREEMENT. Base salary: \$120,000. Employee agrees to 12 months non-compete.',
        documentType: 'Employment Agreement',
        fileName: 'Valid_Offer.txt',
      );

      final state = container.read(documentNotifierProvider);
      expect(state.isAnalyzing, false);
      expect(state.currentDocument, isNotNull);
      expect(state.currentDocument!.fileName, 'Valid_Offer.txt');
    });
  });

  group('ChecklistNotifier Unit Tests', () {
    test('loadForDocument, toggleItem, and addCustomItem', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(checklistNotifierProvider.notifier);
      final doc = _buildMockDoc();

      await notifier.loadForDocument(doc);
      final state = container.read(checklistNotifierProvider);
      expect(state.items.length, 1);
      expect(state.items.first.isChecked, false);

      // Toggle item
      await notifier.toggleItem('c1');
      expect(container.read(checklistNotifierProvider).items.first.isChecked, true);

      // Add custom item
      await notifier.addCustomItem('Consult attorney on non-compete', 'Legal');
      final updated = container.read(checklistNotifierProvider).items;
      expect(updated.length, 2);
      expect(updated.last.title, 'Consult attorney on non-compete');
      expect(updated.last.isCustom, true);
    });
  });

  group('ComparisonNotifier Unit Tests', () {
    test('compare updates comparison state and clearComparison resets', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(comparisonNotifierProvider.notifier);
      await notifier.compare(
        textA: 'Contract A with salary of \$165,000.',
        nameA: 'Offer_A.txt',
        textB: 'Contract B with salary of \$180,000.',
        nameB: 'Offer_B.txt',
      );

      final state = container.read(comparisonNotifierProvider);
      expect(state.isComparing, false);
      expect(state.comparison, isNotNull);
      expect(state.comparison!.docAName, 'Offer_A.txt');

      notifier.clearComparison();
      expect(container.read(comparisonNotifierProvider).comparison, isNull);
    });
  });

  group('QANotifier Unit Tests', () {
    test('initForDocument, askQuestion, and clearChat', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(qaNotifierProvider.notifier);
      final doc = _buildMockDoc();

      notifier.initForDocument(doc);
      expect(container.read(qaNotifierProvider).messages.length, 1);
      expect(container.read(qaNotifierProvider).messages.first.isUser, false);

      await notifier.askQuestion(question: 'What is my salary?', document: doc);
      final messages = container.read(qaNotifierProvider).messages;
      expect(messages.length, 3); // greeting, user question, AI response
      expect(messages[1].isUser, true);
      expect(messages[2].isUser, false);

      notifier.clearChat();
      expect(container.read(qaNotifierProvider).messages, isEmpty);
    });
  });
}
