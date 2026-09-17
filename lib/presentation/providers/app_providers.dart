import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/repositories/repository_impls.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/legal_entities.dart';
import '../../domain/repositories/repositories.dart';
import '../../services/ai/ai_service.dart';
import '../../services/storage/local_storage_service.dart';

// Storage & Service singletons
final storageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

final documentRepositoryProvider = Provider<IDocumentRepository>((ref) {
  return DocumentRepositoryImpl(ref.watch(storageServiceProvider));
});

final checklistRepositoryProvider = Provider<IChecklistRepository>((ref) {
  return ChecklistRepositoryImpl(ref.watch(storageServiceProvider));
});

final settingsRepositoryProvider = Provider<ISettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.watch(storageServiceProvider));
});

final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

// Theme Mode Provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ThemeModeNotifier(storage);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final LocalStorageService _storage;

  ThemeModeNotifier(this._storage) : super(ThemeMode.dark) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final isDark = await _storage.getIsDarkMode();
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = newMode;
    await _storage.setIsDarkMode(newMode == ThemeMode.dark);
  }
}

// Settings State Provider
class SettingsState {
  final bool isDemoMode;
  final String? apiKey;
  final bool isLoaded;

  const SettingsState({
    this.isDemoMode = true,
    this.apiKey,
    this.isLoaded = false,
  });

  SettingsState copyWith({bool? isDemoMode, String? apiKey, bool? isLoaded}) {
    return SettingsState(
      isDemoMode: isDemoMode ?? this.isDemoMode,
      apiKey: apiKey ?? this.apiKey,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

final settingsNotifierProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  final aiService = ref.watch(aiServiceProvider);
  return SettingsNotifier(settingsRepo, aiService);
});

class SettingsNotifier extends StateNotifier<SettingsState> {
  final ISettingsRepository _repo;
  final AIService _aiService;

  SettingsNotifier(this._repo, this._aiService) : super(const SettingsState()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final isDemo = await _repo.isDemoMode();
    final key = await _repo.getApiKey();
    _aiService.configure(useDemoMode: isDemo, apiKey: key);
    state = SettingsState(isDemoMode: isDemo, apiKey: key, isLoaded: true);
  }

  Future<void> setDemoMode(bool isDemo) async {
    await _repo.setDemoMode(isDemo);
    _aiService.configure(useDemoMode: isDemo, apiKey: state.apiKey);
    state = state.copyWith(isDemoMode: isDemo);
  }

  Future<void> setApiKey(String? key) async {
    await _repo.setApiKey(key);
    _aiService.configure(useDemoMode: state.isDemoMode, apiKey: key);
    state = state.copyWith(apiKey: key);
  }

  Future<void> clearAllData() async {
    await _repo.clearAllData();
    await loadSettings();
  }
}

// Document Analysis State
class DocumentAnalysisState {
  final LegalDocument? currentDocument;
  final bool isAnalyzing;
  final String? progressStage;
  final String? errorMessage;

  const DocumentAnalysisState({
    this.currentDocument,
    this.isAnalyzing = false,
    this.progressStage,
    this.errorMessage,
  });

  DocumentAnalysisState copyWith({
    LegalDocument? currentDocument,
    bool? isAnalyzing,
    String? progressStage,
    String? errorMessage,
  }) {
    return DocumentAnalysisState(
      currentDocument: currentDocument ?? this.currentDocument,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      progressStage: progressStage ?? this.progressStage,
      errorMessage: errorMessage,
    );
  }
}

final documentNotifierProvider = StateNotifierProvider<DocumentNotifier, DocumentAnalysisState>((ref) {
  final ai = ref.watch(aiServiceProvider);
  final docRepo = ref.watch(documentRepositoryProvider);
  return DocumentNotifier(ai, docRepo);
});

class DocumentNotifier extends StateNotifier<DocumentAnalysisState> {
  final AIService _ai;
  final IDocumentRepository _docRepo;
  static const _uuid = Uuid();

  DocumentNotifier(this._ai, this._docRepo) : super(const DocumentAnalysisState());

