import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/legal_entities.dart';
import '../providers/app_providers.dart';
import '../widgets/shared_widgets.dart';

class ActionCenterPage extends ConsumerStatefulWidget {
  const ActionCenterPage({super.key});

  @override
  ConsumerState<ActionCenterPage> createState() => _ActionCenterPageState();
}

class _ActionCenterPageState extends ConsumerState<ActionCenterPage> {
  final TextEditingController _customItemController = TextEditingController();

  @override
  void dispose() {
    _customItemController.dispose();
    super.dispose();
  }

  void _handleAddCustomItem() {
    final title = _customItemController.text.trim();
    if (title.isNotEmpty) {
      ref.read(checklistNotifierProvider.notifier).addCustomItem(title, 'Custom');
      _customItemController.clear();
    }
  }

  void _copyChecklistToClipboard(List<ChecklistItem> items) {
    final buffer = StringBuffer();
    buffer.writeln('LegalLens AI — Before You Sign Checklist\n');
    for (final item in items) {
      buffer.writeln('[${item.isChecked ? "X" : " "}] ${item.title} (${item.category})');
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Checklist copied to clipboard!'), duration: Duration(seconds: 2)),
    );
  }

  void _copyLawyerQuestions(List<LawyerQuestion> questions) {
    final buffer = StringBuffer();
    buffer.writeln('LegalLens AI — Questions Prepared for Legal Professional\n');
    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      buffer.writeln('${i + 1}. ${q.question}');
      buffer.writeln('   Context: ${q.contextReason}');
      buffer.writeln('   Source: ${q.sourceClause}\n');
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Questions for lawyer copied to clipboard!'), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final docState = ref.watch(documentNotifierProvider);
    final doc = docState.currentDocument;
    final checklistState = ref.watch(checklistNotifierProvider);

    if (doc == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.checklist_rounded, size: 54, color: AppColors.primaryLight),
            const SizedBox(height: 16),
            const Text('No Document Analyzed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Please upload a document to generate your signing checklist & lawyer questions.'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file_rounded, size: 18),
              label: const Text('Go to Upload'),
              onPressed: () => context.go('/upload'),
            ),
          ],
        ),
      );
    }

    final items = checklistState.items.isNotEmpty ? checklistState.items : doc.checklist;
    final completedCount = items.where((i) => i.isChecked).length;
    final questions = doc.lawyerQuestions;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'Action Center & Lawyer Consultation Prep',
                subtitle: 'Personalized "Before You Sign" interactive checklist and generated questions for a legal professional.',
                icon: Icons.checklist_rounded,
              ),

              // Checklist Section
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Before You Sign Checklist',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Completed $completedCount of ${items.length} safety verification tasks',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.copy_rounded, size: 15),
                          label: const Text('Export / Copy Checklist'),
                          onPressed: () => _copyChecklistToClipboard(items),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: items.isEmpty ? 0 : completedCount / items.length,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(4),
                      backgroundColor: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                      color: completedCount == items.length ? AppColors.priorityInfo : AppColors.primary,
                    ),
                    const Divider(height: 28),

                    // Checklist items
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Material(
                          color: Colors.transparent,
                          child: CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            activeColor: AppColors.primary,
                            value: item.isChecked,
                            title: Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                decoration: item.isChecked ? TextDecoration.lineThrough : null,
                                color: item.isChecked
                                    ? Colors.grey
                                    : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                              ),
                            ),
                            subtitle: Text(
                              item.category,
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            onChanged: (_) {
                              ref.read(checklistNotifierProvider.notifier).toggleItem(item.id);
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Add custom item input
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _customItemController,
                            decoration: const InputDecoration(
                              hintText: 'Add custom checklist item (e.g. Verify remote equipment stipend)...',
                              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                            onSubmitted: (_) => _handleAddCustomItem(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text('Add Task'),
                          onPressed: _handleAddCustomItem,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Questions for a Legal Professional Section
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Questions for a Legal Professional',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'High-impact questions generated from detected attention areas to maximize your lawyer consultation.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.copy_rounded, size: 15),
                          label: const Text('Copy Questions'),
                          onPressed: () => _copyLawyerQuestions(questions),
                        ),
                      ],
                    ),
                    const Divider(height: 28),

                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: questions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final q = questions[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      q.category,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryLight),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Target: ${q.sourceClause}',
                                      style: const TextStyle(fontSize: 11.5, color: Colors.grey, fontStyle: FontStyle.italic),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '"${q.question}"',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.help_outline_rounded, size: 14, color: AppColors.secondary),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Why ask this: ${q.contextReason}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              const LegalDisclaimerBanner(),
            ],
          ),
        ),
      ),
    );
  }
}
