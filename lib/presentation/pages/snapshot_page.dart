import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/legal_entities.dart';
import '../../services/export/export_service.dart';
import '../providers/app_providers.dart';
import '../widgets/shared_widgets.dart';

class SnapshotPage extends ConsumerWidget {
  const SnapshotPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final docState = ref.watch(documentNotifierProvider);
    final doc = docState.currentDocument;

    if (doc == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.description_outlined, size: 54, color: AppColors.primaryLight),
            const SizedBox(height: 16),
            const Text(
              'No Document Loaded Yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload a contract or select one of our sample agreements to view the Legal Snapshot.',
              style: TextStyle(fontSize: 13),
            ),
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

    final snapshot = doc.snapshot;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              SectionHeader(
                title: 'Legal Snapshot Overview',
                subtitle: 'High-level synthesis of covenants, complexity rating, and attention hotspots for ${doc.fileName}.',
                icon: Icons.dashboard_rounded,
                trailing: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.alt_route_rounded, size: 16),
                      label: const Text('Options & Next Steps'),
                      onPressed: () => context.go('/options'),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.download_rounded, size: 16),
                      label: const Text('Export Report'),
                      onPressed: () => _showExportDialog(context, doc),
                    ),
                  ],
                ),
              ),

              // Overview Primary Card
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doc.documentType,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'File: ${doc.fileName} • ${doc.charCount} characters analyzed',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Attention Tier & Complexity
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            _buildComplexityBadge(snapshot.complexity),
                            PriorityBadge(tier: snapshot.attentionLevel),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 28),

                    // Executive Summary
                    const Text(
                      'Executive Plain-Language Summary',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.executiveSummary,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.6,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Key Areas Tag Cloud
                    const Text(
                      'Key Areas Identified in Document',
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: snapshot.keyAreas.map((area) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primaryLight.withOpacity(0.2)),
                          ),
                          child: Text(
                            area,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryLight,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Metrics Counter Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMultiCol = constraints.maxWidth > 650;
                  return GridView.count(
                    crossAxisCount: isMultiCol ? 4 : 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: isMultiCol ? 1.4 : 1.3,
                    children: [
                      _MetricTile(
                        title: 'Total Clauses',
                        count: '${snapshot.totalClauses}',
                        icon: Icons.list_alt_rounded,
                        color: AppColors.primaryLight,
                        onTap: () => context.go('/clauses'),
                      ),
                      _MetricTile(
                        title: 'High Attention',
                        count: '${snapshot.highAttentionCount}',
                        icon: Icons.warning_amber_rounded,
                        color: AppColors.priorityAttention,
                        onTap: () => context.go('/risk-map'),
                      ),
                      _MetricTile(
                        title: 'Extracted Obligations',
                        count: '${doc.obligations.length}',
                        icon: Icons.assignment_turned_in_outlined,
                        color: AppColors.secondary,
                        onTap: () => context.go('/obligations'),
                      ),
                      _MetricTile(
                        title: 'Important Dates',
                        count: '${doc.dates.where((d) => d.isDetected).length}',
                        icon: Icons.event_note_rounded,
                        color: AppColors.priorityInfo,
                        onTap: () => context.go('/timeline'),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),

              // Quick Action Roadmap Navigation
              const Text(
                'Next Steps & Analysis Modules',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;
                  return GridView.count(
                    crossAxisCount: isWide ? 4 : (MediaQuery.of(context).size.width > 600 ? 2 : 1),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: isWide ? 1.5 : 2.5,
                    children: [
                      const _ActionCard(
                        title: 'Clause Intelligence',
                        description: 'Examine plain-language explanations & why each clause matters.',
                        icon: Icons.analytics_outlined,
                        route: '/clauses',
                      ),
                      const _ActionCard(
                        title: 'Risk & Attention Map',
                        description: 'Inspect 6-category risk radar with safe advisory tips.',
                        icon: Icons.shield_outlined,
                        route: '/risk-map',
                      ),
                      const _ActionCard(
                        title: 'Options & Next Steps',
                        description: 'Explore strategic negotiation paths, draft redlines & actions.',
                        icon: Icons.alt_route_rounded,
                        route: '/options',
                      ),
                      const _ActionCard(
                        title: 'Before You Sign Checklist',
                        description: 'Track interactive tasks and prep questions for your lawyer.',
                        icon: Icons.checklist_rounded,
                        route: '/action-center',
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              const LegalDisclaimerBanner(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComplexityBadge(DocumentComplexity complexity) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    switch (complexity) {
      case DocumentComplexity.simple:
        bg = AppColors.priorityInfo.withOpacity(0.15);
        fg = AppColors.priorityInfo;
        label = 'Complexity: Simple';
        icon = Icons.looks_one_outlined;
        break;
      case DocumentComplexity.moderate:
        bg = AppColors.priorityReview.withOpacity(0.15);
        fg = AppColors.priorityReview;
        label = 'Complexity: Moderate';
        icon = Icons.looks_two_outlined;
        break;
      case DocumentComplexity.complex:
        bg = AppColors.priorityAttention.withOpacity(0.15);
        fg = AppColors.priorityAttention;
        label = 'Complexity: Complex';
        icon = Icons.looks_3_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MetricTile({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.grey),
            ],
          ),
          const Spacer(),
          Text(
            count,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String route;

  const _ActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassCard(
      onTap: () => context.go(route),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primaryLight),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 11.5,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showExportDialog(BuildContext context, LegalDocument doc) {
  showDialog(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.download_rounded, color: AppColors.primary),
          SizedBox(width: 10),
          Text('Export Intelligence Report'),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export the complete synthesized intelligence for "${doc.fileName}" across all 8 challenge deliverables.',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.description_rounded, color: AppColors.primary),
              title: const Text('Markdown (.md) Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Formatted document with summaries, clauses, obligations, dates, radar, and options.', style: TextStyle(fontSize: 12)),
              onTap: () {
                final md = ExportService.generateMarkdownReport(doc);
                Clipboard.setData(ClipboardData(text: md));
                Navigator.of(dialogCtx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Complete Markdown report copied to clipboard!')),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.code_rounded, color: AppColors.secondary),
              title: const Text('Structured JSON Bundle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Raw machine-readable JSON data containing all extracted entities and scores.', style: TextStyle(fontSize: 12)),
              onTap: () {
                final json = ExportService.generateJsonReport(doc);
                Clipboard.setData(ClipboardData(text: json));
                Navigator.of(dialogCtx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Complete JSON bundle copied to clipboard!')),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogCtx).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

