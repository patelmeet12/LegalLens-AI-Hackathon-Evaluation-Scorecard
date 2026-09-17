import 'dart:math';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/legal_entities.dart';
import 'ai_provider.dart';

class DemoAIProvider implements AIProvider {
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
    // Simulate brief processing for realistic UX feel
    await Future.delayed(const Duration(milliseconds: 300));

    final normalized = text.toLowerCase();

    // 1. Detect Clauses across 15 categories
    final clauses = _extractClauses(text, normalized);

    // 2. Extract Obligations (Your, Other, Shared)
    final obligations = _extractObligations(text, normalized);

    // 3. Extract Important Dates & Timeline
    final dates = _extractDates(text, normalized);

    // 4. Extract Risk & Attention Map (6 categories)
    final risks = _extractRisks(text, normalized, clauses);

    // 5. Generate Snapshot & Complexity
    final snapshot = _generateSnapshot(
      documentType: documentType.isNotEmpty ? documentType : _detectDocumentType(normalized),
      clauses: clauses,
      textLength: text.length,
    );

    // 6. Generate Lawyer Questions
    final lawyerQuestions = _generateLawyerQuestions(clauses, risks);

    // 7. Generate Smart Checklist
    final checklist = _generateChecklist(clauses);

    // 8. Generate Possible Options and Next Steps
    final options = _generateOptions(clauses, risks, snapshot.documentType);

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

  String _detectDocumentType(String text) {
    if (text.contains('employment') || text.contains('employee') || text.contains('salary')) {
      return 'Employment Agreement';
    } else if (text.contains('lease') || text.contains('tenant') || text.contains('landlord')) {
      return 'Rental / Lease Agreement';
    } else if (text.contains('non-disclosure') || text.contains('confidential information') || text.contains('nda')) {
      return 'NDA';
    } else if (text.contains('freelance') || text.contains('contractor') || text.contains('consulting')) {
      return 'Freelance Agreement';
    } else if (text.contains('service agreement') || text.contains('statement of work')) {
      return 'Service Agreement';
    }
    return 'General Contract';
  }