  Future<void> analyzeDocument({
    required String rawText,
    required String documentType,
    required String fileName,
  }) async {
    if (rawText.trim().isEmpty) {
      state = state.copyWith(
        isAnalyzing: false,
        errorMessage: 'Document is empty. Please provide readable legal text or upload a document.',
      );
      return;
    }

    try {
      state = state.copyWith(
        isAnalyzing: true,
        progressStage: 'Extracting text and structure...',
        errorMessage: null,
      );

      await Future.delayed(const Duration(milliseconds: 250));
      state = state.copyWith(progressStage: 'Segmenting clauses and legal covenants...');

      await Future.delayed(const Duration(milliseconds: 250));
      state = state.copyWith(progressStage: 'Identifying obligations and timelines...');

      await Future.delayed(const Duration(milliseconds: 250));
      state = state.copyWith(progressStage: 'Evaluating risk indicators and attention points...');

      final result = await _ai.analyzeDocument(
        text: rawText,
        documentType: documentType,
        fileName: fileName,
      );

      final legalDoc = LegalDocument(
        id: _uuid.v4(),
        fileName: fileName,
        documentType: result.snapshot.documentType,
        rawText: rawText,
        charCount: rawText.length,
        createdAt: DateTime.now(),
        snapshot: result.snapshot,
        clauses: result.clauses,
        obligations: result.obligations,
        dates: result.dates,
        risks: result.risks,
        lawyerQuestions: result.lawyerQuestions,
        checklist: result.checklist,
        options: result.options,
      );

      // Save document to history
      await _docRepo.saveDocument(legalDoc);

      state = DocumentAnalysisState(
        currentDocument: legalDoc,
        isAnalyzing: false,
        progressStage: null,
      );
    } catch (e) {
      state = const DocumentAnalysisState(
        currentDocument: null,
        isAnalyzing: false,
        errorMessage: 'Analysis encountered an error. Please verify the document text or try again.',
      );
    }
  }

  void setDocument(LegalDocument doc) {
    state = DocumentAnalysisState(
      currentDocument: doc,
      isAnalyzing: false,
      progressStage: null,
    );
  }

  void clearDocument() {
    state = const DocumentAnalysisState();
  }
}

// Grounded Q&A Provider
class QAState {
  final List<QAMessage> messages;
  final bool isAnswering;
  final String? errorMessage;

  const QAState({
    this.messages = const [],
    this.isAnswering = false,
    this.errorMessage,
  });

  QAState copyWith({
    List<QAMessage>? messages,
    bool? isAnswering,
    String? errorMessage,
  }) {
    return QAState(
      messages: messages ?? this.messages,
      isAnswering: isAnswering ?? this.isAnswering,
      errorMessage: errorMessage,
    );
  }
}

final qaNotifierProvider = StateNotifierProvider<QANotifier, QAState>((ref) {
  final ai = ref.watch(aiServiceProvider);
  return QANotifier(ai);
});

class QANotifier extends StateNotifier<QAState> {
  final AIService _ai;
  static const _uuid = Uuid();

  QANotifier(this._ai) : super(const QAState());

  void initForDocument(LegalDocument doc) {
    final welcome = QAMessage(
      id: _uuid.v4(),
      isUser: false,
      text: 'Hello! I am your document intelligence assistant for "${doc.fileName}". '
          'You can ask me questions about termination notice, IP ownership, compensation, renewal conditions, '
          'or obligations. I answer strictly based on this document and will cite specific clauses.',
      timestamp: DateTime.now(),
      citations: [doc.documentType],
      confidence: ConfidenceLevel.high,
    );
    state = QAState(messages: [welcome]);
  }

  Future<void> askQuestion({
    required String question,
    required LegalDocument document,
  }) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty) return;

    final userMsg = QAMessage(
      id: _uuid.v4(),
      isUser: true,
      text: trimmed,
      timestamp: DateTime.now(),
    );

    final updated = [...state.messages, userMsg];
    state = QAState(messages: updated, isAnswering: true);

    try {
      final aiResponse = await _ai.answerQuestion(
        question: trimmed,
        document: document,
        previousHistory: updated,
      );

      state = QAState(
        messages: [...updated, aiResponse],
        isAnswering: false,
      );
    } catch (_) {
      final errorMsg = QAMessage(
        id: _uuid.v4(),
        isUser: false,
        text: 'Unable to process your query at this moment. Please check your question or try again.',
        timestamp: DateTime.now(),
        citations: [],
      );
      state = QAState(
        messages: [...updated, errorMsg],
        isAnswering: false,
      );
    }
  }

  void clearChat() {
    state = const QAState();
  }
}

