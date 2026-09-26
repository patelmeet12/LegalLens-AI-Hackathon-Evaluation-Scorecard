import 'package:flutter_test/flutter_test.dart';
import 'package:legallens_ai/core/constants/app_constants.dart';
import 'package:legallens_ai/services/ai/demo/date_extractor.dart';

void main() {
  group('DateExtractor Unit Tests & Safe Fallback Policy', () {
    late DateExtractor extractor;

    setUp(() {
      extractor = DateExtractor();
    });

    test('Positive: Extracts explicit contract dates with isDetected = true', () {
      const text = '''
This Agreement is entered into as of March 1, 2025.
The Employee is subject to a 90-day probation review.
Termination requires 30 days written notice.
The agreement term shall be: December 31, 2026.
Non-compete covenants shall remain active for 12 months following termination.
''';

      final dates = extractor.extract(text, text.toLowerCase());
      expect(dates, isNotEmpty);

      final startDate = dates.firstWhere((d) => d.type == 'Contract Start');
      expect(startDate.isDetected, isTrue);
      expect(startDate.dateString, 'March 1, 2025');

      final probation = dates.firstWhere((d) => d.type == 'Probation Period');
      expect(probation.isDetected, isTrue);
      expect(probation.dateString, contains('90-day'));

      final notice = dates.firstWhere((d) => d.type == 'Notice Period');
      expect(notice.isDetected, isTrue);
      expect(notice.dateString, contains('30 days'));

      final expiration = dates.firstWhere((d) => d.type == 'Expiration');
      expect(expiration.isDetected, isTrue);
      expect(expiration.dateString, 'December 31, 2026');

      final restriction = dates.firstWhere((d) => d.type == 'Restriction Window');
      expect(restriction.isDetected, isTrue);
      expect(restriction.dateString, contains('12 months'));
    });

    test('Positive: Detects automatic renewal cycle when fixed date is absent', () {
      const text = 'The contract will continue with automatic renewal on a month-to-month cycle.';
      final dates = extractor.extract(text, text.toLowerCase());

      final renewal = dates.firstWhere((d) => d.type == 'Renewal');
      expect(renewal.isDetected, isTrue);
      expect(renewal.dateString, contains('Automatic'));
    });

    test('Negative & Safe Fallback: Missing dates are marked Not detected with isDetected = false', () {
      const text = 'The parties agree to mutual non-disclosure and trade secret protection.';
      final dates = extractor.extract(text, text.toLowerCase());

      final startDate = dates.firstWhere((d) => d.type == 'Contract Start');
      expect(startDate.isDetected, isFalse);
      expect(startDate.dateString, AppConstants.notDetectedDate);

      final expiration = dates.firstWhere((d) => d.type == 'Expiration');
      expect(expiration.isDetected, isFalse);
      expect(expiration.dateString, AppConstants.notDetectedDate);

      expect(dates.any((d) => d.type == 'Probation Period'), isFalse);
      expect(dates.any((d) => d.type == 'Notice Period'), isFalse);
      expect(dates.any((d) => d.type == 'Restriction Window'), isFalse);
    });
  });
}