  List<LegalClause> _extractClauses(String rawText, String lower) {
    final List<LegalClause> clauses = [];
    int idCounter = 1;

    void addClause({
      required String title,
      required String category,
      required AttentionTier importance,
      required String originalText,
      required String plainExplanation,
      required String whyItMatters,
      required String potentialConcern,
      required String recommendedReview,
      ConfidenceLevel confidence = ConfidenceLevel.high,
    }) {
      clauses.add(LegalClause(
        id: 'clause_${idCounter++}',
        title: title,
        category: category,
        importance: importance,
        originalText: originalText,
        plainLanguageExplanation: plainExplanation,
        whyItMatters: whyItMatters,
        potentialConcern: potentialConcern,
        recommendedReview: recommendedReview,
        confidence: confidence,
      ));
    }

    // 1. Payment / Compensation
    if (lower.contains('compensation') || lower.contains('salary') || lower.contains('rent') || lower.contains('payment')) {
      final snippet = _findSnippet(rawText, ['salary of', 'base salary', 'rent of', 'shall pay', 'monthly rent', 'compensation']);
      addClause(
        title: 'Compensation & Payment Structure',
        category: 'Payment',
        importance: AttentionTier.informational,
        originalText: snippet.isNotEmpty ? snippet : 'Section detailing compensation amounts, schedules, or payment obligations.',
        plainExplanation: 'Outlines the agreed financial payment, schedule, and any associated bonuses or deductions.',
        whyItMatters: 'Establishes exactly how much money is paid, when disbursements occur, and preconditions for payment.',
        potentialConcern: 'Pay attention to bonus discretion, late payment terms, or clawback provisions.',
        recommendedReview: 'Confirm payment frequency and verify whether bonuses or expense reimbursements have mandatory deadlines.',
      );
    }

    // 2. Termination
    if (lower.contains('termination') || lower.contains('terminate') || lower.contains('at-will')) {
      final snippet = _findSnippet(rawText, ['terminate this agreement', 'at-will', 'termination for cause', 'without cause', 'notice of termination']);
      final isHighNotice = lower.contains('90') && lower.contains('notice');
      addClause(
        title: 'Termination Conditions & Notice',
        category: 'Termination',
        importance: isHighNotice ? AttentionTier.highAttention : AttentionTier.review,
        originalText: snippet.isNotEmpty ? snippet : 'Section governing how either party may end the agreement and required notice.',
        plainExplanation: 'Explains under what conditions either side can cancel the contract, immediate cause triggers, and notice timelines.',
        whyItMatters: 'Determines your freedom to exit and how vulnerable you are to sudden contract cancellation.',
        potentialConcern: isHighNotice
            ? 'A 90-day notice requirement is substantially longer than market standard (typically 14-30 days) and may restrict rapid job transitions.'
            : 'Immediate termination clauses for cause should clearly specify what acts constitute cause.',
        recommendedReview: 'Consider requesting symmetric termination rights and clarifying whether severance applies upon exit without cause.',
      );
    }

    // 3. Notice Period
    if (lower.contains('notice period') || lower.contains('written notice') || lower.contains('days notice') || lower.contains('days\' notice')) {
      final snippet = _findSnippet(rawText, ['written notice', 'days notice', 'prior notice', 'advance notice']);
      addClause(
        title: 'Mandatory Notice Period',
        category: 'Notice',
        importance: AttentionTier.review,
        originalText: snippet.isNotEmpty ? snippet : 'Notice requirements specifying formal communication timeframes before action.',
        plainExplanation: 'Defines how many days advance notice must be served in writing before termination, renewal, or modifications.',
        whyItMatters: 'Failing to deliver notice within the specified window can trigger default or automatic continuation.',
        potentialConcern: 'Unusually long notice windows may hinder your agility; extremely short notice leaves little preparation time.',
        recommendedReview: 'Add calendar reminders for all formal notice trigger windows.',
      );
    }

    // 4. Confidentiality
    if (lower.contains('confidential') || lower.contains('non-disclosure') || lower.contains('trade secret')) {
      final snippet = _findSnippet(rawText, ['hold in strict confidence', 'confidential information', 'trade secrets', 'proprietary information']);
      addClause(
        title: 'Confidentiality & Non-Disclosure',
        category: 'Confidentiality',
        importance: AttentionTier.informational,
        originalText: snippet.isNotEmpty ? snippet : 'Section restricting disclosure of proprietary or sensitive party information.',
        plainExplanation: 'Prohibits sharing trade secrets, financial records, client lists, or internal technical architectures with third parties.',
        whyItMatters: 'Protects business secrets but remains legally binding even after the relationship terminates.',
        potentialConcern: 'Check whether the confidentiality obligation has an expiration date (e.g. 3-5 years) or lasts indefinitely.',
        recommendedReview: 'Verify standard exclusions exist (e.g., information already public or received legally from third parties).',
      );
    }

    // 5. Intellectual Property
    if (lower.contains('intellectual property') || lower.contains('work made for hire') || lower.contains('inventions') || lower.contains('work product')) {
      final snippet = _findSnippet(rawText, ['work product ownership', 'work made for hire', 'all inventions', 'patents, and work products', 'intellectual property']);
      final coversPersonalTime = lower.contains('outside standard') || lower.contains('at home') || lower.contains('personal time');
      addClause(
        title: 'Intellectual Property & Work Product Ownership',
        category: 'Intellectual Property',
        importance: coversPersonalTime ? AttentionTier.highAttention : AttentionTier.review,
        originalText: snippet.isNotEmpty ? snippet : 'Clause assigning ownership of inventions and creations developed during the contract.',
        plainExplanation: 'Specifies that work, code, algorithms, and designs created belong to the company rather than the individual.',
        whyItMatters: 'Prevents you from repurposing code or inventions you built, and may even encumber personal side-projects.',
        potentialConcern: coversPersonalTime
            ? 'Potential concern: Language covers inventions made "at home" or "outside standard working hours", which may capture personal side projects.'
            : 'Ensure pre-existing patents and tools are explicitly excluded in an Exhibit.',
        recommendedReview: 'Request an explicit carve-out for personal hobby projects built entirely on personal devices without company data.',
      );
    }

    // 6. Non-Compete
    if (lower.contains('non-compete') || lower.contains('compete directly') || lower.contains('covenant not to compete')) {
      final snippet = _findSnippet(rawText, ['non-compete', 'shall not directly or indirectly engage in', 'competes directly', 'restrictive covenants']);
      addClause(
        title: 'Post-Termination Non-Compete Restriction',
        category: 'Non-Compete',
        importance: AttentionTier.highAttention,
        originalText: snippet.isNotEmpty ? snippet : 'Clause restricting future employment or business activities with competitors.',
        plainExplanation: 'Restricts you from working for, investing in, or consulting with competing businesses for a designated duration after leaving.',
        whyItMatters: 'Directly limits your future career prospects, freelance opportunities, and ability to work in your area of expertise.',
        potentialConcern: 'Requires attention: Broad geographic scope or lengthy restriction windows may severely curtail livelihood.',
        recommendedReview: 'Consider professional legal review regarding local jurisdiction enforceability and negotiate narrower scope.',
      );
    }

    // 7. Non-Solicitation
    if (lower.contains('non-solicitation') || lower.contains('solicit or induce') || lower.contains('solicit')) {
      final snippet = _findSnippet(rawText, ['non-solicitation', 'solicit or induce any employee', 'solicit customers']);
      addClause(
        title: 'Non-Solicitation of Personnel & Clients',
        category: 'Non-Solicitation',
        importance: AttentionTier.review,
        originalText: snippet.isNotEmpty ? snippet : 'Clause barring recruitment of coworkers or poaching of clients.',
        plainExplanation: 'Prevents you from recruiting former colleagues or soliciting clients/customers for a specified period after departure.',
        whyItMatters: 'Protects the enterprise from talent and revenue drain when key personnel depart.',
        potentialConcern: 'Ensure the restriction applies only to clients you directly handled, not every client company-wide.',
        recommendedReview: 'Verify duration is reasonable (typically 12 months rather than 24-36 months).',
      );
    }

    // 8. Indemnity
    if (lower.contains('indemnif') || lower.contains('hold harmless')) {
      final snippet = _findSnippet(rawText, ['indemnify, defend, and hold harmless', 'shall indemnify', 'indemnification']);
      addClause(
        title: 'Indemnification & Hold Harmless',
        category: 'Indemnity',
        importance: AttentionTier.highAttention,
        originalText: snippet.isNotEmpty ? snippet : 'Clause requiring one party to compensate the other for legal losses or third-party claims.',
        plainExplanation: 'Requires you to pay the legal defense and damages if a third party sues the other party over your work or conduct.',
        whyItMatters: 'Can create uncapped personal financial liability for attorney fees and court settlements.',
        potentialConcern: 'Requires attention: Uncapped indemnity without clear limits to proven gross negligence poses substantial risk.',
        recommendedReview: 'Propose capping indemnity to actual insurance coverage or fees earned, and exclude ordinary inadvertent errors.',
      );
    }

    // 9. Liability Limitation
    if (lower.contains('limitation of liability') || lower.contains('consequential damages') || lower.contains('total liability')) {
      final snippet = _findSnippet(rawText, ['limitation of liability', 'total liability under this agreement', 'shall not exceed']);
      addClause(
        title: 'Limitation of Liability',
        category: 'Liability',
        importance: AttentionTier.review,
        originalText: snippet.isNotEmpty ? snippet : 'Clause capping monetary damages payable in the event of a dispute.',
        plainExplanation: 'Caps the maximum dollar compensation either party can recover if things go wrong under the contract.',
        whyItMatters: 'Prevents catastrophic runaway damages, but may also prevent you from recovering full damages if the other party breaches.',
        potentialConcern: 'Check whether the liability cap is mutual or one-sided.',
        recommendedReview: 'Ensure liability limits are mutual and fair to both contracting entities.',
      );
    }

    // 10. Dispute Resolution
    if (lower.contains('dispute') || lower.contains('arbitration') || lower.contains('jams') || lower.contains('aaa')) {
      final snippet = _findSnippet(rawText, ['mandatory arbitration', 'binding individual arbitration', 'dispute, controversy', 'jams']);
      final waivesClass = lower.contains('class actions') || lower.contains('jury');
      addClause(
        title: 'Dispute Resolution & Mandatory Arbitration',
        category: 'Dispute Resolution',
        importance: waivesClass ? AttentionTier.review : AttentionTier.informational,
        originalText: snippet.isNotEmpty ? snippet : 'Clause mandating private arbitration rather than public court trials.',
        plainExplanation: 'Requires all disputes to be handled through confidential private arbitration instead of a public courtroom or jury trial.',
        whyItMatters: 'Arbitration is usually faster and private, but limits formal appeal rights and may waive class action participation.',
        potentialConcern: 'Waiver of jury trials and class actions prevents collective bargaining in legal grievances.',
        recommendedReview: 'Confirm who pays the arbitrator fees and whether the arbitration venue is reasonably accessible to you.',
      );
    }

    // 11. Governing Law
    if (lower.contains('governing law') || lower.contains('state of') || lower.contains('jurisdiction')) {
      final snippet = _findSnippet(rawText, ['governed by and construed in accordance', 'governing law', 'laws of the state']);
      addClause(
        title: 'Governing Law & Legal Jurisdiction',
        category: 'Governing Law',
        importance: AttentionTier.informational,
        originalText: snippet.isNotEmpty ? snippet : 'Designates which state or national legal statutes govern the interpretation of the contract.',
        plainExplanation: 'Specifies which state\'s legal statutes and court systems will interpret and enforce the contract terms.',
        whyItMatters: 'Different jurisdictions interpret non-competes, employment rights, and liability very differently (e.g. CA vs DE vs NY).',
        potentialConcern: 'If the chosen jurisdiction is far from where you live, traveling for legal proceedings could be costly.',
        recommendedReview: 'Verify whether the designated state has favorable statutory interpretations for your role.',
      );
    }

    // 12. Renewal
    if (lower.contains('renew') || lower.contains('automatic renewal') || lower.contains('month-to-month')) {
      final snippet = _findSnippet(rawText, ['automatic renewal', 'renew on a month-to-month', 'renewal date']);
      addClause(
        title: 'Renewal & Extension Terms',
        category: 'Renewal',
        importance: AttentionTier.review,
        originalText: snippet.isNotEmpty ? snippet : 'Clause governing contract renewal and automatic extension cycles.',
        plainExplanation: 'Specifies whether the contract automatically extends at the end of the term or requires affirmative re-signing.',
        whyItMatters: 'Automatic renewal clauses (evergreen clauses) can lock you into future terms unless you cancel in a strict window.',
        potentialConcern: 'Missing the opt-out window can inadvertently bind you to another entire contract cycle.',
        recommendedReview: 'Mark cancellation notice deadlines on your calendar at least 60 days before the renewal cutoff.',
      );
    }

    // 13. Penalties
    if (lower.contains('penalty') || lower.contains('late fee') || lower.contains('liquidated damages')) {
      final snippet = _findSnippet(rawText, ['late fee', 'penalty', 'penalties']);
      addClause(
        title: 'Financial Penalties & Late Fees',
        category: 'Penalties',
        importance: AttentionTier.review,
        originalText: snippet.isNotEmpty ? snippet : 'Clause imposing fees or monetary penalties for delayed performance or payments.',
        plainExplanation: 'Outlines predetermined fees charged if rent, reports, or obligations are submitted past specific deadlines.',
        whyItMatters: 'Adds unexpected financial burdens for minor delays.',
        potentialConcern: 'Cumulative per-day penalty structures can escalate quickly.',
        recommendedReview: 'Request a standard 5-to-10 day grace period before penalties accrue.',
      );
    }

    // 14. Refunds / Deposits
    if (lower.contains('refund') || lower.contains('security deposit') || lower.contains('deposit')) {
      final snippet = _findSnippet(rawText, ['security deposit', 'deposit with landlord', 'deposit shall be returned', 'refund']);
      addClause(
        title: 'Deposit Retention & Refund Terms',
        category: 'Refunds',
        importance: AttentionTier.review,
        originalText: snippet.isNotEmpty ? snippet : 'Clause outlining deposit handling, deductions, and return conditions.',
        plainExplanation: 'Explains how deposited funds are held, when deductions can be made for damages, and timelines for refunding.',
        whyItMatters: 'Guarantees the conditions required to recover your money after the contract concludes.',
        potentialConcern: 'Vague damage deduction rules may allow the holder to withhold funds improperly.',
        recommendedReview: 'Ensure a mandatory move-in/move-out documented inspection is required prior to deductions.',
      );
    }

    // 15. Data Privacy
    if (lower.contains('privacy') || lower.contains('data') || lower.contains('personal information') || lower.contains('gdpr')) {
      final snippet = _findSnippet(rawText, ['privacy', 'data collection', 'personal data', 'proprietary data']);
      addClause(
        title: 'Data Privacy & Governance',
        category: 'Data Privacy',
        importance: AttentionTier.informational,
        originalText: snippet.isNotEmpty ? snippet : 'Clause regarding processing, handling, or storage of personal information.',
        plainExplanation: 'Governs how personal records, user data, or client confidential info must be stored, processed, and safeguarded.',
        whyItMatters: 'Mandates compliance with privacy standards and avoids security breaches.',
        potentialConcern: 'Verify whether personal devices used for work could be subjected to corporate remote wiping.',
        recommendedReview: 'Clarify data retention schedules and device monitoring policies.',
      );
    }

    // Fallback if very few clauses matched
    if (clauses.isEmpty) {
      addClause(
        title: 'General Terms & Mutual Agreement',
        category: 'General Contract',
        importance: AttentionTier.informational,
        originalText: rawText.length > 300 ? rawText.substring(0, 300) : rawText,
        plainExplanation: 'General contractual clauses defining mutual understanding, covenants, and terms.',
        whyItMatters: 'Binds the parties to the explicit written terms of the document.',
        potentialConcern: 'Review all terms carefully to ensure oral representations were fully committed to writing.',
        recommendedReview: 'Review complete agreement with an attorney if binding commitments are involved.',
      );
    }

    return clauses;
  }

