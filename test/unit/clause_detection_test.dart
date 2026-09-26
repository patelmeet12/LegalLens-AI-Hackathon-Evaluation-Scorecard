import 'package:flutter_test/flutter_test.dart';
import 'package:legallens_ai/domain/entities/enums.dart';
import 'package:legallens_ai/domain/entities/legal_entities.dart';
import 'package:legallens_ai/services/ai/demo/clause_detector.dart';

void main() {
  group('ClauseDetector Unit Tests (15 Standard Categories)', () {
    late ClauseDetector detector;

    setUp(() {
      detector = ClauseDetector();
    });

    test('All 15 default rules are registered in the registry', () {
      expect(detector.rules.length, 15);
      final categories = detector.rules.map((r) => r.category).toSet();
      expect(categories.contains('Payment'), isTrue);
      expect(categories.contains('Termination'), isTrue);
      expect(categories.contains('Notice'), isTrue);
      expect(categories.contains('Confidentiality'), isTrue);
      expect(categories.contains('Intellectual Property'), isTrue);
      expect(categories.contains('Non-Compete'), isTrue);
      expect(categories.contains('Non-Solicitation'), isTrue);
      expect(categories.contains('Indemnity'), isTrue);
      expect(categories.contains('Liability'), isTrue);
      expect(categories.contains('Dispute Resolution'), isTrue);
      expect(categories.contains('Governing Law'), isTrue);
      expect(categories.contains('Renewal'), isTrue);
      expect(categories.contains('Penalties'), isTrue);
      expect(categories.contains('Refunds'), isTrue);
      expect(categories.contains('Data Privacy'), isTrue);
    });

    test('Positive: Payment clause detected when text contains salary or compensation', () {
      const text = 'Employee shall receive an annual base salary of \$140,000 paid semi-monthly.';
      final clauses = detector.detect(text, text.toLowerCase());
      expect(clauses.any((c) => c.category == 'Payment'), isTrue);
      final payment = clauses.firstWhere((c) => c.category == 'Payment');
      expect(payment.importance, AttentionTier.informational);
      expect(payment.confidence, ConfidenceLevel.high);
    });

    test('Positive: Termination clause with 90-day notice elevates to highAttention', () {
      const text = 'Either party may terminate upon 90 days notice in writing.';
      final clauses = detector.detect(text, text.toLowerCase());
      expect(clauses.any((c) => c.category == 'Termination'), isTrue);
      final term = clauses.firstWhere((c) => c.category == 'Termination');
      expect(term.importance, AttentionTier.highAttention);
      expect(term.potentialConcern, contains('90 days\' notice'));
    });

    test('Positive: Non-Compete clause always requires high attention', () {
      const text = 'Executive covenants not to compete directly in the field of cloud computing.';
      final clauses = detector.detect(text, text.toLowerCase());
      expect(clauses.any((c) => c.category == 'Non-Compete'), isTrue);
      final nonCompete = clauses.firstWhere((c) => c.category == 'Non-Compete');
      expect(nonCompete.importance, AttentionTier.highAttention);
      expect(nonCompete.potentialConcern, contains('Requires attention'));
    });

    test('Positive: Indemnity clause identified with highAttention', () {
      const text = 'The contractor shall indemnify and hold harmless the client against all liabilities.';
      final clauses = detector.detect(text, text.toLowerCase());
      expect(clauses.any((c) => c.category == 'Indemnity'), isTrue);
      final indemnity = clauses.firstWhere((c) => c.category == 'Indemnity');
      expect(indemnity.importance, AttentionTier.highAttention);
    });

    test('Positive: Lease-specific categories (Penalties, Refunds, Renewal)', () {
      const text = 'Tenant shall pay a late fee penalty of \$50. A security deposit of \$2,000 will be refunded upon inspection. Lease will renew automatically month-to-month.';
      final clauses = detector.detect(text, text.toLowerCase());
      expect(clauses.any((c) => c.category == 'Penalties'), isTrue);
      expect(clauses.any((c) => c.category == 'Refunds'), isTrue);
      expect(clauses.any((c) => c.category == 'Renewal'), isTrue);
    });

    test('Positive: Data Privacy & Governance detected on GDPR or personal data', () {
      const text = 'Company enforces GDPR compliance for processing of user personal information.';
      final clauses = detector.detect(text, text.toLowerCase());
      expect(clauses.any((c) => c.category == 'Data Privacy'), isTrue);
    });

    test('Negative: Non-compete NOT detected in pure non-disclosure agreement', () {
      const text = 'The receiving party agrees to keep all trade secrets confidential without disclosure.';
      final clauses = detector.detect(text, text.toLowerCase());
      expect(clauses.any((c) => c.category == 'Confidentiality'), isTrue);
      expect(clauses.any((c) => c.category == 'Non-Compete'), isFalse);
      expect(clauses.any((c) => c.category == 'Penalties'), isFalse);
    });

    test('Edge case: Completely unrelated text defaults gracefully to General Contract fallback clause', () {
      const text = 'The quick brown fox jumps over the lazy dog in an open field.';
      final clauses = detector.detect(text, text.toLowerCase());
      expect(clauses.length, 1);
      expect(clauses.first.category, 'General Contract');
      expect(clauses.first.title, 'General Terms & Mutual Agreement');
      expect(clauses.first.confidence, ConfidenceLevel.high);
    });

    test('Registry Extensibility: custom rule can be registered and detected', () {
      final customRule = ClauseRule(
        category: 'Custom ESG',
        title: 'Environmental Sustainability Commitment',
        defaultImportance: AttentionTier.informational,
        keywords: const ['carbon neutral', 'esg commitment'],
        snippetTargets: const ['carbon neutral'],
        builder: ({required id, required rawText, required normalizedText, required snippet}) {
          return LegalClause(
            id: id,
            title: 'Environmental Sustainability Commitment',
            category: 'Custom ESG',
            importance: AttentionTier.informational,
            originalText: snippet.isNotEmpty ? snippet : rawText,
            plainLanguageExplanation: 'Parties agree to meet carbon neutral targets.',
            whyItMatters: 'Ensures environmental regulatory alignment.',
            potentialConcern: '',
            recommendedReview: 'Verify reporting timelines.',
          );
        },
      );

      final customDetector = ClauseDetector(rules: [...detector.rules, customRule]);
      expect(customDetector.rules.length, 16);

      const testDoc = 'The supplier agrees to remain carbon neutral throughout the lifecycle.';
      final clauses = customDetector.detect(testDoc, testDoc.toLowerCase());
      expect(clauses.any((c) => c.category == 'Custom ESG'), isTrue);
    });
  });
}
