import 'enums.dart';

class LegalClause {
  final String id;
  final String title;
  final String category; // One of the 15 clause categories
  final AttentionTier importance;
  final String originalText;
  final String plainLanguageExplanation;
  final String whyItMatters;
  final String potentialConcern;
  final String recommendedReview;
  final ConfidenceLevel confidence;

  const LegalClause({
    required this.id,
    required this.title,
    required this.category,
    required this.importance,
    required this.originalText,
    required this.plainLanguageExplanation,
    required this.whyItMatters,
    required this.potentialConcern,
    required this.recommendedReview,
    this.confidence = ConfidenceLevel.high,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'importance': importance.index,
        'originalText': originalText,
        'plainLanguageExplanation': plainLanguageExplanation,
        'whyItMatters': whyItMatters,
        'potentialConcern': potentialConcern,
        'recommendedReview': recommendedReview,
        'confidence': confidence.index,
      };

  factory LegalClause.fromJson(Map<String, dynamic> json) => LegalClause(
        id: json['id'] as String,
        title: json['title'] as String,
        category: json['category'] as String,
        importance: AttentionTier.values[json['importance'] as int],
        originalText: json['originalText'] as String,
        plainLanguageExplanation: json['plainLanguageExplanation'] as String,
        whyItMatters: json['whyItMatters'] as String,
        potentialConcern: json['potentialConcern'] as String,
        recommendedReview: json['recommendedReview'] as String,
        confidence: json['confidence'] != null
            ? ConfidenceLevel.values[json['confidence'] as int]
            : ConfidenceLevel.high,
      );
}

class Obligation {
  final String id;
  final ObligationParty party;
  final String description;
  final String sourceClause;
  final bool isCompleted;

  const Obligation({
    required this.id,
    required this.party,
    required this.description,
    required this.sourceClause,
    this.isCompleted = false,
  });

  Obligation copyWith({bool? isCompleted}) => Obligation(
        id: id,
        party: party,
        description: description,
        sourceClause: sourceClause,
        isCompleted: isCompleted ?? this.isCompleted,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'party': party.index,
        'description': description,
        'sourceClause': sourceClause,
        'isCompleted': isCompleted,
      };

  factory Obligation.fromJson(Map<String, dynamic> json) => Obligation(
        id: json['id'] as String,
        party: ObligationParty.values[json['party'] as int],
        description: json['description'] as String,
        sourceClause: json['sourceClause'] as String,
        isCompleted: json['isCompleted'] as bool? ?? false,
      );
}

class ImportantDate {
  final String id;
  final String title;
  final String dateString;
  final String type; // e.g. "Effective Date", "Probation Window", "Notice Period"
  final String sourceSnippet;
  final bool isDetected;

  const ImportantDate({
    required this.id,
    required this.title,
    required this.dateString,
    required this.type,
    required this.sourceSnippet,
    this.isDetected = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'dateString': dateString,
        'type': type,
        'sourceSnippet': sourceSnippet,
        'isDetected': isDetected,
      };

  factory ImportantDate.fromJson(Map<String, dynamic> json) => ImportantDate(
        id: json['id'] as String,
        title: json['title'] as String,
        dateString: json['dateString'] as String,
        type: json['type'] as String,
        sourceSnippet: json['sourceSnippet'] as String,
        isDetected: json['isDetected'] as bool? ?? true,
      );
}

class RiskItem {
  final String id;
  final RiskCategory category;
  final AttentionTier attentionLevel;
  final String relevantClause;
  final String explanation;
  final String recommendedAction;
  final ConfidenceLevel confidence;

  const RiskItem({
    required this.id,
    required this.category,
    required this.attentionLevel,
    required this.relevantClause,
    required this.explanation,
    required this.recommendedAction,
    this.confidence = ConfidenceLevel.high,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category.index,
        'attentionLevel': attentionLevel.index,
        'relevantClause': relevantClause,
        'explanation': explanation,
        'recommendedAction': recommendedAction,
        'confidence': confidence.index,
      };

  factory RiskItem.fromJson(Map<String, dynamic> json) => RiskItem(
        id: json['id'] as String,
        category: RiskCategory.values[json['category'] as int],
        attentionLevel: AttentionTier.values[json['attentionLevel'] as int],
        relevantClause: json['relevantClause'] as String,
        explanation: json['explanation'] as String,
        recommendedAction: json['recommendedAction'] as String,
        confidence: json['confidence'] != null
            ? ConfidenceLevel.values[json['confidence'] as int]
            : ConfidenceLevel.high,
      );
}

class LegalSnapshot {
  final String documentType;
  final DocumentComplexity complexity;
  final AttentionTier attentionLevel;
  final String executiveSummary;
  final List<String> keyAreas;
  final int totalClauses;
  final int highAttentionCount;
  final int reviewCount;
  final int informationalCount;

