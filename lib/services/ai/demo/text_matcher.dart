import 'dart:math';

/// Utility service to extract context-aware verbatim snippets from document text.
class TextMatcher {
  /// Searches [text] for the first matching target in [targets] (case-insensitive)
  /// and returns a contextual excerpt bounded by [windowBefore] and [windowAfter].
  static String findSnippet(
    String text,
    List<String> targets, {
    int windowBefore = 40,
    int windowAfter = 260,
  }) {
    final lowerText = text.toLowerCase();
    for (final target in targets) {
      final idx = lowerText.indexOf(target.toLowerCase());
      if (idx != -1) {
        final start = max(0, idx - windowBefore);
        final end = min(text.length, idx + windowAfter);
        String snippet = text.substring(start, end).replaceAll('\n', ' ').trim();
        if (start > 0) snippet = '...$snippet';
        if (end < text.length) snippet = '$snippet...';
        return snippet;
      }
    }
    return '';
  }
}
