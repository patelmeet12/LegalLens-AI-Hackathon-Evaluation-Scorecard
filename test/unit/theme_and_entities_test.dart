import 'package:flutter_test/flutter_test.dart';
import 'package:legallens_ai/core/theme/app_theme.dart';
import 'package:legallens_ai/domain/entities/enums.dart';
import 'package:legallens_ai/domain/entities/legal_entities.dart';

void main() {

  group('AppColors Unit Tests', () {
    test('brand and attention color tokens are distinct and valid', () {
      expect(AppColors.primary, isNotNull);
      expect(AppColors.secondary, isNotNull);
      expect(AppColors.darkBg, isNotNull);
      expect(AppColors.lightBg, isNotNull);
      expect(AppColors.priorityAttention, isNot(equals(AppColors.priorityInfo)));
      expect(AppColors.priorityReview, isNot(equals(AppColors.priorityInfo)));
    });
  });

  group('LegalDocument and Options Serialization Tests', () {
    test('NextStep and LegalOption JSON round trip and copyWith', () {
      const step = NextStep(
        id: 's1',
        title: 'Review termination dates',
        description: 'Verify the 30-day notice requirement',
        priority: 'Immediate',
        isCompleted: false,
      );

      final stepJson = step.toJson();
      final revivedStep = NextStep.fromJson(stepJson);
      expect(revivedStep.id, 's1');
      expect(revivedStep.title, 'Review termination dates');
      expect(revivedStep.priority, 'Immediate');

      final updatedStep = step.copyWith(isCompleted: true);
      expect(updatedStep.isCompleted, true);

      const option = LegalOption(
        id: 'opt1',
        title: 'Option A: Sign as is',
        category: 'Acceptance',
        summary: 'Accept the agreement without modification',
        pros: ['Quick execution', 'Standard terms'],
        cons: ['No negotiation of non-compete'],
        riskProfile: AttentionTier.informational,
        actionableSteps: [step],
        suggestedDraftLanguage: 'Standard execution text',
      );

      final optJson = option.toJson();
      final revivedOpt = LegalOption.fromJson(optJson);
      expect(revivedOpt.id, 'opt1');
      expect(revivedOpt.title, 'Option A: Sign as is');
      expect(revivedOpt.pros.length, 2);
      expect(revivedOpt.cons.length, 1);
      expect(revivedOpt.actionableSteps.length, 1);
    });

    test('LegalDocument toJson and fromJson round trip', () {
      final now = DateTime.now();
      final doc = LegalDocument(
        id: 'doc_123',
        fileName: 'Agreement.txt',
        documentType: 'Employment Agreement',
        rawText: 'Employment text',
        charCount: 15,
        createdAt: now,
        snapshot: const LegalSnapshot(
          documentType: 'Employment Agreement',
          complexity: DocumentComplexity.moderate,
          attentionLevel: AttentionTier.review,
          executiveSummary: 'Executive summary',
          keyAreas: ['Term', 'Pay'],
          totalClauses: 1,
          highAttentionCount: 0,
          reviewCount: 1,
          informationalCount: 0,
        ),
        clauses: const [
          LegalClause(
            id: 'c1',
            title: 'Base Pay',
            category: 'Compensation',
            importance: AttentionTier.review,
            originalText: 'Pay is \$100k',
            plainLanguageExplanation: 'Annual salary',
            whyItMatters: 'Income',
            potentialConcern: 'Discretionary bonus',
            recommendedReview: 'Clarify target bonus',
          ),
        ],
        obligations: const [
          Obligation(
            id: 'o1',
            party: ObligationParty.your,
            description: 'Work 40 hours',
            sourceClause: 'Section 1',
          ),
        ],
        dates: const [
          ImportantDate(
            id: 'd1',
            title: 'Start',
            dateString: '2025-01-01',
            type: 'Start Date',
            sourceSnippet: 'Starts on 2025-01-01',
            isDetected: true,
          ),
        ],
        risks: const [
          RiskItem(
            id: 'r1',
            category: RiskCategory.financial,
            attentionLevel: AttentionTier.review,
            relevantClause: 'Section 2',
            explanation: 'Pay bonus is discretionary',
            recommendedAction: 'Ask for KPI target',
          ),
        ],
        lawyerQuestions: const [
          LawyerQuestion(
            id: 'q1',
            question: 'Is bonus guaranteed?',
            category: 'Bonus',
            contextReason: 'Discretionary clause',
            sourceClause: 'Section 2',
          ),
        ],
        checklist: const [
          ChecklistItem(
            id: 'k1',
            title: 'Verify start date',
            category: 'Pre-flight',
          ),
        ],
      );

      final json = doc.toJson();
      final revived = LegalDocument.fromJson(json);

      expect(revived.id, 'doc_123');
      expect(revived.fileName, 'Agreement.txt');
      expect(revived.clauses.length, 1);
      expect(revived.obligations.length, 1);
      expect(revived.dates.length, 1);
      expect(revived.risks.length, 1);
      expect(revived.lawyerQuestions.length, 1);
      expect(revived.checklist.length, 1);
    });
  });
}
