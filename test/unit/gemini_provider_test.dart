import 'package:flutter_test/flutter_test.dart';
import 'package:legallens_ai/domain/entities/enums.dart';
import 'package:legallens_ai/services/ai/gemini_ai_provider.dart';

void main() {
  group('GeminiAIProvider Unit Tests', () {
    test('isConfigured reflects API key presence', () {
      final providerNone = GeminiAIProvider();
      expect(providerNone.isConfigured, false);

      final providerValid = GeminiAIProvider(apiKey: 'test_gemini_key');
      expect(providerValid.isConfigured, true);

      final providerEmpty = GeminiAIProvider(apiKey: '');
      expect(providerEmpty.isConfigured, false);

      final providerSpaces = GeminiAIProvider(apiKey: '   ');
      expect(providerSpaces.isConfigured, false);
    });

    test('analyzeDocument gracefully falls back to deterministic analysis without API key', () async {
      final provider = GeminiAIProvider();
      final result = await provider.analyzeDocument(
        text: 'EMPLOYMENT AGREEMENT. Base salary: \$140,000 per annum. Notice period: 60 days.',
        documentType: 'Employment Agreement',
        fileName: 'Fallback_Doc.txt',
      );

      expect(result.snapshot.documentType, 'Employment Agreement');
      expect(result.clauses.isNotEmpty, true);
      expect(result.options.length, 4);
    });

    test('provider name is defined', () {
      final provider = GeminiAIProvider();
      expect(provider.name, contains('Google Gemini AI'));
    });

    test('parseJsonToResult parses all risk categories, attention tiers, and obligations', () {
      final provider = GeminiAIProvider();

      final mockJson = {
        'complexity': 'complex',
        'attentionLevel': 'high attention',
        'summary': 'Executive summary of agreement',
        'keyAreas': ['Compensation', 'IP', 'Termination'],
        'clauses': [
          {
            'id': 'c1',
            'title': 'Non-Compete',
            'category': 'Restrictions',
            'importance': 'high attention',
            'originalText': 'Cannot work for competitor for 2 years',
            'plainLanguageExplanation': 'Restricts working for competing companies',
            'whyItMatters': 'Limits job mobility',
            'potentialConcern': 'Overly broad geographic scope',
            'recommendedReview': 'Negotiate shorter duration',
          },
          {
            'id': 'c2',
            'title': 'Confidentiality',
            'category': 'IP',
            'importance': 'review',
            'originalText': 'Keep trade secrets confidential',
            'plainLanguageExplanation': 'Maintain secrecy of company info',
            'whyItMatters': 'Standard protection',
            'potentialConcern': 'Survives indefinitely',
            'recommendedReview': 'Limit to 3 years',
          },
          {
            'id': 'c3',
            'title': 'Governing Law',
            'category': 'General',
            'importance': 'informational',
            'originalText': 'Governed by laws of Delaware',
            'plainLanguageExplanation': 'Delaware law applies',
            'whyItMatters': 'Jurisdiction specification',
            'potentialConcern': 'None',
            'recommendedReview': 'Standard clause',
          },
        ],
        'obligations': [
          {
            'id': 'o1',
            'party': 'other party',
            'description': 'Pay monthly compensation',
            'sourceClause': 'Section 3',
          },
          {
            'id': 'o2',
            'party': 'shared mutual',
            'description': 'Maintain confidentiality',
            'sourceClause': 'Section 5',
          },
          {
            'id': 'o3',
            'party': 'your duties',
            'description': 'Deliver source code on Friday',
            'sourceClause': 'Section 1',
          },
        ],
        'dates': [
          {
            'id': 'd1',
            'title': 'Commencement Date',
            'dateString': 'October 1, 2025',
            'type': 'Effective',
            'sourceSnippet': 'Agreement begins October 1, 2025',
          },
          {
            'id': 'd2',
            'title': 'Renewal Date',
            'dateString': 'Not detected.',
            'type': 'Renewal',
            'sourceSnippet': '',
          },
        ],
        'risks': [
          {
            'id': 'r1',
            'category': 'employment duties',
            'attentionLevel': 'high',
            'relevantClause': 'Section 2',
            'explanation': 'At-will status with immediate dismissal',
            'recommendedAction': 'Request severance agreement',
          },
          {
            'id': 'r2',
            'category': 'privacy & data',
            'attentionLevel': 'review',
            'relevantClause': 'Section 4',
            'explanation': 'Extensive monitoring of personal devices',
            'recommendedAction': 'Limit monitoring to corporate equipment',
          },
          {
            'id': 'r3',
            'category': 'liability & indemnification',
            'attentionLevel': 'high',
            'relevantClause': 'Section 7',
            'explanation': 'Uncapped personal liability for breach',
            'recommendedAction': 'Cap liability to 12 months fees',
          },
          {
            'id': 'r4',
            'category': 'intellectual property / ip',
            'attentionLevel': 'review',
            'relevantClause': 'Section 8',
            'explanation': 'Assignment of prior inventions',
            'recommendedAction': 'Attach Exhibit A list of excluded inventions',
          },
          {
            'id': 'r5',
            'category': 'restrictions & non-compete',
            'attentionLevel': 'high',
            'relevantClause': 'Section 9',
            'explanation': 'Worldwide restriction for 24 months',
            'recommendedAction': 'Narrow scope to primary metro area',
          },
          {
            'id': 'r6',
            'category': 'financial compensation',
            'attentionLevel': 'informational',
            'relevantClause': 'Section 3',
            'explanation': 'Base salary paid biweekly',
            'recommendedAction': 'Standard payment schedule',
          },
        ],
        'lawyerQuestions': [
          {
            'id': 'q1',
            'question': 'Is the non-compete enforceable in California?',
            'category': 'Enforceability',
            'contextReason': 'California Business and Professions Code 16600',
            'sourceClause': 'Section 9',
          }
        ],
        'checklist': [
          {
            'id': 'k1',
            'title': 'Sign and return Exhibit A',
            'category': 'Pre-signing',
          }
        ],
      };

      final result = provider.parseJsonToResult(mockJson, 'Employment Contract');
      expect(result.snapshot.documentType, 'Employment Contract');
      expect(result.snapshot.complexity, DocumentComplexity.complex);
      expect(result.snapshot.attentionLevel, AttentionTier.highAttention);
      expect(result.snapshot.highAttentionCount, 1);
      expect(result.snapshot.reviewCount, 1);
      expect(result.snapshot.informationalCount, 1);

      expect(result.clauses.length, 3);
      expect(result.obligations.length, 3);
      expect(result.obligations[0].party, ObligationParty.otherParty);
      expect(result.obligations[1].party, ObligationParty.shared);
      expect(result.obligations[2].party, ObligationParty.your);

      expect(result.dates.length, 2);
      expect(result.dates[0].isDetected, true);
      expect(result.dates[1].isDetected, false);

      expect(result.risks.length, 6);
      expect(result.risks[0].category, RiskCategory.employment);
      expect(result.risks[1].category, RiskCategory.privacy);
      expect(result.risks[2].category, RiskCategory.liability);
      expect(result.risks[3].category, RiskCategory.intellectualProperty);
      expect(result.risks[4].category, RiskCategory.restrictions);
      expect(result.risks[5].category, RiskCategory.financial);

      expect(result.lawyerQuestions.length, 1);
      expect(result.checklist.length, 1);
    });

    test('compareDocuments executes comparison via fallback engine', () async {
      final provider = GeminiAIProvider();
      final comparison = await provider.compareDocuments(
        textA: 'Contract A: Salary is \$165,000. Non-compete: 12 months.',
        nameA: 'Offer_A.txt',
        textB: 'Contract B: Salary is \$180,000. Non-compete: 24 months.',
        nameB: 'Offer_B.txt',
      );

      expect(comparison.docAName, 'Offer_A.txt');
      expect(comparison.docBName, 'Offer_B.txt');
      expect(comparison.changedFinancialTerms.isNotEmpty, true);
    });
  });
}
