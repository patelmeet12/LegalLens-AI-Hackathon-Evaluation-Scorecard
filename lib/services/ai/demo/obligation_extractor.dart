import '../../../domain/entities/enums.dart';
import '../../../domain/entities/legal_entities.dart';

/// Extracts contractual obligations and partitions them across parties:
/// Your responsibilities, Other Party responsibilities, and Shared/Mutual duties.
class ObligationExtractor {
  /// Analyzes text and extracts structured obligations.
  List<Obligation> extract(String rawText, String normalizedText) {
    final List<Obligation> list = [];
    int idCounter = 1;
    final lower = normalizedText;

    // 1. Your Responsibilities
    if (lower.contains('employee') ||
        lower.contains('tenant') ||
        lower.contains('receiving party') ||
        lower.contains('contractor')) {
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
          description:
              'Maintain strict confidentiality of trade secrets and proprietary data during and post-term',
          sourceClause: 'Confidentiality Section',
        ));
      }
      if (lower.contains('non-compete') || lower.contains('restrictive')) {
        list.add(Obligation(
          id: 'ob_${idCounter++}',
          party: ObligationParty.your,
          description:
              'Refrain from engaging with or consulting for direct competitors during restriction window',
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

    // 2. Other Party Responsibilities
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
        description:
            'Return refundable security deposit within 30 days of lease expiration less documented damages',
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

    // 3. Shared / Mutual Responsibilities
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
        description:
            'Execute all amendments or modifications jointly in writing signed by both authorized parties',
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
}
