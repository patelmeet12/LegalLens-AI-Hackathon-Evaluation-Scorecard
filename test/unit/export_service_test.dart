import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:legallens_ai/core/constants/app_constants.dart';
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

    test('generateMarkdownReport exports all 8 challenge deliverables', () {
      final md = ExportService.generateMarkdownReport(doc);

      // Verify Header & Disclaimers
      expect(md, contains('LegalLens AI — Complete Legal Document Intelligence Report'));
      expect(md, contains('IMPORTANT LEGAL INFORMATION DISCLAIMER'));

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
      expect(map['clauses'], isA<List>());
      expect(map['obligations'], isA<List>());
      expect(map['dates'], isA<List>());
      expect(map['risks'], isA<List>());
      expect(map['options'], isA<List>());

      // Deserialization round-trip
      final revived = LegalDocument.fromJson(map);
      expect(revived.fileName, doc.fileName);
      expect(revived.options.length, doc.options.length);
    });
  });
}
