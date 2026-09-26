import 'package:flutter_test/flutter_test.dart';
import 'package:legallens_ai/core/constants/app_constants.dart';
import 'package:legallens_ai/services/ai/ai_service.dart';
import 'package:legallens_ai/services/ai/analysis_cache.dart';

void main() {
  group('AnalysisCache Abstraction Unit Tests', () {
    late AnalysisCache cache;

    setUp(() {
      cache = AnalysisCache();
    });

    test('Initial cache state has zero entries, hits, and misses', () {
      expect(cache.size, 0);
      expect(cache.hits, 0);
      expect(cache.misses, 0);
      final diag = cache.getDiagnostics();
      expect(diag['cachedEntries'], 0);
      expect(diag['hitRate'], 0.0);
    });

    test('Key generation is strictly content-addressed and deterministic', () {
      const text1 = 'This is a test contract for Software Services.';
      const text2 = 'This is a test contract for Software Services.';
      const text3 = 'This is a test contract for Software Services. Modified.';

      final key1 = AnalysisCache.computeKey(text: text1, documentType: 'Service');
      final key2 = AnalysisCache.computeKey(text: text2, documentType: 'Service');
      final key3 = AnalysisCache.computeKey(text: text3, documentType: 'Service');
      final keyNoType = AnalysisCache.computeKey(text: text1);

      expect(key1, equals(key2));
      expect(key1, isNot(equals(key3)));
      expect(key1, isNot(equals(keyNoType)));
      expect(key1.length, 64); // Valid SHA-256 hex string
    });

    test('Put, get, contains, and hit/miss diagnostic tracking', () async {
      final aiService = AIService();
      final sampleResult = await aiService.analyzeDocument(
        text: AppConstants.sampleNdaAgreement,
        documentType: 'NDA',
        fileName: 'sample_nda.txt',
      );

      expect(cache.contains(text: AppConstants.sampleNdaAgreement, documentType: 'NDA'), isFalse);
      expect(cache.get(text: AppConstants.sampleNdaAgreement, documentType: 'NDA'), isNull);
      expect(cache.misses, 1);
      expect(cache.hits, 0);

      cache.put(
        text: AppConstants.sampleNdaAgreement,
        result: sampleResult,
        documentType: 'NDA',
      );

      expect(cache.size, 1);
      expect(cache.contains(text: AppConstants.sampleNdaAgreement, documentType: 'NDA'), isTrue);

      final retrieved = cache.get(text: AppConstants.sampleNdaAgreement, documentType: 'NDA');
      expect(retrieved, isNotNull);
      expect(retrieved!.snapshot.documentType, sampleResult.snapshot.documentType);
      expect(cache.hits, 1);

      final diag = cache.getDiagnostics();
      expect(diag['cachedEntries'], 1);
      expect(diag['hits'], 1);
      expect(diag['misses'], 1);
      expect(diag['hitRate'], 0.5);

      cache.clear();
      expect(cache.size, 0);
      expect(cache.hits, 0);
      expect(cache.misses, 0);
    });

    test('Independent documents with same name produce different cache entries based on content', () async {
      final aiService = AIService();
      const contentA = 'Employment agreement version A with salary \$100,000.';
      const contentB = 'Employment agreement version B with salary \$150,000.';

      final resA = await aiService.analyzeDocument(
        text: contentA,
        documentType: 'Employment Agreement',
        fileName: 'same_filename.txt',
      );
      final resB = await aiService.analyzeDocument(
        text: contentB,
        documentType: 'Employment Agreement',
        fileName: 'same_filename.txt',
      );

      cache.put(text: contentA, result: resA, documentType: 'Employment Agreement');
      cache.put(text: contentB, result: resB, documentType: 'Employment Agreement');

      expect(cache.size, 2);
      expect(
        cache.get(text: contentA, documentType: 'Employment Agreement'),
        isNot(same(cache.get(text: contentB, documentType: 'Employment Agreement'))),
      );
    });
  });

  group('AIService Cache Integration & Scaled Performance Tests', () {
    late AIService aiService;

    setUp(() {
      aiService = AIService();
    });

    test('First analysis parses document and populates memoization cache', () async {
      expect(aiService.cachedAnalysisCount, 0);

      final result1 = await aiService.analyzeDocument(
        text: AppConstants.sampleEmploymentAgreement,
        documentType: 'Employment Agreement',
        fileName: 'contract.txt',
      );

      expect(result1.clauses.isNotEmpty, isTrue);
      expect(aiService.cachedAnalysisCount, 1);
      expect(
        aiService.isCached('Employment Agreement', AppConstants.sampleEmploymentAgreement),
        isTrue,
      );
    });

    test('Repeated identical analysis uses cache without reprocessing', () async {
      // Warm cache
      await aiService.analyzeDocument(
        text: AppConstants.sampleLeaseAgreement,
        documentType: 'Rental Agreement',
        fileName: 'lease.txt',
      );
      expect(aiService.cachedAnalysisCount, 1);

      final initialHits = aiService.cacheHits;

      // Second identical call
      final cachedResult = await aiService.analyzeDocument(
        text: AppConstants.sampleLeaseAgreement,
        documentType: 'Rental Agreement',
        fileName: 'different_filename.txt', // Filename differs, content is identical
      );

      expect(aiService.cacheHits, initialHits + 1);
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

    // Scaled performance benchmarks (10 KB, 100 KB, 500 KB, 1 MB)
    test('Performance: 10 KB document analysis completes, caches, and verifies cache hit', () async {
      const baseBlock = '${AppConstants.sampleEmploymentAgreement}\n\n';
      // Build ~10 KB document
      final buffer = StringBuffer();
      while (buffer.length < 10 * 1024) {
        buffer.write(baseBlock);
      }
      final doc10kb = buffer.toString();
      expect(doc10kb.length, greaterThanOrEqualTo(10 * 1024));

      final sw = Stopwatch()..start();
      final result = await aiService.analyzeDocument(
        text: doc10kb,
        documentType: 'Employment Agreement',
        fileName: 'doc_10kb.txt',
      );
      sw.stop();

      expect(result.clauses.isNotEmpty, isTrue);
      expect(aiService.isCached('Employment Agreement', doc10kb), isTrue);

      // Verify repeated call uses cache
      final hitsBefore = aiService.cacheHits;
      final cachedResult = await aiService.analyzeDocument(
        text: doc10kb,
        documentType: 'Employment Agreement',
        fileName: 'doc_10kb.txt',
      );
      expect(aiService.cacheHits, hitsBefore + 1);
      expect(cachedResult.snapshot.totalClauses, result.snapshot.totalClauses);
    });

    test('Performance: 100 KB document analysis completes and caches deterministically', () async {
      const baseBlock = '${AppConstants.sampleLeaseAgreement}\n\n';
      final buffer = StringBuffer();
      while (buffer.length < 100 * 1024) {
        buffer.write(baseBlock);
      }
      final doc100kb = buffer.toString();
      expect(doc100kb.length, greaterThanOrEqualTo(100 * 1024));

      final result = await aiService.analyzeDocument(
        text: doc100kb,
        documentType: 'Rental / Lease Agreement',
        fileName: 'doc_100kb.txt',
      );

      expect(result.clauses.isNotEmpty, isTrue);
      expect(result.dates.isNotEmpty, isTrue);
      expect(aiService.isCached('Rental / Lease Agreement', doc100kb), isTrue);

      // Cache hit check
      final hitsBefore = aiService.cacheHits;
      await aiService.analyzeDocument(
        text: doc100kb,
        documentType: 'Rental / Lease Agreement',
        fileName: 'doc_100kb.txt',
      );
      expect(aiService.cacheHits, hitsBefore + 1);
    });

    test('Performance: 500 KB document analysis completes without crash or memory fault', () async {
      const baseBlock = '${AppConstants.sampleEmploymentContract}\n\n';
      final buffer = StringBuffer();
      while (buffer.length < 500 * 1024) {
        buffer.write(baseBlock);
      }
      final doc500kb = buffer.toString();
      expect(doc500kb.length, greaterThanOrEqualTo(500 * 1024));

      final result = await aiService.analyzeDocument(
        text: doc500kb,
        documentType: 'Employment Agreement',
        fileName: 'doc_500kb.txt',
      );

      expect(result.snapshot.totalClauses, greaterThan(0));
      expect(result.risks.length, 6);
      expect(aiService.isCached('Employment Agreement', doc500kb), isTrue);
    });

    test('Performance: 1 MB document analysis completes deterministically', () async {
      const baseBlock =
          'SECTION 1. DEFINITIONS AND TERMS. The parties agree to confidentiality, payment, termination notice of 90 days, and non-compete for 12 months.\n\n';
      final buffer = StringBuffer();
      while (buffer.length < 1024 * 1024) {
        buffer.write(baseBlock);
      }
      final doc1mb = buffer.toString();
      expect(doc1mb.length, greaterThanOrEqualTo(1024 * 1024));

      final result = await aiService.analyzeDocument(
        text: doc1mb,
        documentType: 'General Contract',
        fileName: 'doc_1mb.txt',
      );

      expect(result.clauses, isNotEmpty);
      expect(result.snapshot.complexity.name, isNotEmpty);
      expect(aiService.isCached('General Contract', doc1mb), isTrue);

      // Verify clearing cache invalidates this 1 MB entry
      aiService.clearCache();
      expect(aiService.isCached('General Contract', doc1mb), isFalse);
    });
  });
}
