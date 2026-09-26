import 'package:flutter_test/flutter_test.dart';
import 'package:legallens_ai/domain/entities/enums.dart';
import 'package:legallens_ai/services/ai/demo/obligation_extractor.dart';

void main() {
  group('ObligationExtractor Unit Tests', () {
    late ObligationExtractor extractor;

    setUp(() {
      extractor = ObligationExtractor();
    });

    test('Positive: Extracts Your, Other, and Shared obligations for employment context', () {
      const text = '''
The Employee agrees to provide 90 days notice before voluntary resignation.
Employee shall keep all trade secrets confidential.
Company will pay a base salary of \$160,000 and provide severance upon termination without cause.
Disputes will be submitted to binding arbitration.
Any amendments must be in written form signed by both parties.
''';

      final obligations = extractor.extract(text, text.toLowerCase());
      expect(obligations, isNotEmpty);

      final yourObs = obligations.where((o) => o.party == ObligationParty.your).toList();
      final otherObs = obligations.where((o) => o.party == ObligationParty.otherParty).toList();
      final sharedObs = obligations.where((o) => o.party == ObligationParty.shared).toList();

      expect(yourObs.any((o) => o.description.contains('90 days advance written notice')), isTrue);
      expect(yourObs.any((o) => o.description.contains('confidentiality')), isTrue);
      expect(otherObs.any((o) => o.description.contains('Disburse base salary')), isTrue);
      expect(otherObs.any((o) => o.description.contains('severance')), isTrue);
      expect(sharedObs.any((o) => o.description.contains('arbitration')), isTrue);
      expect(sharedObs.any((o) => o.description.contains('amendments')), isTrue);
    });

    test('Positive: Extracts tenant and landlord obligations for lease context', () {
      const text = '''
Tenant agrees to maintain premises cleanly and obtain renter insurance.
Landlord will return the refundable security deposit within 30 days and maintain heating.
Both parties agree to a joint move-in walkthrough inspection.
''';

      final obligations = extractor.extract(text, text.toLowerCase());
      final yourObs = obligations.where((o) => o.party == ObligationParty.your).toList();
      final otherObs = obligations.where((o) => o.party == ObligationParty.otherParty).toList();
      final sharedObs = obligations.where((o) => o.party == ObligationParty.shared).toList();

      expect(yourObs.any((o) => o.description.contains('cleanly') && o.description.contains('insurance')), isTrue);
      expect(otherObs.any((o) => o.description.contains('security deposit')), isTrue);
      expect(otherObs.any((o) => o.description.contains('structural integrity') || o.description.contains('heating')), isTrue);
      expect(sharedObs.any((o) => o.description.contains('walkthrough inspection')), isTrue);
    });

    test('Negative: Non-tenant text does not extract tenant clean/insurance duties', () {
      const text = 'The contractor shall deliver software modules according to specification.';
      final obligations = extractor.extract(text, text.toLowerCase());
      expect(obligations.any((o) => o.description.contains('premises cleanly')), isFalse);
    });

    test('Edge case: Generic text without identified roles produces fallback Core Covenants obligation', () {
      const text = 'General terms regarding mutual collaboration between parties.';
      final obligations = extractor.extract(text, text.toLowerCase());
      final yourObs = obligations.where((o) => o.party == ObligationParty.your).toList();
      expect(yourObs.length, 1);
      expect(yourObs.first.sourceClause, 'Core Covenants');
    });
  });
}
