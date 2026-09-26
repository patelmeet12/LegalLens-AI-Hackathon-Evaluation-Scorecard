import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:legallens_ai/core/constants/app_constants.dart';
import 'package:legallens_ai/domain/entities/enums.dart';
import 'package:legallens_ai/domain/entities/legal_entities.dart';
import 'package:legallens_ai/services/ai/demo_ai_provider.dart';
import 'package:legallens_ai/services/export/export_service.dart';

void main() {
  group('ExportService Deliverables Report Unit Tests', () {
    late DemoAIProvider provider;
    late LegalDocument doc;

    setUp(() async {
      provider = DemoAIProvider();
      final result = await provider.analyzeDocument(
        text: AppConstants.sampleEmploymentAgreement,
        documentType: 'Employment Agreement',
        fileName: 'employment_test.txt',
      );

      doc = LegalDocument(
        id: 'test_doc_id',
        fileName: 'employment_test.txt',
        documentType: 'Employment Agreement',
        rawText: AppConstants.sampleEmploymentAgreement,
        charCount: AppConstants.sampleEmploymentAgreement.length,
        createdAt: DateTime.now(),
        snapshot: result.snapshot,
        clauses: result.clauses,
        obligations: result.obligations,
        dates: result.dates,
        risks: result.risks,
        lawyerQuestions: result.lawyerQuestions,
        checklist: result.checklist,
        options: result.options,
      );
    });

    test('generateMarkdownReport exports all 8 challenge deliverables with disclaimer', () {
      final md = ExportService.generateMarkdownReport(doc);

      // Verify Header & Disclaimers
      expect(md, contains('LegalLens AI — Complete Legal Document Intelligence Report'));
      expect(md, contains('IMPORTANT LEGAL INFORMATION DISCLAIMER'));
      expect(md, contains('does NOT constitute legal advice'));

      // 1. Executive Snapshot
      expect(md, contains('## 1. Executive Snapshot & Summary'));
      expect(md, contains('Complexity Score:'));

      // 2. Options & Next Steps
      expect(md, contains('## 2. Possible Strategic Options & Next Steps'));
      expect(md, contains('Option 1:'));
      expect(md, contains('Actionable Next Steps:'));

      // 3. Clause Intelligence
      expect(md, contains('## 3. Clause Intelligence & Plain-Language Explanations'));
      expect(md, contains('Original Verbatim Contract Text:'));

      // 4. Obligations
      expect(md, contains('## 4. Responsibility Breakdown (Obligations)'));
      expect(md, contains('Your Responsibilities'));
      expect(md, contains('Other Party Responsibilities'));

      // 5. Dates
      expect(md, contains('## 5. Important Dates & Milestone Timeline'));

      // 6. Risk Radar
      expect(md, contains('## 6. Risk & Attention Radar (6 Categories)'));

      // 7. Checklist
      expect(md, contains('## 7. Action Center: "Before You Sign" Preparation Checklist'));

      // 8. Lawyer Questions
      expect(md, contains('## 8. Personalized Questions for a Legal Professional'));
    });

    test('generateJsonReport outputs valid JSON with full schema parity', () {
      final jsonString = ExportService.generateJsonReport(doc);
      final dynamic decoded = jsonDecode(jsonString);

      expect(decoded, isA<Map<String, dynamic>>());
      final map = decoded as Map<String, dynamic>;
      expect(map['fileName'], 'employment_test.txt');
      expect(map['documentType'], 'Employment Agreement');
      expect(map['clauses'], isA<List<dynamic>>());
      expect(map['obligations'], isA<List<dynamic>>());
      expect(map['dates'], isA<List<dynamic>>());
      expect(map['risks'], isA<List<dynamic>>());
      expect(map['options'], isA<List<dynamic>>());

      // Deserialization round-trip
      final revived = LegalDocument.fromJson(map);
      expect(revived.fileName, doc.fileName);
      expect(revived.options.length, doc.options.length);
    });

    test('Empty document export produces clean structure without crashing', () {
      final emptyDoc = LegalDocument(
        id: 'empty_doc',
        fileName: 'empty.txt',
        documentType: 'General Contract',
        rawText: '',
        charCount: 0,
        createdAt: DateTime.now(),
        snapshot: const LegalSnapshot(
          documentType: 'General Contract',
          complexity: DocumentComplexity.simple,
          attentionLevel: AttentionTier.informational,
          executiveSummary: 'Empty document summary.',
          keyAreas: [],
          totalClauses: 0,
          highAttentionCount: 0,
          reviewCount: 0,
          informationalCount: 0,
        ),
        clauses: const [],
        obligations: const [],
        dates: const [],
        risks: const [],
        lawyerQuestions: const [],
        checklist: const [],
        options: const [],
      );

      final md = ExportService.generateMarkdownReport(emptyDoc);
      expect(md, contains('IMPORTANT LEGAL INFORMATION DISCLAIMER'));
      expect(md, contains('No specific timeline dates detected in document.'));

      final json = ExportService.generateJsonReport(emptyDoc);
      expect(json, contains('"clauses": []'));
      expect(json, contains('"options": []'));
    });

    test('Special characters, quotes, multiline text, and Unicode preserved in export', () {
      final specialDoc = LegalDocument(
        id: 'special_doc',
        fileName: 'special_«contrat»_©_2025.txt',
        documentType: 'Employment Agreement',
        rawText: 'Section 1: "Quotes", <brackets>, & ampersands.\nLine 2 with \ttabs.\nLine 3: ⚖️ €100,000 / ¥1,000,000.',
        charCount: 100,
        createdAt: DateTime.now(),
        snapshot: const LegalSnapshot(
          documentType: 'Employment Agreement',
          complexity: DocumentComplexity.moderate,
          attentionLevel: AttentionTier.review,
          executiveSummary: 'Executive summary with "quotes" and <tags> & symbols: ⚖️.',
          keyAreas: ['Payment', 'Confidentiality'],
          totalClauses: 1,
          highAttentionCount: 0,
          reviewCount: 1,
          informationalCount: 0,
        ),
        clauses: const [
          LegalClause(
            id: 'c_special',
            title: 'Multilingual & Special Clause «1»',
            category: 'Payment',
            importance: AttentionTier.review,
            originalText: 'Verbatim clause with quotes: "shall pay 100% of fees & expenses" up to €100,000.\nParagraph 2.',
            plainLanguageExplanation: 'Payment explanation with € and ¥ currency indicators.',
            whyItMatters: 'Guarantees agreed reimbursement & protections.',
            potentialConcern: 'Late fees accrue after 5 business days: > 2%.',
            recommendedReview: 'Review with local counsel & verify tax withholding.',
          ),
        ],
        obligations: const [
          Obligation(
            id: 'ob_spec',
            party: ObligationParty.your,
            description: 'Maintain confidentiality of code & "proprietary algorithms".',
            sourceClause: 'Section 4: Confidentiality & IP',
          ),
        ],
        dates: const [
          ImportantDate(
            id: 'd_spec',
            title: 'Notice & Cure Timeline',
            dateString: '30 days',
            type: 'Notice Period',
            sourceSnippet: 'Deliver 30 days "written notice" via certified courier.',
          ),
        ],
        risks: const [
          RiskItem(
            id: 'r_spec',
            category: RiskCategory.liability,
            attentionLevel: AttentionTier.review,
            relevantClause: 'Section 9: Indemnity & "Hold Harmless"',
            explanation: 'Broad indemnity covering third-party IP claims & damages.',
            recommendedAction: 'Propose capping indemnity to total fees paid (e.g. €50,000).',
            confidence: ConfidenceLevel.high,
          ),
        ],
        lawyerQuestions: const [
          LawyerQuestion(
            id: 'q_spec',
            question: 'Can Section 9 be amended to exclude indirect & consequential damages?',
            category: 'Liability',
            contextReason: 'Caps exposure under governing jurisdiction statutes.',
            sourceClause: 'Section 9: Indemnity',
          ),
        ],
        checklist: const [
          ChecklistItem(
            id: 'chk_spec',
            title: 'Verify all "Exhibits" & appendices are attached prior to signing',
            category: 'Legal Review',
            isChecked: true,
          ),
        ],
        options: const [
          LegalOption(
            id: 'opt_spec',
            title: 'Redline & Negotiate Mutual Terms',
            category: 'Balanced Redline',
            summary: 'Propose adjustments for reciprocal indemnification & liability caps.',
            pros: ['Balances risk & establishes fair commercial partnership'],
            cons: ['May require 48h counter-review delay'],
            riskProfile: AttentionTier.review,
            actionableSteps: [
              NextStep(
                id: 's_spec',
                title: 'Send formal redline draft',
                description: 'Email revised draft to counterparty legal counsel.',
                priority: 'Immediate',
              ),
            ],
            suggestedDraftLanguage: 'Attached please find our proposed revisions to Section 9.',
          ),
        ],
      );

      final md = ExportService.generateMarkdownReport(specialDoc);
      expect(md, contains('special_«contrat»_©_2025.txt'));
      expect(md, contains('⚖️'));
      expect(md, contains('€100,000'));
      expect(md, contains('"shall pay 100% of fees & expenses"'));
      expect(md, contains('Attached please find our proposed revisions'));

      final jsonString = ExportService.generateJsonReport(specialDoc);
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      expect(decoded['fileName'], contains('special_«contrat»_©_2025.txt'));
      expect(decoded['clauses'][0]['title'], contains('Multilingual & Special Clause «1»'));
      expect(decoded['options'][0]['pros'][0], contains('Balances risk & establishes fair'));
    });
  });
}