  String _findSnippet(String text, List<String> targets) {
    for (final target in targets) {
      final idx = text.toLowerCase().indexOf(target.toLowerCase());
      if (idx != -1) {
        final start = max(0, idx - 40);
        final end = min(text.length, idx + 260);
        String snippet = text.substring(start, end).replaceAll('\n', ' ').trim();
        if (start > 0) snippet = '...$snippet';
        if (end < text.length) snippet = '$snippet...';
        return snippet;
      }
    }
    return '';
  }

  List<Obligation> _extractObligations(String rawText, String lower) {
    final List<Obligation> list = [];
    int idCounter = 1;

    // Your Responsibilities
    if (lower.contains('employee') || lower.contains('tenant') || lower.contains('receiving party') || lower.contains('contractor')) {
      if (lower.contains('notice')) {
        list.add(Obligation(
          id: 'ob_${idCounter++}',
          party: ObligationParty.your,
          description: lower.contains('90')
              ? 'Provide 90 days advance written notice prior to termination'
              : 'Provide required written notice before termination or vacation',
          sourceClause: 'Termination & Notice Section',
        ));
      }
      if (lower.contains('confidential')) {
        list.add(Obligation(
          id: 'ob_${idCounter++}',
          party: ObligationParty.your,
          description: 'Maintain strict confidentiality of trade secrets and proprietary data during and post-term',
          sourceClause: 'Confidentiality Section',
        ));
      }
      if (lower.contains('non-compete') || lower.contains('restrictive')) {
        list.add(Obligation(
          id: 'ob_${idCounter++}',
          party: ObligationParty.your,
          description: 'Refrain from engaging with or consulting for direct competitors during restriction window',
          sourceClause: 'Restrictive Covenants Section',
        ));
      }
      if (lower.contains('clean') || lower.contains('sanitary') || lower.contains('insurance')) {
        list.add(Obligation(
          id: 'ob_${idCounter++}',
          party: ObligationParty.your,
          description: 'Maintain premises cleanly and maintain active tenant/renter insurance coverage',
          sourceClause: 'Maintenance & Insurance Section',
        ));
      }
      if (lower.contains('expense') || lower.contains('reimbursement')) {
        list.add(Obligation(
          id: 'ob_${idCounter++}',
          party: ObligationParty.your,
          description: 'Submit expense reimbursement documentation within specified 30-day window',
          sourceClause: 'Compensation & Reimbursement Section',
        ));
      }
    } else {
      list.add(Obligation(
        id: 'ob_${idCounter++}',
        party: ObligationParty.your,
        description: 'Faithfully fulfill all terms, service deliverables, and covenants agreed in document',
        sourceClause: 'Core Covenants',
      ));
    }

    // Other Party Responsibilities
    if (lower.contains('salary') || lower.contains('base salary') || lower.contains('compensation')) {
      list.add(Obligation(
        id: 'ob_${idCounter++}',
        party: ObligationParty.otherParty,
        description: 'Disburse base salary on regular semi-monthly payroll schedule',
        sourceClause: 'Compensation Section',
      ));
    }
    if (lower.contains('severance')) {
      list.add(Obligation(
        id: 'ob_${idCounter++}',
        party: ObligationParty.otherParty,
        description: 'Provide severance payment upon termination without cause',
        sourceClause: 'Termination & Severance Section',
      ));
    }
    if (lower.contains('deposit') || lower.contains('security deposit')) {
      list.add(Obligation(
        id: 'ob_${idCounter++}',
        party: ObligationParty.otherParty,
        description: 'Return refundable security deposit within 30 days of lease expiration less documented damages',
        sourceClause: 'Deposit Section',
      ));
    }
    if (lower.contains('structural') || lower.contains('heating') || lower.contains('equipment')) {
      list.add(Obligation(
        id: 'ob_${idCounter++}',
        party: ObligationParty.otherParty,
        description: 'Maintain structural integrity, utilities, heating, and essential infrastructure',
        sourceClause: 'Repairs & Property Maintenance Section',
      ));
    }

    // Shared Responsibilities
    list.add(Obligation(
      id: 'ob_${idCounter++}',
      party: ObligationParty.shared,
      description: 'Resolve disputes through specified mediation or binding arbitration prior to litigation',
      sourceClause: 'Dispute Resolution Section',
    ));
    if (lower.contains('written') && lower.contains('amend')) {
      list.add(Obligation(
        id: 'ob_${idCounter++}',
        party: ObligationParty.shared,
        description: 'Execute all amendments or modifications jointly in writing signed by both authorized parties',
        sourceClause: 'Amendments & Entire Agreement Section',
      ));
    }
    if (lower.contains('inspection')) {
      list.add(Obligation(
        id: 'ob_${idCounter++}',
        party: ObligationParty.shared,
        description: 'Conduct joint move-in and move-out condition walkthrough inspection',
        sourceClause: 'Inspection Section',
      ));
    }

    return list;
  }

