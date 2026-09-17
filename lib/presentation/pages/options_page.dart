import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/legal_entities.dart';
import '../providers/app_providers.dart';
import '../widgets/shared_widgets.dart';

class OptionsPage extends ConsumerStatefulWidget {
  const OptionsPage({super.key});

  @override
  ConsumerState<OptionsPage> createState() => _OptionsPageState();
}

class _OptionsPageState extends ConsumerState<OptionsPage> {
  int _selectedOptionIndex = 1; // Default to Recommended (Propose Clarifications)
  final Set<String> _completedSteps = {};

  void _toggleStep(String stepId) {
    setState(() {
      if (_completedSteps.contains(stepId)) {
        _completedSteps.remove(stepId);
      } else {
        _completedSteps.add(stepId);
      }
    });
  }

  void _copyDraft(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Draft communication copied to clipboard!'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final docState = ref.watch(documentNotifierProvider);
    final document = docState.currentDocument;

    if (document == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.alt_route_rounded, size: 64, color: AppColors.textTertiary),
              const SizedBox(height: 16),
              const Text(
                'No Document Loaded',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please upload or select a legal contract first to evaluate options.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go('/upload'),
                icon: const Icon(Icons.upload_file_rounded),
                label: const Text('Upload Document'),
              ),
            ],
          ),
        ),
      );
    }

    final options = document.options;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Legal Disclaimer
            Semantics(
              container: true,
              label: 'Legal assistance disclaimer',
              child: const LegalDisclaimerBanner(),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.alt_route_rounded, color: AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Possible Options & Next Steps',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Strategic decision paths for "${document.fileName}" (${document.snapshot.documentType}) with actionable recommendations.',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _exportOptionsSummary(document),
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('Export Strategy'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Overview Metric Bar
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    title: 'Available Options',
                    value: '${options.length}',
                    icon: Icons.list_alt_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: MetricCard(
                    title: 'Recommended Path',
                    value: 'Mutual Redline',
                    icon: Icons.thumb_up_alt_outlined,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MetricCard(
                    title: 'Attention Hotspots',
                    value: '${document.snapshot.highAttentionCount}',
                    icon: Icons.warning_amber_rounded,
                    color: document.snapshot.highAttentionCount > 0 ? AppColors.error : AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Option Selector Tabs
            Semantics(
              container: true,
              label: 'Strategic options selection tabs',
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(options.length, (index) {
                    final opt = options[index];
                    final isSelected = index == _selectedOptionIndex;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Semantics(
                        button: true,
                        selected: isSelected,
                        label: 'Option ${index + 1}: ${opt.title}',
                        child: ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Option ${index + 1}: ${opt.title}'),
                              if (index == 1) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'RECOMMENDED',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) setState(() => _selectedOptionIndex = index);
                          },
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Active Option Detail Card
            if (options.isNotEmpty && _selectedOptionIndex < options.length)
              _buildOptionDetailCard(options[_selectedOptionIndex], context),

            const SizedBox(height: 36),

            // Quick Next Steps Action Center Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.checklist_rtl_rounded, size: 36, color: AppColors.primary),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ready to finalize your preparation?',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Review your customized "Before You Sign" checklist and tailored lawyer consultation questions.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/action-center'),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: const Text('Open Action Center'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionDetailCard(LegalOption opt, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opt.title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Strategy Category: ${opt.category}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              PriorityBadge(tier: opt.riskProfile),
            ],
          ),
          const SizedBox(height: 16),

          // Summary
          Text(
            opt.summary,
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 24),

          // Pros & Cons Grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pros
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Advantages / Pros',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.success),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...opt.pros.map(
                        (pro) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                              Expanded(child: Text(pro, style: const TextStyle(fontSize: 13, height: 1.4))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Cons
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Considerations / Cons',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...opt.cons.map(
                        (con) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                              Expanded(child: Text(con, style: const TextStyle(fontSize: 13, height: 1.4))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Actionable Next Steps
          const Text(
            'Actionable Next Steps for this Option',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...opt.actionableSteps.map((step) {
            final isDone = _completedSteps.contains(step.id);
            return Semantics(
              checked: isDone,
              label: '${step.title}. Priority: ${step.priority}',
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDone ? AppColors.success.withValues(alpha: 0.05) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDone ? AppColors.success.withValues(alpha: 0.3) : AppColors.darkBorder.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: isDone,
                      activeColor: AppColors.success,
                      onChanged: (_) => _toggleStep(step.id),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  step.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    decoration: isDone ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: step.priority == 'Immediate'
                                      ? AppColors.error.withValues(alpha: 0.15)
                                      : AppColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  step.priority,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: step.priority == 'Immediate' ? AppColors.error : AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            step.description,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),

          // Suggested Communication Draft
          if (opt.suggestedDraftLanguage.isNotEmpty) ...[
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                const Text(
                  'Suggested Communication / Draft Language',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () => _copyDraft(opt.suggestedDraftLanguage, context),
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Copy to Clipboard'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkBackground
                    : AppColors.lightBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: SelectableText(
                opt.suggestedDraftLanguage,
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _exportOptionsSummary(LegalDocument doc) {
    final buffer = StringBuffer();
    buffer.writeln('# Options & Next Steps Strategy Report');
    buffer.writeln('Document: ${doc.fileName} (${doc.snapshot.documentType})');
    buffer.writeln('Generated by LegalLens AI on ${DateTime.now().toIso8601String()}');
    buffer.writeln();
    buffer.writeln('## Executive Snapshot');
    buffer.writeln(doc.snapshot.executiveSummary);
    buffer.writeln();

    for (int i = 0; i < doc.options.length; i++) {
      final opt = doc.options[i];
      buffer.writeln('### Option ${i + 1}: ${opt.title} (${opt.category})');
      buffer.writeln('**Risk Profile:** ${opt.riskProfile.name}');
      buffer.writeln('**Summary:** ${opt.summary}');
      buffer.writeln();
      buffer.writeln('**Pros:**');
      for (final p in opt.pros) {
        buffer.writeln('- $p');
      }
      buffer.writeln('**Cons:**');
      for (final c in opt.cons) {
        buffer.writeln('- $c');
      }
      buffer.writeln();
      buffer.writeln('**Actionable Next Steps:**');
      for (final s in opt.actionableSteps) {
        buffer.writeln('- [ ] [${s.priority}] ${s.title}: ${s.description}');
      }
      buffer.writeln();
      buffer.writeln('**Suggested Draft Communication:**');
      buffer.writeln('> ${opt.suggestedDraftLanguage}');
      buffer.writeln();
      buffer.writeln('---');
      buffer.writeln();
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Complete Options Strategy Report copied to clipboard as Markdown!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
