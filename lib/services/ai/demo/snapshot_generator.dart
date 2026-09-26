import '../../../domain/entities/enums.dart';
import '../../../domain/entities/legal_entities.dart';

/// Generates an executive snapshot, complexity classification, and overall attention tier.
class SnapshotGenerator {
  /// Computes a [LegalSnapshot] from detected clauses and document metadata.
  LegalSnapshot generate({
    required String documentType,
    required List<LegalClause> clauses,
    required int textLength,
  }) {
    final highAttention = clauses.where((c) => c.importance == AttentionTier.highAttention).length;
    final review = clauses.where((c) => c.importance == AttentionTier.review).length;
    final info = clauses.where((c) => c.importance == AttentionTier.informational).length;

    DocumentComplexity complexity = DocumentComplexity.simple;
    if (clauses.length > 8 || textLength > 4000) {
      complexity = DocumentComplexity.complex;
    } else if (clauses.length > 4 || textLength > 1500) {
      complexity = DocumentComplexity.moderate;
    }

    AttentionTier attentionLevel = AttentionTier.informational;
    if (highAttention >= 2) {
      attentionLevel = AttentionTier.highAttention;
    } else if (highAttention == 1 || review >= 2) {
      attentionLevel = AttentionTier.review;
    }

    final keyAreas = clauses.map((c) => c.category).toSet().toList();

    final summary = 'This $documentType contains ${clauses.length} key analyzed sections. '
        'We identified $highAttention clause(s) requiring high attention and $review clause(s) recommended for review. '
        'Key focus areas include ${keyAreas.take(4).join(', ')}. '
        'Ensure critical obligations, notice periods, and restrictive covenants are thoroughly understood prior to signing.';

    return LegalSnapshot(
      documentType: documentType,
      complexity: complexity,
      attentionLevel: attentionLevel,
      executiveSummary: summary,
      keyAreas: keyAreas,
      totalClauses: clauses.length,
      highAttentionCount: highAttention,
      reviewCount: review,
      informationalCount: info,
    );
  }
}
