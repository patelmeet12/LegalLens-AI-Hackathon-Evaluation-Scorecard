import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/legal_entities.dart';
import '../providers/app_providers.dart';
import '../widgets/shared_widgets.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final history = ref.watch(historyNotifierProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 950),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Document Analysis History',
                subtitle: 'Locally cached document insights stored in your browser storage. You can reopen or purge them anytime.',
                icon: Icons.history_rounded,
                trailing: history.isNotEmpty
                    ? OutlinedButton.icon(
                        icon: const Icon(Icons.delete_sweep_rounded, size: 16, color: AppColors.priorityAttention),
                        label: const Text('Clear All', style: TextStyle(color: AppColors.priorityAttention)),
                        onPressed: () => _confirmClearAll(context, ref),
                      )
                    : null,
              ),

              if (history.isEmpty)
                GlassCard(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.folder_open_rounded, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text('No Document History Found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        const Text('Documents you analyze will appear here for instant retrieval.'),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.upload_file_rounded, size: 18),
                          label: const Text('Upload a Document'),
                          onPressed: () => context.go('/upload'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: history.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final doc = history[index];
                    return _HistoryDocCard(doc: doc, isDark: isDark);
                  },
                ),

              const SizedBox(height: 32),
              const LegalDisclaimerBanner(),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmClearAll(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Document History?'),
        content: const Text('This will permanently delete all cached analysis and checklists from browser storage.'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.priorityAttention),
            child: const Text('Clear All'),
            onPressed: () {
              ref.read(historyNotifierProvider.notifier).clearAll();
              ref.read(documentNotifierProvider.notifier).clearDocument();
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}

class _HistoryDocCard extends ConsumerWidget {
  final LegalDocument doc;
  final bool isDark;

  const _HistoryDocCard({required this.doc, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.description_outlined, color: AppColors.primaryLight, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        doc.fileName,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    PriorityBadge(tier: doc.snapshot.attentionLevel, compact: true),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${doc.documentType} • ${doc.clauses.length} clauses • Analyzed on ${doc.createdAt.year}-${doc.createdAt.month.toString().padLeft(2, '0')}-${doc.createdAt.day.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.open_in_new_rounded, size: 14),
                label: const Text('Open'),
                onPressed: () {
                  ref.read(documentNotifierProvider.notifier).setDocument(doc);
                  ref.read(qaNotifierProvider.notifier).initForDocument(doc);
                  ref.read(checklistNotifierProvider.notifier).loadForDocument(doc);
                  context.go('/snapshot');
                },
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.grey),
                tooltip: 'Delete',
                onPressed: () {
                  ref.read(historyNotifierProvider.notifier).deleteDocument(doc.id);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
