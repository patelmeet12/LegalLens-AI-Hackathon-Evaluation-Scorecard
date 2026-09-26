import '../../../domain/entities/legal_entities.dart';

/// Generates an actionable "Before You Sign" preparation checklist.
class ChecklistGenerator {
  /// Generates a standardized list of pre-signature verification items.
  List<ChecklistItem> generate(List<LegalClause> clauses) {
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
}
