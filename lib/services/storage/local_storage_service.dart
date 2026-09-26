import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/legal_entities.dart';

/// Local persistence service for document history, user checklists, and preferences.
///
/// SECURITY & PLATFORM BOUNDARY NOTICE:
/// On Flutter Web, SharedPreferences persists via browser `window.localStorage`.
/// While this ensures 100% offline client-side privacy with zero external transmission,
/// web localStorage is unencrypted and does NOT provide hardware-backed secure storage
/// (such as Apple Keychain, Android Keystore, or Linux Secret Service).
/// In high-security or multi-tenant desktop environments, sensitive credentials (like Gemini API keys)
/// should interface with a dedicated platform-native secure enclave implementation.
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

      final List<LegalDocument> docs = [];
      for (final item in rawList) {
        try {
          final Map<String, dynamic> map = jsonDecode(item) as Map<String, dynamic>;
          docs.add(LegalDocument.fromJson(map));
        } catch (_) {
          // Gracefully skip corrupted individual document entries
        }
      }
      return docs;
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

    // Remove associated checklist to prevent orphaned records
    await prefs.remove('$_keyChecklistPrefix$id');
  }

  /// Clears all document history AND purges all associated checklist records,
  /// guaranteeing zero orphaned local records in storage.
  Future<void> clearAllDocuments() async {
    final prefs = await _prefs;
    final history = await getHistory();
    for (final doc in history) {
      await prefs.remove('$_keyChecklistPrefix${doc.id}');
    }

    // Purge any lingering checklist keys by prefix
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_keyChecklistPrefix)) {
        await prefs.remove(key);
      }
    }

    await prefs.remove(_keyHistory);
  }

  // Checklist
  Future<List<ChecklistItem>?> getChecklist(String docId) async {
    try {
      final prefs = await _prefs;
      final rawList = prefs.getStringList('$_keyChecklistPrefix$docId');
      if (rawList == null) return null;

      final List<ChecklistItem> items = [];
      for (final str in rawList) {
        try {
          final Map<String, dynamic> map = jsonDecode(str) as Map<String, dynamic>;
          items.add(ChecklistItem.fromJson(map));
        } catch (_) {
          // Gracefully skip corrupted individual checklist entries
        }
      }
      return items;
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
