import '../../../domain/entities/enums.dart';
import '../../../domain/entities/legal_entities.dart';

/// Generates 4 strategic options and actionable next steps for the user before signing.
class OptionsGenerator {
  /// Generates strategic options tailored to document risk profile.
  List<LegalOption> generate(
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
        pros: const [
          'Immediate execution with zero negotiation delay',
          'Preserves counterparty momentum and relationship goodwill',
          'Zero legal or administrative friction',
        ],
        cons: [
          'You remain strictly bound by all unilateral obligations and covenants',
          if (hasHighAttention)
            'High-attention clauses ($riskCategories) remain active and unmitigated',
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
            description:
                'Ensure confidentiality and indemnity protections apply bilaterally to both parties.',
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
            description:
                'List all open-source repositories and side projects created prior to signing.',
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
            description:
                'Narrow non-compete period and restrict geographic reach to direct competitors.',
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
        pros: const [
          'Provides formal, binding legal advice tailored to specific local laws',
          'Attorney-client privileged assessment of high-attention items',
          'Direct professional representation in negotiations if needed',
        ],
        cons: const [
          'Incurs hourly professional legal fees (\$250–\$600/hr)',
          'Requires scheduling lead time and coordination',
        ],
        riskProfile: AttentionTier.informational,
        actionableSteps: const [
          NextStep(
            id: 'step_4_1',
            title: 'Export LegalLens Executive Summary & Lawyer Questions',
            description:
                'Download the synthesized report to minimize attorney consultation billing time.',
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
            description:
                'Direct the attorney to Section-specific questions generated by LegalLens AI.',
            priority: 'Before Signing',
          ),
        ],
        suggestedDraftLanguage:
            'Hello [Counsel Name], I have received a $docType under review with key attention areas around $riskCategories. I have prepared an executive briefing and specific clause questions via LegalLens AI and would like to schedule a 30-minute review session.',
      ),
    ];
  }
}
