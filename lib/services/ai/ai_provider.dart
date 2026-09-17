import '../../domain/entities/legal_entities.dart';

class LegalAnalysisResult {
  final LegalSnapshot snapshot;
  final List<LegalClause> clauses;
  final List<Obligation> obligations;
  final List<ImportantDate> dates;
  final List<RiskItem> risks;
  final List<LawyerQuestion> lawyerQuestions;
  final List<ChecklistItem> checklist;

  const LegalAnalysisResult({
    required this.snapshot,
    required this.clauses,
    required this.obligations,
    required this.dates,
    required this.risks,
    required this.lawyerQuestions,
    required this.checklist,
  });
}

abstract class AIProvider {
  String get name;
  bool get isConfigured;

  Future<LegalAnalysisResult> analyzeDocument({
    required String text,
    required String documentType,
    required String fileName,
  });

  Future<QAMessage> answerQuestion({
    required String question,
    required LegalDocument document,
    required List<QAMessage> previousHistory,
  });

  Future<DocumentComparison> compareDocuments({
    required String textA,
    required String nameA,
    required String textB,
    required String nameB,
  });
}
