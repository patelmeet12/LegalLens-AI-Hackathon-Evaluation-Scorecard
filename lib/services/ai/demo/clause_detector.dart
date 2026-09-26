import '../../../domain/entities/enums.dart';
import '../../../domain/entities/legal_entities.dart';
import 'text_matcher.dart';

/// Builder signature for generating a [LegalClause] from matched rule context.
typedef ClauseBuilder = LegalClause Function({
  required String id,
  required String rawText,
  required String normalizedText,
  required String snippet,
});

/// A declarative rule definition for detecting and constructing legal clauses.
class ClauseRule {
  final String category;
  final String title;
  final AttentionTier defaultImportance;
  final List<String> keywords;
  final List<String> snippetTargets;
  final ClauseBuilder builder;

  const ClauseRule({
    required this.category,
    required this.title,
    required this.defaultImportance,
    required this.keywords,
    required this.snippetTargets,
    required this.builder,
  });

  /// Evaluates whether the document contains any of the trigger keywords.
  bool matches(String normalizedText) {
    return keywords.any(normalizedText.contains);
  }

  /// Extracts contextual snippet using defined targets.
  String extractSnippet(String rawText) {
    return TextMatcher.findSnippet(rawText, snippetTargets);
  }

  /// Builds the concrete [LegalClause] for this rule.
  LegalClause buildClause({
    required String id,
    required String rawText,
    required String normalizedText,
  }) {
    final snippet = extractSnippet(rawText);
    return builder(
      id: id,
      rawText: rawText,
      normalizedText: normalizedText,
      snippet: snippet,
    );
  }
}

/// Modular detector for identifying legal clauses across 15 standard categories.
/// Uses a declarative rule registry to ensure maintainability, determinism, and testability.
class ClauseDetector {
  final List<ClauseRule> _rules;

  ClauseDetector({List<ClauseRule>? rules}) : _rules = rules ?? _defaultRules();

  /// Read-only access to registered clause rules.
  List<ClauseRule> get rules => List.unmodifiable(_rules);

  /// Analyzes document text and returns detected clauses.
  List<LegalClause> detect(String rawText, String normalizedText) {
    final List<LegalClause> clauses = [];
    int idCounter = 1;

    for (final rule in _rules) {
      if (rule.matches(normalizedText)) {
        clauses.add(rule.buildClause(
          id: 'clause_${idCounter++}',
          rawText: rawText,
          normalizedText: normalizedText,
        ));
      }
    }

    // Fallback if no specific clauses matched
    if (clauses.isEmpty) {
      clauses.add(LegalClause(
        id: 'clause_${idCounter++}',
        title: 'General Terms & Mutual Agreement',
        category: 'General Contract',
        importance: AttentionTier.informational,
        originalText: rawText.length > 300 ? rawText.substring(0, 300) : rawText,
        plainLanguageExplanation:
            'General contractual clauses defining mutual understanding, covenants, and terms.',
        whyItMatters: 'Binds the parties to the explicit written terms of the document.',
        potentialConcern:
            'Review all terms carefully to ensure oral representations were fully committed to writing.',
        recommendedReview:
            'Review complete agreement with a qualified legal professional if binding commitments are involved.',
        confidence: ConfidenceLevel.high,
      ));
    }

    return clauses;
  }

