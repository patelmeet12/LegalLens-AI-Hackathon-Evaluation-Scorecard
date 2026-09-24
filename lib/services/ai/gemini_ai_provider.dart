import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/legal_entities.dart';
import 'ai_provider.dart';
import 'demo_ai_provider.dart';

class GeminiAIProvider implements AIProvider {
  final String? apiKey;
  final Dio _dio;
  final DemoAIProvider _fallbackProvider = DemoAIProvider();

  GeminiAIProvider({this.apiKey}) : _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
  ));

  @override
  String get name => 'Google Gemini AI (External Cloud LLM)';

  @override
  bool get isConfigured => apiKey != null && apiKey!.trim().isNotEmpty;

  @override
  Future<LegalAnalysisResult> analyzeDocument({
    required String text,
    required String documentType,
    required String fileName,
  }) async {
    if (!isConfigured) {
      return _fallbackProvider.analyzeDocument(
        text: text,
        documentType: documentType,
        fileName: fileName,
      );
    }

    try {
      final prompt = '''
You are a legal document information and analysis assistant for LegalLens AI.
Analyze the following legal document.
IMPORTANT RULES:
1. Provide legal information ONLY. Never give legal advice or determine legal outcomes.
2. Never call clauses "illegal" or "unlawful". Use safe phrasing: "Requires attention", "Potential concern", "Consider professional review".
3. Never invent dates. If a date is missing, return "Not detected."
4. Extract key clauses across categories: Payment, Termination, Notice, Confidentiality, Intellectual Property, Liability, Indemnity, Non-Compete, Non-Solicitation, Dispute Resolution, Governing Law, Renewal, Penalties, Refunds, Data Privacy.
5. Extract obligations into Your, Other Party, and Shared responsibilities.
6. Extract 6 risk categories: Financial, Employment, Privacy, Liability, Intellectual Property, Restrictions.

Document Type: $documentType
Filename: $fileName
Text:
$text

Respond with strict JSON matching this structure:
{
  "complexity": "simple" | "moderate" | "complex",
  "attentionLevel": "informational" | "review" | "highAttention",
  "summary": "plain-language summary",
  "keyAreas": ["Compensation", "Termination"],
  "clauses": [
    {
      "id": "c1",
      "title": "Title",
      "category": "Category",
      "importance": "informational" | "review" | "highAttention",
      "originalText": "verbatim text snippet",
      "plainLanguageExplanation": "explanation",
      "whyItMatters": "impact",
      "potentialConcern": "concern",
      "recommendedReview": "review advice"
    }
  ],
  "obligations": [
    {
      "id": "o1",
      "party": "your" | "otherParty" | "shared",
      "description": "text",
      "sourceClause": "section"
    }
  ],
  "dates": [
    {
      "id": "d1",
      "title": "Date Title",
      "dateString": "Date or 'Not detected.'",
      "type": "Start/End/Notice/etc",
      "sourceSnippet": "snippet"
    }
  ],
  "risks": [
    {
      "id": "r1",
      "category": "financial" | "employment" | "privacy" | "liability" | "intellectualProperty" | "restrictions",
      "attentionLevel": "informational" | "review" | "highAttention",
      "relevantClause": "clause",
      "explanation": "safe explanation",
      "recommendedAction": "action"
    }
  ],
  "lawyerQuestions": [
    {
      "id": "q1",
      "question": "question",
      "category": "category",
      "contextReason": "reason",
      "sourceClause": "clause"
    }
  ],
  "checklist": [
    {
      "id": "ck1",
      "title": "item",
      "category": "category"
    }
  ]
}
''';

      final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey';
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'responseMimeType': 'application/json',
            'temperature': 0.1,
          }
        },
      );

      final dataMap = response.data ?? {};
      final candidates = dataMap['candidates'] as List<dynamic>? ?? [];
      if (candidates.isEmpty) {
        throw Exception('No candidates returned from Gemini API');
      }
      final firstCandidate = candidates.first as Map<String, dynamic>;
      final content = firstCandidate['content'] as Map<String, dynamic>? ?? {};
      final parts = content['parts'] as List<dynamic>? ?? [];
      final firstPart = parts.isNotEmpty ? parts.first as Map<String, dynamic> : <String, dynamic>{};
      final candidateText = firstPart['text'] as String? ?? '{}';
      final jsonMap = jsonDecode(candidateText) as Map<String, dynamic>;

      return _parseJsonToResult(jsonMap, documentType);
    } catch (_) {
      // Fall back safely to demo provider on network or parse error
      return _fallbackProvider.analyzeDocument(
        text: text,
        documentType: documentType,
        fileName: fileName,
      );
    }
  }

  LegalAnalysisResult parseJsonToResult(Map<String, dynamic> json, String docType) =>
      _parseJsonToResult(json, docType);

  LegalAnalysisResult _parseJsonToResult(Map<String, dynamic> json, String docType) {
    final compStr = (json['complexity'] as String? ?? 'moderate').toLowerCase();
    final complexity = compStr.contains('simple')
        ? DocumentComplexity.simple
        : (compStr.contains('complex') ? DocumentComplexity.complex : DocumentComplexity.moderate);

    final attStr = (json['attentionLevel'] as String? ?? 'review').toLowerCase();
    final attention = attStr.contains('high')
        ? AttentionTier.highAttention
        : (attStr.contains('review') ? AttentionTier.review : AttentionTier.informational);

    final clauses = <LegalClause>[];
    final rawClauses = json['clauses'] as List<dynamic>?;
    if (rawClauses != null) {
      for (final raw in rawClauses) {
        if (raw is! Map<String, dynamic>) continue;
        final c = raw;
        final importanceStr = (c['importance'] as String? ?? '').toLowerCase();
        final tier = importanceStr.contains('high')
            ? AttentionTier.highAttention
            : (importanceStr.contains('review')
                ? AttentionTier.review
                : AttentionTier.informational);

        clauses.add(LegalClause(
          id: (c['id'] as String?) ?? 'c_${clauses.length}',
          title: (c['title'] as String?) ?? 'Clause',
          category: (c['category'] as String?) ?? 'General',
          importance: tier,
          originalText: (c['originalText'] as String?) ?? '',
          plainLanguageExplanation: (c['plainLanguageExplanation'] as String?) ?? '',
          whyItMatters: (c['whyItMatters'] as String?) ?? '',
          potentialConcern: (c['potentialConcern'] as String?) ?? '',
          recommendedReview: (c['recommendedReview'] as String?) ?? '',
        ));
      }
    }

    final obligations = <Obligation>[];
    final rawObligations = json['obligations'] as List<dynamic>?;
    if (rawObligations != null) {
      for (final raw in rawObligations) {
        if (raw is! Map<String, dynamic>) continue;
        final o = raw;
        final pStr = (o['party'] as String? ?? '').toLowerCase();
        final party = pStr.contains('other')
            ? ObligationParty.otherParty
            : (pStr.contains('shared') ? ObligationParty.shared : ObligationParty.your);

        obligations.add(Obligation(
          id: (o['id'] as String?) ?? 'o_${obligations.length}',
          party: party,
          description: (o['description'] as String?) ?? '',
          sourceClause: (o['sourceClause'] as String?) ?? '',
        ));
      }
    }

    final dates = <ImportantDate>[];
    final rawDates = json['dates'] as List<dynamic>?;
    if (rawDates != null) {
      for (final raw in rawDates) {
        if (raw is! Map<String, dynamic>) continue;
        final d = raw;
        final dateStr = (d['dateString'] as String?) ?? AppConstants.notDetectedDate;
        dates.add(ImportantDate(
          id: (d['id'] as String?) ?? 'd_${dates.length}',
          title: (d['title'] as String?) ?? 'Date',
          dateString: dateStr,
          type: (d['type'] as String?) ?? 'Period',
          sourceSnippet: (d['sourceSnippet'] as String?) ?? '',
          isDetected: !dateStr.contains('Not detected'),
        ));
      }
    }

    final risks = <RiskItem>[];
    final rawRisks = json['risks'] as List<dynamic>?;
    if (rawRisks != null) {
      for (final raw in rawRisks) {
        if (raw is! Map<String, dynamic>) continue;
        final r = raw;
        final catStr = (r['category'] as String? ?? '').toLowerCase();
        RiskCategory cat = RiskCategory.financial;
        if (catStr.contains('employ')) cat = RiskCategory.employment;
        if (catStr.contains('priv')) cat = RiskCategory.privacy;
        if (catStr.contains('liab')) cat = RiskCategory.liability;
        if (catStr.contains('intel') || catStr.contains('ip')) cat = RiskCategory.intellectualProperty;
        if (catStr.contains('rest')) cat = RiskCategory.restrictions;

        final levelStr = (r['attentionLevel'] as String? ?? '').toLowerCase();
        final tier = levelStr.contains('high')
            ? AttentionTier.highAttention
            : (levelStr.contains('review')
                ? AttentionTier.review
                : AttentionTier.informational);

        risks.add(RiskItem(
          id: (r['id'] as String?) ?? 'r_${risks.length}',
          category: cat,
          attentionLevel: tier,
          relevantClause: (r['relevantClause'] as String?) ?? '',
          explanation: (r['explanation'] as String?) ?? '',
          recommendedAction: (r['recommendedAction'] as String?) ?? '',
        ));
      }
    }

    final questions = <LawyerQuestion>[];
    final rawQuestions = json['lawyerQuestions'] as List<dynamic>?;
    if (rawQuestions != null) {
      for (final raw in rawQuestions) {
        if (raw is! Map<String, dynamic>) continue;
        final q = raw;
        questions.add(LawyerQuestion(
          id: (q['id'] as String?) ?? 'q_${questions.length}',
          question: (q['question'] as String?) ?? '',
          category: (q['category'] as String?) ?? '',
          contextReason: (q['contextReason'] as String?) ?? '',
          sourceClause: (q['sourceClause'] as String?) ?? '',
        ));
      }
    }

    final checklist = <ChecklistItem>[];
    final rawChecklist = json['checklist'] as List<dynamic>?;
    if (rawChecklist != null) {
      for (final raw in rawChecklist) {
        if (raw is! Map<String, dynamic>) continue;
        final k = raw;
        checklist.add(ChecklistItem(
          id: (k['id'] as String?) ?? 'k_${checklist.length}',
          title: (k['title'] as String?) ?? '',
          category: (k['category'] as String?) ?? '',
        ));
      }
    }

    final rawKeyAreas = json['keyAreas'] as List<dynamic>? ?? [];
    final keyAreas = rawKeyAreas.map((e) => e.toString()).toList();

    final snapshot = LegalSnapshot(
      documentType: docType,
      complexity: complexity,
      attentionLevel: attention,
      executiveSummary: (json['summary'] as String?) ?? '',
      keyAreas: keyAreas,
      totalClauses: clauses.length,
      highAttentionCount: clauses.where((c) => c.importance == AttentionTier.highAttention).length,
      reviewCount: clauses.where((c) => c.importance == AttentionTier.review).length,
      informationalCount: clauses.where((c) => c.importance == AttentionTier.informational).length,
    );

    return LegalAnalysisResult(
      snapshot: snapshot,
      clauses: clauses,
      obligations: obligations,
      dates: dates,
      risks: risks,
      lawyerQuestions: questions,
      checklist: checklist,
    );
  }

  @override
  Future<QAMessage> answerQuestion({
    required String question,
    required LegalDocument document,
    required List<QAMessage> previousHistory,
  }) async {
    if (!isConfigured) {
      return _fallbackProvider.answerQuestion(
        question: question,
        document: document,
        previousHistory: previousHistory,
      );
    }

    try {
      final prompt = '''
You are a document-grounded legal assistant for LegalLens AI.
You must answer using ONLY the provided document text.
If the document does not contain the answer, you MUST respond exactly:
"${AppConstants.noHallucinationRefusal}"
Never invent facts, clauses, dates, or legal precedents.

Document:
${document.rawText}

Question: $question

Respond with JSON:
{
  "answer": "answer text or exact refusal",
  "citations": ["clause or section titles cited"],
  "isRefusal": true | false
}
''';

      final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey';
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'responseMimeType': 'application/json',
            'temperature': 0.1,
          }
        },
      );

      final dataMap = response.data ?? <String, dynamic>{};
      final candidates = dataMap['candidates'] as List<dynamic>? ?? [];
      if (candidates.isEmpty) {
        throw Exception('No candidates returned');
      }
      final firstCandidate = candidates.first as Map<String, dynamic>;
      final content = firstCandidate['content'] as Map<String, dynamic>? ?? {};
      final parts = content['parts'] as List<dynamic>? ?? [];
      final firstPart = parts.isNotEmpty ? parts.first as Map<String, dynamic> : <String, dynamic>{};
      final candidate = firstPart['text'] as String? ?? '{}';
      final Map<String, dynamic> res = jsonDecode(candidate) as Map<String, dynamic>;
      final answerStr = res['answer'] as String? ?? '';
      final isRefusal = (res['isRefusal'] as bool? ?? false) || answerStr.contains('couldn\'t find');

      final rawCitations = res['citations'] as List<dynamic>? ?? [];
      final citations = rawCitations.map((e) => e.toString()).toList();

      return QAMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        isUser: false,
        text: answerStr.isNotEmpty ? answerStr : AppConstants.noHallucinationRefusal,
        timestamp: DateTime.now(),
        citations: citations,
        confidence: ConfidenceLevel.high,
        isRefusal: isRefusal,
      );
    } catch (_) {
      return _fallbackProvider.answerQuestion(
        question: question,
        document: document,
        previousHistory: previousHistory,
      );
    }
  }

  @override
  Future<DocumentComparison> compareDocuments({
    required String textA,
    required String nameA,
    required String textB,
    required String nameB,
  }) async {
    // For comparison, fall back to local comparison or can query Gemini similarly
    return _fallbackProvider.compareDocuments(
      textA: textA,
      nameA: nameA,
      textB: textB,
      nameB: nameB,
    );
  }
}
