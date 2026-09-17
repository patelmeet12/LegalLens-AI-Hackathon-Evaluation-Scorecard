import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../widgets/shared_widgets.dart';

class LandingPage extends ConsumerWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mandatory Disclaimer Banner
              const LegalDisclaimerBanner(),
              const SizedBox(height: 36),

              // Hero Section
              _buildHero(context, ref, isDark),
              const SizedBox(height: 48),

              // Quick Try Sample Documents (1-Click hackathon demo)
              _buildSampleContracts(context, ref, isDark),
              const SizedBox(height: 48),

              // How it Works
              _buildHowItWorks(context, isDark),
              const SizedBox(height: 48),

              // Key Capabilities Grid
              _buildCapabilitiesGrid(context, isDark),
              const SizedBox(height: 48),

              // Privacy & Legal Safety Assurance
              _buildPrivacyAndSafety(context, isDark),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, WidgetRef ref, bool isDark) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.priorityInfo,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'PromptWars AI for Legal Assistance & Access',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryLight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Understand Before You Sign.',
          style: theme.textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Text(
            'Legal contracts are often complex, dense, and risky to navigate alone. '
            'LegalLens AI transforms legal agreements into plain-language explanations, '
            'extracts clear obligations, pinpoints hidden risks, and prepares you with smart questions for a lawyer.',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 17,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('Analyze a Document Now'),
              onPressed: () => context.go('/upload'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.compare_arrows_rounded, size: 18),
              label: const Text('Compare Two Contracts'),
              onPressed: () => context.go('/comparison'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSampleContracts(BuildContext context, WidgetRef ref, bool isDark) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flash_on_rounded, color: AppColors.priorityReview, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Quick Evaluation Presets (Instant 1-Click Analysis)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Test the intelligence engine immediately with real-world sample contracts containing subtle attention areas:',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _SampleContractButton(
                title: 'Tech Employment Agreement',
                subtitle: '90-day notice, IP assignment, 12-mo non-compete',
                icon: Icons.badge_outlined,
                onTap: () async {
                  context.go('/upload');
                  await ref.read(documentNotifierProvider.notifier).analyzeDocument(
                        rawText: AppConstants.sampleEmploymentContract,
                        documentType: 'Employment Agreement',
                        fileName: 'Sample_Tech_Employment_Agreement.txt',
                      );
                  if (context.mounted) context.go('/snapshot');
                },
              ),
              _SampleContractButton(
                title: 'Residential Lease Agreement',
                subtitle: 'Late fee penalties, auto-renewal, security deposit',
                icon: Icons.apartment_outlined,
                onTap: () async {
                  context.go('/upload');
                  await ref.read(documentNotifierProvider.notifier).analyzeDocument(
                        rawText: AppConstants.sampleLeaseAgreement,
                        documentType: 'Rental / Lease Agreement',
                        fileName: 'Sample_Residential_Lease.txt',
                      );
                  if (context.mounted) context.go('/snapshot');
                },
              ),
              _SampleContractButton(
                title: 'Mutual Non-Disclosure (NDA)',
                subtitle: 'Trade secret survival, return duties, injunction',
                icon: Icons.lock_outline_rounded,
                onTap: () async {
                  context.go('/upload');
                  await ref.read(documentNotifierProvider.notifier).analyzeDocument(
                        rawText: AppConstants.sampleMutualNDA,
                        documentType: 'NDA',
                        fileName: 'Sample_Mutual_NDA.txt',
                      );
                  if (context.mounted) context.go('/snapshot');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks(BuildContext context, bool isDark) {
    final steps = [
      {'step': '01', 'title': 'Select & Ingest', 'desc': 'Upload PDF/TXT or paste text. Select your document category with zero server transmission.'},
      {'step': '02', 'title': 'Grounded Analysis', 'desc': 'Local NLP extracts 15 clause categories, maps obligations, and detects timelines.'},
      {'step': '03', 'title': 'Risk & Clause Radar', 'desc': 'Explore plain-language breakdowns, why clauses matter, and safe attention ratings.'},
      {'step': '04', 'title': 'Decide & Prepare', 'desc': 'Ask grounded questions, complete the action checklist, and generate lawyer questions.'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How LegalLens AI Works',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          'From wall of legal jargon to an actionable, understandable roadmap in seconds.',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final isMultiCol = constraints.maxWidth > 700;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: steps.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMultiCol ? 4 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isMultiCol ? 0.95 : 0.85,
              ),
              itemBuilder: (context, index) {
                final s = steps[index];
                return GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        s['step']!,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryLight.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s['title']!,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s['desc']!,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildCapabilitiesGrid(BuildContext context, bool isDark) {
    final features = [
      {'icon': Icons.lightbulb_outline_rounded, 'title': 'Plain-Language Translations', 'desc': 'Every clause is translated into direct English alongside "Why It Matters" and the original verbatim text.'},
      {'icon': Icons.checklist_rtl_rounded, 'title': 'Tri-Partitioned Obligations', 'desc': 'Separates responsibilities into "Your Duties", "Other Party Duties", and "Shared Responsibilities".'},
      {'icon': Icons.timeline_rounded, 'title': 'Milestone Timeline', 'desc': 'Extracts probation, notice, and expiration dates. Never invents dates ("Not detected" fallback).'},
      {'icon': Icons.shield_outlined, 'title': '6-Category Risk Radar', 'desc': 'Evaluates Financial, Employment, Privacy, Liability, IP, and Restrictions using safe non-definitive phrasing.'},
      {'icon': Icons.chat_bubble_outline_rounded, 'title': 'Document Grounded Q&A', 'desc': 'Answers strictly using provided text, cites section titles, and refuses unmentioned queries.'},
      {'icon': Icons.compare_arrows_rounded, 'title': 'Side-by-Side Comparison', 'desc': 'Diff two contract versions to pinpoint altered compensation, expanded restrictions, or lost severance.'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deep Document Intelligence Features',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final isThreeCol = constraints.maxWidth > 850;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: features.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isThreeCol ? 3 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isThreeCol ? 1.3 : 1.2,
              ),
              itemBuilder: (context, index) {
                final f = features[index];
                return GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(f['icon'] as IconData, color: AppColors.primaryLight, size: 20),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        f['title'] as String,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Text(
                          f['desc'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildPrivacyAndSafety(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.priorityInfo.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.security_rounded, color: AppColors.priorityInfo, size: 26),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Privacy-First Architecture & Responsible AI Guarantee',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  '• Zero Backend Uploads: Documents are parsed and analyzed directly within your browser.\n'
                  '• Safe Advisory Language: We avoid definitive legal conclusions and label risks as "Requires attention" or "Potential concern".\n'
                  '• Anti-Hallucination Guardrails: If information is missing from the document, the AI will explicitly state so.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    height: 1.5,
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

class _SampleContractButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _SampleContractButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primaryLight, size: 20),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primaryLight),
          ],
        ),
      ),
    );
  }
}
