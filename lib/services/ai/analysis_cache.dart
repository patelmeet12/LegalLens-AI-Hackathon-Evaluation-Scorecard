import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'ai_provider.dart';

/// In-memory content-addressed cache for legal document analysis results.
/// Uses SHA-256 of the normalized document text (and document type) to provide
/// deterministic O(1) lookups, completely decoupled from filenames or volatile paths.
class AnalysisCache {
  final Map<String, LegalAnalysisResult> _store = {};
  int _hits = 0;
  int _misses = 0;

  /// Returns total number of cached analysis results.
  int get size => _store.length;

  /// Cumulative cache hit count.
  int get hits => _hits;

  /// Cumulative cache miss count.
  int get misses => _misses;

  /// Computes a deterministic SHA-256 hash of the normalized document content.
  /// Two documents with the same content will always produce the identical key,
  /// while documents with even a single changed character produce distinct keys.
  static String computeKey({required String text, String documentType = ''}) {
    final normalized = text.trim();
    final payload = documentType.isEmpty ? normalized : '$documentType:$normalized';
    return sha256.convert(utf8.encode(payload)).toString();
  }

  /// Retrieves cached analysis result if present, updating hit/miss metrics.
  LegalAnalysisResult? get({required String text, String documentType = ''}) {
    final key = computeKey(text: text, documentType: documentType);
    final result = _store[key];
    if (result != null) {
      _hits++;
      return result;
    }
    _misses++;
    return null;
  }

  /// Stores analysis result keyed by content SHA-256 hash.
  void put({
    required String text,
    required LegalAnalysisResult result,
    String documentType = '',
  }) {
    final key = computeKey(text: text, documentType: documentType);
    _store[key] = result;
  }

  /// Checks if an analysis result exists in cache for the given content.
  bool contains({required String text, String documentType = ''}) {
    final key = computeKey(text: text, documentType: documentType);
    return _store.containsKey(key);
  }

  /// Clears all cached items and resets hit/miss counters.
  void clear() {
    _store.clear();
    _hits = 0;
    _misses = 0;
  }

  /// Returns diagnostic metadata for telemetry and auditing.
  Map<String, dynamic> getDiagnostics() {
    return {
      'cachedEntries': _store.length,
      'hits': _hits,
      'misses': _misses,
      'hitRate': (_hits + _misses) > 0 ? _hits / (_hits + _misses) : 0.0,
    };
  }
}
