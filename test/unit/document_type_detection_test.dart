import 'package:flutter_test/flutter_test.dart';
import 'package:legallens_ai/services/ai/demo/document_type_detector.dart';

void main() {
  group('DocumentTypeDetector Unit Tests', () {
    late DocumentTypeDetector detector;

    setUp(() {
      detector = DocumentTypeDetector();
    });

    test('Detects Employment Agreement from employment terms', () {
      expect(detector.detect('executive employment agreement with base salary'), 'Employment Agreement');
      expect(detector.detect('at-will employment relationship and job title of manager'), 'Employment Agreement');
    });

    test('Detects Rental / Lease Agreement from tenancy terms', () {
      expect(detector.detect('residential lease agreement between landlord and tenant'), 'Rental / Lease Agreement');
      expect(detector.detect('monthly rent of \$2,500 for leased premises'), 'Rental / Lease Agreement');
    });

    test('Detects NDA from confidentiality and proprietary terms', () {
      expect(detector.detect('mutual non-disclosure agreement regarding confidential information'), 'NDA');
      expect(detector.detect('safeguard proprietary information under this nda'), 'NDA');
    });

    test('Detects Freelance Agreement from contractor terms', () {
      expect(detector.detect('independent contractor and freelance consulting agreement'), 'Freelance Agreement');
      expect(detector.detect('services rendered as a contractor'), 'Freelance Agreement');
    });

    test('Detects Service Agreement from SOW or MSA terms', () {
      expect(detector.detect('master services agreement and statement of work'), 'Service Agreement');
      expect(detector.detect('professional service agreement for infrastructure migration'), 'Service Agreement');
    });

    test('Falls back to General Contract when text lacks specific classification keywords', () {
      expect(detector.detect('mutual collaboration and protocol definitions'), 'General Contract');
      expect(detector.detect('the quick brown fox'), 'General Contract');
      expect(detector.detect(''), 'General Contract');
    });
  });
}
