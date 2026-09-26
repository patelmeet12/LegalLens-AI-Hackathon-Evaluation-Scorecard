import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:legallens_ai/services/document/document_parser_service.dart';

void main() {
  group('DocumentParserService Comprehensive Edge-Case Unit Tests', () {
    // 1. Empty document
    test('Case 1: empty document returns empty section list', () {
      final sections = DocumentParserService.splitIntoSections('');
      expect(sections, isEmpty);
    });

    // 2. Whitespace-only document
    test('Case 2: whitespace-only document returns empty section list', () {
      final sections = DocumentParserService.splitIntoSections('   \n\t  \r\n   \n   ');
      expect(sections, isEmpty);
    });

    // 3. Normal contract
    test('Case 3: normal contract splits into coherent sections with content preserved', () {
      const normalContract = '''
Preamble
This Agreement is entered into on January 1, 2025.

SECTION 1 DUTIES
The Consultant shall perform strategic software advisory services.

SECTION 2 COMPENSATION
The Company shall pay \$10,000 per month.
''';
      final sections = DocumentParserService.splitIntoSections(normalContract);
      expect(sections.length, 3);
      expect(sections[0].title, 'Preamble / Introduction');
      expect(sections[0].content, contains('January 1, 2025'));
      expect(sections[1].title, contains('SECTION 1 DUTIES'));
      expect(sections[1].content, contains('strategic software advisory services'));
      expect(sections[2].title, contains('SECTION 2 COMPENSATION'));
      expect(sections[2].content, contains('\$10,000 per month'));
    });

    // 4. Numbered sections
    test('Case 4: numbered sections (1. Title, 2. Title) detected cleanly', () {
      const numberedDoc = '''
1. APPOINTMENT AND SCOPE
Employee is appointed as Principal Architect.

2. TERM AND TERMINATION
Either party may terminate upon thirty days written notice.

3. CONFIDENTIALITY COVENANTS
Employee agrees not to disclose trade secrets.
''';
      final sections = DocumentParserService.splitIntoSections(numberedDoc);
      expect(sections.length, 3);
      expect(sections.any((s) => s.title.contains('1. APPOINTMENT AND SCOPE')), isTrue);
      expect(sections.any((s) => s.title.contains('2. TERM AND TERMINATION')), isTrue);
      expect(sections.any((s) => s.title.contains('3. CONFIDENTIALITY COVENANTS')), isTrue);
    });

    // 5. ARTICLE headings
    test('Case 5: ARTICLE headings (Roman numerals & numbers) detected', () {
      const articleDoc = '''
ARTICLE I DEFINITIONS
Terms used herein shall have standard definitions.

ARTICLE II GOVERNANCE
Board shall oversee operations.

ARTICLE 3 DISPUTE RESOLUTION
Binding arbitration under JAMS rules.
''';
      final sections = DocumentParserService.splitIntoSections(articleDoc);
      expect(sections.length, 3);
      expect(sections[0].title, contains('ARTICLE I DEFINITIONS'));
      expect(sections[1].title, contains('ARTICLE II GOVERNANCE'));
      expect(sections[2].title, contains('ARTICLE 3 DISPUTE RESOLUTION'));
    });

    // 6. SECTION headings
    test('Case 6: SECTION headings with various numerical formats detected', () {
      const sectionDoc = '''
SECTION 1 SCOPE OF SERVICES
Provider will deliver cloud migrations.

SECTION 2 FEES AND EXPENSES
Payment is net-30 days.

SECTION 10 MISCELLANEOUS
This agreement is governed by the laws of Delaware.
''';
      final sections = DocumentParserService.splitIntoSections(sectionDoc);
      expect(sections.length, 3);
      expect(sections[0].title, contains('SECTION 1'));
      expect(sections[1].title, contains('SECTION 2'));
      expect(sections[2].title, contains('SECTION 10'));
    });

    // 7. All-uppercase headings
    test('Case 7: all-uppercase headings without numbered prefix recognized as headers', () {
      const uppercaseDoc = '''
NON-DISCLOSURE AGREEMENT
This agreement protects proprietary technology.

CONFIDENTIAL INFORMATION
All non-public source code and customer lists.

PERMITTED DISCLOSURES
Disclosures required by subpoena or law.
''';
      final sections = DocumentParserService.splitIntoSections(uppercaseDoc);
      expect(sections.length, greaterThanOrEqualTo(2));
      expect(sections.any((s) => s.title.contains('NON-DISCLOSURE AGREEMENT') || s.title.contains('CONFIDENTIAL INFORMATION')), isTrue);
    });

    // 8. Malformed headings
    test('Case 8: malformed headings and noisy lines do not crash the parser', () {
      const malformedDoc = '''
### 1. (MALFORMED HEADER WITH SYMBOLS & COLONS) :::
This is text under malformed section 1.

ARTICLE ?!! INVALID ROMAN
Some content under strange article.

SECTION     99999    SPACED
Spaced section content.
''';
      final sections = DocumentParserService.splitIntoSections(malformedDoc);
      expect(sections, isNotEmpty);
      expect(sections.first.content, isNotEmpty);
    });

    // 9. Very large text
    test('Case 9: very large document (thousands of lines) parses without stack overflow', () {
      final buffer = StringBuffer();
      buffer.writeln('MASTER SERVICES FRAMEWORK AGREEMENT');
      buffer.writeln('Preamble text outlining general terms and business context.\n');
      for (int i = 1; i <= 50; i++) {
        buffer.writeln('SECTION $i SPECIFIC CLAUSE $i');
        buffer.writeln('This is paragraph 1 of section $i detailing rights and warranties.');
        buffer.writeln('This is paragraph 2 of section $i with additional covenants.');
        buffer.writeln();
      }

      final sections = DocumentParserService.splitIntoSections(buffer.toString());
      expect(sections.length, greaterThanOrEqualTo(50));
      expect(sections[0].title, contains('MASTER SERVICES'));
      expect(sections.last.content, contains('additional covenants'));
    });

    // 10. Text containing unusual Unicode characters
    test('Case 10: text containing unusual Unicode characters (emojis, accents, Cyrillic, Asian scripts)', () {
      const unicodeDoc = '''
⚖️ CONTRAT DE PRESTATION DE SERVICES / УСЛОВИЯ СОГЛАШЕНИЯ / 法律合同
Ce contrat régit la confidentialité et les droits d'auteur © 2025.

SECTION 1 DONNÉES PERSONNELLES & RGPD 🛡️
Les parties s'engagent à respecter le RGPD (Règlement Général sur la Protection des Données).
Rémunération: 100,000 € / ¥1,000,000 / ₽5,000,000.

SECTION 2 RÉSILIATION ET PRÉAVIS ⏱️
Préavis écrit de 30 jours sans pénalité.
''';
      final sections = DocumentParserService.splitIntoSections(unicodeDoc);
      expect(sections.length, greaterThanOrEqualTo(2));
      expect(sections.any((s) => s.content.contains('RGPD') && s.content.contains('100,000 €')), isTrue);
      expect(sections.any((s) => s.content.contains('Préavis écrit')), isTrue);
    });

    // 11. Text with multiple blank lines
    test('Case 11: text with multiple consecutive blank lines preserves paragraph structure without corruption', () {
      const multiBlankDoc = '''
SECTION 1 SEPARATION


Paragraph 1.



Paragraph 2 with deep gaps.




SECTION 2 SUBSEQUENT
Final clause paragraph.
''';
      final sections = DocumentParserService.splitIntoSections(multiBlankDoc);
      expect(sections.length, 2);
      expect(sections[0].title, contains('SECTION 1'));
      expect(sections[0].content, contains('Paragraph 1.'));
      expect(sections[0].content, contains('Paragraph 2 with deep gaps.'));
      expect(sections[1].title, contains('SECTION 2'));
    });

    test('Deterministic parsing: identical text yields identical section list across runs', () {
      const sample = '''
SECTION 1 FIRST
Text one.

SECTION 2 SECOND
Text two.
''';
      final runA = DocumentParserService.splitIntoSections(sample);
      final runB = DocumentParserService.splitIntoSections(sample);

      expect(runA.length, runB.length);
      for (int i = 0; i < runA.length; i++) {
        expect(runA[i].title, runB[i].title);
        expect(runA[i].content, runB[i].content);
        expect(runA[i].index, runB[i].index);
      }
    });

    test('extractTextFromPdf throws friendly Exception on invalid bytes', () async {
      final invalidBytes = Uint8List.fromList([0, 1, 2, 3, 4, 5]);
      expect(
        () async => await DocumentParserService.extractTextFromPdf(invalidBytes),
        throwsA(isA<Exception>()),
      );
    });
  });
}
