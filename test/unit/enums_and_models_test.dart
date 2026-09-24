import 'package:flutter_test/flutter_test.dart';
import 'package:legallens_ai/domain/entities/enums.dart';
import 'package:legallens_ai/domain/entities/legal_entities.dart';

void main() {
  group('Domain Enums Coverage Tests', () {
    test('AttentionTier labels and emojis', () {
      expect(AttentionTier.informational.label, 'Informational');
      expect(AttentionTier.informational.emojiIcon, '🟢');

      expect(AttentionTier.review.label, 'Requires Review');
      expect(AttentionTier.review.emojiIcon, '🟡');

      expect(AttentionTier.highAttention.label, 'High Attention');
      expect(AttentionTier.highAttention.emojiIcon, '🔴');
    });

    test('DocumentComplexity labels', () {
      expect(DocumentComplexity.simple.label, 'Simple');
      expect(DocumentComplexity.moderate.label, 'Moderate');
      expect(DocumentComplexity.complex.label, 'Complex');
    });

    test('ConfidenceLevel labels', () {
      expect(ConfidenceLevel.high.label, 'High Confidence');
      expect(ConfidenceLevel.medium.label, 'Moderate Confidence');
      expect(ConfidenceLevel.low.label, 'Low Confidence');
    });

    test('ObligationParty titles', () {
      expect(ObligationParty.your.title, 'Your Responsibilities');
      expect(ObligationParty.otherParty.title, 'Other Party Responsibilities');
      expect(ObligationParty.shared.title, 'Shared Responsibilities');
    });

    test('RiskCategory labels', () {
      expect(RiskCategory.financial.label, 'Financial Terms & Penalties');
      expect(RiskCategory.employment.label, 'Employment & Termination');
      expect(RiskCategory.privacy.label, 'Privacy & Data Governance');
      expect(RiskCategory.liability.label, 'Liability & Indemnification');
      expect(RiskCategory.intellectualProperty.label, 'Intellectual Property Ownership');
      expect(RiskCategory.restrictions.label, 'Post-Term Restrictive Covenants');
    });
  });

  group('Domain Entities Serialization & CopyWith Tests', () {
    test('LegalClause JSON round trip and null fallbacks', () {
      const clause = LegalClause(
        id: 'c1',
        title: 'Title',
        category: 'Category',
        importance: AttentionTier.highAttention,
        originalText: 'Original',
        plainLanguageExplanation: 'Explanation',
        whyItMatters: 'Why',
        potentialConcern: 'Concern',
        recommendedReview: 'Review',
      );

      final json = clause.toJson();
      final revived = LegalClause.fromJson(json);

      expect(revived.id, clause.id);
      expect(revived.title, clause.title);
      expect(revived.importance, AttentionTier.highAttention);
      expect(revived.potentialConcern, 'Concern');
      expect(revived.recommendedReview, 'Review');
    });

    test('Obligation JSON round trip', () {
      const ob = Obligation(
        id: 'o1',
        party: ObligationParty.otherParty,
        description: 'Deliver goods',
        sourceClause: 'Section 4',
      );

      final json = ob.toJson();
      final revived = Obligation.fromJson(json);

      expect(revived.id, 'o1');
      expect(revived.party, ObligationParty.otherParty);
    });

    test('ImportantDate JSON round trip', () {
      const date = ImportantDate(
        id: 'd1',
        title: 'Start',
        dateString: '2025-01-01',
        type: 'Effective',
        sourceSnippet: 'Snippet',
        isDetected: true,
      );

      final json = date.toJson();
      final revived = ImportantDate.fromJson(json);

      expect(revived.id, 'd1');
      expect(revived.isDetected, true);
    });

    test('RiskItem JSON round trip', () {
      const risk = RiskItem(
        id: 'r1',
        category: RiskCategory.liability,
        attentionLevel: AttentionTier.review,
        relevantClause: 'Section 9',
        explanation: 'Requires review: uncapped liability',
        recommendedAction: 'Add mutual cap',
      );

      final json = risk.toJson();
      final revived = RiskItem.fromJson(json);

      expect(revived.category, RiskCategory.liability);
      expect(revived.attentionLevel, AttentionTier.review);
    });

    test('LawyerQuestion JSON round trip', () {
      const question = LawyerQuestion(
        id: 'q1',
        question: 'Is this enforceable?',
        category: 'Non-Compete',
        contextReason: 'State restrictions',
        sourceClause: 'Section 12',
      );

      final json = question.toJson();
      final revived = LawyerQuestion.fromJson(json);

      expect(revived.id, 'q1');
      expect(revived.question, 'Is this enforceable?');
    });

    test('ChecklistItem JSON round trip and copyWith', () {
      const item = ChecklistItem(
        id: 'ck1',
        title: 'Task 1',
        category: 'HR',
        isCustom: false,
        isChecked: false,
      );

      final json = item.toJson();
      final revived = ChecklistItem.fromJson(json);
      expect(revived.title, 'Task 1');
      expect(revived.isChecked, false);

      final toggled = item.copyWith(isChecked: true, title: 'Updated Task');
      expect(toggled.isChecked, true);
      expect(toggled.title, 'Updated Task');
    });

    test('LegalSnapshot JSON round trip', () {
      const snapshot = LegalSnapshot(
        documentType: 'NDA',
        complexity: DocumentComplexity.simple,
        attentionLevel: AttentionTier.informational,
        executiveSummary: 'Brief summary',
        keyAreas: ['Term', 'Exclusions'],
        totalClauses: 2,
        highAttentionCount: 0,
        reviewCount: 0,
        informationalCount: 2,
      );

      final json = snapshot.toJson();
      final revived = LegalSnapshot.fromJson(json);

      expect(revived.documentType, 'NDA');
      expect(revived.complexity, DocumentComplexity.simple);
      expect(revived.keyAreas.length, 2);
    });

    test('ClauseDiff and DocumentComparison models', () {
      const diff = ClauseDiff(
        clauseTitle: 'Severance',
        docAText: '3 months',
        docBText: '6 months',
        changeSummary: 'Higher protection',
        differenceTier: AttentionTier.review,
      );

      expect(diff.clauseTitle, 'Severance');
      expect(diff.changeSummary, 'Higher protection');

      const comp = DocumentComparison(
        docAName: 'Doc A',
        docBName: 'Doc B',
        addedClauses: ['Bonus'],
        removedClauses: ['Overtime'],
        changedClauses: [diff],
        changedFinancialTerms: ['Salary'],
        changedObligations: ['Reporting'],
        changedDates: ['Notice period'],
        highAttentionDifferences: ['Severance changed'],
      );

      expect(comp.docAName, 'Doc A');
      expect(comp.docBName, 'Doc B');
      expect(comp.addedClauses.length, 1);
      expect(comp.removedClauses.length, 1);
      expect(comp.changedClauses.length, 1);
    });
  });
}