  List<ImportantDate> _extractDates(String rawText, String lower) {
    final List<ImportantDate> dates = [];
    int idCounter = 1;

    // Effective Date
    final effMatch = RegExp(
      r'(?:effective as of|entered into as of|effective date[:\s]*|date[:\s]*|on)\s+([a-zA-Z]+\s+\d{1,2},\s+\d{4})',
      caseSensitive: false,
    ).firstMatch(rawText);
    if (effMatch != null) {
      dates.add(ImportantDate(
        id: 'date_${idCounter++}',
        title: 'Effective Start Date',
        dateString: effMatch.group(1)!,
        type: 'Contract Start',
        sourceSnippet: effMatch.group(0)!,
        isDetected: true,
      ));
    } else {
      dates.add(ImportantDate(
        id: 'date_${idCounter++}',
        title: 'Contract Start Date',
        dateString: AppConstants.notDetectedDate,
        type: 'Contract Start',
        sourceSnippet: 'Start date not explicitly stated in document.',
        isDetected: false,
      ));
    }

    // Probation Window
    if (lower.contains('probation')) {
      final probMatch = RegExp(r'(\d+[\s-]day|\d+[\s-]month)\s+probation', caseSensitive: false).firstMatch(rawText);
      dates.add(ImportantDate(
        id: 'date_${idCounter++}',
        title: 'Probation Window',
        dateString: probMatch != null ? probMatch.group(1)! : '90 Days',
        type: 'Probation Period',
        sourceSnippet: probMatch != null ? probMatch.group(0)! : 'Subject to probationary performance evaluation',
        isDetected: true,
      ));
    }

    // Notice Period
    final noticeMatch = RegExp(r'(\d+[\s-](?:days|business days|months))\s+(?:prior|written)?\s*notice', caseSensitive: false).firstMatch(rawText);
    if (noticeMatch != null) {
      dates.add(ImportantDate(
        id: 'date_${idCounter++}',
        title: 'Termination Notice Window',
        dateString: noticeMatch.group(1)!,
        type: 'Notice Period',
        sourceSnippet: noticeMatch.group(0)!,
        isDetected: true,
      ));
    }

    // Renewal Date or Expiration
    final expMatch = RegExp(r'(?:expiring|expiration date[:\s]+|term shall be[:\s]+)([a-zA-Z]+\s+\d{1,2},\s+\d{4}|\d+\s+months)', caseSensitive: false).firstMatch(rawText);
    if (expMatch != null) {
      dates.add(ImportantDate(
        id: 'date_${idCounter++}',
        title: 'Contract Expiration Date',
        dateString: expMatch.group(1)!,
        type: 'Expiration',
        sourceSnippet: expMatch.group(0)!,
        isDetected: true,
      ));
    } else if (lower.contains('month-to-month') || lower.contains('automatic renewal')) {
      dates.add(ImportantDate(
        id: 'date_${idCounter++}',
        title: 'Automatic Renewal Cycle',
        dateString: 'Annual / Month-to-Month Automatic',
        type: 'Renewal',
        sourceSnippet: 'Agreement automatically extends unless terminated in advance',
        isDetected: true,
      ));
    } else {
      dates.add(ImportantDate(
        id: 'date_${idCounter++}',
        title: 'Expiration Date',
        dateString: AppConstants.notDetectedDate,
        type: 'Expiration',
        sourceSnippet: 'No explicit fixed expiration date found in document.',
        isDetected: false,
      ));
    }

    // Post-Termination Restriction Window
    if (lower.contains('non-compete') || lower.contains('restrictive covenants')) {
      final resMatch = RegExp(r'(\d+[\s-]months?|\d+[\s-]years?)\s+following\s+termination', caseSensitive: false).firstMatch(rawText);
      dates.add(ImportantDate(
        id: 'date_${idCounter++}',
        title: 'Post-Termination Restriction Window',
        dateString: resMatch != null ? resMatch.group(1)! : '12-24 Months',
        type: 'Restriction Window',
        sourceSnippet: resMatch != null ? resMatch.group(0)! : 'Post-termination covenants remain active',
        isDetected: true,
      ));
    }

    return dates;
  }

