import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:legallens_ai/data/repositories/repository_impls.dart';
import 'package:legallens_ai/domain/entities/enums.dart';
import 'package:legallens_ai/domain/entities/legal_entities.dart';
import 'package:legallens_ai/services/storage/local_storage_service.dart';

LegalDocument _createSampleDoc(String id, String name) {
  return LegalDocument(
    id: id,
    fileName: name,
    documentType: 'Non-Disclosure Agreement',
    rawText: 'Confidentiality agreement text.',
    charCount: 30,
    createdAt: DateTime.now(),
    snapshot: const LegalSnapshot(
      documentType: 'Non-Disclosure Agreement',
      complexity: DocumentComplexity.simple,
      attentionLevel: AttentionTier.informational,
      executiveSummary: 'Standard mutual NDA.',
      keyAreas: ['Confidentiality'],
      totalClauses: 1,
      highAttentionCount: 0,
      reviewCount: 0,
      informationalCount: 1,
    ),
    clauses: const [],
    obligations: const [],
    dates: const [],
    risks: const [],
    lawyerQuestions: const [],
    checklist: const [
      ChecklistItem(id: 'c1', title: 'Check term', category: 'Term'),
    ],
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LocalStorageService Unit Tests', () {
    late LocalStorageService storage;

    setUp(() {
      storage = LocalStorageService();
    });

    test('Saves, retrieves, finds by ID, and deletes documents', () async {
      final doc1 = _createSampleDoc('doc_1', 'NDA_v1.txt');
      final doc2 = _createSampleDoc('doc_2', 'NDA_v2.txt');

      await storage.saveDocument(doc1);
      await storage.saveDocument(doc2);

      final history = await storage.getHistory();
      expect(history.length, 2);
      expect(history.first.id, 'doc_2'); // Most recent first

      final found = await storage.getDocumentById('doc_1');
      expect(found, isNotNull);
      expect(found!.fileName, 'NDA_v1.txt');

      final notFound = await storage.getDocumentById('doc_unknown');
      expect(notFound, isNull);

      await storage.deleteDocument('doc_1');
      final updatedHistory = await storage.getHistory();
      expect(updatedHistory.length, 1);
      expect(updatedHistory.first.id, 'doc_2');

      await storage.clearAllDocuments();
      final emptyHistory = await storage.getHistory();
      expect(emptyHistory, isEmpty);
    });

    test('Updating document: saving document with existing ID updates entry and preserves order', () async {
      final doc1 = _createSampleDoc('doc_1', 'NDA_v1.txt');
      await storage.saveDocument(doc1);

      final updatedDoc1 = _createSampleDoc('doc_1', 'NDA_v1_Revised.txt');
      await storage.saveDocument(updatedDoc1);

      final history = await storage.getHistory();
      expect(history.length, 1);
      expect(history.first.fileName, 'NDA_v1_Revised.txt');
    });

    test('Checklist persistence and retrieval', () async {
      const items = [
        ChecklistItem(id: 'k1', title: 'Review IP', category: 'IP'),
        ChecklistItem(id: 'k2', title: 'Confirm pay', category: 'Pay', isChecked: true),
      ];

      await storage.saveChecklist('doc_10', items);
      final retrieved = await storage.getChecklist('doc_10');

      expect(retrieved, isNotNull);
      expect(retrieved!.length, 2);
      expect(retrieved.last.isChecked, true);

      final missing = await storage.getChecklist('doc_absent');
      expect(missing, isNull);
    });

    test('Zero Orphaned Data: clearAllDocuments purges history and all associated checklist records', () async {
      final doc1 = _createSampleDoc('doc_clean_1', 'Doc1.txt');
      final doc2 = _createSampleDoc('doc_clean_2', 'Doc2.txt');

      await storage.saveDocument(doc1);
      await storage.saveDocument(doc2);

      await storage.saveChecklist('doc_clean_1', [
        const ChecklistItem(id: 'c1', title: 'Item 1', category: 'General'),
      ]);
      await storage.saveChecklist('doc_clean_2', [
        const ChecklistItem(id: 'c2', title: 'Item 2', category: 'General'),
      ]);

      expect(await storage.getChecklist('doc_clean_1'), isNotNull);
      expect(await storage.getChecklist('doc_clean_2'), isNotNull);

      await storage.clearAllDocuments();

      expect(await storage.getHistory(), isEmpty);
      expect(await storage.getChecklist('doc_clean_1'), isNull);
      expect(await storage.getChecklist('doc_clean_2'), isNull);

      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith('legallens_checklist_'));
      expect(keys, isEmpty, reason: 'All checklist keys must be purged with clearAllDocuments()');
    });

    test('deleteDocument removes associated checklist record to avoid orphaned records', () async {
      final doc = _createSampleDoc('doc_del_1', 'DocDel.txt');
      await storage.saveDocument(doc);
      await storage.saveChecklist('doc_del_1', [
        const ChecklistItem(id: 'c_del', title: 'Check item', category: 'Notice'),
      ]);

      expect(await storage.getChecklist('doc_del_1'), isNotNull);
      await storage.deleteDocument('doc_del_1');

      expect(await storage.getDocumentById('doc_del_1'), isNull);
      expect(await storage.getChecklist('doc_del_1'), isNull);
    });

    test('Malformed stored JSON in document history is skipped gracefully without crashing', () async {
      final prefs = await SharedPreferences.getInstance();
      final validDoc = _createSampleDoc('valid_1', 'valid.txt');
      final validDocJson = jsonEncode(validDoc.toJson());
      const corruptedJson = '{invalid_json_missing_quotes: true, broken';

      await prefs.setStringList('legallens_history_docs', [validDocJson, corruptedJson]);

      final history = await storage.getHistory();
      expect(history.length, 1);
      expect(history.first.id, 'valid_1');
    });

    test('Malformed stored JSON in checklist is skipped gracefully', () async {
      final prefs = await SharedPreferences.getInstance();
      const validItemJson = '{"id":"chk_v","title":"Valid task","category":"Legal","isChecked":false}';
      const corruptItemJson = 'NOT_JSON';

      await prefs.setStringList('legallens_checklist_doc_test', [validItemJson, corruptItemJson]);

      final checklist = await storage.getChecklist('doc_test');
      expect(checklist, isNotNull);
      expect(checklist!.length, 1);
      expect(checklist.first.id, 'chk_v');
    });

    test('Settings persistence (Demo mode, API Key, Dark mode, clearAllData)', () async {
      // Demo Mode defaults to true
      final defaultDemo = await storage.getIsDemoMode();
      expect(defaultDemo, true);

      await storage.setIsDemoMode(false);
      expect(await storage.getIsDemoMode(), false);

      // API Key
      expect(await storage.getApiKey(), isNull);
      await storage.setApiKey('test_key_123');
      expect(await storage.getApiKey(), 'test_key_123');

      await storage.setApiKey(null);
      expect(await storage.getApiKey(), isNull);

      // Dark Mode defaults to true
      expect(await storage.getIsDarkMode(), true);
      await storage.setIsDarkMode(false);
      expect(await storage.getIsDarkMode(), false);

      // Clear all data
      await storage.setApiKey('secret_key');
      await storage.clearAllData();
      expect(await storage.getApiKey(), isNull);
    });
  });

  group('Repository Implementations Unit Tests', () {
    late LocalStorageService storage;
    late DocumentRepositoryImpl docRepo;
    late ChecklistRepositoryImpl checklistRepo;
    late SettingsRepositoryImpl settingsRepo;

    setUp(() {
      storage = LocalStorageService();
      docRepo = DocumentRepositoryImpl(storage);
      checklistRepo = ChecklistRepositoryImpl(storage);
      settingsRepo = SettingsRepositoryImpl(storage);
    });

    test('DocumentRepositoryImpl delegates correctly', () async {
      final doc = _createSampleDoc('r_doc_1', 'Repo_Doc.txt');
      await docRepo.saveDocument(doc);

      final list = await docRepo.getHistory();
      expect(list.length, 1);

      final fetched = await docRepo.getDocumentById('r_doc_1');
      expect(fetched?.fileName, 'Repo_Doc.txt');

      await docRepo.deleteDocument('r_doc_1');
      expect(await docRepo.getHistory(), isEmpty);

      await docRepo.saveDocument(doc);
      await docRepo.clearAllDocuments();
      expect(await docRepo.getHistory(), isEmpty);
    });

    test('ChecklistRepositoryImpl get, save, and updateItem', () async {
      const item1 = ChecklistItem(id: 'i1', title: 'Task 1', category: 'General');
      const item2 = ChecklistItem(id: 'i2', title: 'Task 2', category: 'General');

      await checklistRepo.saveChecklist('doc_repo', [item1]);
      final initial = await checklistRepo.getChecklist('doc_repo');
      expect(initial.length, 1);

      // Update existing item
      await checklistRepo.updateItem('doc_repo', item1.copyWith(isChecked: true));
      final updated = await checklistRepo.getChecklist('doc_repo');
      expect(updated.first.isChecked, true);

      // Add new item via updateItem
      await checklistRepo.updateItem('doc_repo', item2);
      final withNew = await checklistRepo.getChecklist('doc_repo');
      expect(withNew.length, 2);
    });

    test('SettingsRepositoryImpl delegates correctly', () async {
      expect(await settingsRepo.isDemoMode(), true);
      await settingsRepo.setDemoMode(false);
      expect(await settingsRepo.isDemoMode(), false);

      await settingsRepo.setApiKey('repo_api_key');
      expect(await settingsRepo.getApiKey(), 'repo_api_key');

      expect(await settingsRepo.isDarkMode(), true);
      await settingsRepo.setDarkMode(false);
      expect(await settingsRepo.isDarkMode(), false);

      await settingsRepo.clearAllData();
      expect(await settingsRepo.getApiKey(), isNull);
    });
  });
}
