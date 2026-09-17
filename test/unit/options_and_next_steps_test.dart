import 'package:flutter_test/flutter_test.dart';
import 'package:legallens_ai/core/constants/app_constants.dart';
import 'package:legallens_ai/domain/entities/enums.dart';
import 'package:legallens_ai/domain/entities/legal_entities.dart';
import 'package:legallens_ai/services/ai/demo_ai_provider.dart';

void main() {
  group('Options & Next Steps Strategic Generator Unit Tests', () {
    late DemoAIProvider provider;

    setUp(() {
      provider = DemoAIProvider();
    });

    test('Generates 4 distinct strategic options for Employment Agreement', () async {
      final result = await provider.analyzeDocument(
        text: AppConstants.sampleEmploymentAgreement,
        documentType: 'Employment Agreement',
        fileName: 'employment_contract.txt',
      );

      expect(result.options.length, 4);

      final optionTitles = result.options.map((o) => o.title).toList();
      expect(optionTitles, contains(contains('Execute Agreement As-Is')));
      expect(optionTitles, contains(contains('Propose Clarifications')));
      expect(optionTitles, contains(contains('Targeted Carve-Outs')));
      expect(optionTitles, contains(contains('Engage Professional Legal Counsel')));
    });

    test('Option 1 (Execute As-Is) contains pros, cons, and calendar reminders', () async {
      final result = await provider.analyzeDocument(
        text: AppConstants.sampleEmploymentAgreement,
        documentType: 'Employment Agreement',
        fileName: 'employment_contract.txt',
      );

      final opt1 = result.options.firstWhere((o) => o.category == 'Acceptance');
      expect(opt1.pros.isNotEmpty, isTrue);
      expect(opt1.cons.isNotEmpty, isTrue);
      expect(opt1.actionableSteps.length, greaterThanOrEqualTo(2));
      expect(opt1.actionableSteps.any((s) => s.title.toLowerCase().contains('calendar')), isTrue);
      expect(opt1.suggestedDraftLanguage.isNotEmpty, isTrue);
    });

    test('Option 2 (Balanced Redline) focuses on cure periods and reciprocity', () async {
      final result = await provider.analyzeDocument(
        text: AppConstants.sampleEmploymentAgreement,
        documentType: 'Employment Agreement',
        fileName: 'employment_contract.txt',
      );

      final opt2 = result.options.firstWhere((o) => o.category == 'Balanced Redline');
      expect(opt2.riskProfile, AttentionTier.review);
      expect(opt2.actionableSteps.any((s) => s.title.contains('15-day cure period')), isTrue);
      expect(opt2.actionableSteps.any((s) => s.title.toLowerCase().contains('reciprocal')), isTrue);
      expect(opt2.suggestedDraftLanguage.toLowerCase(), contains('cure period'));
    });

    test('Option 3 (Targeted Carve-Outs) includes IP exhibit and liability cap', () async {
      final result = await provider.analyzeDocument(
        text: AppConstants.sampleEmploymentAgreement,
        documentType: 'Employment Agreement',
        fileName: 'employment_contract.txt',
      );

      final opt3 = result.options.firstWhere((o) => o.category == 'Targeted Carve-Out');
      expect(opt3.actionableSteps.any((s) => s.title.contains('Exhibit of Prior Inventions')), isTrue);
      expect(opt3.actionableSteps.any((s) => s.title.toLowerCase().contains('liability cap')), isTrue);
      expect(opt3.actionableSteps.any((s) => s.title.toLowerCase().contains('restrictive covenant')), isTrue);
    });

    test('Option 4 (Legal Counsel) provides consultation steps and briefing text', () async {
      final result = await provider.analyzeDocument(
        text: AppConstants.sampleEmploymentAgreement,
        documentType: 'Employment Agreement',
        fileName: 'employment_contract.txt',
      );

      final opt4 = result.options.firstWhere((o) => o.category == 'Legal Counsel');
      expect(opt4.riskProfile, AttentionTier.informational);
      expect(opt4.actionableSteps.any((s) => s.title.contains('Export LegalLens Executive Summary')), isTrue);
      expect(opt4.actionableSteps.any((s) => s.title.toLowerCase().contains('30-minute consultation')), isTrue);
      expect(opt4.suggestedDraftLanguage.toLowerCase(), contains('counsel'));
    });

    test('NextStep model supports copyWith and completion toggle', () {
      const step = NextStep(
        id: 's1',
        title: 'Review Section 3',
        description: 'Verify 30-day notice requirement',
        priority: 'Immediate',
        isCompleted: false,
      );

      final completed = step.copyWith(isCompleted: true);
      expect(completed.isCompleted, isTrue);
      expect(completed.id, 's1');
      expect(completed.title, 'Review Section 3');
    });

    test('LegalOption JSON serialization round-trip maintains integrity', () {
      const original = LegalOption(
        id: 'opt_test',
        title: 'Test Strategic Option',
        category: 'Redline',
        summary: 'A test summary of consequences',
        pros: ['Pro 1', 'Pro 2'],
        cons: ['Con 1', 'Con 2'],
        riskProfile: AttentionTier.highAttention,
        actionableSteps: [
          NextStep(
            id: 'step_test',
            title: 'Test Step',
            description: 'Step description',
            priority: 'Immediate',
            isCompleted: true,
          ),
        ],
        suggestedDraftLanguage: 'Test email wording',
      );

      final json = original.toJson();
      final revived = LegalOption.fromJson(json);

      expect(revived.id, original.id);
      expect(revived.title, original.title);
      expect(revived.category, original.category);
      expect(revived.pros.length, 2);
      expect(revived.cons.length, 2);
      expect(revived.riskProfile, AttentionTier.highAttention);
      expect(revived.actionableSteps.length, 1);
      expect(revived.actionableSteps.first.isCompleted, isTrue);
      expect(revived.suggestedDraftLanguage, original.suggestedDraftLanguage);
    });
  });
}
