import 'package:flutter_test/flutter_test.dart';
import 'package:legallens_ai/services/ai/ai_service.dart';

void main() {
  group('Security & Safe Advisory Phrasing Unit Tests', () {
    late AIService aiService;

    setUp(() {
      aiService = AIService();
    });

    test('AIService sanitizes defamatory and definitive words from clauses', () async {
      // Input document containing problematic terms
      const inputContract = '''
CONFIDENTIALITY AND NON-COMPETE AGREEMENT
This agreement is completely illegal and unlawful under state statutes.
If you breach Section 2, you will lose all severance payments immediately.
''';

      final result = await aiService.analyzeDocument(
        text: inputContract,
        documentType: 'NDA',
        fileName: 'unlawful_sample.txt',
      );

      for (final clause in result.clauses) {
        final lowerConcern = clause.potentialConcern.toLowerCase();
        expect(lowerConcern.contains('illegal'), isFalse,
            reason: 'Defamatory term "illegal" must be scrubbed from potentialConcern');
        expect(lowerConcern.contains('unlawful'), isFalse,
            reason: 'Defamatory term "unlawful" must be scrubbed from potentialConcern');
        expect(lowerConcern.contains('you will lose'), isFalse,
            reason: 'Definitive outcome declaration "you will lose" must be scrubbed');
      }
    });

    test('Anti-Hallucination: Missing dates return "Not detected."', () async {
      const contractWithoutDates = '''
SERVICE CONTRACT
Company agrees to pay Contractor monthly for software design.
Disputes shall be settled by arbitration in New York.
''';

      final result = await aiService.analyzeDocument(
        text: contractWithoutDates,
        documentType: 'Service Agreement',
        fileName: 'no_dates.txt',
      );

      // Verify that dates are either marked Not detected or not falsely fabricated
      for (final date in result.dates) {
        if (!date.isDetected) {
          expect(date.dateString, 'Not detected.');
        }
      }
    });

    test('Safe Language Guidance: Risk recommendations maintain advisory stance', () async {
      const contract = '''
EMPLOYMENT AGREEMENT
Section 8: Employee shall never work for any competitor worldwide for 10 years.
''';

      final result = await aiService.analyzeDocument(
        text: contract,
        documentType: 'Employment Agreement',
        fileName: 'sample.txt',
      );

      for (final risk in result.risks) {
        final rec = risk.recommendedAction.toLowerCase();
        expect(rec.contains('illegal'), isFalse);
        expect(rec.contains('unlawful'), isFalse);
        expect(rec.contains('void'), isFalse);
        expect(rec.contains('you will lose'), isFalse);
        expect(rec.isNotEmpty, isTrue);
      }
    });
  });
}
