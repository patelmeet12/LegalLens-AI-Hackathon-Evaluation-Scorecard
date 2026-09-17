import '../entities/legal_entities.dart';

abstract class IDocumentRepository {
  Future<void> saveDocument(LegalDocument document);
  Future<List<LegalDocument>> getHistory();
  Future<LegalDocument?> getDocumentById(String id);
  Future<void> deleteDocument(String id);
  Future<void> clearAllDocuments();
}

abstract class IChecklistRepository {
  Future<List<ChecklistItem>> getChecklist(String documentId);
  Future<void> saveChecklist(String documentId, List<ChecklistItem> items);
  Future<void> updateItem(String documentId, ChecklistItem item);
}

abstract class ISettingsRepository {
  Future<bool> isDemoMode();
  Future<void> setDemoMode(bool isDemo);
  Future<String?> getApiKey();
  Future<void> setApiKey(String? key);
  Future<bool> isDarkMode();
  Future<void> setDarkMode(bool isDark);
  Future<void> clearAllData();
}
