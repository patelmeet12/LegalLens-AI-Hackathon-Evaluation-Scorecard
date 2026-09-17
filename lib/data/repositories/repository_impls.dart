import '../../domain/entities/legal_entities.dart';
import '../../domain/repositories/repositories.dart';
import '../../services/storage/local_storage_service.dart';

class DocumentRepositoryImpl implements IDocumentRepository {
  final LocalStorageService _storage;

  DocumentRepositoryImpl(this._storage);

  @override
  Future<void> saveDocument(LegalDocument document) => _storage.saveDocument(document);

  @override
  Future<List<LegalDocument>> getHistory() => _storage.getHistory();

  @override
  Future<LegalDocument?> getDocumentById(String id) => _storage.getDocumentById(id);

  @override
  Future<void> deleteDocument(String id) => _storage.deleteDocument(id);

  @override
  Future<void> clearAllDocuments() => _storage.clearAllDocuments();
}

class ChecklistRepositoryImpl implements IChecklistRepository {
  final LocalStorageService _storage;

  ChecklistRepositoryImpl(this._storage);

  @override
  Future<List<ChecklistItem>> getChecklist(String documentId) async {
    final saved = await _storage.getChecklist(documentId);
    if (saved != null) return saved;

    final doc = await _storage.getDocumentById(documentId);
    return doc?.checklist ?? [];
  }

  @override
  Future<void> saveChecklist(String documentId, List<ChecklistItem> items) =>
      _storage.saveChecklist(documentId, items);

  @override
  Future<void> updateItem(String documentId, ChecklistItem item) async {
    final items = await getChecklist(documentId);
    final idx = items.indexWhere((i) => i.id == item.id);
    if (idx != -1) {
      items[idx] = item;
    } else {
      items.add(item);
    }
    await saveChecklist(documentId, items);
  }
}

class SettingsRepositoryImpl implements ISettingsRepository {
  final LocalStorageService _storage;

  SettingsRepositoryImpl(this._storage);

  @override
  Future<bool> isDemoMode() => _storage.getIsDemoMode();

  @override
  Future<void> setDemoMode(bool isDemo) => _storage.setIsDemoMode(isDemo);

  @override
  Future<String?> getApiKey() => _storage.getApiKey();

  @override
  Future<void> setApiKey(String? key) => _storage.setApiKey(key);

  @override
  Future<bool> isDarkMode() => _storage.getIsDarkMode();

  @override
  Future<void> setDarkMode(bool isDark) => _storage.setIsDarkMode(isDark);

  @override
  Future<void> clearAllData() => _storage.clearAllData();
}
