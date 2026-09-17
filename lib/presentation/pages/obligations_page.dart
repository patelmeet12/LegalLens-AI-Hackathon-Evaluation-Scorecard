import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/legal_entities.dart';
import '../providers/app_providers.dart';
import '../widgets/shared_widgets.dart';

class ObligationsPage extends ConsumerStatefulWidget {
  const ObligationsPage({super.key});

  @override
  ConsumerState<ObligationsPage> createState() => _ObligationsPageState();
}

class _ObligationsPageState extends ConsumerState<ObligationsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, bool> _completedMap = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
            const Icon(Icons.assignment_outlined, size: 54, color: AppColors.primaryLight),
            const SizedBox(height: 16),
            const Text('No Document Analyzed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Please upload a document to view extracted party obligations.'),
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

    final yourObs = doc.obligations.where((o) => o.party == ObligationParty.your).toList();
    final otherObs = doc.obligations.where((o) => o.party == ObligationParty.otherParty).toList();
    final sharedObs = doc.obligations.where((o) => o.party == ObligationParty.shared).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 950),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'Obligation Extractor & Responsibility Matrix',
                subtitle: 'Deconstruct contract commitments into distinct, actionable duties for each contracting party.',
                icon: Icons.assignment_turned_in_outlined,
              ),

              // Tri-Party Tabs Bar
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  labelColor: isDark ? Colors.white : AppColors.primaryDark,
                  unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  tabs: [
                    Tab(
                      text: 'Your Responsibilities (${yourObs.length})',
                      icon: const Icon(Icons.person_outline_rounded, size: 18),
                    ),
                    Tab(
                      text: 'Other Party (${otherObs.length})',
                      icon: const Icon(Icons.business_outlined, size: 18),
                    ),
                    Tab(
                      text: 'Shared Duties (${sharedObs.length})',
                      icon: const Icon(Icons.handshake_outlined, size: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tab Views Container
              SizedBox(
                height: 480,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildObligationList(yourObs, ObligationParty.your, isDark),
                    _buildObligationList(otherObs, ObligationParty.otherParty, isDark),
                    _buildObligationList(sharedObs, ObligationParty.shared, isDark),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Export/Add to Action Center Banner
              GlassCard(
                child: Row(
                  children: [
                    const Icon(Icons.checklist_rtl_rounded, color: AppColors.primaryLight, size: 24),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ready to prepare for signing?',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Transfer critical obligations directly to your Action Center checklist to track completion.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      child: const Text('Open Action Center'),
                      onPressed: () => context.go('/action-center'),
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

  Widget _buildObligationList(List<Obligation> obligations, ObligationParty party, bool isDark) {
    if (obligations.isEmpty) {
      return Center(
        child: Text(
          'No specific obligations detected for this category.',
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: obligations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final ob = obligations[index];
        final isDone = _completedMap[ob.id] ?? false;

        return GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: isDone,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setState(() => _completedMap[ob.id] = val ?? false);
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ob.description,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        color: isDone
                            ? Colors.grey
                            : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.bookmark_border_rounded, size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Source: ${ob.sourceClause}',
                          style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