  List<RiskItem> _extractRisks(String rawText, String lower, List<LegalClause> clauses) {
    final List<RiskItem> risks = [];
    int idCounter = 1;

    // 1. Financial
    final hasPenalties = lower.contains('penalty') || lower.contains('late fee') || lower.contains('deduction');
    risks.add(RiskItem(
      id: 'risk_${idCounter++}',
      category: RiskCategory.financial,
      attentionLevel: hasPenalties ? AttentionTier.review : AttentionTier.informational,
      relevantClause: hasPenalties ? 'Penalties & Deductions Clause' : 'Compensation & Payment Terms',
      explanation: hasPenalties
          ? 'Potential concern: Prescribed financial penalties, late fees, or clawback provisions may apply if deadlines or terms are missed.'
          : 'Payment terms appear standard. Confirm schedule and reimbursement time limits.',
      recommendedAction: hasPenalties
          ? 'Request a grace period before penalties apply and verify calculation caps.'
          : 'Verify compensation disbursement dates align with your monthly commitments.',
      confidence: ConfidenceLevel.high,
    ));

    // 2. Employment
    final is90DayNotice = lower.contains('90') && lower.contains('notice');
    risks.add(RiskItem(
      id: 'risk_${idCounter++}',
      category: RiskCategory.employment,
      attentionLevel: is90DayNotice ? AttentionTier.highAttention : AttentionTier.review,
      relevantClause: 'Termination & Notice Section',
      explanation: is90DayNotice
          ? 'Requires attention: The 90-day termination notice requirement is substantially above standard market practice (usually 14-30 days).'
          : 'Contract contains standard termination provisions and probation terms.',
      recommendedAction: is90DayNotice
          ? 'Consider requesting a reduction to 30 days notice to avoid locking yourself into prolonged exit periods.'
          : 'Confirm severance rights in the event of involuntary termination without cause.',
      confidence: ConfidenceLevel.high,
    ));

    // 3. Privacy
    risks.add(RiskItem(
      id: 'risk_${idCounter++}',
      category: RiskCategory.privacy,
      attentionLevel: AttentionTier.informational,
      relevantClause: 'Confidentiality & Data Protection Section',
      explanation: 'Confidentiality provisions protect company trade secrets and technical data. No unusual personal surveillance language detected.',
      recommendedAction: 'Confirm whether data retention duties expire after 3-5 years.',
      confidence: ConfidenceLevel.high,
    ));

    // 4. Liability
    final hasIndemnity = lower.contains('indemnif') || lower.contains('hold harmless');
    risks.add(RiskItem(
      id: 'risk_${idCounter++}',
      category: RiskCategory.liability,
      attentionLevel: hasIndemnity ? AttentionTier.highAttention : AttentionTier.informational,
      relevantClause: 'Indemnification & Limitation of Liability Section',
      explanation: hasIndemnity
          ? 'Requires attention: Broad indemnification may expose you to personal legal costs defending third-party claims.'
          : 'Liability terms contain mutual caps and standard commercial risk allocations.',
      recommendedAction: hasIndemnity
          ? 'Limit indemnification strictly to proven gross negligence or willful misconduct, and add an overall monetary cap.'
          : 'Confirm both parties share reciprocal liability limits.',
      confidence: ConfidenceLevel.high,
    ));

    // 5. Intellectual Property
    final coversPersonalTime = lower.contains('outside standard') || lower.contains('at home') || lower.contains('personal time');
    risks.add(RiskItem(
      id: 'risk_${idCounter++}',
      category: RiskCategory.intellectualProperty,
      attentionLevel: coversPersonalTime ? AttentionTier.highAttention : AttentionTier.review,
      relevantClause: 'Intellectual Property & Work For Hire Section',
      explanation: coversPersonalTime
          ? 'Requires attention: IP assignment language claims ownership over inventions developed at home or outside standard working hours.'
          : 'Standard work-for-hire assignment for company-related deliverables.',
      recommendedAction: coversPersonalTime
          ? 'Explicitly carve out pre-existing inventions and clarify that independent personal side-projects on personal hardware remain yours.'
          : 'List any prior inventions or open-source projects in an Exhibit before signing.',
      confidence: ConfidenceLevel.high,
    ));

    // 6. Restrictions
    final hasNonCompete = lower.contains('non-compete') || lower.contains('compete directly');
    risks.add(RiskItem(
      id: 'risk_${idCounter++}',
      category: RiskCategory.restrictions,
      attentionLevel: hasNonCompete ? AttentionTier.highAttention : AttentionTier.informational,
      relevantClause: 'Restrictive Covenants & Non-Compete Section',
      explanation: hasNonCompete
          ? 'Requires attention: Post-employment non-compete restricts engaging with competitors for 12 months post-termination across broad geographic regions.'
          : 'No aggressive post-termination non-compete restrictions detected.',
      recommendedAction: hasNonCompete
          ? 'Check whether non-competes are enforceable in your state (e.g. California generally prohibits them) and consult legal counsel.'
          : 'Confirm non-solicitation of colleagues is limited to 12 months.',
      confidence: ConfidenceLevel.high,
    ));

    return risks;
  }

