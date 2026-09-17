import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../providers/app_providers.dart';

class NavItem {
  final String label;
  final IconData icon;
  final String route;
  final bool requiresDocument;

  const NavItem({
    required this.label,
    required this.icon,
    required this.route,
    this.requiresDocument = false,
  });
}

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const List<NavItem> navItems = [
    NavItem(label: 'Home & Vision', icon: Icons.home_rounded, route: '/'),
    NavItem(label: 'Upload Document', icon: Icons.upload_file_rounded, route: '/upload'),
    NavItem(label: 'Legal Snapshot', icon: Icons.dashboard_rounded, route: '/snapshot', requiresDocument: true),
    NavItem(label: 'Clause Intelligence', icon: Icons.analytics_outlined, route: '/clauses', requiresDocument: true),
    NavItem(label: 'Obligation Extractor', icon: Icons.assignment_outlined, route: '/obligations', requiresDocument: true),
    NavItem(label: 'Important Dates', icon: Icons.timeline_rounded, route: '/timeline', requiresDocument: true),
    NavItem(label: 'Risk & Attention Map', icon: Icons.shield_outlined, route: '/risk-map', requiresDocument: true),
    NavItem(label: 'Document Grounded Q&A', icon: Icons.forum_outlined, route: '/qa', requiresDocument: true),
    NavItem(label: 'Compare Contracts', icon: Icons.compare_arrows_rounded, route: '/comparison'),
    NavItem(label: 'Action Center & Prep', icon: Icons.checklist_rounded, route: '/action-center', requiresDocument: true),
    NavItem(label: 'Document History', icon: Icons.history_rounded, route: '/history'),
    NavItem(label: 'Settings & Privacy', icon: Icons.settings_outlined, route: '/settings'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentRoute = GoRouterState.of(context).uri.path;
    final docState = ref.watch(documentNotifierProvider);
    final currentDoc = docState.currentDocument;

    final isWideScreen = MediaQuery.of(context).size.width >= 960;

    return Scaffold(
      appBar: isWideScreen
          ? null
          : AppBar(
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.gavel_rounded, size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AppConstants.appName,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: 'Toggle Dark / Light Theme',
                  icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
                  onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
                ),
              ],
            ),
      drawer: isWideScreen ? null : Drawer(child: _buildNavContent(context, ref, currentRoute, currentDoc, isDark)),
      body: Row(
        children: [
          if (isWideScreen)
            SizedBox(
              width: 270,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  border: Border(
                    right: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      width: 1,
                    ),
                  ),
                ),
                child: _buildNavContent(context, ref, currentRoute, currentDoc, isDark),
              ),
            ),
          Expanded(
            child: Column(
              children: [
                // Top Header Bar
                _buildTopBar(context, ref, currentRoute, currentDoc, isDark, isWideScreen),
                // Main Content Body
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    WidgetRef ref,
    String currentRoute,
    dynamic currentDoc,
    bool isDark,
    bool isWide,
  ) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBg : AppColors.lightBg,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Legal Notice Pill
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.verified_user_outlined, size: 16, color: AppColors.primaryLight),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppConstants.legalDisclaimerShort,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Quick Action / Active Document Status
          if (currentDoc != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.description_outlined, size: 14, color: AppColors.primaryLight),
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 160),
                    child: Text(
                      currentDoc.fileName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 12),
          if (isWide)
            IconButton(
              tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              icon: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                size: 20,
              ),
              onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
            ),
        ],
      ),
    );
  }

  Widget _buildNavContent(
    BuildContext context,
    WidgetRef ref,
    String currentRoute,
    dynamic currentDoc,
    bool isDark,
  ) {
    return Column(
      children: [
        // Brand Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.gavel_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.appName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    AppConstants.appTagline,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Nav Links List
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            children: navItems.map((item) {
              final isSelected = currentRoute == item.route;
              final isDisabled = item.requiresDocument && currentDoc == null;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: ListTile(
                  dense: true,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  tileColor: isSelected
                      ? AppColors.primary.withOpacity(0.14)
                      : Colors.transparent,
                  leading: Icon(
                    item.icon,
                    size: 19,
                    color: isSelected
                        ? AppColors.primaryLight
                        : (isDisabled
                            ? (isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight)
                            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                  ),
                  title: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? (isDark ? Colors.white : AppColors.primaryDark)
                          : (isDisabled
                              ? (isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight)
                              : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                    ),
                  ),
                  trailing: isDisabled
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Doc req.', style: TextStyle(fontSize: 9)),
                        )
                      : null,
                  onTap: () {
                    if (isDisabled) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please upload or select a document first to unlock this view.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      context.go('/upload');
                    } else {
                      context.go(item.route);
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const Divider(height: 1),
        // Privacy & Storage Badge
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.priorityInfo),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Privacy-First Architecture',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Processed locally in browser',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
