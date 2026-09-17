import 'package:flutter_test/flutter_test.dart';
import 'package:legallens_ai/core/constants/app_constants.dart';
import 'package:legallens_ai/domain/entities/enums.dart';
import 'package:legallens_ai/domain/entities/legal_entities.dart';
import 'package:legallens_ai/services/ai/demo_ai_provider.dart';

void main() {
  late DemoAIProvider provider;

  setUp(() {
    provider = DemoAIProvider();
  });

  group('Clause Intelligence Unit Tests', () {
    test('Extracts critical clauses with original text, plain explanation, and why it matters', () async {
      final result = await provider.analyzeDocument(
        text: AppConstants.sampleEmploymentContract,
        documentType: 'Employment Agreement',
        fileName: 'Sample_Tech_Employment.txt',
      );

      expect(result.clauses.isNotEmpty, isTrue);

      // Check Payment clause
      final payment = result.clauses.firstWhere((c) => c.category == 'Payment');
      expect(payment.originalText.isNotEmpty, isTrue);
      expect(payment.plainLanguageExplanation.isNotEmpty, isTrue);
      expect(payment.whyItMatters.isNotEmpty, isTrue);

      // Check Non-Compete clause
      final nonCompete = result.clauses.firstWhere((c) => c.category == 'Non-Compete');
      expect(nonCompete.importance, AttentionTier.highAttention);
      expect(nonCompete.potentialConcern, contains('Requires attention'));

      // Check Intellectual Property clause
      final ip = result.clauses.firstWhere((c) => c.category == 'Intellectual Property');
      expect(ip.importance, AttentionTier.highAttention);
      expect(ip.plainLanguageExplanation, contains('belong to the company'));
    });

    test('Identifies lease specific clauses like Penalties, Refunds, and Renewal', () async {
      final result = await provider.analyzeDocument(
        text: AppConstants.sampleLeaseAgreement,
        documentType: 'Rental / Lease Agreement',
        fileName: 'Sample_Lease.txt',
      );

      final categories = result.clauses.map((c) => c.category).toSet();
      expect(categories.contains('Penalties') || categories.contains('Payment'), isTrue);
      expect(categories.contains('Renewal'), isTrue);
      expect(categories.contains('Refunds'), isTrue);
    });
  });

  group('Obligation Extractor Unit Tests', () {
    test('Tri-partitions obligations into Your, Other Party, and Shared responsibilities', () async {
      final result = await provider.analyzeDocument(
        text: AppConstants.sampleEmploymentContract,
        documentType: 'Employment Agreement',
        fileName: 'Sample_Employment.txt',
      );

      final yourObs = result.obligations.where((o) => o.party == ObligationParty.your).toList();
      final otherObs = result.obligations.where((o) => o.party == ObligationParty.otherParty).toList();
      final sharedObs = result.obligations.where((o) => o.party == ObligationParty.shared).toList();

      expect(yourObs.isNotEmpty, isTrue);
      expect(otherObs.isNotEmpty, isTrue);
      expect(sharedObs.isNotEmpty, isTrue);

      expect(yourObs.any((o) => o.description.contains('notice') || o.description.contains('confidentiality')), isTrue);
      expect(otherObs.any((o) => o.description.contains('salary')), isTrue);
    });
  });

  group('Date Extractor & Anti-Hallucination Safeguards', () {
    test('Extracts stated dates and returns "Not detected." for absent dates', () async {
      final result = await provider.analyzeDocument(
        text: AppConstants.sampleEmploymentContract,
        documentType: 'Employment Agreement',
        fileName: 'Sample_Employment.txt',
      );

      final effDate = result.dates.firstWhere((d) => d.type == 'Contract Start');
      expect(effDate.isDetected, isTrue);
      expect(effDate.dateString, contains('October 1, 2025'));

      // If document lacks expiration, it MUST return "Not detected."
      final expDate = result.dates.firstWhere((d) => d.type == 'Expiration');
      expect(expDate.dateString, AppConstants.notDetectedDate);
      expect(expDate.isDetected, isFalse);
    });

    test('Never fabricates dates in empty or ambiguous text', () async {
      final result = await provider.analyzeDocument(
        text: 'This is a brief general note between two parties without dates.',
        documentType: 'General Contract',
        fileName: 'Simple.txt',
      );

      final start = result.dates.firstWhere((d) => d.type == 'Contract Start');
      expect(start.isDetected, isFalse);
      expect(start.dateString, AppConstants.notDetectedDate);
    });
  });

  group('Risk Classification & Safe Advisory Language', () {
    test('Evaluates 6 risk categories without defamatory or definitive legal conclusions', () async {
      final result = await provider.analyzeDocument(
        text: AppConstants.sampleEmploymentContract,
        documentType: 'Employment Agreement',
        fileName: 'Sample_Employment.txt',
      );

      expect(result.risks.length, 6);

      for (final r in result.risks) {
        // Assert no prohibited absolute phrases
        expect(r.explanation.toLowerCase(), isNot(contains('illegal')));
        expect(r.explanation.toLowerCase(), isNot(contains('unlawful')));
        expect(r.explanation.toLowerCase(), isNot(contains('you will lose')));
      }

      final nonCompeteRisk = result.risks.firstWhere((r) => r.category == RiskCategory.restrictions);
      expect(nonCompeteRisk.attentionLevel, AttentionTier.highAttention);
      expect(nonCompeteRisk.explanation, contains('Requires attention'));
    });
  });

  group('Document Grounded Q&A Unit Tests', () {
    late LegalDocument doc;

    setUp(() async {
      final res = await provider.analyzeDocument(
        text: AppConstants.sampleEmploymentContract,
        documentType: 'Employment Agreement',
        fileName: 'Sample_Employment.txt',
      );

      doc = LegalDocument(
        id: 'test_doc_1',
        fileName: 'Sample_Employment.txt',
        documentType: res.snapshot.documentType,
        rawText: AppConstants.sampleEmploymentContract,
        charCount: AppConstants.sampleEmploymentContract.length,
        createdAt: DateTime.now(),
        snapshot: res.snapshot,
        clauses: res.clauses,
        obligations: res.obligations,
        dates: res.dates,
        risks: res.risks,
        lawyerQuestions: res.lawyerQuestions,
        checklist: res.checklist,
      );
    });

    test('Answers questions present in the document and attaches citations', () async {
      final response = await provider.answerQuestion(
        question: 'How much notice do I need to give if I resign?',
        document: doc,
        previousHistory: [],
      );

      expect(response.isRefusal, isFalse);
      expect(response.text, contains('90'));
      expect(response.citations.isNotEmpty, isTrue);
    });

    test('Answers IP ownership inquiry grounded in Section 5', () async {
      final response = await provider.answerQuestion(
        question: 'Who owns the work I create?',
        document: doc,
        previousHistory: [],
      );

      expect(response.isRefusal, isFalse);
      expect(response.text.toLowerCase(), contains('works made for hire'));
      expect(response.citations.any((c) => c.contains('Intellectual Property')), isTrue);
    });

    test('Refuses to answer unmentioned and hallucinatory queries', () async {
      final response = await provider.answerQuestion(
        question: 'Can I bring my pet dog to Mars on weekends?',
        document: doc,
        previousHistory: [],
      );

      expect(response.isRefusal, isTrue);
      expect(response.text, AppConstants.noHallucinationRefusal);
      expect(response.citations.isEmpty, isTrue);
    });
  });

  group('Contract Comparison Unit Tests', () {
    test('Identifies diffs in compensation, notice, non-compete, and severance', () async {
      final comparison = await provider.compareDocuments(
        textA: AppConstants.sampleComparisonOfferA,
        nameA: 'Offer Option A',
        textB: AppConstants.sampleComparisonOfferB,
        nameB: 'Offer Option B',
      );

      expect(comparison.changedClauses.isNotEmpty, isTrue);
      expect(comparison.changedFinancialTerms.isNotEmpty, isTrue);
      expect(comparison.changedDates.isNotEmpty, isTrue);
      expect(comparison.highAttentionDifferences.isNotEmpty, isTrue);

      final nonCompeteDiff = comparison.changedClauses.firstWhere((c) => c.clauseTitle.contains('Non-Compete'));
      expect(nonCompeteDiff.differenceTier, AttentionTier.highAttention);
      expect(nonCompeteDiff.changeSummary, contains('Option B'));
    });
  });

  group('Action Center & Lawyer Questions Unit Tests', () {
    test('Generates actionable checklist and tailored lawyer questions', () async {
      final result = await provider.analyzeDocument(
        text: AppConstants.sampleEmploymentContract,
        documentType: 'Employment Agreement',
        fileName: 'Sample_Employment.txt',
      );

      expect(result.checklist.isNotEmpty, isTrue);
      expect(result.lawyerQuestions.isNotEmpty, isTrue);

      expect(result.lawyerQuestions.any((q) => q.question.contains('non-compete') || q.question.contains('IP')), isTrue);
    });
  });
}