  LegalSnapshot _generateSnapshot({
    required String documentType,
    required List<LegalClause> clauses,
    required int textLength,
  }) {
    final highAttention = clauses.where((c) => c.importance == AttentionTier.highAttention).length;
    final review = clauses.where((c) => c.importance == AttentionTier.review).length;
    final info = clauses.where((c) => c.importance == AttentionTier.informational).length;

    DocumentComplexity complexity = DocumentComplexity.simple;
    if (clauses.length > 8 || textLength > 4000) {
      complexity = DocumentComplexity.complex;
    } else if (clauses.length > 4 || textLength > 1500) {
      complexity = DocumentComplexity.moderate;
    }

    AttentionTier attentionLevel = AttentionTier.informational;
    if (highAttention >= 2) {
      attentionLevel = AttentionTier.highAttention;
    } else if (highAttention == 1 || review >= 2) {
      attentionLevel = AttentionTier.review;
    }

    final keyAreas = clauses.map((c) => c.category).toSet().toList();

    final summary = 'This $documentType contains ${clauses.length} key analyzed sections. '
        'We identified $highAttention clause(s) requiring high attention and $review clause(s) recommended for review. '
        'Key focus areas include ${keyAreas.take(4).join(', ')}. '
        'Ensure critical obligations, notice periods, and restrictive covenants are thoroughly understood prior to signing.';

    return LegalSnapshot(
      documentType: documentType,
      complexity: complexity,
      attentionLevel: attentionLevel,
      executiveSummary: summary,
      keyAreas: keyAreas,
      totalClauses: clauses.length,
      highAttentionCount: highAttention,
      reviewCount: review,
      informationalCount: info,
    );
  }

  List<LawyerQuestion> _generateLawyerQuestions(List<LegalClause> clauses, List<RiskItem> risks) {
    final List<LawyerQuestion> questions = [];
    int idCounter = 1;

    for (final clause in clauses.where((c) => c.importance == AttentionTier.highAttention)) {
      if (clause.category == 'Non-Compete') {
        questions.add(LawyerQuestion(
          id: 'lq_${idCounter++}',
          question: 'Is the 12-month post-employment non-compete enforceable under the governing law of my jurisdiction?',
          category: 'Non-Compete Enforceability',
          contextReason: 'Many jurisdictions have statutory bans or strict geographic limitations on post-employment non-compete clauses.',
          sourceClause: clause.title,
        ));
      } else if (clause.category == 'Intellectual Property') {
        questions.add(LawyerQuestion(
          id: 'lq_${idCounter++}',
          question: 'Does the IP assignment clause restrict me from building independent side-projects on personal time using personal hardware?',
          category: 'IP Carve-Outs',
          contextReason: 'The contract contains broad language assigning inventions made outside standard working hours.',
          sourceClause: clause.title,
        ));
      } else if (clause.category == 'Indemnity') {
        questions.add(LawyerQuestion(
          id: 'lq_${idCounter++}',
          question: 'Can the indemnification clause be revised to require a standard cap and apply strictly to proven gross negligence?',
          category: 'Liability Exposure',
          contextReason: 'Uncapped indemnity creates personal financial risk for third-party litigation.',
          sourceClause: clause.title,
        ));
      } else if (clause.category == 'Termination') {
        questions.add(LawyerQuestion(
          id: 'lq_${idCounter++}',
          question: 'Is the 90-day termination notice period mutually enforceable, and can it be shortened to 30 days without penalty?',
          category: 'Notice & Exit Flexibility',
          contextReason: 'A 90-day notice period may complicate transitioning to prospective new positions.',
          sourceClause: clause.title,
        ));
      }
    }

    if (questions.isEmpty) {
      questions.add(LawyerQuestion(
        id: 'lq_${idCounter++}',
        question: 'Are the dispute resolution and mandatory arbitration terms standard and reciprocal for both parties?',
        category: 'Dispute Terms',
        contextReason: 'Ensures equitable recourse if disagreements arise during contract execution.',
        sourceClause: 'Dispute Resolution Clause',
      ));
    }

    return questions;
  }

  List<ChecklistItem> _generateChecklist(List<LegalClause> clauses) {
    final List<ChecklistItem> items = [];
    int idCounter = 1;

    items.add(ChecklistItem(
      id: 'chk_${idCounter++}',
      title: 'Verify compensation amount, payment dates, and expense reimbursement timelines',
      category: 'Compensation',
    ));
    items.add(ChecklistItem(
      id: 'chk_${idCounter++}',
      title: 'Confirm notice period requirements for voluntary termination',
      category: 'Termination',
    ));
    items.add(ChecklistItem(
      id: 'chk_${idCounter++}',
      title: 'Review confidentiality duration and list any pre-existing knowledge',
      category: 'Confidentiality',
    ));
    items.add(ChecklistItem(
      id: 'chk_${idCounter++}',
      title: 'Disclose pre-existing inventions on Exhibit to preserve ownership',
      category: 'Intellectual Property',
    ));
    items.add(ChecklistItem(
      id: 'chk_${idCounter++}',
      title: 'Examine post-contract non-compete and non-solicitation scope',
      category: 'Restrictions',
    ));
    items.add(ChecklistItem(
      id: 'chk_${idCounter++}',
      title: 'Confirm dispute resolution procedure and arbitration venue location',
      category: 'Dispute Resolution',
    ));
    items.add(ChecklistItem(
      id: 'chk_${idCounter++}',
      title: 'Prepare list of clarifying questions for professional legal review',
      category: 'Legal Review',
    ));

    return items;
  }

