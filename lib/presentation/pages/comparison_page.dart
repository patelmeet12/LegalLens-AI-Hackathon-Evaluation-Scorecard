import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/legal_entities.dart';
import '../providers/app_providers.dart';
import '../widgets/shared_widgets.dart';

class ComparisonPage extends ConsumerStatefulWidget {
  const ComparisonPage({super.key});

  @override
  ConsumerState<ComparisonPage> createState() => _ComparisonPageState();
}

class _ComparisonPageState extends ConsumerState<ComparisonPage> {
  final TextEditingController _docANameController = TextEditingController(text: 'Offer_Option_A.txt');
  final TextEditingController _docATextController = TextEditingController(text: AppConstants.sampleComparisonOfferA);

  final TextEditingController _docBNameController = TextEditingController(text: 'Offer_Option_B.txt');
  final TextEditingController _docBTextController = TextEditingController(text: AppConstants.sampleComparisonOfferB);

  @override
  void dispose() {
    _docANameController.dispose();
    _docATextController.dispose();
    _docBNameController.dispose();
    _docBTextController.dispose();
    super.dispose();
  }

  Future<void> _handleCompare() async {
    await ref.read(comparisonNotifierProvider.notifier).compare(
          textA: _docATextController.text,
          nameA: _docANameController.text,
          textB: _docBTextController.text,
          nameB: _docBNameController.text,
        );
  }

  void _loadPresetOffers() {
    setState(() {
      _docANameController.text = 'Option_A_Enterprise_Offer.txt';
      _docATextController.text = AppConstants.sampleComparisonOfferA;
      _docBNameController.text = 'Option_B_Startup_Offer.txt';
      _docBTextController.text = AppConstants.sampleComparisonOfferB;
    });
    _handleCompare();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final compState = ref.watch(comparisonNotifierProvider);
    final result = compState.comparison;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1050),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Contract Side-by-Side Comparison',
                subtitle: 'Compare two versions of an agreement to identify added, removed, or changed clauses, obligations, and financial terms.',
                icon: Icons.compare_arrows_rounded,
                trailing: ElevatedButton.icon(
                  icon: const Icon(Icons.flash_on_rounded, size: 16),
                  label: const Text('Load Sample Comparison'),
                  onPressed: _loadPresetOffers,
                ),
              ),

              // Inputs Container (Document A vs Document B)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;
                  return Flex(
                    direction: isWide ? Axis.horizontal : Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Document A
                      Expanded(
                        flex: isWide ? 1 : 0,
                        child: GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text('Doc A (Base)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryLight)),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _docANameController,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _docATextController,
                                maxLines: 6,
                                style: const TextStyle(fontSize: 12, height: 1.4, fontFamily: 'monospace'),
                                decoration: const InputDecoration(hintText: 'Paste Document A text...'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Document B
                      Expanded(
                        child: GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text('Doc B (Revision)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondary)),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _docBNameController,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _docBTextController,
                                maxLines: 6,
                                style: const TextStyle(fontSize: 12, height: 1.4, fontFamily: 'monospace'),
                                decoration: const InputDecoration(hintText: 'Paste Document B text...'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 18),

              // Run Comparison Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.analytics_rounded, size: 18),
                  label: Text(
                    compState.isComparing ? 'Diffing Contracts...' : 'Run Contract Comparison',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  onPressed: compState.isComparing ? null : _handleCompare,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
              ),
              const SizedBox(height: 28),

              // Comparison Results View
              if (result != null) ...[
                // High Attention Differences Banner
                if (result.highAttentionDifferences.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.priorityAttention.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.priorityAttention.withOpacity(0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: AppColors.priorityAttention, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Potentially Important Differences Detected',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.priorityAttention,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...result.highAttentionDifferences.map((d) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ', style: TextStyle(color: AppColors.priorityAttention)),
                                  Expanded(child: Text(d, style: const TextStyle(fontSize: 13, height: 1.4))),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Changed Clauses Side-by-Side
                const Text(
                  'Changed & Modified Clauses',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: result.changedClauses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final diff = result.changedClauses[index];
                    return _ChangedClauseCard(diff: diff, isDark: isDark);
                  },
                ),
                const SizedBox(height: 24),

                // Financial & Obligation Changes Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 700;
                    return Flex(
                      direction: isWide ? Axis.horizontal : Axis.vertical,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: isWide ? 1 : 0,
                          child: GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.monetization_on_outlined, size: 18, color: AppColors.primaryLight),
                                    SizedBox(width: 8),
                                    Text('Financial & Term Changes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                                const Divider(height: 18),
                                ...result.changedFinancialTerms.map((f) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Text('• $f', style: const TextStyle(fontSize: 12.5, height: 1.4)),
                                    )),
                                ...result.changedDates.map((d) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Text('• $d', style: const TextStyle(fontSize: 12.5, height: 1.4)),
                                    )),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.rule_folder_outlined, size: 18, color: AppColors.secondary),
                                    SizedBox(width: 8),
                                    Text('Added & Removed Terms', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                                const Divider(height: 18),
                                ...result.addedClauses.map((a) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Text('➕ Added: $a', style: const TextStyle(fontSize: 12.5, height: 1.4, color: AppColors.priorityInfo)),
                                    )),
                                ...result.removedClauses.map((r) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Text('➖ Removed: $r', style: const TextStyle(fontSize: 12.5, height: 1.4, color: AppColors.priorityAttention)),
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],

              const SizedBox(height: 32),
              const LegalDisclaimerBanner(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChangedClauseCard extends StatelessWidget {
  final ClauseDiff diff;
  final bool isDark;

  const _ChangedClauseCard({required this.diff, required this.isDark});

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
                diff.clauseTitle,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              PriorityBadge(tier: diff.differenceTier, compact: true),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.primaryLight),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Diff Analysis: ${diff.changeSummary}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Document A Text:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(diff.docAText, style: const TextStyle(fontSize: 11.5, height: 1.4)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primaryLight.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Document B Text (Modified):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryLight)),
                          const SizedBox(height: 4),
                          Text(diff.docBText, style: const TextStyle(fontSize: 11.5, height: 1.4)),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
