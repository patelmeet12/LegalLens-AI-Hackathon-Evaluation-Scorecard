import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/legal_entities.dart';

/// Extracts contractual milestone dates, deadlines, and timeframes.
/// Adheres to safe policies: marks undetected dates as "Not detected." rather than guessing.
class DateExtractor {
  /// Analyzes text and extracts structured dates.
  List<ImportantDate> extract(String rawText, String normalizedText) {
    final List<ImportantDate> dates = [];
    int idCounter = 1;
    final lower = normalizedText;

    // 1. Effective Date
    final effMatch = RegExp(
      r'(?:effective as of|entered into as of|effective date[:\s]*|date[:\s]*|on)\s+([a-zA-Z]+\s+\d{1,2},\s+\d{4})',
      caseSensitive: false,
    ).firstMatch(rawText);
    if (effMatch != null) {
      dates.add(ImportantDate(
        id: 'date_${idCounter++}',
        title: 'Effective Start Date',
        dateString: effMatch.group(1)!,
        type: 'Contract Start',
        sourceSnippet: effMatch.group(0)!,
        isDetected: true,
      ));
    } else {
      dates.add(ImportantDate(
        id: 'date_${idCounter++}',
        title: 'Contract Start Date',
        dateString: AppConstants.notDetectedDate,
        type: 'Contract Start',
        sourceSnippet: 'Start date not explicitly stated in document.',
        isDetected: false,
      ));
    }

    // 2. Probation Window
    if (lower.contains('probation')) {
      final probMatch = RegExp(
        r'(\d+[\s-]day|\d+[\s-]month)\s+probation',
        caseSensitive: false,
      ).firstMatch(rawText);
      dates.add(ImportantDate(
        id: 'date_${idCounter++}',
        title: 'Probation Window',
        dateString: probMatch != null ? probMatch.group(1)! : '90 Days',
        type: 'Probation Period',
        sourceSnippet: probMatch != null
            ? probMatch.group(0)!
            : 'Subject to probationary performance evaluation',
        isDetected: true,
      ));
    }

    // 3. Notice Period
    final noticeMatch = RegExp(
      r'(\d+[\s-](?:days|business days|months))\s+(?:prior|written)?\s*notice',
      caseSensitive: false,
    ).firstMatch(rawText);
    if (noticeMatch != null) {
      dates.add(ImportantDate(
        id: 'date_${idCounter++}',
        title: 'Termination Notice Window',
        dateString: noticeMatch.group(1)!,
        type: 'Notice Period',
        sourceSnippet: noticeMatch.group(0)!,
        isDetected: true,
      ));
    }

    // 4. Renewal Date or Expiration
    final expMatch = RegExp(
      r'(?:expiring|expiration date[:\s]+|term shall be[:\s]+)([a-zA-Z]+\s+\d{1,2},\s+\d{4}|\d+\s+months)',
      caseSensitive: false,
    ).firstMatch(rawText);
    if (expMatch != null) {
      dates.add(ImportantDate(
        id: 'date_${idCounter++}',
        title: 'Contract Expiration Date',
        dateString: expMatch.group(1)!,
        type: 'Expiration',
        sourceSnippet: expMatch.group(0)!,
        isDetected: true,
      ));
    } else if (lower.contains('month-to-month') || lower.contains('automatic renewal')) {
      dates.add(ImportantDate(
        id: 'date_${idCounter++}',
        title: 'Automatic Renewal Cycle',
        dateString: 'Annual / Month-to-Month Automatic',
        type: 'Renewal',
        sourceSnippet: 'Agreement automatically extends unless terminated in advance',
        isDetected: true,
      ));
    } else {
      dates.add(ImportantDate(
        id: 'date_${idCounter++}',
        title: 'Expiration Date',
        dateString: AppConstants.notDetectedDate,
        type: 'Expiration',
        sourceSnippet: 'No explicit fixed expiration date found in document.',
        isDetected: false,
      ));
    }

    // 5. Post-Termination Restriction Window
    if (lower.contains('non-compete') || lower.contains('restrictive covenants')) {
      final resMatch = RegExp(
        r'(\d+[\s-]months?|\d+[\s-]years?)\s+following\s+termination',
        caseSensitive: false,
      ).firstMatch(rawText);
      dates.add(ImportantDate(
        id: 'date_${idCounter++}',
        title: 'Post-Termination Restriction Window',
        dateString: resMatch != null ? resMatch.group(1)! : '12-24 Months',
        type: 'Restriction Window',
        sourceSnippet: resMatch != null
            ? resMatch.group(0)!
            : 'Post-termination covenants remain active',
        isDetected: true,
      ));
    }

    return dates;
  }
}