// Contract Comparison Provider
class ComparisonState {
  final DocumentComparison? comparison;
  final bool isComparing;
  final String? errorMessage;

  const ComparisonState({
    this.comparison,
    this.isComparing = false,
    this.errorMessage,
  });

  ComparisonState copyWith({
    DocumentComparison? comparison,
    bool? isComparing,
    String? errorMessage,
  }) {
    return ComparisonState(
      comparison: comparison ?? this.comparison,
      isComparing: isComparing ?? this.isComparing,
      errorMessage: errorMessage,
    );
  }
}

final comparisonNotifierProvider = StateNotifierProvider<ComparisonNotifier, ComparisonState>((ref) {
  final ai = ref.watch(aiServiceProvider);
  return ComparisonNotifier(ai);
});

class ComparisonNotifier extends StateNotifier<ComparisonState> {
  final AIService _ai;

  ComparisonNotifier(this._ai) : super(const ComparisonState());

  Future<void> compare({
    required String textA,
    required String nameA,
    required String textB,
    required String nameB,
  }) async {
    if (textA.trim().isEmpty || textB.trim().isEmpty) {
      state = state.copyWith(
        isComparing: false,
        errorMessage: 'Both documents must contain text for comparison.',
      );
      return;
    }

    state = state.copyWith(isComparing: true, errorMessage: null);

    try {
      final result = await _ai.compareDocuments(
        textA: textA,
        nameA: nameA,
        textB: textB,
        nameB: nameB,
      );
      state = ComparisonState(comparison: result, isComparing: false);
    } catch (_) {
      state = state.copyWith(
        isComparing: false,
        errorMessage: 'Comparison failed. Please verify the documents and try again.',
      );
    }
  }

  void clearComparison() {
    state = const ComparisonState();
  }
}

// Checklist Provider with local persistence
class ChecklistState {
  final List<ChecklistItem> items;
  final String? documentId;

  const ChecklistState({
    this.items = const [],
    this.documentId,
  });
}

final checklistNotifierProvider = StateNotifierProvider<ChecklistNotifier, ChecklistState>((ref) {
  final repo = ref.watch(checklistRepositoryProvider);
  return ChecklistNotifier(repo);
});

class ChecklistNotifier extends StateNotifier<ChecklistState> {
  final IChecklistRepository _repo;
  static const _uuid = Uuid();

  ChecklistNotifier(this._repo) : super(const ChecklistState());

  Future<void> loadForDocument(LegalDocument doc) async {
    final list = await _repo.getChecklist(doc.id);
    if (list.isNotEmpty) {
      state = ChecklistState(items: list, documentId: doc.id);
    } else {
      state = ChecklistState(items: doc.checklist, documentId: doc.id);
      await _repo.saveChecklist(doc.id, doc.checklist);
    }
  }

  Future<void> toggleItem(String id) async {
    if (state.documentId == null) return;
    final updated = state.items.map((item) {
      if (item.id == id) {
        return item.copyWith(isChecked: !item.isChecked);
      }
      return item;
    }).toList();

    state = ChecklistState(items: updated, documentId: state.documentId);
    await _repo.saveChecklist(state.documentId!, updated);
  }

  Future<void> addCustomItem(String title, String category) async {
    if (state.documentId == null || title.trim().isEmpty) return;

    final newItem = ChecklistItem(
      id: _uuid.v4(),
      title: title.trim(),
      category: category.isNotEmpty ? category : 'Custom',
      isCustom: true,
      isChecked: false,
    );

    final updated = [...state.items, newItem];
    state = ChecklistState(items: updated, documentId: state.documentId);
    await _repo.saveChecklist(state.documentId!, updated);
  }
}

// History Provider
final historyNotifierProvider = StateNotifierProvider<HistoryNotifier, List<LegalDocument>>((ref) {
  final repo = ref.watch(documentRepositoryProvider);
  return HistoryNotifier(repo);
});

class HistoryNotifier extends StateNotifier<List<LegalDocument>> {
  final IDocumentRepository _repo;

  HistoryNotifier(this._repo) : super([]) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    final docs = await _repo.getHistory();
    state = docs;
  }

  Future<void> deleteDocument(String id) async {
    await _repo.deleteDocument(id);
    await loadHistory();
  }

  Future<void> clearAll() async {
    await _repo.clearAllDocuments();
    state = [];
  }
}
