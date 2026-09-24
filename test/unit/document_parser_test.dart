import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:legallens_ai/services/document/document_parser_service.dart';

void main() {
  group('DocumentParserService Unit Tests', () {
    test('splitIntoSections returns empty list for empty text', () {
      final sections = DocumentParserService.splitIntoSections('   ');
      expect(sections, isEmpty);
    });

    test('splitIntoSections parses preamble, all-caps headers, and numbered sections', () {
      const sampleText = '''
CONFIDENTIAL EMPLOYMENT AGREEMENT
This agreement is made between Company and Employee.

SECTION 1 COMPENSATION
Employee will receive a base salary of \$150,000 per annum.

2. TERM AND TERMINATION
The employment shall continue until terminated by either party upon 30 days notice.

ARTICLE III MISCELLANEOUS
This agreement constitutes the entire understanding between the parties.
''';

      final sections = DocumentParserService.splitIntoSections(sampleText);
      expect(sections.isNotEmpty, true);
      expect(sections.length, greaterThanOrEqualTo(3));
      expect(sections[0].title, contains('CONFIDENTIAL EMPLOYMENT AGREEMENT'));
      expect(sections.any((s) => s.title.contains('SECTION 1 COMPENSATION')), true);
      expect(sections.any((s) => s.title.contains('2. TERM AND TERMINATION')), true);
      expect(sections.any((s) => s.title.contains('ARTICLE III MISCELLANEOUS')), true);
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
