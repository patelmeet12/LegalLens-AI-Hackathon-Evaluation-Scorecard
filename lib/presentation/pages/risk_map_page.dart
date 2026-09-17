import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/legal_entities.dart';
import '../providers/app_providers.dart';
import '../widgets/shared_widgets.dart';

class RiskMapPage extends ConsumerWidget {
  const RiskMapPage({super.key});

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
            const Icon(Icons.shield_outlined, size: 54, color: AppColors.primaryLight),
            const SizedBox(height: 16),
            const Text('No Document Analyzed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Please upload a document to view its 6-category risk radar.'),
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

    final risks = doc.risks;
    final highCount = risks.where((r) => r.attentionLevel == AttentionTier.highAttention).length;
    final reviewCount = risks.where((r) => r.attentionLevel == AttentionTier.review).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Risk & Attention Radar',
                subtitle: 'Multidimensional evaluation across Financial, Employment, Privacy, Liability, IP, and Restrictions.',
                icon: Icons.shield_outlined,
              ),

              // Attention Overview Banner
              GlassCard(
                borderColor: highCount > 0 ? AppColors.priorityAttention.withOpacity(0.4) : null,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (highCount > 0 ? AppColors.priorityAttention : AppColors.priorityInfo).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        highCount > 0 ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                        color: highCount > 0 ? AppColors.priorityAttention : AppColors.priorityInfo,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            highCount > 0
                                ? '$highCount Risk Area(s) Require High Attention'
                                : 'All Evaluated Categories Appear Standard',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Identified $highCount high attention concern(s) and $reviewCount review recommendation(s). '
                            'All indicators use safe advisory language and should be reviewed with legal counsel if necessary.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 6 Risk Category Cards
              LayoutBuilder(
                builder: (context, constraints) {
                  final isTwoCol = constraints.maxWidth > 750;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: risks.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTwoCol ? 2 : 1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: isTwoCol ? 1.35 : 1.5,
                    ),
                    itemBuilder: (context, index) {
                      final item = risks[index];
                      return _RiskCard(item: item, isDark: isDark);
                    },
                  );
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
}

class _RiskCard extends StatelessWidget {
  final RiskItem item;
  final bool isDark;

  const _RiskCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.category.label,
                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
              ),
              PriorityBadge(tier: item.attentionLevel, compact: true),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.bookmark_outline_rounded, size: 13, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item.relevantClause,
                  style: const TextStyle(fontSize: 11.5, color: Colors.grey, fontStyle: FontStyle.italic),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ConfidenceBadge(confidence: item.confidence),
            ],
          ),
          const Divider(height: 18),
          Expanded(
            child: Text(
              item.explanation,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.5,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.recommend_outlined, size: 14, color: AppColors.primaryLight),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.recommendedAction,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
