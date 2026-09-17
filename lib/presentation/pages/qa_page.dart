import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/legal_entities.dart';
import '../providers/app_providers.dart';
import '../widgets/shared_widgets.dart';

class QAPage extends ConsumerStatefulWidget {
  const QAPage({super.key});

  @override
  ConsumerState<QAPage> createState() => _QAPageState();
}

class _QAPageState extends ConsumerState<QAPage> {
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const List<String> sampleQuestions = [
    'What happens if I resign?',
    'How much notice do I need to give?',
    'Who owns the work I create?',
    'Is there a renewal clause?',
    'Where is the termination condition?',
  ];

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _submitQuestion(String query) async {
    final text = query.trim();
    if (text.isEmpty) return;

    final docState = ref.read(documentNotifierProvider);
    final doc = docState.currentDocument;
    if (doc == null) return;

    _questionController.clear();
    _scrollToBottom();

    await ref.read(qaNotifierProvider.notifier).askQuestion(
          question: text,
          document: doc,
        );

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final docState = ref.watch(documentNotifierProvider);
    final doc = docState.currentDocument;
    final qaState = ref.watch(qaNotifierProvider);

    if (doc == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.forum_outlined, size: 54, color: AppColors.primaryLight),
            const SizedBox(height: 16),
            const Text('No Document Analyzed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Upload a document to chat with the grounded AI assistant.'),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Document Grounded AI Q&A',
                subtitle: 'Ask questions strictly grounded in "${doc.fileName}". Answers cite specific sections and refuse ungrounded topics.',
                icon: Icons.forum_outlined,
              ),

              // Grounding notice badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primaryLight.withOpacity(0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.gavel_rounded, size: 16, color: AppColors.primaryLight),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Document-Mode Active: Responses are verified strictly against the document text. The assistant will never hallucinate or invent legal terms.',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primaryLight),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Suggested Questions Pills
              Text(
                'Suggested Document Questions:',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sampleQuestions.map((sq) {
                  return ActionChip(
                    label: Text(sq, style: const TextStyle(fontSize: 12)),
                    onPressed: qaState.isAnswering ? null : () => _submitQuestion(sq),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Chat Messages Container
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 350, maxHeight: 480),
                      child: ListView.separated(
                        controller: _scrollController,
                        itemCount: qaState.messages.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final msg = qaState.messages[index];
                          return _MessageBubble(message: msg, isDark: isDark);
                        },
                      ),
                    ),

                    if (qaState.isAnswering) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Searching document clauses & synthesizing grounded answer...',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const Divider(height: 24),

                    // Input Box
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _questionController,
                            decoration: InputDecoration(
                              hintText: 'Ask anything about "${doc.fileName}" (e.g. severance, non-compete, notice)...',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onSubmitted: qaState.isAnswering ? null : _submitQuestion,
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: qaState.isAnswering ? null : () => _submitQuestion(_questionController.text),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Icon(Icons.send_rounded, size: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const LegalDisclaimerBanner(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final QAMessage message;
  final bool isDark;

  const _MessageBubble({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isUser
                ? AppColors.primary
                : (isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated),
            borderRadius: BorderRadius.circular(14),
            border: isUser
                ? null
                : Border.all(
                    color: message.isRefusal
                        ? AppColors.priorityAttention.withOpacity(0.4)
                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isUser ? Icons.person_rounded : Icons.auto_awesome_rounded,
                    size: 14,
                    color: isUser ? Colors.white : AppColors.primaryLight,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isUser ? 'You' : 'LegalLens Grounded AI',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isUser ? Colors.white70 : AppColors.primaryLight,
                    ),
                  ),
                  if (!isUser && !message.isRefusal) ...[
                    const SizedBox(width: 10),
                    ConfidenceBadge(confidence: message.confidence),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Text(
                message.text,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  color: isUser
                      ? Colors.white
                      : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                ),
              ),
              if (message.citations.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: message.citations.map((cite) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkBg : AppColors.lightBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.link_rounded, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            cite,
                            style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