  const LegalSnapshot({
    required this.documentType,
    required this.complexity,
    required this.attentionLevel,
    required this.executiveSummary,
    required this.keyAreas,
    required this.totalClauses,
    required this.highAttentionCount,
    required this.reviewCount,
    required this.informationalCount,
  });

  Map<String, dynamic> toJson() => {
        'documentType': documentType,
        'complexity': complexity.index,
        'attentionLevel': attentionLevel.index,
        'executiveSummary': executiveSummary,
        'keyAreas': keyAreas,
        'totalClauses': totalClauses,
        'highAttentionCount': highAttentionCount,
        'reviewCount': reviewCount,
        'informationalCount': informationalCount,
      };

  factory LegalSnapshot.fromJson(Map<String, dynamic> json) => LegalSnapshot(
        documentType: json['documentType'] as String,
        complexity: DocumentComplexity.values[json['complexity'] as int],
        attentionLevel: AttentionTier.values[json['attentionLevel'] as int],
        executiveSummary: json['executiveSummary'] as String,
        keyAreas: List<String>.from(json['keyAreas'] as List),
        totalClauses: json['totalClauses'] as int,
        highAttentionCount: json['highAttentionCount'] as int,
        reviewCount: json['reviewCount'] as int,
        informationalCount: json['informationalCount'] as int,
      );
}

class LawyerQuestion {
  final String id;
  final String question;
  final String category;
  final String contextReason;
  final String sourceClause;

  const LawyerQuestion({
    required this.id,
    required this.question,
    required this.category,
    required this.contextReason,
    required this.sourceClause,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'category': category,
        'contextReason': contextReason,
        'sourceClause': sourceClause,
      };

  factory LawyerQuestion.fromJson(Map<String, dynamic> json) => LawyerQuestion(
        id: json['id'] as String,
        question: json['question'] as String,
        category: json['category'] as String,
        contextReason: json['contextReason'] as String,
        sourceClause: json['sourceClause'] as String,
      );
}

class ChecklistItem {
  final String id;
  final String title;
  final String category;
  final bool isCustom;
  final bool isChecked;

  const ChecklistItem({
    required this.id,
    required this.title,
    required this.category,
    this.isCustom = false,
    this.isChecked = false,
  });

  ChecklistItem copyWith({bool? isChecked, String? title}) => ChecklistItem(
        id: id,
        title: title ?? this.title,
        category: category,
        isCustom: isCustom,
        isChecked: isChecked ?? this.isChecked,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'isCustom': isCustom,
        'isChecked': isChecked,
      };

  factory ChecklistItem.fromJson(Map<String, dynamic> json) => ChecklistItem(
        id: json['id'] as String,
        title: json['title'] as String,
        category: json['category'] as String,
        isCustom: json['isCustom'] as bool? ?? false,
        isChecked: json['isChecked'] as bool? ?? false,
      );
}

class QAMessage {
  final String id;
  final bool isUser;
  final String text;
  final DateTime timestamp;
  final List<String> citations; // e.g., ["Section 3.1 Termination", "Section 6.1 Non-Compete"]
  final ConfidenceLevel confidence;
  final bool isRefusal;

