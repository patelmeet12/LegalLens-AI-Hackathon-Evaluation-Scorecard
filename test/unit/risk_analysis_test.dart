import 'package:flutter_test/flutter_test.dart';
import 'package:legallens_ai/domain/entities/enums.dart';
import 'package:legallens_ai/services/ai/demo/clause_detector.dart';
import 'package:legallens_ai/services/ai/demo/risk_analyzer.dart';

void main() {
  group('RiskAnalyzer Unit Tests (6-Category Radar)', () {
    late RiskAnalyzer analyzer;
    late ClauseDetector clauseDetector;

    setUp(() {
      analyzer = RiskAnalyzer();
      clauseDetector = ClauseDetector();
    });

    test('Always generates exactly 6 risk items covering all standard risk categories', () {
      const text = 'Standard agreement between parties.';
      final clauses = clauseDetector.detect(text, text.toLowerCase());
      final risks = analyzer.analyze(text, text.toLowerCase(), clauses);

      expect(risks.length, 6);
      final categories = risks.map((r) => r.category).toSet();
      expect(categories.contains(RiskCategory.financial), isTrue);
      expect(categories.contains(RiskCategory.employment), isTrue);
      expect(categories.contains(RiskCategory.privacy), isTrue);
      expect(categories.contains(RiskCategory.liability), isTrue);
      expect(categories.contains(RiskCategory.intellectualProperty), isTrue);
      expect(categories.contains(RiskCategory.restrictions), isTrue);
    });

    test('Financial risk elevates to review when penalties or late fees are present', () {
      const text = 'Any delayed delivery triggers a penalty and late fee deduction of \$200 per day.';
      final clauses = clauseDetector.detect(text, text.toLowerCase());
      final risks = analyzer.analyze(text, text.toLowerCase(), clauses);

      final financial = risks.firstWhere((r) => r.category == RiskCategory.financial);
      expect(financial.attentionLevel, AttentionTier.review);
      expect(financial.explanation, contains('penalties'));
    });

    test('Employment risk elevates to highAttention on 90-day notice requirement', () {
      const text = 'Termination requires 90 days notice in writing.';
      final clauses = clauseDetector.detect(text, text.toLowerCase());
      final risks = analyzer.analyze(text, text.toLowerCase(), clauses);

      final employment = risks.firstWhere((r) => r.category == RiskCategory.employment);
      expect(employment.attentionLevel, AttentionTier.highAttention);
      expect(employment.explanation, contains('90-day'));
    });

    test('Liability risk elevates to highAttention on broad indemnity clause', () {
      const text = 'Employee shall indemnify and hold harmless the Company against all third party claims.';
      final clauses = clauseDetector.detect(text, text.toLowerCase());
      final risks = analyzer.analyze(text, text.toLowerCase(), clauses);

      final liability = risks.firstWhere((r) => r.category == RiskCategory.liability);
      expect(liability.attentionLevel, AttentionTier.highAttention);
      expect(liability.recommendedAction, contains('gross negligence'));
    });

    test('IP risk elevates to highAttention when claiming inventions created at home / personal time', () {
      const text = 'All inventions created at home or outside standard working hours belong to Company.';
      final clauses = clauseDetector.detect(text, text.toLowerCase());
      final risks = analyzer.analyze(text, text.toLowerCase(), clauses);

      final ipRisk = risks.firstWhere((r) => r.category == RiskCategory.intellectualProperty);
      expect(ipRisk.attentionLevel, AttentionTier.highAttention);
      expect(ipRisk.recommendedAction, contains('personal side-projects'));
    });

    test('Safe language: risks contain zero defamatory or categorical legal conclusions', () {
      const text = 'Employee agrees to 90 days notice, broad indemnification, and nationwide non-compete for 2 years.';
      final clauses = clauseDetector.detect(text, text.toLowerCase());
      final risks = analyzer.analyze(text, text.toLowerCase(), clauses);

      for (final r in risks) {
        final combined = '${r.explanation} ${r.recommendedAction}'.toLowerCase();
        expect(combined.contains('definitely illegal'), isFalse);
        expect(combined.contains('you will definitely lose'), isFalse);
        expect(combined.contains('you must sue'), isFalse);
        expect(combined.contains('market standard'), isFalse);
      }
    });
  });
}
