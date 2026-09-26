import '../../../domain/entities/enums.dart';
import '../../../domain/entities/legal_entities.dart';

/// Generates targeted, personalized questions to guide consultation with a licensed attorney.
class LawyerQuestionGenerator {
  /// Generates questions based on detected clauses and risk items.
  List<LawyerQuestion> generate(
    List<LegalClause> clauses,
    List<RiskItem> risks,
  ) {
    final List<LawyerQuestion> questions = [];
    int idCounter = 1;

    for (final clause in clauses.where((c) => c.importance == AttentionTier.highAttention)) {
      if (clause.category == 'Non-Compete') {
        questions.add(LawyerQuestion(
          id: 'lq_${idCounter++}',
          question:
              'Is the post-employment non-compete enforceable under the governing law of my jurisdiction?',
          category: 'Non-Compete Enforceability',
          contextReason:
              'Many jurisdictions have statutory bans or strict geographic limitations on post-employment non-compete clauses.',
          sourceClause: clause.title,
        ));
      } else if (clause.category == 'Intellectual Property') {
        questions.add(LawyerQuestion(
          id: 'lq_${idCounter++}',
          question:
              'Does the IP assignment clause restrict me from building independent side-projects on personal time using personal hardware?',
          category: 'IP Carve-Outs',
          contextReason:
              'The contract contains broad language assigning inventions made outside standard working hours.',
          sourceClause: clause.title,
        ));
      } else if (clause.category == 'Indemnity') {
        questions.add(LawyerQuestion(
          id: 'lq_${idCounter++}',
          question:
              'Can the indemnification clause be revised to require a standard cap and apply strictly to proven gross negligence?',
          category: 'Liability Exposure',
          contextReason:
              'Uncapped indemnity creates personal financial risk for third-party litigation.',
          sourceClause: clause.title,
        ));
      } else if (clause.category == 'Termination') {
        questions.add(LawyerQuestion(
          id: 'lq_${idCounter++}',
          question:
              'Is the 90-day termination notice period mutually enforceable, and can it be shortened to 30 days without penalty?',
          category: 'Notice & Exit Flexibility',
          contextReason:
              'A 90-day notice period may complicate transitioning to prospective new positions.',
          sourceClause: clause.title,
        ));
      }
    }

    if (questions.isEmpty) {
      questions.add(LawyerQuestion(
        id: 'lq_${idCounter++}',
        question:
            'Are the dispute resolution and mandatory arbitration terms standard and reciprocal for both parties?',
        category: 'Dispute Terms',
        contextReason:
            'Ensures equitable recourse if disagreements arise during contract execution.',
        sourceClause: 'Dispute Resolution Clause',
      ));
    }

    return questions;
  }
}
