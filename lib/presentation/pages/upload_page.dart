import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../services/document/document_parser_service.dart';
import '../providers/app_providers.dart';
import '../widgets/shared_widgets.dart';

class UploadPage extends ConsumerStatefulWidget {
  const UploadPage({super.key});

  @override
  ConsumerState<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends ConsumerState<UploadPage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _fileNameController = TextEditingController(text: 'Contract_Document.txt');
  String _selectedCategory = AppConstants.documentCategories.first;
  bool _isReadingFile = false;
  String? _uploadError;

  @override
  void dispose() {
    _textController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    setState(() {
      _uploadError = null;
      _isReadingFile = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt', 'md'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        _fileNameController.text = file.name;

        String extracted = '';
        final ext = (file.extension ?? '').toLowerCase();

        if (ext == 'pdf') {
          if (file.bytes == null) {
            throw Exception('Unable to read PDF file data. Please paste text directly.');
          }
          extracted = await DocumentParserService.extractTextFromPdf(file.bytes!);
        } else {
          // TXT or MD
          if (file.bytes != null) {
            extracted = String.fromCharCodes(file.bytes!);
          } else {
            throw Exception('Empty file data.');
          }
        }

        if (extracted.trim().isEmpty) {
          throw Exception(
              'Unable to extract text from this document. Please upload a text-readable PDF or paste the document text.');
        }

        _textController.text = extracted;

        // Auto-detect category if possible
        _autoSelectCategory(extracted);
      }
    } catch (e) {
      setState(() {
        _uploadError = e.toString().replaceAll('Exception:', '').trim();
      });
    } finally {
      setState(() {
        _isReadingFile = false;
      });
    }
  }

  void _autoSelectCategory(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('employment') || lower.contains('employee')) {
      _selectedCategory = 'Employment Agreement';
    } else if (lower.contains('lease') || lower.contains('tenant')) {
      _selectedCategory = 'Rental / Lease Agreement';
    } else if (lower.contains('non-disclosure') || lower.contains('nda')) {
      _selectedCategory = 'NDA';
    } else if (lower.contains('consulting') || lower.contains('contractor')) {
      _selectedCategory = 'Freelance Agreement';
    }
  }

  void _loadSample(String text, String category, String name) {
    setState(() {
      _textController.text = text;
      _selectedCategory = category;
      _fileNameController.text = name;
      _uploadError = null;
    });
  }

  Future<void> _handleStartAnalysis() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _uploadError = 'Please paste contract text or upload a document before proceeding.';
      });
      return;
    }

    final notifier = ref.read(documentNotifierProvider.notifier);
    await notifier.analyzeDocument(
      rawText: text,
      documentType: _selectedCategory,
      fileName: _fileNameController.text.trim().isNotEmpty
          ? _fileNameController.text.trim()
          : 'Document.txt',
    );

    final state = ref.read(documentNotifierProvider);
    if (state.currentDocument != null && mounted) {
      // Initialize QA
      ref.read(qaNotifierProvider.notifier).initForDocument(state.currentDocument!);
      // Initialize Checklist
      ref.read(checklistNotifierProvider.notifier).loadForDocument(state.currentDocument!);
      context.go('/snapshot');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final docState = ref.watch(documentNotifierProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'Upload or Paste Legal Document',
                subtitle: 'Select document category, upload a PDF/TXT, or paste your contract for local analysis.',
                icon: Icons.upload_file_rounded,
              ),

              // Analysis in progress card
              if (docState.isAnalyzing) ...[
                _buildAnalysisProgressCard(docState, isDark),
                const SizedBox(height: 24),
              ],

              // Error banner if any
              if (_uploadError != null || docState.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.priorityAttention.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.priorityAttention.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.priorityAttention, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _uploadError ?? docState.errorMessage!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.priorityAttention,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Preset Samples Row
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Try Sample Preset:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.work_outline_rounded, size: 14),
                    label: const Text('Tech Employment', style: TextStyle(fontSize: 12)),
                    onPressed: () => _loadSample(
                      AppConstants.sampleEmploymentContract,
                      'Employment Agreement',
                      'Nexus_Cloud_Employment_Agreement.txt',
                    ),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.home_work_outlined, size: 14),
                    label: const Text('Lease Agreement', style: TextStyle(fontSize: 12)),
                    onPressed: () => _loadSample(
                      AppConstants.sampleLeaseAgreement,
                      'Rental / Lease Agreement',
                      'Evergreen_Residential_Lease.txt',
                    ),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.lock_outline_rounded, size: 14),
                    label: const Text('Mutual NDA', style: TextStyle(fontSize: 12)),
                    onPressed: () => _loadSample(
                      AppConstants.sampleMutualNDA,
                      'NDA',
                      'Mutual_NonDisclosure_Agreement.txt',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Configuration Form (Category & Filename)
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Document Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                value: _selectedCategory,
                                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                                items: AppConstants.documentCategories
                                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 13.5), overflow: TextOverflow.ellipsis)))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedCategory = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Document Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _fileNameController,
                                decoration: const InputDecoration(
                                  hintText: 'e.g. Employment_Agreement.pdf',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // File Upload / Drop Area
              InkWell(
                onTap: _isReadingFile || docState.isAnalyzing ? null : _pickFile,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.4),
                      style: BorderStyle.solid,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      if (_isReadingFile)
                        const CircularProgressIndicator(strokeWidth: 2.5)
                      else
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.cloud_upload_outlined, size: 30, color: AppColors.primaryLight),
                        ),
                      const SizedBox(height: 12),
                      const Text(
                        'Click to Upload PDF, TXT, or Markdown Document',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Text is extracted 100% locally in your browser. Maximum privacy assured.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Text Area for Copy / Paste
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Or Paste Contract Text Directly:',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                      ),
                      if (_textController.text.isNotEmpty)
                        TextButton.icon(
                          icon: const Icon(Icons.clear, size: 14),
                          label: const Text('Clear', style: TextStyle(fontSize: 12)),
                          onPressed: () => setState(() => _textController.clear()),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _textController,
                    maxLines: 12,
                    style: const TextStyle(fontSize: 13, height: 1.5, fontFamily: 'monospace'),
                    decoration: InputDecoration(
                      hintText: 'Paste full contract, clauses, terms and conditions, or lease text here...',
                      hintStyle: TextStyle(
                        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Launch Analysis CTA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                  label: Text(
                    docState.isAnalyzing ? 'Analyzing Contract...' : 'Run LegalLens AI Analysis',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  onPressed: docState.isAnalyzing ? null : _handleStartAnalysis,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Legal Disclaimer
              const Center(child: LegalDisclaimerBanner()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisProgressCard(DocumentAnalysisState docState, bool isDark) {
    return GlassCard(
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text(
                docState.progressStage ?? 'Synthesizing document intelligence...',
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const LinearProgressIndicator(minHeight: 4),
        ],
      ),
    );
  }
}
