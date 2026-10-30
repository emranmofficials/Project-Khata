import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/contractor_strings.dart';

/// ১. HeroSummaryCard: রেফারেন্স কার্ড স্টাইলে নেভি গ্রেডিয়েন্ট, ব্যালেন্স/বাজেট ও ট্রেন্ড ব্যাজ
class HeroSummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final String? subtitle;
  final String? badgeText;
  final IconData? badgeIcon;
  final String? secondaryText;
  final VoidCallback? onTap;
  final VoidCallback? onActionTap;
  final IconData? actionIcon;

  const HeroSummaryCard({
    super.key,
    required this.title,
    required this.amount,
    this.subtitle,
    this.badgeText,
    this.badgeIcon,
    this.secondaryText,
    this.onTap,
    this.onActionTap,
    this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20), // ২০ px গোল কোণ
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.contractorNavy, // #1E3A8A নেভি
            Color(0xFF172554), // গাঢ় নেভি
            Color(0xFF0F172A), // ডিপ নেভি স্লেট (কোনো সবুজ নয়)
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.contractorNavy.withValues(alpha: 0.18),
            offset: const Offset(0, 8),
            blurRadius: 20,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // ব্যাকগ্রাউন্ড ওয়াটারমার্ক / অলঙ্করণ সার্কেল (বাইরের কোনো ছবি বা ইউআরএল নয়)
              Positioned(
                right: -24,
                top: -24,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                right: 32,
                bottom: -40,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.03),
                  ),
                ),
              ),

              // কার্ড কন্টেন্ট
              Padding(
                padding: const EdgeInsets.all(22.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // টাইটেল রো এবং অপশনাল অ্যাকশন বাটন
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                        if (actionIcon != null)
                          IconButton(
                            icon: Icon(actionIcon, color: Colors.white70, size: 20),
                            onPressed: onActionTap,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          )
                        else if (secondaryText != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              secondaryText!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // বড় অ্যামাউন্ট টাইপোগ্রাফি
                    Text(
                      amount,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ব্যাজ রো (ট্রেন্ড বা সক্রিয় প্রজেক্ট সংখ্যা)
                    if (badgeText != null || subtitle != null)
                      Row(
                        children: [
                          if (badgeText != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    badgeIcon ?? Icons.trending_up_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    badgeText!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (badgeText != null && subtitle != null)
                            const SizedBox(width: 8),
                          if (subtitle != null)
                            Expanded(
                              child: Text(
                                subtitle!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ২. QuickAction: রেফারেন্স অনুযায়ী সার্কুলার অ্যাকশন বাটন ও নিচে লেবেল
class QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final int? badgeCount;

  const QuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor = backgroundColor ??
        AppColors.contractorNavy.withValues(alpha: 0.08);
    final effectiveIconColor = iconColor ?? AppColors.contractorNavy;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: effectiveBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: effectiveIconColor,
                      size: 26,
                    ),
                  ),
                ),
                if (badgeCount != null && badgeCount! > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '$badgeCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ৩. SectionTitleRow: সেকশন শিরোনাম ও ডানপাশে 'সব দেখুন' লিঙ্ক
class SectionTitleRow extends StatelessWidget {
  final String title;
  final String? actionTitle;
  final VoidCallback? onActionTap;
  final Widget? trailing;

  const SectionTitleRow({
    super.key,
    required this.title,
    this.actionTitle,
    this.onActionTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.darkTextPrimary,
            ),
          ),
          if (trailing != null)
            trailing!
          else if (actionTitle != null)
            InkWell(
              onTap: onActionTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionTitle ?? ContractorStrings.seeAll,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.contractorNavy,
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: AppColors.contractorNavy,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// ৪. IconTile: গোল কোণযুক্ত কার্ড ও আইকন বক্স সহ লিস্ট টাইল (ট্রানজ্যাকশন/প্রজেক্ট স্টাইল)
class IconTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailingTitle;
  final String? trailingSubtitle;
  final Widget? trailingWidget;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final Color? trailingColor;
  final VoidCallback? onTap;

  const IconTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailingTitle,
    this.trailingSubtitle,
    this.trailingWidget,
    this.iconColor,
    this.iconBackgroundColor,
    this.trailingColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveIconColor = iconColor ?? AppColors.contractorNavy;
    final effectiveIconBg = iconBackgroundColor ??
        effectiveIconColor.withValues(alpha: 0.1);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20), // ২০ px গোল কোণ
        border: Border.all(color: borderColor, width: 1), // হালকা বর্ডার (ছায়া নয়)
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // আইকন কনটেইনার (রেফারেন্স স্টাইল)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: effectiveIconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: effectiveIconColor,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // শিরোনাম ও সাবটাইটেল
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // ট্রেইলিং এলিমেন্ট
                if (trailingWidget != null)
                  trailingWidget!
                else if (trailingTitle != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        trailingTitle!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: trailingColor ??
                              (isDark ? Colors.white : AppColors.darkTextPrimary),
                        ),
                      ),
                      if (trailingSubtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          trailingSubtitle!,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ],
                  )
                else
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ৫. StatusChip: স্ট্যাটাস ব্যাজ উইজেট
class StatusChip extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? backgroundColor;

  const StatusChip({
    super.key,
    required this.label,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.contractorNavy;
    final effectiveBg = backgroundColor ?? effectiveColor.withValues(alpha: 0.1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: effectiveColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: effectiveColor,
        ),
      ),
    );
  }
}

/// ৬. EmptyState: তালিকা খালি থাকলে ক্লিন আইকন ও বার্তা
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : AppColors.contractorNavy.withValues(alpha: 0.08),
              ),
              child: Icon(
                icon,
                size: 34,
                color: isDark ? Colors.white70 : AppColors.contractorNavy,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
            if (actionLabel != null && onActionTap != null) ...[
              const SizedBox(height: 18),
              OutlinedButton(
                onPressed: onActionTap,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// ৭. KpiCard: ২০ px গোল কোণ কার্ড মেট্রিক প্রদর্শনের জন্য
class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor = iconColor ?? AppColors.contractorNavy;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: effectiveColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 18, color: effectiveColor),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// ৮. toBn: সংখ্যাকে বাংলা ডিজিটে রূপান্তর
String toBn(dynamic value) {
  if (value == null) return '';
  final str = value.toString();
  const enToBn = {
    '0': '০',
    '1': '১',
    '2': '২',
    '3': '৩',
    '4': '৪',
    '5': '৫',
    '6': '৬',
    '7': '৭',
    '8': '৮',
    '9': '৯',
  };
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    final char = str[i];
    buffer.write(enToBn[char] ?? char);
  }
  return buffer.toString();
}

/// ৯. requiredValidator: খালি ফিল্ড ভ্যালিডেশন
String? requiredValidator(String? value, [String message = 'এই তথ্যটি দেওয়া আবশ্যক']) {
  if (value == null || value.trim().isEmpty) {
    return message;
  }
  return null;
}

/// ১০. greetingByHour: সময়ভিত্তিক বাংলা অভিবাদন
String greetingByHour(DateTime time) {
  final hour = time.hour;
  if (hour >= 4 && hour < 12) {
    return ContractorStrings.greetingMorning;
  } else if (hour >= 12 && hour < 17) {
    return ContractorStrings.greetingAfternoon;
  } else {
    return ContractorStrings.greetingEvening;
  }
}
