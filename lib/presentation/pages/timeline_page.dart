import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/legal_entities.dart';
import '../providers/app_providers.dart';
import '../widgets/shared_widgets.dart';

class TimelinePage extends ConsumerWidget {
  const TimelinePage({super.key});

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
            const Icon(Icons.timeline_rounded, size: 54, color: AppColors.primaryLight),
            const SizedBox(height: 16),
            const Text('No Document Analyzed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Please upload a document to view its milestone timeline.'),
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

    final dates = doc.dates;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Important Dates & Milestone Timeline',
                subtitle: 'Chronological timeline of effective windows, probation, notice requirements, and renewal cycles.',
                icon: Icons.timeline_rounded,
              ),

              // Responsible AI Warning Card regarding Dates
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryLight.withOpacity(0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_clock_outlined, size: 18, color: AppColors.primaryLight),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Anti-Hallucination Safe Policy: Dates are only shown when explicitly cited in the agreement. If omitted from the document, they are strictly marked as "Not detected." We never fabricate dates.',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primaryLight),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Milestone Timeline Visual
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dates.length,
                itemBuilder: (context, index) {
                  final item = dates[index];
                  final isLast = index == dates.length - 1;
                  return _TimelineNode(
                    date: item,
                    isLast: isLast,
                    isDark: isDark,
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

class _TimelineNode extends StatelessWidget {
  final ImportantDate date;
  final bool isLast;
  final bool isDark;

  const _TimelineNode({
    required this.date,
    required this.isLast,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isDetected = date.isDetected;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stepper Line & Dot
        SizedBox(
          width: 40,
          child: Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDetected ? AppColors.primary : Colors.grey.withOpacity(0.4),
                  border: Border.all(
                    color: isDetected ? AppColors.primaryLight : Colors.grey,
                    width: 2,
                  ),
                ),
                child: isDetected
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : const Icon(Icons.close, size: 12, color: Colors.white),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 90,
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Content Card
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: GlassCard(
              padding: const EdgeInsets.all(16),
              borderColor: !isDetected ? Colors.grey.withOpacity(0.3) : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (isDetected ? AppColors.primary : Colors.grey).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          date.type,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDetected ? AppColors.primaryLight : Colors.grey,
                          ),
                        ),
                      ),
                      Text(
                        isDetected ? date.dateString : AppConstants.notDetectedDate,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isDetected ? AppColors.priorityInfo : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    date.title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    date.sourceSnippet,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
