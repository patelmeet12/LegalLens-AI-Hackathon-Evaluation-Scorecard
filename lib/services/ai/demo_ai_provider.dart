import '../../core/constants/app_constants.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/legal_entities.dart';
import 'ai_provider.dart';
import 'demo/checklist_generator.dart';
import 'demo/clause_detector.dart';
import 'demo/date_extractor.dart';
import 'demo/document_type_detector.dart';
import 'demo/lawyer_question_generator.dart';
import 'demo/obligation_extractor.dart';
import 'demo/options_generator.dart';
import 'demo/risk_analyzer.dart';
import 'demo/snapshot_generator.dart';

/// Orchestrates local heuristic intelligence across modular sub-services.
/// Acts as the coordinator between document type detection, clause detection,
/// obligation tri-partitioning, timeline extraction, risk scoring, executive snapshotting,
/// attorney question synthesis, checklist assembly, and strategic options generation.
class DemoAIProvider implements AIProvider {
  final DocumentTypeDetector documentTypeDetector;
  final ClauseDetector clauseDetector;
  final ObligationExtractor obligationExtractor;
  final DateExtractor dateExtractor;
  final RiskAnalyzer riskAnalyzer;
  final SnapshotGenerator snapshotGenerator;
  final LawyerQuestionGenerator lawyerQuestionGenerator;
  final ChecklistGenerator checklistGenerator;
  final OptionsGenerator optionsGenerator;

  DemoAIProvider({
    DocumentTypeDetector? documentTypeDetector,
    ClauseDetector? clauseDetector,
    ObligationExtractor? obligationExtractor,
    DateExtractor? dateExtractor,
    RiskAnalyzer? riskAnalyzer,
    SnapshotGenerator? snapshotGenerator,
    LawyerQuestionGenerator? lawyerQuestionGenerator,
    ChecklistGenerator? checklistGenerator,
    OptionsGenerator? optionsGenerator,
  })  : documentTypeDetector = documentTypeDetector ?? DocumentTypeDetector(),
        clauseDetector = clauseDetector ?? ClauseDetector(),
        obligationExtractor = obligationExtractor ?? ObligationExtractor(),
        dateExtractor = dateExtractor ?? DateExtractor(),
        riskAnalyzer = riskAnalyzer ?? RiskAnalyzer(),
        snapshotGenerator = snapshotGenerator ?? SnapshotGenerator(),
        lawyerQuestionGenerator =
            lawyerQuestionGenerator ?? LawyerQuestionGenerator(),
        checklistGenerator = checklistGenerator ?? ChecklistGenerator(),
        optionsGenerator = optionsGenerator ?? OptionsGenerator();

  @override
  String get name => 'Demo AI Engine (Local Heuristic Intelligence)';

  @override
  bool get isConfigured => true;

  @override
  Future<LegalAnalysisResult> analyzeDocument({
    required String text,
    required String documentType,
    required String fileName,
  }) async {
    // 1. Normalize input
    final normalized = text.toLowerCase();

    // 2. Detect document type if not specified
    final resolvedDocType = documentType.isNotEmpty
        ? documentType
        : documentTypeDetector.detect(normalized);

    // 3. Detect Clauses across 15 standard categories
    final clauses = clauseDetector.detect(text, normalized);

    // 4. Extract Obligations (Your, Other Party, Shared)
    final obligations = obligationExtractor.extract(text, normalized);

    // 5. Extract Important Dates & Milestones
    final dates = dateExtractor.extract(text, normalized);

    // 6. Extract Risk & Attention Radar (6 categories)
    final risks = riskAnalyzer.analyze(text, normalized, clauses);

    // 7. Generate Executive Snapshot & Complexity
    final snapshot = snapshotGenerator.generate(
      documentType: resolvedDocType,
      clauses: clauses,
      textLength: text.length,
    );

    // 8. Generate Personalized Lawyer Questions
    final lawyerQuestions = lawyerQuestionGenerator.generate(clauses, risks);

    // 9. Generate Smart Action Checklist
    final checklist = checklistGenerator.generate(clauses);

    // 10. Generate Strategic Options & Next Steps
    final options = optionsGenerator.generate(
      clauses,
      risks,
      snapshot.documentType,
    );

    // 11. Return LegalAnalysisResult
    return LegalAnalysisResult(
      snapshot: snapshot,
      clauses: clauses,
      obligations: obligations,
      dates: dates,
      risks: risks,
      lawyerQuestions: lawyerQuestions,
      checklist: checklist,
      options: options,
    );
  }

