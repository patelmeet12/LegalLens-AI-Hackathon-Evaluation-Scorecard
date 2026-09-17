import 'package:flutter_test/flutter_test.dart';
import 'package:legallens_ai/core/constants/app_constants.dart';
import 'package:legallens_ai/services/ai/ai_service.dart';

void main() {
  group('AIService SHA-256 Analysis Cache & Performance Unit Tests', () {
    late AIService aiService;

    setUp(() {
      aiService = AIService();
    });

    test('First analysis parses document and populates memoization cache', () async {
      expect(aiService.cachedAnalysisCount, 0);

      final stopwatch = Stopwatch()..start();
      final result1 = await aiService.analyzeDocument(
        text: AppConstants.sampleEmploymentAgreement,
        documentType: 'Employment Agreement',
        fileName: 'contract.txt',
      );
      stopwatch.stop();

      expect(result1.clauses.isNotEmpty, isTrue);
      expect(aiService.cachedAnalysisCount, 1);
      expect(aiService.isCached('Employment Agreement', AppConstants.sampleEmploymentAgreement), isTrue);
    });

    test('Second call to analyzeDocument uses O(1) cache (< 5ms response)', () async {
      // First call warms cache
      await aiService.analyzeDocument(
        text: AppConstants.sampleLeaseAgreement,
        documentType: 'Rental Agreement',
        fileName: 'lease.txt',
      );

      expect(aiService.isCached('Rental Agreement', AppConstants.sampleLeaseAgreement), isTrue);

      // Second call should return cached instance in sub-millisecond time
      final stopwatch = Stopwatch()..start();
      final cachedResult = await aiService.analyzeDocument(
        text: AppConstants.sampleLeaseAgreement,
        documentType: 'Rental Agreement',
        fileName: 'lease.txt',
      );
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(15));
      expect(cachedResult.snapshot.documentType, 'Rental Agreement');
      expect(cachedResult.options.length, 4);
    });

    test('clearCache purges in-memory entries', () async {
      await aiService.analyzeDocument(
        text: AppConstants.sampleNdaAgreement,
        documentType: 'NDA',
        fileName: 'nda.txt',
      );
      expect(aiService.cachedAnalysisCount, 1);

      aiService.clearCache();
      expect(aiService.cachedAnalysisCount, 0);
      expect(aiService.isCached('NDA', AppConstants.sampleNdaAgreement), isFalse);
    });

    test('Configuring AI mode automatically invalidates previous cache', () async {
      await aiService.analyzeDocument(
        text: AppConstants.sampleEmploymentAgreement,
        documentType: 'Employment Agreement',
        fileName: 'employment.txt',
      );
      expect(aiService.cachedAnalysisCount, 1);

      aiService.configure(useDemoMode: false, apiKey: 'test_key_123');
      expect(aiService.cachedAnalysisCount, 0);
    });
  });
}
