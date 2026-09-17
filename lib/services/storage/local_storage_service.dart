import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/legal_entities.dart';

class LocalStorageService {
  static const String _keyHistory = 'legallens_history_docs';
  static const String _keyDemoMode = 'legallens_setting_demo_mode';
  static const String _keyApiKey = 'legallens_setting_api_key';
  static const String _keyDarkMode = 'legallens_setting_dark_mode';
  static const String _keyChecklistPrefix = 'legallens_checklist_';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // Document History
  Future<void> saveDocument(LegalDocument doc) async {
    final prefs = await _prefs;
    final history = await getHistory();

    // Avoid duplicate IDs, insert at front
    history.removeWhere((item) => item.id == doc.id);
    history.insert(0, doc);

    // Keep up to 20 recent documents
    final trimmed = history.take(20).toList();
    final jsonList = trimmed.map((d) => jsonEncode(d.toJson())).toList();
    await prefs.setStringList(_keyHistory, jsonList);
  }

  Future<List<LegalDocument>> getHistory() async {
    try {
      final prefs = await _prefs;
      final rawList = prefs.getStringList(_keyHistory);
      if (rawList == null) return [];

      return rawList.map((item) {
        final Map<String, dynamic> map = jsonDecode(item);
        return LegalDocument.fromJson(map);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<LegalDocument?> getDocumentById(String id) async {
    final history = await getHistory();
    try {
      return history.firstWhere((doc) => doc.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteDocument(String id) async {
    final prefs = await _prefs;
    final history = await getHistory();
    history.removeWhere((item) => item.id == id);
    final jsonList = history.map((d) => jsonEncode(d.toJson())).toList();
    await prefs.setStringList(_keyHistory, jsonList);

    // Remove associated checklist
    await prefs.remove('$_keyChecklistPrefix$id');
  }

  Future<void> clearAllDocuments() async {
    final prefs = await _prefs;
    await prefs.remove(_keyHistory);
  }

  // Checklist
  Future<List<ChecklistItem>?> getChecklist(String docId) async {
    try {
      final prefs = await _prefs;
      final rawList = prefs.getStringList('$_keyChecklistPrefix$docId');
      if (rawList == null) return null;

      return rawList.map((str) {
        final Map<String, dynamic> map = jsonDecode(str);
        return ChecklistItem.fromJson(map);
      }).toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> saveChecklist(String docId, List<ChecklistItem> items) async {
    final prefs = await _prefs;
    final jsonList = items.map((i) => jsonEncode(i.toJson())).toList();
    await prefs.setStringList('$_keyChecklistPrefix$docId', jsonList);
  }

  // Settings
  Future<bool> getIsDemoMode() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyDemoMode) ?? true;
  }

  Future<void> setIsDemoMode(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyDemoMode, value);
  }

  Future<String?> getApiKey() async {
    final prefs = await _prefs;
    return prefs.getString(_keyApiKey);
  }

  Future<void> setApiKey(String? key) async {
    final prefs = await _prefs;
    if (key == null || key.trim().isEmpty) {
      await prefs.remove(_keyApiKey);
    } else {
      await prefs.setString(_keyApiKey, key.trim());
    }
  }

  Future<bool> getIsDarkMode() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyDarkMode) ?? true;
  }

  Future<void> setIsDarkMode(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyDarkMode, value);
  }

  Future<void> clearAllData() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