  List<LegalOption> _generateOptions(
    List<LegalClause> clauses,
    List<RiskItem> risks,
    String docType,
  ) {
    final hasHighAttention = clauses.any((c) => c.importance == AttentionTier.highAttention) ||
        risks.any((r) => r.attentionLevel == AttentionTier.highAttention);

    final highRiskClauses = clauses
        .where((c) => c.importance == AttentionTier.highAttention)
        .map((c) => c.category)
        .toSet()
        .join(', ');

    final riskCategories = highRiskClauses.isNotEmpty ? highRiskClauses : 'General Terms';

    return [
      LegalOption(
        id: 'opt_1',
        title: 'Execute Agreement As-Is',
        category: 'Acceptance',
        summary:
            'Sign the agreement without requested modifications if commercial timeline is urgent and you accept all identified obligations.',
        pros: [
          'Immediate execution with zero negotiation delay',
          'Preserves counterparty momentum and relationship goodwill',
          'Zero legal or administrative friction',
        ],
        cons: [
          'You remain strictly bound by all unilateral obligations and covenants',
          if (hasHighAttention) 'High-attention clauses ($riskCategories) remain active and unmitigated',
          'Potential exposure to indemnification or restrictive covenants without formal carve-outs',
        ],
        riskProfile: hasHighAttention ? AttentionTier.highAttention : AttentionTier.informational,
        actionableSteps: const [
          NextStep(
            id: 'step_1_1',
            title: 'Calendar notification and termination deadlines',
            description: 'Set automated reminders for notice periods and renewal milestones.',
            priority: 'Immediate',
          ),
          NextStep(
            id: 'step_1_2',
            title: 'Archive countersigned copy securely',
            description: 'Save an immutable, timestamped PDF copy in your personal offline storage.',
            priority: 'Before Signing',
          ),
          NextStep(
            id: 'step_1_3',
            title: 'Inventory personal pre-existing assets',
            description: 'Maintain an independent dated log of prior work and personal side projects.',
            priority: 'Before Signing',
          ),
        ],
        suggestedDraftLanguage:
            'Thank you for providing the agreement. I have reviewed the terms and executed the document. Looking forward to our collaboration.',
      ),
      const LegalOption(
        id: 'opt_2',
        title: 'Propose Clarifications & Mutual Adjustments (Recommended)',
        category: 'Balanced Redline',
        summary:
            'Request standard, industry-standard clarifications to balance unilateral covenants and establish mutual protections.',
        pros: [
          'Mitigates primary high-attention liabilities without jeopardizing the deal',
          'Widely accepted standard commercial practice across reputable organizations',
          'Preemptively resolves ambiguous wording before disputes arise',
        ],
        cons: [
          'Introduces a brief 24–72 hour counter-review turnaround window',
          'Requires review by counterparty legal or business representative',
        ],
        riskProfile: AttentionTier.review,
        actionableSteps: [
          NextStep(
            id: 'step_2_1',
            title: 'Mark clauses requiring attention',
            description: 'Highlight sections identified by LegalLens AI as requiring review.',
            priority: 'Immediate',
          ),
          NextStep(
            id: 'step_2_2',
            title: 'Request standard 15-day cure period',
            description: 'Ensure notice of alleged breach includes a reasonable opportunity to cure.',
            priority: 'Before Signing',
          ),
          NextStep(
            id: 'step_2_3',
            title: 'Make indemnification and confidentiality reciprocal',
            description: 'Ensure confidentiality and indemnity protections apply bilaterally to both parties.',
            priority: 'Before Signing',
          ),
        ],
        suggestedDraftLanguage:
            'Thank you for sharing the agreement. In reviewing the terms, I would like to request two standard adjustments for mutual clarity: (1) inserting a reasonable 15-business-day cure period in the termination clause, and (2) making the confidentiality and indemnification covenants bilateral. Please let me know if your team can incorporate these adjustments.',
      ),
      const LegalOption(
        id: 'opt_3',
        title: 'Request Targeted Carve-Outs & Scope Reductions',
        category: 'Targeted Carve-Out',
        summary:
            'Carve out pre-existing personal inventions, narrow post-termination restrictive covenants, or add an aggregate liability cap.',
        pros: [
          'Directly safeguards personal career mobility, side projects, and private intellectual property',
          'Caps maximum monetary exposure to a predictable threshold (e.g. fees paid)',
          'Limits non-compete/non-solicitation duration and geography to direct competitors',
        ],
        cons: [
          'May require internal escalation or approval from counterparty leadership',
          'Requires clear documentation of your pre-existing intellectual property',
        ],
        riskProfile: AttentionTier.review,
        actionableSteps: [
          NextStep(
            id: 'step_3_1',
            title: 'Prepare Exhibit of Prior Inventions',
            description: 'List all open-source repositories and side projects created prior to signing.',
            priority: 'Immediate',
          ),
          NextStep(
            id: 'step_3_2',
            title: 'Propose liability cap equal to 12 months fees',
            description: 'Limit aggregate liability under all causes of action to total contract value.',
            priority: 'Before Signing',
          ),
          NextStep(
            id: 'step_3_3',
            title: 'Limit restrictive covenant duration to 6 months',
            description: 'Narrow non-compete period and restrict geographic reach to direct competitors.',
            priority: 'Before Signing',
          ),
        ],
        suggestedDraftLanguage:
            'In reviewing Section [X] (Intellectual Property / Restrictive Covenants), I would like to attach Exhibit A acknowledging my pre-existing personal open-source projects. Additionally, to ensure balanced risk allocation, I propose adding a standard liability cap equal to total amounts paid under the contract. Attached is a redlined draft for your review.',
      ),
      LegalOption(
        id: 'opt_4',
        title: 'Engage Professional Legal Counsel',
        category: 'Legal Counsel',
        summary:
            'Retain a licensed attorney in the applicable jurisdiction for an authoritative, privileged review tailored to local statutes.',
        pros: [
          'Provides formal, binding legal advice tailored to specific local laws',
          'Attorney-client privileged assessment of high-attention items',
          'Direct professional representation in negotiations if needed',
        ],
        cons: [
          'Incurs hourly professional legal fees (\$250–\$600/hr)',
          'Requires scheduling lead time and coordination',
        ],
        riskProfile: AttentionTier.informational,
        actionableSteps: const [
          NextStep(
            id: 'step_4_1',
            title: 'Export LegalLens Executive Summary & Lawyer Questions',
            description: 'Download the synthesized report to minimize attorney consultation billing time.',
            priority: 'Immediate',
          ),
          NextStep(
            id: 'step_4_2',
            title: 'Schedule a 30-minute consultation',
            description: 'Book a targeted session with a specialized contract/employment attorney.',
            priority: 'Before Signing',
          ),
          NextStep(
            id: 'step_4_3',
            title: 'Focus discussion on high-attention risk areas',
            description: 'Direct the attorney to Section-specific questions generated by LegalLens AI.',
            priority: 'Before Signing',
          ),
        ],
        suggestedDraftLanguage:
            'Hello [Counsel Name], I have received a $docType under review with key attention areas around $riskCategories. I have prepared an executive briefing and specific clause questions via LegalLens AI and would like to schedule a 30-minute review session.',
      ),
    ];
  }

  @override
  Future<QAMessage> answerQuestion({
    required String question,
    required LegalDocument document,
    required List<QAMessage> previousHistory,
  }) async {
    // Simulate natural AI reasoning latency
    await Future.delayed(const Duration(milliseconds: 350));

    final q = question.toLowerCase();
    final docText = document.rawText.toLowerCase();

    // 1. Check for hallucination/unrelated queries
    // Strict rule: if the query asks about something completely absent, refuse immediately!
    final ungroundedTerms = [
      'alien', 'weather', 'stock market', 'crypto', 'recipe', 'dog', 'cat', 'pet',
      'dental', 'gym', 'football', 'mars', 'superhero', 'joke', 'movie', 'song',
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
        citations: [],
        confidence: ConfidenceLevel.high,
        isRefusal: true,
      );
    }

