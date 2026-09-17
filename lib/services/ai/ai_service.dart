import '../../domain/entities/legal_entities.dart';
import 'ai_provider.dart';
import 'demo_ai_provider.dart';
import 'gemini_ai_provider.dart';

class AIService {
  final DemoAIProvider _demoProvider = DemoAIProvider();
  GeminiAIProvider? _geminiProvider;
  bool _useDemoMode = true;

  AIService({bool useDemoMode = true, String? apiKey}) {
    _useDemoMode = useDemoMode;
    if (apiKey != null && apiKey.isNotEmpty) {
      _geminiProvider = GeminiAIProvider(apiKey: apiKey);
    }
  }

  bool get isDemoMode => _useDemoMode;
  bool get hasRealConfigured => _geminiProvider?.isConfigured ?? false;

  void configure({required bool useDemoMode, String? apiKey}) {
    _useDemoMode = useDemoMode;
    if (apiKey != null && apiKey.trim().isNotEmpty) {
      _geminiProvider = GeminiAIProvider(apiKey: apiKey.trim());
    } else {
      _geminiProvider = null;
    }
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
    final result = await _activeProvider.analyzeDocument(
      text: text,
      documentType: documentType,
      fileName: fileName,
    );

    // Safeguard validation: ensure no forbidden defamatory or legal conclusion words exist
    return _sanitizeAnalysisResult(result);
  }

  Future<QAMessage> answerQuestion({
    required String question,
    required LegalDocument document,
    required List<QAMessage> previousHistory,
  }) async {
    final response = await _activeProvider.answerQuestion(
      question: question,
      document: document,
      previousHistory: previousHistory,
    );

    return response;
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
    // Ensure all clauses use safe language
    final safeClauses = result.clauses.map((clause) {
      String potential = clause.potentialConcern
          .replaceAll(RegExp(r'\billegal\b', caseSensitive: false), 'potentially non-standard')
          .replaceAll(RegExp(r'\bunlawful\b', caseSensitive: false), 'subject to jurisdictional limitations')
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
    );
  }
}
