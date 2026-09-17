import 'package:flutter_test/flutter_test.dart';
import 'package:legallens_ai/services/document/document_parser_service.dart';

void main() {
  group('DocumentParserService Unit Tests', () {
    test('Splits document into logical structured sections by headings', () {
      const sample = '''
EMPLOYMENT AGREEMENT

1. POSITION AND DUTIES
Alex is hired as engineer.

2. COMPENSATION AND BENEFITS
Base salary is \$185,000 per annum.

3. TERM AND TERMINATION
At-will employment with 90 days notice.
''';

      final sections = DocumentParserService.splitIntoSections(sample);
      expect(sections.isNotEmpty, isTrue);
      expect(sections.any((s) => s.title.contains('POSITION') || s.title.contains('COMPENSATION')), isTrue);
    });

    test('Handles empty text gracefully without throwing', () {
      final sections = DocumentParserService.splitIntoSections('');
      expect(sections.isEmpty, isTrue);
    });

    test('Preamble section created when text has no leading header', () {
      const sample = 'This is an unstructured contract agreement between party A and party B.';
      final sections = DocumentParserService.splitIntoSections(sample);
      expect(sections.length, 1);
      expect(sections.first.title, contains('Preamble'));
      expect(sections.first.content, contains('unstructured contract'));
    });
  });
}