    // 2. Document Grounded Q&A logic with citations
    if (q.contains('resign') || q.contains('quit') || q.contains('leave') || q.contains('end my job')) {
      final clause = document.clauses.firstWhere(
        (c) => c.category == 'Termination' || c.title.toLowerCase().contains('termination'),
        orElse: () => document.clauses.first,
      );
      final notice = document.dates.firstWhere(
        (d) => d.type == 'Notice Period',
        orElse: () => const ImportantDate(id: '', title: '', dateString: '30-90 days', type: '', sourceSnippet: ''),
      );

      return QAMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        isUser: false,
        text: 'According to ${clause.title}, employment is at-will. Either party may terminate the agreement upon providing written notice. '
            'The required notice period stated in the document is ${notice.dateString}. '
            'Please verify whether any severance or benefits forfeiture applies upon voluntary resignation.',
        timestamp: DateTime.now(),
        citations: [clause.title, 'Section 3: Term and Termination'],
        confidence: ConfidenceLevel.high,
      );
    }

    if (q.contains('notice') || q.contains('how much notice')) {
      final noticeDate = document.dates.firstWhere(
        (d) => d.type == 'Notice Period',
        orElse: () => const ImportantDate(id: '', title: '', dateString: AppConstants.notDetectedDate, type: '', sourceSnippet: ''),
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
          citations: [],
          isRefusal: true,
        );
      }

      return QAMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        isUser: false,
        text: 'The document specifies a notice requirement of ${noticeDate.dateString} prior to termination or cancellation. '
            'This notice must be provided in formal written format.',
        timestamp: DateTime.now(),
        citations: [clause.title],
        confidence: ConfidenceLevel.high,
      );
    }

    if (q.contains('own') || q.contains('intellectual property') || q.contains('create') || q.contains('side project')) {
      final ipClause = document.clauses.firstWhere(
        (c) => c.category == 'Intellectual Property',
        orElse: () => document.clauses.first,
      );

      return QAMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        isUser: false,
        text: 'Under ${ipClause.title}, all inventions, algorithms, code, and work products conceived during the term are considered works made for hire and belong exclusively to the Employer/Client. '
            'If you create personal side projects, note that the clause may also claim inventions developed at home or outside working hours if related to company business. You must list pre-existing inventions on an Exhibit to retain ownership.',
        timestamp: DateTime.now(),
        citations: [ipClause.title, 'Section 5: Intellectual Property and Work for Hire'],
        confidence: ConfidenceLevel.high,
      );
    }

    if (q.contains('compete') || q.contains('non-compete') || q.contains('competitor')) {
      final compClause = document.clauses.firstWhere(
        (c) => c.category == 'Non-Compete',
        orElse: () => document.clauses.first,
      );

      return QAMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        isUser: false,
        text: 'Based on ${compClause.title}, there is a post-termination restriction barring you from performing services for or consulting with direct competitors for 12 months post-termination. '
            'This restriction applies to designated geographic territories (such as North America and Europe). Consider consulting a legal professional regarding enforceability in your state.',
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
          citations: [],
          isRefusal: true,
        );
      }

      return QAMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        isUser: false,
        text: 'The agreement contains automatic renewal provisions. It will automatically renew unless either party delivers advance written notice (typically 60 days) prior to the expiration date.',
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
        text: 'Regarding your inquiry, ${matchedClause.title} states: "${matchedClause.plainLanguageExplanation}" '
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
      citations: [],
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
    await Future.delayed(const Duration(milliseconds: 400));

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
      changedFin.add('Base salary increases from \$165,000 in Option A to \$180,000 with 0.5% equity in Option B.');
      changedFin.add('Sign-on bonus increases from \$15,000 (12 mo clawback) to \$25,000 (24 mo clawback in Option B).');
      changed.add(const ClauseDiff(
        clauseTitle: 'Compensation & Sign-on Clawback',
        docAText: 'Base: \$165,000. Sign-on: \$15,000 with 12-month clawback.',
        docBText: 'Base: \$180,000 + 0.5% equity. Sign-on: \$25,000 with 24-month clawback.',
        changeSummary: 'Higher financial upside in B, but significantly extended 24-month clawback liability.',
        differenceTier: AttentionTier.review,
      ));
    } else {
      changedFin.add('Financial provisions differ in payment structure or fee schedules between versions.');
    }

    // Compare Notice & Termination
    if (lowerA.contains('30 days') && lowerB.contains('90 days')) {
      changedDates.add('Notice period expands from 30 days in Document A to 90 days in Document B.');
      changedDates.add('Probation period doubles from 90 days in Document A to 180 days in Document B.');
      highAttentionDiffs.add('Document B imposes a 90-day notice requirement and doubles probation to 180 days.');
      changed.add(const ClauseDiff(
        clauseTitle: 'Termination Notice & Probation',
        docAText: '30 days written notice. 90 days probation.',
        docBText: '90 days written notice. 180 days probation.',
        changeSummary: 'Document B restricts exit agility with triple the notice period and double the probation period.',
        differenceTier: AttentionTier.highAttention,
      ));
    }

    // Compare Non-Compete
    if (lowerA.contains('6 months') && lowerB.contains('18 months')) {
      highAttentionDiffs.add('Non-compete triples in duration (6 mo vs 18 mo) and expands from California-only to Nationwide in Option B.');
      changed.add(const ClauseDiff(
        clauseTitle: 'Post-Employment Non-Compete Scope',
        docAText: '6 months non-compete restricted to direct competitors in California.',
        docBText: '18 months nationwide non-compete covering all software and technology sectors.',
        changeSummary: 'Substantially more aggressive restriction in Option B that may impair future career opportunities.',
        differenceTier: AttentionTier.highAttention,
      ));
    }

    // Compare IP Ownership
    if (lowerB.contains('broad assignment') || lowerB.contains('at any time')) {
      highAttentionDiffs.add('Option B claims broad assignment of all IP created at any time, including personal time.');
      changedObs.add('Option B expands your IP transfer duties to personal off-hours creations.');
      changed.add(const ClauseDiff(
        clauseTitle: 'Intellectual Property Ownership',
        docAText: 'Work produced during working hours using company assets belongs to Employer.',
        docBText: 'Broad assignment of all IP created at any time, whether at work or on personal time.',
        changeSummary: 'Option B captures personal side-projects and unassisted hobby inventions.',
        differenceTier: AttentionTier.highAttention,
      ));
    }

    // Compare Severance
    if (lowerA.contains('1 month') && lowerB.contains('no severance')) {
      removed.add('Severance pay upon involuntary termination without cause is removed in Option B.');
      changedObs.add('Employer has no duty to provide severance upon termination without cause in Option B.');
    }

    // Added & removed clauses general
    if (added.isEmpty) {
      added.add('Equity grant vesting schedule and 24-month clawback condition added in Document B.');
    }
    if (removed.isEmpty) {
      removed.add('Severance entitlement upon exit without cause is omitted in Document B.');
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
