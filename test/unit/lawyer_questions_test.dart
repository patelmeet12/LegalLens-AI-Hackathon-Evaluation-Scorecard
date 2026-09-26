import 'package:flutter_test/flutter_test.dart';
import 'package:legallens_ai/domain/entities/enums.dart';
import 'package:legallens_ai/services/ai/demo/clause_detector.dart';
import 'package:legallens_ai/services/ai/demo/lawyer_question_generator.dart';
import 'package:legallens_ai/services/ai/demo/risk_analyzer.dart';

void main() {
  group('LawyerQuestionGenerator Unit Tests', () {
    late LawyerQuestionGenerator generator;
    late ClauseDetector clauseDetector;
    late RiskAnalyzer riskAnalyzer;

    setUp(() {
      generator = LawyerQuestionGenerator();
      clauseDetector = ClauseDetector();
      riskAnalyzer = RiskAnalyzer();
    });

    test('Generates targeted questions for each high-attention clause category', () {
      const highAttentionContract = '''
Termination requires 90 days notice.
Executive shall not compete directly in cloud services for 12 months.
All inventions created at home or outside standard working hours belong to Company.
Employee shall indemnify and hold harmless the Company.
''';

      final clauses = clauseDetector.detect(highAttentionContract, highAttentionContract.toLowerCase());
      final risks = riskAnalyzer.analyze(highAttentionContract, highAttentionContract.toLowerCase(), clauses);
      final questions = generator.generate(clauses, risks);

      expect(questions.length, greaterThanOrEqualTo(3));
      final categories = questions.map((q) => q.category).toSet();

      expect(categories.contains('Non-Compete Enforceability'), isTrue);
      expect(categories.contains('IP Carve-Outs'), isTrue);
      expect(categories.contains('Liability Exposure'), isTrue);
      expect(categories.contains('Notice & Exit Flexibility'), isTrue);

      for (final q in questions) {
        expect(q.id.startsWith('lq_'), isTrue);
        expect(q.question.isNotEmpty, isTrue);
        expect(q.contextReason.isNotEmpty, isTrue);
        expect(q.sourceClause.isNotEmpty, isTrue);
      }
    });

    test('Fallback question provided when agreement contains zero high-attention clauses', () {
      const simpleDoc = 'This is a simple mutual confidentiality agreement with no non-compete or indemnification.';
      final clauses = clauseDetector.detect(simpleDoc, simpleDoc.toLowerCase());
      final risks = riskAnalyzer.analyze(simpleDoc, simpleDoc.toLowerCase(), clauses);

      final filteredClauses = clauses.where((c) => c.importance != AttentionTier.highAttention).toList();
      final questions = generator.generate(filteredClauses, risks);

      expect(questions.length, 1);
      expect(questions.first.category, 'Dispute Terms');
      expect(questions.first.question, contains('arbitration terms'));
    });
  });
}
