// Domain Enums with accessibility and UI helpers

enum AttentionTier {
  informational, // 🟢 Informational
  review,        // 🟡 Review
  highAttention; // 🔴 High Attention

  String get label {
    switch (this) {
      case AttentionTier.informational:
        return 'Informational';
      case AttentionTier.review:
        return 'Requires Review';
      case AttentionTier.highAttention:
        return 'High Attention';
    }
  }

  String get emojiIcon {
    switch (this) {
      case AttentionTier.informational:
        return '🟢';
      case AttentionTier.review:
        return '🟡';
      case AttentionTier.highAttention:
        return '🔴';
    }
  }
}

enum DocumentComplexity {
  simple,
  moderate,
  complex;

  String get label {
    switch (this) {
      case DocumentComplexity.simple:
        return 'Simple';
      case DocumentComplexity.moderate:
        return 'Moderate';
      case DocumentComplexity.complex:
        return 'Complex';
    }
  }
}

enum ConfidenceLevel {
  high,
  medium,
  low;

  String get label {
    switch (this) {
      case ConfidenceLevel.high:
        return 'High Confidence';
      case ConfidenceLevel.medium:
        return 'Moderate Confidence';
      case ConfidenceLevel.low:
        return 'Low Confidence';
    }
  }
}

enum ObligationParty {
  your,
  otherParty,
  shared;

  String get title {
    switch (this) {
      case ObligationParty.your:
        return 'Your Responsibilities';
      case ObligationParty.otherParty:
        return 'Other Party Responsibilities';
      case ObligationParty.shared:
        return 'Shared Responsibilities';
    }
  }
}

enum RiskCategory {
  financial,
  employment,
  privacy,
  liability,
  intellectualProperty,
  restrictions;

  String get label {
    switch (this) {
      case RiskCategory.financial:
        return 'Financial Terms & Penalties';
      case RiskCategory.employment:
        return 'Employment & Termination';
      case RiskCategory.privacy:
        return 'Privacy & Data Governance';
      case RiskCategory.liability:
        return 'Liability & Indemnification';
      case RiskCategory.intellectualProperty:
        return 'Intellectual Property Ownership';
      case RiskCategory.restrictions:
        return 'Post-Term Restrictive Covenants';
    }
  }
}
