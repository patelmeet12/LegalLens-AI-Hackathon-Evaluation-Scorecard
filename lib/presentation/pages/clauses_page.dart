import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/legal_entities.dart';
import '../providers/app_providers.dart';
import '../widgets/shared_widgets.dart';

class ClausesPage extends ConsumerStatefulWidget {
  const ClausesPage({super.key});

  @override
  ConsumerState<ClausesPage> createState() => _ClausesPageState();
}

class _ClausesPageState extends ConsumerState<ClausesPage> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  AttentionTier? _selectedTier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final docState = ref.watch(documentNotifierProvider);
    final doc = docState.currentDocument;

    if (doc == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.analytics_outlined, size: 54, color: AppColors.primaryLight),
            const SizedBox(height: 16),
            const Text('No Document Analyzed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Please upload a document to inspect its clauses and explanations.'),
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

    final categories = ['All', ...doc.clauses.map((c) => c.category).toSet()];

    // Filter clauses
    final filteredClauses = doc.clauses.where((c) {
      if (_selectedCategory != 'All' && c.category != _selectedCategory) {
        return false;
      }
      if (_selectedTier != null && c.importance != _selectedTier) {
        return false;
      }
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = c.title.toLowerCase().contains(q) ||
            c.plainLanguageExplanation.toLowerCase().contains(q) ||
            c.originalText.toLowerCase().contains(q) ||
            c.whyItMatters.toLowerCase().contains(q);
        if (!match) return false;
      }
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Clause Intelligence & Plain-Language Explanations',
                subtitle: 'Translating dense legalese into clear terms, why each clause matters, and recommended review points.',
                icon: Icons.analytics_outlined,
              ),

              // Search & Filters Bar
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search text field
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search clauses, terms (e.g. "termination", "non-compete", "notice", "IP")...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                onPressed: () => setState(() => _searchQuery = ''),
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                    const SizedBox(height: 14),

                    // Priority Filter Pills
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text('Attention Level:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        FilterChip(
                          label: const Text('All Levels', style: TextStyle(fontSize: 12)),
                          selected: _selectedTier == null,
                          onSelected: (_) => setState(() => _selectedTier = null),
                        ),
                        FilterChip(
                          avatar: const Text('🔴', style: TextStyle(fontSize: 11)),
                          label: const Text('High Attention', style: TextStyle(fontSize: 12)),
                          selected: _selectedTier == AttentionTier.highAttention,
                          onSelected: (_) => setState(() => _selectedTier = AttentionTier.highAttention),
                        ),
                        FilterChip(
                          avatar: const Text('🟡', style: TextStyle(fontSize: 11)),
                          label: const Text('Requires Review', style: TextStyle(fontSize: 12)),
                          selected: _selectedTier == AttentionTier.review,
                          onSelected: (_) => setState(() => _selectedTier = AttentionTier.review),
                        ),
                        FilterChip(
                          avatar: const Text('🟢', style: TextStyle(fontSize: 11)),
                          label: const Text('Informational', style: TextStyle(fontSize: 12)),
                          selected: _selectedTier == AttentionTier.informational,
                          onSelected: (_) => setState(() => _selectedTier = AttentionTier.informational),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Category Filter Scroll
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.map((cat) {
                          final isSelected = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(cat, style: const TextStyle(fontSize: 11.5)),
                              selected: isSelected,
                              onSelected: (_) => setState(() => _selectedCategory = cat),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Filter results count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing ${filteredClauses.length} of ${doc.clauses.length} detected clauses',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  if (_searchQuery.isNotEmpty || _selectedCategory != 'All' || _selectedTier != null)
                    TextButton(
                      child: const Text('Reset Filters', style: TextStyle(fontSize: 12)),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _selectedCategory = 'All';
                          _selectedTier = null;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Clauses List
              if (filteredClauses.isEmpty)
                GlassCard(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.search_off_rounded, size: 40, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text('No clauses matched your filters.', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        const Text('Try adjusting your search keyword or clearing the attention level filter.'),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredClauses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final clause = filteredClauses[index];
                    return _ClauseDetailCard(clause: clause, isDark: isDark);
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

class _ClauseDetailCard extends StatefulWidget {
  final LegalClause clause;
  final bool isDark;

  const _ClauseDetailCard({required this.clause, required this.isDark});

  @override
  State<_ClauseDetailCard> createState() => _ClauseDetailCardState();
}

class _ClauseDetailCardState extends State<_ClauseDetailCard> {
  bool _showOriginalText = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.clause;
    final isDark = widget.isDark;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Category, Title, Priority Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  c.category,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  c.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              PriorityBadge(tier: c.importance),
            ],
          ),
          const SizedBox(height: 16),

          // Plain-Language Explanation (Highlighted)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border(
                left: BorderSide(
                  color: c.importance == AttentionTier.highAttention
                      ? AppColors.priorityAttention
                      : AppColors.primary,
                  width: 3.5,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.translate_rounded, size: 14, color: AppColors.primaryLight),
                    SizedBox(width: 6),
                    Text(
                      'Plain-Language Explanation:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  c.plainLanguageExplanation,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.5,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Why It Matters
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.secondary),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Why It Matters: ',
                        style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.secondary),
                      ),
                      TextSpan(text: c.whyItMatters),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Potential Concern (if review or high attention)
          if (c.importance != AttentionTier.informational) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: c.importance == AttentionTier.highAttention
                      ? AppColors.priorityAttention
                      : AppColors.priorityReview,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                      children: [
                        TextSpan(
                          text: 'Potential Concern: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: c.importance == AttentionTier.highAttention
                                ? AppColors.priorityAttention
                                : AppColors.priorityReview,
                          ),
                        ),
                        TextSpan(text: c.potentialConcern),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Recommended Review
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.priorityInfo),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Recommended Action: ',
                        style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.priorityInfo),
                      ),
                      TextSpan(text: c.recommendedReview),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 20),

          // Original Text Toggle (Mandatory requirement: Never remove the original text)
          InkWell(
            onTap: () => setState(() => _showOriginalText = !_showOriginalText),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    _showOriginalText ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _showOriginalText ? 'Hide Original Clause Text' : 'View Original Verbatim Clause Text',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          if (_showOriginalText) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle,
                ),
              ),
              child: SelectableText(
                c.originalText,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  height: 1.5,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
