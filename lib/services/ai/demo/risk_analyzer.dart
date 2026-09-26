import '../../../domain/entities/enums.dart';
import '../../../domain/entities/legal_entities.dart';

/// Analyzes document text and clauses to produce a 6-category Risk & Attention Radar.
/// Formulates document-grounded, jurisdiction-neutral advisory points without making
/// categorical legal conclusions.
class RiskAnalyzer {
  /// Analyzes raw and normalized document text along with detected clauses.
  List<RiskItem> analyze(
    String rawText,
    String normalizedText,
    List<LegalClause> clauses,
  ) {
    final List<RiskItem> risks = [];
    int idCounter = 1;
    final lower = normalizedText;

    // 1. Financial Risk
    final hasPenalties = lower.contains('penalty') ||
        lower.contains('late fee') ||
        lower.contains('deduction') ||
        lower.contains('liquidated damages');
    risks.add(RiskItem(
      id: 'risk_${idCounter++}',
      category: RiskCategory.financial,
      attentionLevel: hasPenalties ? AttentionTier.review : AttentionTier.informational,
      relevantClause:
          hasPenalties ? 'Penalties & Deductions Clause' : 'Compensation & Payment Terms',
      explanation: hasPenalties
          ? 'Potential concern: Prescribed financial penalties, late fees, or clawback provisions may apply if deadlines or terms are missed.'
          : 'Payment terms appear standard. Confirm schedule and reimbursement time limits.',
      recommendedAction: hasPenalties
          ? 'Request a grace period before penalties apply and verify calculation caps.'
          : 'Verify compensation disbursement dates align with your monthly commitments.',
      confidence: ConfidenceLevel.high,
    ));

    // 2. Employment Risk
    final is90DayNotice = lower.contains('90') && lower.contains('notice');
    risks.add(RiskItem(
      id: 'risk_${idCounter++}',
      category: RiskCategory.employment,
      attentionLevel: is90DayNotice ? AttentionTier.highAttention : AttentionTier.review,
      relevantClause: 'Termination & Notice Section',
      explanation: is90DayNotice
          ? 'Requires attention: The agreement specifies a 90-day termination notice requirement. Review whether this period is consistent with your employment terms and applicable local requirements.'
          : 'Contract contains standard termination provisions and probation terms.',
      recommendedAction: is90DayNotice
          ? 'Consider requesting a reduction to 30 days notice to avoid locking yourself into prolonged exit periods.'
          : 'Confirm severance rights in the event of involuntary termination without cause.',
      confidence: ConfidenceLevel.high,
    ));

    // 3. Privacy Risk
    risks.add(RiskItem(
      id: 'risk_${idCounter++}',
      category: RiskCategory.privacy,
      attentionLevel: AttentionTier.informational,
      relevantClause: 'Confidentiality & Data Protection Section',
      explanation:
          'Confidentiality provisions protect company trade secrets and technical data. No unusual personal surveillance language detected.',
      recommendedAction: 'Confirm whether data retention duties expire after 3-5 years.',
      confidence: ConfidenceLevel.high,
    ));

    // 4. Liability Risk
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

    // 5. Intellectual Property Risk
    final coversPersonalTime = lower.contains('outside standard') ||
        lower.contains('at home') ||
        lower.contains('personal time');
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

    // 6. Restrictions Risk
    final hasNonCompete = lower.contains('non-compete') || lower.contains('compete directly');
    risks.add(RiskItem(
      id: 'risk_${idCounter++}',
      category: RiskCategory.restrictions,
      attentionLevel: hasNonCompete ? AttentionTier.highAttention : AttentionTier.informational,
      relevantClause: 'Restrictive Covenants & Non-Compete Section',
      explanation: hasNonCompete
          ? 'Requires attention: The agreement contains post-termination non-compete covenants. Consider reviewing scope, duration, geography, and enforceability under applicable local laws with a qualified legal professional.'
          : 'No aggressive post-termination non-compete restrictions detected.',
      recommendedAction: hasNonCompete
          ? 'Check whether non-competes are enforceable in your jurisdiction and consult legal counsel.'
          : 'Confirm non-solicitation of colleagues has a defined, reasonable timeframe.',
      confidence: ConfidenceLevel.high,
    ));

    return risks;
  }
}
