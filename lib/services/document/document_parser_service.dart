import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class DocumentSection {
  final int index;
  final String title;
  final String content;

  const DocumentSection({
    required this.index,
    required this.title,
    required this.content,
  });
}

class DocumentParserService {
  /// Extracts text from PDF bytes using Syncfusion PDF Text Extractor.
  /// Pure Dart, runs 100% client-side on Flutter Web.
  static Future<String> extractTextFromPdf(Uint8List bytes) async {
    try {
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      final String text = extractor.extractText();
      document.dispose();

      if (text.trim().isEmpty) {
        throw Exception(
            'Unable to extract text from this document. Please upload a text-readable PDF or paste the document text.');
      }
      return text;
    } catch (e) {
      if (e.toString().contains('Unable to extract text')) {
        rethrow;
      }
      throw Exception(
          'Unable to extract text from this document. Please upload a text-readable PDF or paste the document text.');
    }
  }

  /// Splits document text into structured sections by numbered headings or headers
  static List<DocumentSection> splitIntoSections(String text) {
    if (text.trim().isEmpty) return [];

    final lines = text.split('\n');
    final List<DocumentSection> sections = [];
    String currentTitle = 'Preamble / Introduction';
    final StringBuffer currentBuffer = StringBuffer();
    int sectionIndex = 0;

    final numberedPattern = RegExp(
      r'^(\d+[\.\)]\s+[A-Za-z\s]{3,}|SECTION\s+\d+|ARTICLE\s+[IVXLCDM\d]+)',
      caseSensitive: false,
    );

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        currentBuffer.writeln();
        continue;
      }

      final isAllCapsHeader = trimmed.length >= 4 &&
          trimmed.length < 70 &&
          trimmed == trimmed.toUpperCase() &&
          RegExp(r'[A-Z]').hasMatch(trimmed);

      final isNumberedHeader = numberedPattern.hasMatch(trimmed) && trimmed.length < 80;

      if (isAllCapsHeader || isNumberedHeader) {
        if (currentBuffer.toString().trim().isNotEmpty) {
          sections.add(
            DocumentSection(
              index: sectionIndex++,
              title: currentTitle,
              content: currentBuffer.toString().trim(),
            ),
          );
          currentBuffer.clear();
        }
        currentTitle = trimmed;
      } else {
        currentBuffer.writeln(line);
      }
    }

    if (currentBuffer.isNotEmpty) {
      sections.add(
        DocumentSection(
          index: sectionIndex,
          title: currentTitle,
          content: currentBuffer.toString().trim(),
        ),
      );
    }

    return sections;
  }
}
