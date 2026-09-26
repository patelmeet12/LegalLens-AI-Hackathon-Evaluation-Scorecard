import 'package:flutter_test/flutter_test.dart';
import 'package:legallens_ai/services/ai/demo/checklist_generator.dart';
import 'package:legallens_ai/services/ai/demo/clause_detector.dart';

void main() {
  group('ChecklistGenerator Unit Tests', () {
    late ChecklistGenerator generator;
    late ClauseDetector clauseDetector;

    setUp(() {
      generator = ChecklistGenerator();
      clauseDetector = ClauseDetector();
    });

    test('Generates 7 actionable preparation checklist items with unique IDs', () {
      final clauses = clauseDetector.detect('sample text', 'sample text');
      final checklist = generator.generate(clauses);

      expect(checklist.length, 7);

      // Verify all items are initially unchecked
      for (final item in checklist) {
        expect(item.isChecked, isFalse);
        expect(item.id.startsWith('chk_'), isTrue);
        expect(item.title.isNotEmpty, isTrue);
        expect(item.category.isNotEmpty, isTrue);
      }

      // Unique IDs
      final ids = checklist.map((i) => i.id).toSet();
      expect(ids.length, checklist.length);

      // Category breadth
      final categories = checklist.map((i) => i.category).toSet();
      expect(categories.contains('Compensation'), isTrue);
      expect(categories.contains('Termination'), isTrue);
      expect(categories.contains('Confidentiality'), isTrue);
      expect(categories.contains('Intellectual Property'), isTrue);
      expect(categories.contains('Restrictions'), isTrue);
      expect(categories.contains('Dispute Resolution'), isTrue);
      expect(categories.contains('Legal Review'), isTrue);
    });

    test('Generates valid checklist even when clause list is completely empty', () {
      final checklist = generator.generate([]);
      expect(checklist.length, 7);
      expect(checklist.first.category, 'Compensation');
    });
  });
}