  /// Returns the standard registry of 15 clause detection rules.
  static List<ClauseRule> _defaultRules() {
    return [
      // 1. Payment / Compensation
      ClauseRule(
        category: 'Payment',
        title: 'Compensation & Payment Structure',
        defaultImportance: AttentionTier.informational,
        keywords: const ['compensation', 'salary', 'rent', 'payment'],
        snippetTargets: const [
          'salary of',
          'base salary',
          'rent of',
          'shall pay',
          'monthly rent',
          'compensation',
        ],
        builder: ({required id, required rawText, required normalizedText, required snippet}) {
          return LegalClause(
            id: id,
            title: 'Compensation & Payment Structure',
            category: 'Payment',
            importance: AttentionTier.informational,
            originalText: snippet.isNotEmpty
                ? snippet
                : 'Section detailing compensation amounts, schedules, or payment obligations.',
            plainLanguageExplanation:
                'Outlines the agreed financial payment, schedule, and any associated bonuses or deductions.',
            whyItMatters:
                'Establishes exactly how much money is paid, when disbursements occur, and preconditions for payment.',
            potentialConcern:
                'Pay attention to bonus discretion, late payment terms, or clawback provisions.',
            recommendedReview:
                'Confirm payment frequency and verify whether bonuses or expense reimbursements have mandatory deadlines.',
            confidence: ConfidenceLevel.high,
          );
        },
      ),

      // 2. Termination
      ClauseRule(
        category: 'Termination',
        title: 'Termination Conditions & Notice',
        defaultImportance: AttentionTier.review,
        keywords: const ['termination', 'terminate', 'at-will'],
        snippetTargets: const [
          'terminate this agreement',
          'at-will',
          'termination for cause',
          'without cause',
          'notice of termination',
        ],
        builder: ({required id, required rawText, required normalizedText, required snippet}) {
          final isHighNotice = normalizedText.contains('90') && normalizedText.contains('notice');
          return LegalClause(
            id: id,
            title: 'Termination Conditions & Notice',
            category: 'Termination',
            importance: isHighNotice ? AttentionTier.highAttention : AttentionTier.review,
            originalText: snippet.isNotEmpty
                ? snippet
                : 'Section governing how either party may end the agreement and required notice.',
            plainLanguageExplanation:
                'Explains under what conditions either side can cancel the contract, immediate cause triggers, and notice timelines.',
            whyItMatters:
                'Determines your freedom to exit and how vulnerable you are to sudden contract cancellation.',
            potentialConcern: isHighNotice
                ? 'The agreement requires 90 days\' notice. Review whether this period is consistent with your employment terms and applicable local requirements.'
                : 'Immediate termination clauses for cause should clearly specify what acts constitute cause.',
            recommendedReview:
                'Consider requesting symmetric termination rights and clarifying whether severance applies upon exit without cause.',
            confidence: ConfidenceLevel.high,
          );
        },
      ),

      // 3. Notice Period
      ClauseRule(
        category: 'Notice',
        title: 'Mandatory Notice Period',
        defaultImportance: AttentionTier.review,
        keywords: const ['notice period', 'written notice', 'days notice', 'days\' notice'],
        snippetTargets: const ['written notice', 'days notice', 'prior notice', 'advance notice'],
        builder: ({required id, required rawText, required normalizedText, required snippet}) {
          return LegalClause(
            id: id,
            title: 'Mandatory Notice Period',
            category: 'Notice',
            importance: AttentionTier.review,
            originalText: snippet.isNotEmpty
                ? snippet
                : 'Notice requirements specifying formal communication timeframes before action.',
            plainLanguageExplanation:
                'Defines how many days advance notice must be served in writing before termination, renewal, or modifications.',
            whyItMatters:
                'Failing to deliver notice within the specified window can trigger default or automatic continuation.',
            potentialConcern:
                'Unusually long notice windows may hinder career agility; extremely short notice leaves little preparation time.',
            recommendedReview: 'Add calendar reminders for all formal notice trigger windows.',
            confidence: ConfidenceLevel.high,
          );
        },
      ),

      // 4. Confidentiality
      ClauseRule(
        category: 'Confidentiality',
        title: 'Confidentiality & Non-Disclosure',
        defaultImportance: AttentionTier.informational,
        keywords: const ['confidential', 'non-disclosure', 'trade secret'],
        snippetTargets: const [
          'hold in strict confidence',
          'confidential information',
          'trade secrets',
          'proprietary information',
        ],
        builder: ({required id, required rawText, required normalizedText, required snippet}) {
          return LegalClause(
            id: id,
            title: 'Confidentiality & Non-Disclosure',
            category: 'Confidentiality',
            importance: AttentionTier.informational,
            originalText: snippet.isNotEmpty
                ? snippet
                : 'Section restricting disclosure of proprietary or sensitive party information.',
            plainLanguageExplanation:
                'Prohibits sharing trade secrets, financial records, client lists, or internal technical architectures with third parties.',
            whyItMatters:
                'Protects business secrets but remains legally binding even after the relationship terminates.',
            potentialConcern:
                'Check whether the confidentiality obligation has an expiration date (e.g. 3-5 years) or lasts indefinitely.',
            recommendedReview:
                'Verify standard exclusions exist (e.g., information already public or received legally from third parties).',
            confidence: ConfidenceLevel.high,
          );
        },
      ),

      // 5. Intellectual Property
      ClauseRule(
        category: 'Intellectual Property',
        title: 'Intellectual Property & Work Product Ownership',
        defaultImportance: AttentionTier.review,
        keywords: const [
          'intellectual property',
          'work made for hire',
          'inventions',
          'work product',
        ],
        snippetTargets: const [
          'work product ownership',
          'work made for hire',
          'all inventions',
          'patents, and work products',
          'intellectual property',
        ],
        builder: ({required id, required rawText, required normalizedText, required snippet}) {
          final coversPersonalTime = normalizedText.contains('outside standard') ||
              normalizedText.contains('at home') ||
              normalizedText.contains('personal time');
          return LegalClause(
            id: id,
            title: 'Intellectual Property & Work Product Ownership',
            category: 'Intellectual Property',
            importance: coversPersonalTime ? AttentionTier.highAttention : AttentionTier.review,
            originalText: snippet.isNotEmpty
                ? snippet
                : 'Clause assigning ownership of inventions and creations developed during the contract.',
            plainLanguageExplanation:
                'Specifies that work, code, algorithms, and designs created belong to the company rather than the individual.',
            whyItMatters:
                'Prevents you from repurposing code or inventions you built, and may even encumber personal side-projects.',
            potentialConcern: coversPersonalTime
                ? 'Language specifies inventions made outside standard working hours or using personal equipment, which may encumber personal side projects.'
                : 'Ensure pre-existing patents, open-source work, and tools are explicitly excluded in an Exhibit.',
            recommendedReview:
                'Request an explicit carve-out for personal hobby projects built entirely on personal devices without company resources.',
            confidence: ConfidenceLevel.high,
          );
        },
      ),

      // 6. Non-Compete
      ClauseRule(
        category: 'Non-Compete',
        title: 'Post-Termination Non-Compete Restriction',
        defaultImportance: AttentionTier.highAttention,
        keywords: const ['non-compete', 'compete directly', 'covenant not to compete'],
        snippetTargets: const [
          'non-compete',
          'shall not directly or indirectly engage in',
          'competes directly',
          'restrictive covenants',
        ],
        builder: ({required id, required rawText, required normalizedText, required snippet}) {
          return LegalClause(
            id: id,
            title: 'Post-Termination Non-Compete Restriction',
            category: 'Non-Compete',
            importance: AttentionTier.highAttention,
            originalText: snippet.isNotEmpty
                ? snippet
                : 'Clause restricting future employment or business activities with competitors.',
            plainLanguageExplanation:
                'Restricts you from working for, investing in, or consulting with competing businesses for a designated duration after leaving.',
            whyItMatters:
                'Directly limits your future career prospects, freelance opportunities, and ability to work in your area of expertise.',
            potentialConcern:
                'Requires attention: The agreement contains restrictive covenants post-termination. Review duration, geography, and scope with a qualified legal professional.',
            recommendedReview:
                'Consider professional legal review regarding local jurisdiction enforceability and negotiate narrower scope.',
            confidence: ConfidenceLevel.high,
          );
        },
      ),

      // 7. Non-Solicitation
      ClauseRule(
        category: 'Non-Solicitation',
        title: 'Non-Solicitation of Personnel & Clients',
        defaultImportance: AttentionTier.review,
        keywords: const ['non-solicitation', 'solicit or induce', 'solicit clients'],
        snippetTargets: const [
          'non-solicitation',
          'solicit or induce any employee',
          'solicit customers',
        ],
        builder: ({required id, required rawText, required normalizedText, required snippet}) {
          return LegalClause(
            id: id,
            title: 'Non-Solicitation of Personnel & Clients',
            category: 'Non-Solicitation',
            importance: AttentionTier.review,
            originalText: snippet.isNotEmpty
                ? snippet
                : 'Clause barring recruitment of coworkers or poaching of clients.',
            plainLanguageExplanation:
                'Prevents you from recruiting former colleagues or soliciting clients/customers for a specified period after departure.',
            whyItMatters:
                'Protects the enterprise from talent and revenue drain when key personnel depart.',
            potentialConcern:
                'Ensure the restriction applies only to clients you directly handled, not every client company-wide.',
            recommendedReview:
                'The agreement contains a restriction on solicitation. Consider reviewing its scope, duration, geography, and enforceability with a qualified legal professional.',
            confidence: ConfidenceLevel.high,
          );
        },
      ),

      // 8. Indemnity
      ClauseRule(
        category: 'Indemnity',
        title: 'Indemnification & Hold Harmless',
        defaultImportance: AttentionTier.highAttention,
        keywords: const ['indemnif', 'hold harmless'],
        snippetTargets: const [
          'indemnify, defend, and hold harmless',
          'shall indemnify',
          'indemnification',
        ],
        builder: ({required id, required rawText, required normalizedText, required snippet}) {
          return LegalClause(
            id: id,
            title: 'Indemnification & Hold Harmless',
            category: 'Indemnity',
            importance: AttentionTier.highAttention,
            originalText: snippet.isNotEmpty
                ? snippet
                : 'Clause requiring one party to compensate the other for legal losses or third-party claims.',
            plainLanguageExplanation:
                'Requires you to pay the legal defense and damages if a third party sues the other party over your work or conduct.',
            whyItMatters:
                'Can create uncapped personal financial liability for attorney fees and court settlements.',
            potentialConcern:
                'Requires attention: Uncapped indemnity without clear limits to proven gross negligence poses substantial risk.',
            recommendedReview:
                'Propose capping indemnity to actual insurance coverage or fees earned, and exclude ordinary inadvertent errors.',
            confidence: ConfidenceLevel.high,
          );
        },
      ),

      // 9. Liability Limitation
      ClauseRule(
        category: 'Liability',
        title: 'Limitation of Liability',
        defaultImportance: AttentionTier.review,
        keywords: const ['limitation of liability', 'consequential damages', 'total liability'],
        snippetTargets: const [
          'limitation of liability',
          'total liability under this agreement',
          'shall not exceed',
        ],
        builder: ({required id, required rawText, required normalizedText, required snippet}) {
          return LegalClause(
            id: id,
            title: 'Limitation of Liability',
            category: 'Liability',
            importance: AttentionTier.review,
            originalText: snippet.isNotEmpty
                ? snippet
                : 'Clause capping monetary damages payable in the event of a dispute.',
            plainLanguageExplanation:
                'Caps the maximum dollar compensation either party can recover if things go wrong under the contract.',
            whyItMatters:
                'Prevents catastrophic runaway damages, but may also prevent you from recovering full damages if the other party breaches.',
            potentialConcern: 'Check whether the liability cap is mutual or one-sided.',
            recommendedReview:
                'Ensure liability limits are mutual and fair to both contracting entities.',
            confidence: ConfidenceLevel.high,
          );
        },
      ),

      // 10. Dispute Resolution
      ClauseRule(
        category: 'Dispute Resolution',
        title: 'Dispute Resolution & Mandatory Arbitration',
        defaultImportance: AttentionTier.review,
        keywords: const ['dispute', 'arbitration', 'jams', 'aaa'],
        snippetTargets: const [
          'mandatory arbitration',
          'binding individual arbitration',
          'dispute, controversy',
          'jams',
        ],
        builder: ({required id, required rawText, required normalizedText, required snippet}) {
          final waivesClass =
              normalizedText.contains('class actions') || normalizedText.contains('jury');
          return LegalClause(
            id: id,
            title: 'Dispute Resolution & Mandatory Arbitration',
            category: 'Dispute Resolution',
            importance: waivesClass ? AttentionTier.review : AttentionTier.informational,
            originalText: snippet.isNotEmpty
                ? snippet
                : 'Clause mandating private arbitration rather than public court trials.',
            plainLanguageExplanation:
                'Requires all disputes to be handled through confidential private arbitration instead of a public courtroom or jury trial.',
            whyItMatters:
                'Arbitration is usually faster and private, but limits formal appeal rights and may waive class action participation.',
            potentialConcern:
                'Waiver of jury trials and class actions prevents collective bargaining in legal grievances.',
            recommendedReview:
                'Confirm who pays the arbitrator fees and whether the arbitration venue is reasonably accessible to you.',
            confidence: ConfidenceLevel.high,
          );
        },
      ),

      // 11. Governing Law
      ClauseRule(
        category: 'Governing Law',
        title: 'Governing Law & Legal Jurisdiction',
        defaultImportance: AttentionTier.informational,
        keywords: const ['governing law', 'state of', 'jurisdiction'],
        snippetTargets: const [
          'governed by and construed in accordance',
          'governing law',
          'laws of the state',
        ],
        builder: ({required id, required rawText, required normalizedText, required snippet}) {
          return LegalClause(
            id: id,
            title: 'Governing Law & Legal Jurisdiction',
            category: 'Governing Law',
            importance: AttentionTier.informational,
            originalText: snippet.isNotEmpty
                ? snippet
                : 'Designates which state or national legal statutes govern the interpretation of the contract.',
            plainLanguageExplanation:
                'Specifies which state\'s legal statutes and court systems will interpret and enforce the contract terms.',
            whyItMatters:
                'Different jurisdictions interpret non-competes, employment rights, and liability very differently.',
            potentialConcern:
                'If the chosen jurisdiction is distant from your domicile, resolving disputes could involve travel and out-of-state counsel costs.',
            recommendedReview:
                'Review whether the designated state has favorable statutory interpretations for your role.',
            confidence: ConfidenceLevel.high,
          );
        },
      ),

      // 12. Renewal
      ClauseRule(
        category: 'Renewal',
        title: 'Renewal & Extension Terms',
        defaultImportance: AttentionTier.review,
        keywords: const ['renew', 'automatic renewal', 'month-to-month'],
        snippetTargets: const [
          'automatic renewal',
          'renew on a month-to-month',
          'renewal date',
        ],
        builder: ({required id, required rawText, required normalizedText, required snippet}) {
          return LegalClause(
            id: id,
            title: 'Renewal & Extension Terms',
            category: 'Renewal',
            importance: AttentionTier.review,
            originalText: snippet.isNotEmpty
                ? snippet
                : 'Clause governing contract renewal and automatic extension cycles.',
            plainLanguageExplanation:
                'Specifies whether the contract automatically extends at the end of the term or requires affirmative re-signing.',
            whyItMatters:
                'Automatic renewal clauses (evergreen clauses) can lock you into future terms unless you cancel in a strict window.',
            potentialConcern:
                'Missing the opt-out window can inadvertently bind you to another entire contract cycle.',
            recommendedReview:
                'Mark cancellation notice deadlines on your calendar at least 60 days before the renewal cutoff.',
            confidence: ConfidenceLevel.high,
          );
        },
      ),

      // 13. Penalties
      ClauseRule(
        category: 'Penalties',
        title: 'Financial Penalties & Late Fees',
        defaultImportance: AttentionTier.review,
        keywords: const ['penalty', 'late fee', 'liquidated damages'],
        snippetTargets: const ['late fee', 'penalty', 'penalties'],
        builder: ({required id, required rawText, required normalizedText, required snippet}) {
          return LegalClause(
            id: id,
            title: 'Financial Penalties & Late Fees',
            category: 'Penalties',
            importance: AttentionTier.review,
            originalText: snippet.isNotEmpty
                ? snippet
                : 'Clause imposing fees or monetary penalties for delayed performance or payments.',
            plainLanguageExplanation:
                'Outlines predetermined fees charged if rent, reports, or obligations are submitted past specific deadlines.',
            whyItMatters: 'Adds unexpected financial burdens for minor delays.',
            potentialConcern: 'Cumulative per-day penalty structures can escalate quickly.',
            recommendedReview: 'Request a standard 5-to-10 day grace period before penalties accrue.',
            confidence: ConfidenceLevel.high,
          );
        },
      ),

      // 14. Refunds / Deposits
      ClauseRule(
        category: 'Refunds',
        title: 'Deposit Retention & Refund Terms',
        defaultImportance: AttentionTier.review,
        keywords: const ['refund', 'security deposit', 'deposit'],
        snippetTargets: const [
          'security deposit',
          'deposit with landlord',
          'deposit shall be returned',
          'refund',
        ],
        builder: ({required id, required rawText, required normalizedText, required snippet}) {
          return LegalClause(
            id: id,
            title: 'Deposit Retention & Refund Terms',
            category: 'Refunds',
            importance: AttentionTier.review,
            originalText: snippet.isNotEmpty
                ? snippet
                : 'Clause outlining deposit handling, deductions, and return conditions.',
            plainLanguageExplanation:
                'Explains how deposited funds are held, when deductions can be made for damages, and timelines for refunding.',
            whyItMatters:
                'Guarantees the conditions required to recover your money after the contract concludes.',
            potentialConcern:
                'Vague damage deduction rules may allow the holder to withhold funds improperly.',
            recommendedReview:
                'Ensure a mandatory move-in/move-out documented inspection is required prior to deductions.',
            confidence: ConfidenceLevel.high,
          );
        },
      ),

      // 15. Data Privacy
      ClauseRule(
        category: 'Data Privacy',
        title: 'Data Privacy & Governance',
        defaultImportance: AttentionTier.informational,
        keywords: const ['privacy', 'data', 'personal information', 'gdpr'],
        snippetTargets: const [
          'privacy',
          'data collection',
          'personal data',
          'proprietary data',
        ],
        builder: ({required id, required rawText, required normalizedText, required snippet}) {
          return LegalClause(
            id: id,
            title: 'Data Privacy & Governance',
            category: 'Data Privacy',
            importance: AttentionTier.informational,
            originalText: snippet.isNotEmpty
                ? snippet
                : 'Clause regarding processing, handling, or storage of personal information.',
            plainLanguageExplanation:
                'Governs how personal records, user data, or client confidential info must be stored, processed, and safeguarded.',
            whyItMatters: 'Mandates compliance with privacy standards and avoids security breaches.',
            potentialConcern:
                'Verify whether personal devices used for work could be subjected to corporate remote wiping.',
            recommendedReview: 'Clarify data retention schedules and device monitoring policies.',
            confidence: ConfidenceLevel.high,
          );
        },
      ),
    ];
  }
}