  const QAMessage({
    required this.id,
    required this.isUser,
    required this.text,
    required this.timestamp,
    this.citations = const [],
    this.confidence = ConfidenceLevel.high,
    this.isRefusal = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'isUser': isUser,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
        'citations': citations,
        'confidence': confidence.index,
        'isRefusal': isRefusal,
      };

  factory QAMessage.fromJson(Map<String, dynamic> json) => QAMessage(
        id: json['id'] as String,
        isUser: json['isUser'] as bool,
        text: json['text'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        citations: List<String>.from(json['citations'] as List? ?? []),
        confidence: json['confidence'] != null
            ? ConfidenceLevel.values[json['confidence'] as int]
            : ConfidenceLevel.high,
        isRefusal: json['isRefusal'] as bool? ?? false,
      );
}

class ClauseDiff {
  final String clauseTitle;
  final String docAText;
  final String docBText;
  final String changeSummary;
  final AttentionTier differenceTier;

  const ClauseDiff({
    required this.clauseTitle,
    required this.docAText,
    required this.docBText,
    required this.changeSummary,
    required this.differenceTier,
  });

  Map<String, dynamic> toJson() => {
        'clauseTitle': clauseTitle,
        'docAText': docAText,
        'docBText': docBText,
        'changeSummary': changeSummary,
        'differenceTier': differenceTier.index,
      };

  factory ClauseDiff.fromJson(Map<String, dynamic> json) => ClauseDiff(
        clauseTitle: json['clauseTitle'] as String,
        docAText: json['docAText'] as String,
        docBText: json['docBText'] as String,
        changeSummary: json['changeSummary'] as String,
        differenceTier: AttentionTier.values[json['differenceTier'] as int],
      );
}

class DocumentComparison {
  final String docAName;
  final String docBName;
  final List<String> addedClauses;
  final List<String> removedClauses;
  final List<ClauseDiff> changedClauses;
  final List<String> changedObligations;
  final List<String> changedFinancialTerms;
  final List<String> changedDates;
  final List<String> highAttentionDifferences;

  const DocumentComparison({
    required this.docAName,
    required this.docBName,
    required this.addedClauses,
    required this.removedClauses,
    required this.changedClauses,
    required this.changedObligations,
    required this.changedFinancialTerms,
    required this.changedDates,
    required this.highAttentionDifferences,
  });

  Map<String, dynamic> toJson() => {
        'docAName': docAName,
        'docBName': docBName,
        'addedClauses': addedClauses,
        'removedClauses': removedClauses,
        'changedClauses': changedClauses.map((c) => c.toJson()).toList(),
        'changedObligations': changedObligations,
        'changedFinancialTerms': changedFinancialTerms,
        'changedDates': changedDates,
        'highAttentionDifferences': highAttentionDifferences,
      };

  factory DocumentComparison.fromJson(Map<String, dynamic> json) => DocumentComparison(
        docAName: json['docAName'] as String,
        docBName: json['docBName'] as String,
        addedClauses: List<String>.from(json['addedClauses'] as List),
        removedClauses: List<String>.from(json['removedClauses'] as List),
        changedClauses: (json['changedClauses'] as List)
            .map((e) => ClauseDiff.fromJson(e as Map<String, dynamic>))
            .toList(),
        changedObligations: List<String>.from(json['changedObligations'] as List),
        changedFinancialTerms: List<String>.from(json['changedFinancialTerms'] as List),
        changedDates: List<String>.from(json['changedDates'] as List),
        highAttentionDifferences: List<String>.from(json['highAttentionDifferences'] as List),
      );
}

class LegalDocument {
  final String id;
  final String fileName;
  final String documentType;
  final String rawText;
  final int charCount;
  final DateTime createdAt;
  final LegalSnapshot snapshot;
  final List<LegalClause> clauses;
  final List<Obligation> obligations;
  final List<ImportantDate> dates;
  final List<RiskItem> risks;
  final List<LawyerQuestion> lawyerQuestions;
  final List<ChecklistItem> checklist;

  const LegalDocument({
    required this.id,
    required this.fileName,
    required this.documentType,
    required this.rawText,
    required this.charCount,
    required this.createdAt,
    required this.snapshot,
    required this.clauses,
    required this.obligations,
    required this.dates,
    required this.risks,
    required this.lawyerQuestions,
    required this.checklist,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'documentType': documentType,
        'rawText': rawText,
        'charCount': charCount,
        'createdAt': createdAt.toIso8601String(),
        'snapshot': snapshot.toJson(),
        'clauses': clauses.map((c) => c.toJson()).toList(),
        'obligations': obligations.map((o) => o.toJson()).toList(),
        'dates': dates.map((d) => d.toJson()).toList(),
        'risks': risks.map((r) => r.toJson()).toList(),
        'lawyerQuestions': lawyerQuestions.map((q) => q.toJson()).toList(),
        'checklist': checklist.map((i) => i.toJson()).toList(),
      };

  factory LegalDocument.fromJson(Map<String, dynamic> json) => LegalDocument(
        id: json['id'] as String,
        fileName: json['fileName'] as String,
        documentType: json['documentType'] as String,
        rawText: json['rawText'] as String,
        charCount: json['charCount'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
        snapshot: LegalSnapshot.fromJson(json['snapshot'] as Map<String, dynamic>),
        clauses: (json['clauses'] as List)
            .map((c) => LegalClause.fromJson(c as Map<String, dynamic>))
            .toList(),
        obligations: (json['obligations'] as List)
            .map((o) => Obligation.fromJson(o as Map<String, dynamic>))
            .toList(),
        dates: (json['dates'] as List)
            .map((d) => ImportantDate.fromJson(d as Map<String, dynamic>))
            .toList(),
        risks: (json['risks'] as List)
            .map((r) => RiskItem.fromJson(r as Map<String, dynamic>))
            .toList(),
        lawyerQuestions: (json['lawyerQuestions'] as List)
            .map((q) => LawyerQuestion.fromJson(q as Map<String, dynamic>))
            .toList(),
        checklist: (json['checklist'] as List)
            .map((i) => ChecklistItem.fromJson(i as Map<String, dynamic>))
            .toList(),
      );
}