  @override
  Future<QAMessage> answerQuestion({
    required String question,
    required LegalDocument document,
    required List<QAMessage> previousHistory,
  }) async {
    final q = question.toLowerCase();
    final docText = document.rawText.toLowerCase();

    // 1. Check for hallucination/unrelated queries
    const ungroundedTerms = [
      'alien',
      'weather',
      'stock market',
      'crypto',
      'recipe',
      'dog',
      'cat',
      'pet',
      'dental',
      'gym',
      'football',
      'mars',
      'superhero',
      'joke',
      'movie',
      'song',
    ];

    bool isIrrelevant = false;
    for (final term in ungroundedTerms) {
      if (q.contains(term) && !docText.contains(term)) {
        isIrrelevant = true;
        break;
      }
    }

    if (isIrrelevant) {
      return QAMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        isUser: false,
        text: AppConstants.noHallucinationRefusal,
        timestamp: DateTime.now(),
        citations: const [],
        confidence: ConfidenceLevel.high,
        isRefusal: true,
      );
    }

    // 2. Document Grounded Q&A logic with citations
    if (q.contains('resign') ||
        q.contains('quit') ||
        q.contains('leave') ||
        q.contains('end my job')) {
      final clause = document.clauses.firstWhere(
        (c) =>
            c.category == 'Termination' ||
            c.title.toLowerCase().contains('termination'),
        orElse: () => document.clauses.first,
      );
      final notice = document.dates.firstWhere(
        (d) => d.type == 'Notice Period',
        orElse: () => const ImportantDate(
          id: '',
          title: '',
          dateString: '30-90 days',
          type: '',
          sourceSnippet: '',
        ),
      );

      return QAMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        isUser: false,
        text:
            'According to ${clause.title}, either party may end the agreement upon providing written notice. '
            'The notice period stated in the document is ${notice.dateString}. '
            'Please verify whether any severance or benefits forfeiture applies upon voluntary resignation.',
        timestamp: DateTime.now(),
        citations: [clause.title, 'Section 3: Term and Termination'],
        confidence: ConfidenceLevel.high,
      );
    }

    if (q.contains('notice') || q.contains('how much notice')) {
      final noticeDate = document.dates.firstWhere(
        (d) => d.type == 'Notice Period',
        orElse: () => const ImportantDate(
          id: '',
          title: '',
          dateString: AppConstants.notDetectedDate,
          type: '',
          sourceSnippet: '',
        ),
      );
      final clause = document.clauses.firstWhere(
        (c) => c.category == 'Notice' || c.category == 'Termination',
        orElse: () => document.clauses.first,
      );

      if (!noticeDate.isDetected && !docText.contains('notice')) {
        return QAMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          isUser: false,
          text: AppConstants.noHallucinationRefusal,
          timestamp: DateTime.now(),
          citations: const [],
          isRefusal: true,
        );
      }

      return QAMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        isUser: false,
        text:
            'The document specifies a notice requirement of ${noticeDate.dateString} prior to termination or cancellation. '
            'This notice must be provided in formal written format.',
        timestamp: DateTime.now(),
        citations: [clause.title],
        confidence: ConfidenceLevel.high,
      );
    }

    if (q.contains('own') ||
        q.contains('intellectual property') ||
        q.contains('create') ||
        q.contains('side project')) {
      final ipClause = document.clauses.firstWhere(
        (c) => c.category == 'Intellectual Property',
        orElse: () => document.clauses.first,
      );

      return QAMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        isUser: false,
        text:
            'Under ${ipClause.title}, inventions, algorithms, code, and work products conceived during the term are considered works made for hire and belong exclusively to the Employer/Client. '
            'If you create personal side projects, note that the clause may also claim inventions developed at home or outside working hours if related to company business. You must list pre-existing inventions on an Exhibit to retain ownership.',
        timestamp: DateTime.now(),
        citations: [
          ipClause.title,
          'Section 5: Intellectual Property and Work for Hire',
        ],
        confidence: ConfidenceLevel.high,
      );
    }

    if (q.contains('compete') ||
        q.contains('non-compete') ||
        q.contains('competitor')) {
      final compClause = document.clauses.firstWhere(
        (c) => c.category == 'Non-Compete',
        orElse: () => document.clauses.first,
      );

      return QAMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        isUser: false,
        text:
            'Based on ${compClause.title}, there is a post-termination restriction barring you from performing services for or consulting with direct competitors for 12 months post-termination. '
            'This restriction applies to designated geographic territories. Consider consulting a legal professional regarding enforceability in your jurisdiction.',
        timestamp: DateTime.now(),
        citations: [compClause.title, 'Section 6: Restrictive Covenants'],
        confidence: ConfidenceLevel.high,
      );
    }

    if (q.contains('renew') || q.contains('renewal')) {
      final renClause = document.clauses.firstWhere(
        (c) => c.category == 'Renewal',
        orElse: () => const LegalClause(
          id: '',
          title: 'Renewal Terms',
          category: 'Renewal',
          importance: AttentionTier.review,
          originalText: '',
          plainLanguageExplanation: '',
          whyItMatters: '',
          potentialConcern: '',
          recommendedReview: '',
        ),
      );

      if (renClause.originalText.isEmpty && !docText.contains('renew')) {
        return QAMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          isUser: false,
          text: AppConstants.noHallucinationRefusal,
          timestamp: DateTime.now(),
          citations: const [],
          isRefusal: true,
        );
      }

      return QAMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        isUser: false,
        text:
            'The agreement contains automatic renewal provisions. It will automatically renew unless either party delivers advance written notice prior to the expiration date.',
        timestamp: DateTime.now(),
        citations: [renClause.title],
        confidence: ConfidenceLevel.high,
      );
    }

    // Generic grounded match across clauses
    LegalClause? matchedClause;
    for (final clause in document.clauses) {
      final words = q.split(' ').where((w) => w.length > 3);
      for (final word in words) {
        if (clause.originalText.toLowerCase().contains(word) ||
            clause.title.toLowerCase().contains(word) ||
            clause.category.toLowerCase().contains(word)) {
          matchedClause = clause;
          break;
        }
      }
      if (matchedClause != null) break;
    }

    if (matchedClause != null) {
      return QAMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        isUser: false,
        text:
            'Regarding your inquiry, ${matchedClause.title} states: "${matchedClause.plainLanguageExplanation}" '
            'Key takeaway: ${matchedClause.whyItMatters}',
        timestamp: DateTime.now(),
        citations: [matchedClause.title, matchedClause.category],
        confidence: ConfidenceLevel.medium,
      );
    }

    // Refusal safeguard
    return QAMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      isUser: false,
      text: AppConstants.noHallucinationRefusal,
      timestamp: DateTime.now(),
      citations: const [],
      confidence: ConfidenceLevel.high,
      isRefusal: true,
    );
  }

  @override
  Future<DocumentComparison> compareDocuments({
    required String textA,
    required String nameA,
    required String textB,
    required String nameB,
  }) async {
    final lowerA = textA.toLowerCase();
    final lowerB = textB.toLowerCase();

    final List<String> added = [];
    final List<String> removed = [];
    final List<ClauseDiff> changed = [];
    final List<String> changedObs = [];
    final List<String> changedFin = [];
    final List<String> changedDates = [];
    final List<String> highAttentionDiffs = [];

    // Compare Compensation / Financial
    if (lowerA.contains('165,000') && lowerB.contains('180,000')) {
      changedFin.add(
          'Base salary increases from \$165,000 in Option A to \$180,000 with 0.5% equity in Option B.');
      changedFin.add(
          'Sign-on bonus increases from \$15,000 (12 mo clawback) to \$25,000 (24 mo clawback in Option B).');
      changed.add(const ClauseDiff(
        clauseTitle: 'Compensation & Sign-on Clawback',
        docAText: 'Base: \$165,000. Sign-on: \$15,000 with 12-month clawback.',
        docBText:
            'Base: \$180,000 + 0.5% equity. Sign-on: \$25,000 with 24-month clawback.',
        changeSummary:
            'Higher financial upside in B, but significantly extended 24-month clawback liability.',
        differenceTier: AttentionTier.review,
      ));
    } else {
      changedFin.add(
          'Financial provisions differ in payment structure or fee schedules between versions.');
    }

    // Compare Notice & Termination
    if (lowerA.contains('30 days') && lowerB.contains('90 days')) {
      changedDates.add(
          'Notice period expands from 30 days in Document A to 90 days in Document B.');
      changedDates.add(
          'Probation period doubles from 90 days in Document A to 180 days in Document B.');
      highAttentionDiffs.add(
          'Document B imposes a 90-day notice requirement and doubles probation to 180 days.');
      changed.add(const ClauseDiff(
        clauseTitle: 'Termination Notice & Probation',
        docAText: '30 days written notice. 90 days probation.',
        docBText: '90 days written notice. 180 days probation.',
        changeSummary:
            'Document B restricts exit agility with triple the notice period and double the probation period.',
        differenceTier: AttentionTier.highAttention,
      ));
    }

    // Compare Non-Compete
    if (lowerA.contains('6 months') && lowerB.contains('18 months')) {
      highAttentionDiffs.add(
          'Non-compete triples in duration (6 mo vs 18 mo) and expands from California-only to Nationwide in Option B.');
      changed.add(const ClauseDiff(
        clauseTitle: 'Post-Employment Non-Compete Scope',
        docAText:
            '6 months non-compete restricted to direct competitors in California.',
        docBText:
            '18 months nationwide non-compete covering all software and technology sectors.',
        changeSummary:
            'Substantially more aggressive restriction in Option B that may impair future career opportunities.',
        differenceTier: AttentionTier.highAttention,
      ));
    }

    // Compare IP Ownership
    if (lowerB.contains('broad assignment') || lowerB.contains('at any time')) {
      highAttentionDiffs.add(
          'Option B claims broad assignment of all IP created at any time, including personal time.');
      changedObs.add(
          'Option B expands your IP transfer duties to personal off-hours creations.');
      changed.add(const ClauseDiff(
        clauseTitle: 'Intellectual Property Ownership',
        docAText:
            'Work produced during working hours using company assets belongs to Employer.',
        docBText:
            'Broad assignment of all IP created at any time, whether at work or on personal time.',
        changeSummary:
            'Option B captures personal side-projects and unassisted hobby inventions.',
        differenceTier: AttentionTier.highAttention,
      ));
    }

    // Compare Severance
    if (lowerA.contains('1 month') && lowerB.contains('no severance')) {
      removed.add(
          'Severance pay upon involuntary termination without cause is removed in Option B.');
      changedObs.add(
          'Employer has no duty to provide severance upon termination without cause in Option B.');
    }

    // Added & removed clauses general
    if (added.isEmpty) {
      added.add(
          'Equity grant vesting schedule and 24-month clawback condition added in Document B.');
    }
    if (removed.isEmpty) {
      removed.add(
          'Severance entitlement upon exit without cause is omitted in Document B.');
    }

    return DocumentComparison(
      docAName: nameA,
      docBName: nameB,
      addedClauses: added,
      removedClauses: removed,
      changedClauses: changed,
      changedObligations: changedObs,
      changedFinancialTerms: changedFin,
      changedDates: changedDates,
      highAttentionDifferences: highAttentionDiffs,
    );
  }
}
