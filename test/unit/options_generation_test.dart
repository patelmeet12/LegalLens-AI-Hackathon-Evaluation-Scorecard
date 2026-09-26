import 'package:flutter_test/flutter_test.dart';
import 'package:legallens_ai/domain/entities/enums.dart';
import 'package:legallens_ai/domain/entities/legal_entities.dart';
import 'package:legallens_ai/services/ai/demo/options_generator.dart';

void main() {
  group('OptionsGenerator Subcomponent Unit Tests', () {
    late OptionsGenerator generator;

    setUp(() {
      generator = OptionsGenerator();
    });

    test('Generates 4 strategic paths with distinct risk profiles', () {
      final clauses = [
        const LegalClause(
          id: 'c1',
          title: 'Termination Clause',
          category: 'Termination',
          importance: AttentionTier.highAttention,
          originalText: '90 days notice required.',
          plainLanguageExplanation: '90 days exit notice.',
          whyItMatters: 'Limits agility.',
          potentialConcern: 'Longer notice.',
          recommendedReview: 'Shorten to 30 days.',
        ),
      ];

      final risks = [
        const RiskItem(
          id: 'r1',
          category: RiskCategory.employment,
          attentionLevel: AttentionTier.highAttention,
          relevantClause: 'Termination Clause',
          explanation: '90-day notice requirement.',
          recommendedAction: 'Request 30-day notice.',
          confidence: ConfidenceLevel.high,
        ),
      ];

      final options = generator.generate(clauses, risks, 'Employment Agreement');
      expect(options.length, 4);

      final opt1 = options[0]; // Acceptance
      final opt2 = options[1]; // Balanced Redline
      final opt3 = options[2]; // Targeted Carve-Out
      final opt4 = options[3]; // Legal Counsel

      expect(opt1.category, 'Acceptance');
      expect(opt1.riskProfile, AttentionTier.highAttention); // Inherits highAttention because of risk

      expect(opt2.category, 'Balanced Redline');
      expect(opt2.riskProfile, AttentionTier.review);

      expect(opt3.category, 'Targeted Carve-Out');
      expect(opt3.riskProfile, AttentionTier.review);

      expect(opt4.category, 'Legal Counsel');
      expect(opt4.riskProfile, AttentionTier.informational);

      for (final opt in options) {
        expect(opt.pros, isNotEmpty);
        expect(opt.cons, isNotEmpty);
        expect(opt.actionableSteps, isNotEmpty);
        expect(opt.suggestedDraftLanguage, isNotEmpty);
      }
    });

    test('Option 1 riskProfile drops to informational when there are no high-attention clauses', () {
      final options = generator.generate([], [], 'General Contract');
      expect(options.first.riskProfile, AttentionTier.informational);
    });
  });
}
