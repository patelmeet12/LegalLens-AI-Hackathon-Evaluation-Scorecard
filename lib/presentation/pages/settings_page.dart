import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../widgets/shared_widgets.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _obscureKey = true;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsNotifierProvider);
    if (settings.apiKey != null) {
      _apiKeyController.text = settings.apiKey!;
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveApiKey() async {
    final key = _apiKeyController.text.trim();
    await ref.read(settingsNotifierProvider.notifier).setApiKey(key.isNotEmpty ? key : null);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI Configuration updated successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = ref.watch(settingsNotifierProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Settings, AI Engine & Privacy',
                subtitle: 'Configure local Demo Mode or optional cloud GenAI keys, manage data retention, and review legal notices.',
                icon: Icons.settings_outlined,
              ),

              // AI Engine Configuration Card
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.psychology_rounded, color: AppColors.primaryLight, size: 22),
                        SizedBox(width: 10),
                        Text(
                          'GenAI Engine Mode',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Choose between instant deterministic client-side analysis (Demo Mode) or connecting your personal Google Gemini API key.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const Divider(height: 24),

                    // Demo Mode Switch
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Use Local Demo Intelligence Engine (Recommended)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text(
                        '100% private, zero network latency, deterministic 15-category clause parsing, and grounded Q&A.',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: settings.isDemoMode,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        ref.read(settingsNotifierProvider.notifier).setDemoMode(val);
                      },
                    ),

                    if (!settings.isDemoMode) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Optional Google Gemini API Key', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(
                              'Your key is stored only in browser local storage and never sent to any intermediary server.',
                              style: TextStyle(fontSize: 11.5, color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _apiKeyController,
                                    obscureText: _obscureKey,
                                    decoration: InputDecoration(
                                      hintText: 'Enter AIzaSy... API key',
                                      suffixIcon: IconButton(
                                        icon: Icon(_obscureKey ? Icons.visibility_off : Icons.visibility, size: 18),
                                        onPressed: () => setState(() => _obscureKey = !_obscureKey),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: _saveApiKey,
                                  child: const Text('Save Key'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Privacy & Data Center
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.security_rounded, color: AppColors.priorityInfo, size: 22),
                        SizedBox(width: 10),
                        Text('Privacy & Data Governance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• No server uploads: Documents are processed locally in your browser session.\n'
                      '• No permanent remote storage: No Firebase, Supabase, or external database is used.\n'
                      '• Immediate purge available: You can purge all cached history, preferences, and checklists instantly.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.delete_forever_rounded, size: 16, color: AppColors.priorityAttention),
                      label: const Text('Purge All Local Data & Reset', style: TextStyle(color: AppColors.priorityAttention)),
                      onPressed: () async {
                        await ref.read(settingsNotifierProvider.notifier).clearAllData();
                        ref.read(documentNotifierProvider.notifier).clearDocument();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('All local data and storage purged successfully.')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Full Legal Disclaimer
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.gavel_rounded, color: AppColors.primaryLight, size: 22),
                        SizedBox(width: 10),
                        Text('Official Legal Disclaimer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppConstants.legalDisclaimerFull,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'LegalLens AI does not represent, warrant, or guarantee any specific legal outcome. '
                      'Contract interpretation varies across state, federal, and international jurisdictions.',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                      ),
                    ),
                  ],
                ),
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
