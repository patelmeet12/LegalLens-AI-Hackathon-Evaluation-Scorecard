import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/enums.dart';

/// Multi-factor Priority Badge: Uses Icon + Text + Color (Never relies on color alone)
class PriorityBadge extends StatelessWidget {
  final AttentionTier tier;
  final bool compact;

  const PriorityBadge({
    super.key,
    required this.tier,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;
    String text;

    switch (tier) {
      case AttentionTier.informational:
        bg = AppColors.priorityInfo.withOpacity(0.15);
        fg = AppColors.priorityInfo;
        icon = Icons.check_circle_outline_rounded;
        text = 'Informational';
        break;
      case AttentionTier.review:
        bg = AppColors.priorityReview.withOpacity(0.15);
        fg = AppColors.priorityReview;
        icon = Icons.help_outline_rounded;
        text = 'Requires Review';
        break;
      case AttentionTier.highAttention:
        bg = AppColors.priorityAttention.withOpacity(0.15);
        fg = AppColors.priorityAttention;
        icon = Icons.warning_amber_rounded;
        text = 'High Attention';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 13 : 15, color: fg),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: compact ? 11 : 12.5,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

/// Confidence Indicator: High / Medium / Low with alert on low
class ConfidenceBadge extends StatelessWidget {
  final ConfidenceLevel confidence;

  const ConfidenceBadge({super.key, required this.confidence});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (confidence) {
      case ConfidenceLevel.high:
        color = AppColors.priorityInfo;
        label = 'High Confidence';
        break;
      case ConfidenceLevel.medium:
        color = AppColors.priorityReview;
        label = 'Medium Confidence';
        break;
      case ConfidenceLevel.low:
        color = AppColors.priorityAttention;
        label = 'Low Confidence';
        break;
    }

    return Tooltip(
      message: confidence == ConfidenceLevel.low ? AppConstants.lowConfidenceWarning : label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modern Surface Card Container
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? backgroundColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final card = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark ? AppColors.darkCard : AppColors.lightCard),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ?? (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: 1,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: card,
      );
    }

    return card;
  }
}

/// Standardized Section Header
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primaryLight, size: 22),
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Mandatory Legal Disclaimer Banner
class LegalDisclaimerBanner extends StatelessWidget {
  final bool isDismissible;

  const LegalDisclaimerBanner({super.key, this.isDismissible = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryDark.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryLight.withOpacity(0.25), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.verified_user_outlined, size: 18, color: AppColors.primaryLight),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppConstants.legalDisclaimerShort,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
