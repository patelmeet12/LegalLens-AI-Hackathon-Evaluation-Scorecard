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
      final response = await _dio.post(
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

      final candidate = response.data['candidates'][0]['content']['parts'][0]['text'];
      final Map<String, dynamic> jsonMap = jsonDecode(candidate);

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
    if (json['clauses'] != null) {
      for (final c in json['clauses']) {
        final tier = (c['importance'] as String? ?? '').toLowerCase().contains('high')
            ? AttentionTier.highAttention
            : ((c['importance'] as String? ?? '').toLowerCase().contains('review')
                ? AttentionTier.review
                : AttentionTier.informational);

        clauses.add(LegalClause(
          id: c['id'] ?? 'c_${clauses.length}',
          title: c['title'] ?? 'Clause',
          category: c['category'] ?? 'General',
          importance: tier,
          originalText: c['originalText'] ?? '',
          plainLanguageExplanation: c['plainLanguageExplanation'] ?? '',
          whyItMatters: c['whyItMatters'] ?? '',
          potentialConcern: c['potentialConcern'] ?? '',
          recommendedReview: c['recommendedReview'] ?? '',
        ));
      }
    }

    final obligations = <Obligation>[];
    if (json['obligations'] != null) {
      for (final o in json['obligations']) {
        final pStr = (o['party'] as String? ?? '').toLowerCase();
        final party = pStr.contains('other')
            ? ObligationParty.otherParty
            : (pStr.contains('shared') ? ObligationParty.shared : ObligationParty.your);

        obligations.add(Obligation(
          id: o['id'] ?? 'o_${obligations.length}',
          party: party,
          description: o['description'] ?? '',
          sourceClause: o['sourceClause'] ?? '',
        ));
      }
    }

    final dates = <ImportantDate>[];
    if (json['dates'] != null) {
      for (final d in json['dates']) {
        final dateStr = d['dateString'] ?? AppConstants.notDetectedDate;
        dates.add(ImportantDate(
          id: d['id'] ?? 'd_${dates.length}',
          title: d['title'] ?? 'Date',
          dateString: dateStr,
          type: d['type'] ?? 'Period',
          sourceSnippet: d['sourceSnippet'] ?? '',
          isDetected: !dateStr.contains('Not detected'),
        ));
      }
    }

    final risks = <RiskItem>[];
    if (json['risks'] != null) {
      for (final r in json['risks']) {
        final catStr = (r['category'] as String? ?? '').toLowerCase();
        RiskCategory cat = RiskCategory.financial;
        if (catStr.contains('employ')) cat = RiskCategory.employment;
        if (catStr.contains('priv')) cat = RiskCategory.privacy;
        if (catStr.contains('liab')) cat = RiskCategory.liability;
        if (catStr.contains('intel') || catStr.contains('ip')) cat = RiskCategory.intellectualProperty;
        if (catStr.contains('rest')) cat = RiskCategory.restrictions;

        final tier = (r['attentionLevel'] as String? ?? '').toLowerCase().contains('high')
            ? AttentionTier.highAttention
            : ((r['attentionLevel'] as String? ?? '').toLowerCase().contains('review')
                ? AttentionTier.review
                : AttentionTier.informational);

        risks.add(RiskItem(
          id: r['id'] ?? 'r_${risks.length}',
          category: cat,
          attentionLevel: tier,
          relevantClause: r['relevantClause'] ?? '',
          explanation: r['explanation'] ?? '',
          recommendedAction: r['recommendedAction'] ?? '',
        ));
      }
    }

    final questions = <LawyerQuestion>[];
    if (json['lawyerQuestions'] != null) {
      for (final q in json['lawyerQuestions']) {
        questions.add(LawyerQuestion(
          id: q['id'] ?? 'q_${questions.length}',
          question: q['question'] ?? '',
          category: q['category'] ?? '',
          contextReason: q['contextReason'] ?? '',
          sourceClause: q['sourceClause'] ?? '',
        ));
      }
    }

    final checklist = <ChecklistItem>[];
    if (json['checklist'] != null) {
      for (final k in json['checklist']) {
        checklist.add(ChecklistItem(
          id: k['id'] ?? 'k_${checklist.length}',
          title: k['title'] ?? '',
          category: k['category'] ?? '',
        ));
      }
    }

    final snapshot = LegalSnapshot(
      documentType: docType,
      complexity: complexity,
      attentionLevel: attention,
      executiveSummary: json['summary'] ?? '',
      keyAreas: List<String>.from(json['keyAreas'] ?? []),
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
      final response = await _dio.post(
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

      final candidate = response.data['candidates'][0]['content']['parts'][0]['text'];
      final Map<String, dynamic> res = jsonDecode(candidate);
      final isRefusal = res['isRefusal'] as bool? ?? false || (res['answer'] as String? ?? '').contains('couldn\'t find');

      return QAMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        isUser: false,
        text: res['answer'] ?? AppConstants.noHallucinationRefusal,
        timestamp: DateTime.now(),
        citations: List<String>.from(res['citations'] ?? []),
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
