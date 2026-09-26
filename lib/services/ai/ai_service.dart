import '../../domain/entities/legal_entities.dart';
import 'ai_provider.dart';
import 'analysis_cache.dart';
import 'demo_ai_provider.dart';
import 'gemini_ai_provider.dart';

/// Application AI Service acting as the single gateway for document analysis,
/// question answering, and contract comparison.
/// Coordinates between Demo AI (local) and Gemini AI (remote), with integrated
/// deterministic SHA-256 caching and safety sanitization.
class AIService {
  final DemoAIProvider _demoProvider = DemoAIProvider();
  GeminiAIProvider? _geminiProvider;
  bool _useDemoMode = true;

  /// Dedicated in-memory content-addressed cache
  final AnalysisCache _analysisCache = AnalysisCache();

  AIService({bool useDemoMode = true, String? apiKey}) {
    _useDemoMode = useDemoMode;
    if (apiKey != null && apiKey.isNotEmpty) {
      _geminiProvider = GeminiAIProvider(apiKey: apiKey);
    }
  }

  bool get isDemoMode => _useDemoMode;
  bool get hasRealConfigured => _geminiProvider?.isConfigured ?? false;
  int get cachedAnalysisCount => _analysisCache.size;
  int get cacheHits => _analysisCache.hits;
  int get cacheMisses => _analysisCache.misses;
  Map<String, dynamic> get cacheDiagnostics => _analysisCache.getDiagnostics();

  void configure({required bool useDemoMode, String? apiKey}) {
    _useDemoMode = useDemoMode;
    if (apiKey != null && apiKey.trim().isNotEmpty) {
      _geminiProvider = GeminiAIProvider(apiKey: apiKey.trim());
    } else {
      _geminiProvider = null;
    }
    // Clear cache when AI configuration changes
    clearCache();
  }

  void clearCache() {
    _analysisCache.clear();
  }

  bool isCached(String documentType, String text) {
    return _analysisCache.contains(text: text, documentType: documentType);
  }

  AIProvider get _activeProvider {
    if (!_useDemoMode && _geminiProvider != null && _geminiProvider!.isConfigured) {
      return _geminiProvider!;
    }
    return _demoProvider;
  }

  String get activeProviderName => _activeProvider.name;

  Future<LegalAnalysisResult> analyzeDocument({
    required String text,
    required String documentType,
    required String fileName,
  }) async {
    // 1. Check content-addressed cache first
    final cached = _analysisCache.get(text: text, documentType: documentType);
    if (cached != null) {
      return cached;
    }

    // 2. Perform fresh analysis via active provider
    final result = await _activeProvider.analyzeDocument(
      text: text,
      documentType: documentType,
      fileName: fileName,
    );

    // 3. Safeguard validation: ensure safe, non-defamatory, non-conclusive legal language
    final sanitized = _sanitizeAnalysisResult(result);

    // 4. Cache sanitized result
    _analysisCache.put(text: text, result: sanitized, documentType: documentType);
    return sanitized;
  }

  Future<QAMessage> answerQuestion({
    required String question,
    required LegalDocument document,
    required List<QAMessage> previousHistory,
  }) async {
    return _activeProvider.answerQuestion(
      question: question,
      document: document,
      previousHistory: previousHistory,
    );
  }

  Future<DocumentComparison> compareDocuments({
    required String textA,
    required String nameA,
    required String textB,
    required String nameB,
  }) async {
    return _activeProvider.compareDocuments(
      textA: textA,
      nameA: nameA,
      textB: textB,
      nameB: nameB,
    );
  }

  LegalAnalysisResult _sanitizeAnalysisResult(LegalAnalysisResult result) {
    // Ensure all clauses use safe, jurisdiction-neutral language
    final safeClauses = result.clauses.map((clause) {
      final String potential = clause.potentialConcern
          .replaceAll(RegExp(r'\billegal\b', caseSensitive: false), 'potentially non-standard')
          .replaceAll(
              RegExp(r'\bunlawful\b', caseSensitive: false), 'subject to jurisdictional limitations')
          .replaceAll(RegExp(r'\byou will lose\b', caseSensitive: false), 'may present dispute risks');

      return LegalClause(
        id: clause.id,
        title: clause.title,
        category: clause.category,
        importance: clause.importance,
        originalText: clause.originalText,
        plainLanguageExplanation: clause.plainLanguageExplanation,
        whyItMatters: clause.whyItMatters,
        potentialConcern: potential,
        recommendedReview: clause.recommendedReview,
        confidence: clause.confidence,
      );
    }).toList();

    return LegalAnalysisResult(
      snapshot: result.snapshot,
      clauses: safeClauses,
      obligations: result.obligations,
      dates: result.dates,
      risks: result.risks,
      lawyerQuestions: result.lawyerQuestions,
      checklist: result.checklist,
      options: result.options,
    );
  }
}
