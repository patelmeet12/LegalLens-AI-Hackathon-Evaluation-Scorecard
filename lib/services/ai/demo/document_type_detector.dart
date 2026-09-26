/// Detects high-level document categories from normalized text heuristics.
class DocumentTypeDetector {
  /// Analyzes normalized text and returns an identified legal document type.
  String detect(String normalizedText) {
    final lower = normalizedText.toLowerCase();

    if (lower.contains('employment') ||
        lower.contains('employee') ||
        lower.contains('salary') ||
        lower.contains('job title') ||
        lower.contains('at-will employment')) {
      return 'Employment Agreement';
    } else if (lower.contains('lease') ||
        lower.contains('tenant') ||
        lower.contains('landlord') ||
        lower.contains('premises') ||
        lower.contains('monthly rent')) {
      return 'Rental / Lease Agreement';
    } else if (lower.contains('non-disclosure') ||
        lower.contains('confidential information') ||
        lower.contains('proprietary information') ||
        lower.contains('nda')) {
      return 'NDA';
    } else if (lower.contains('freelance') ||
        lower.contains('contractor') ||
        lower.contains('independent contractor') ||
        lower.contains('consulting agreement')) {
      return 'Freelance Agreement';
    } else if (lower.contains('service agreement') ||
        lower.contains('statement of work') ||
        lower.contains('master services agreement') ||
        lower.contains('msa')) {
      return 'Service Agreement';
    }

    return 'General Contract';
  }
}
