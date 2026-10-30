import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_khata/core/constants/app_colors.dart';
import 'package:project_khata/core/constants/contractor_routes.dart';
import 'package:project_khata/core/constants/contractor_strings.dart';
import '../contractor_providers.dart';

/// পুনঃব্যবহারযোগ্য ঠিকাদার অ্যাপবার (ব্র্যান্ডেড হেডার)
/// এটি ঠিকাদার ইন্টারফেসের প্রতিটি মূল স্ক্রিনে একই নান্দনিক রূপ প্রদান করে।
class ContractorAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final PreferredSizeWidget? bottom;
  final Widget? customTitle;
  final List<Widget>? customActions;
  final bool automaticallyImplyLeading;

  const ContractorAppBar({
    super.key,
    this.bottom,
    this.customTitle,
    this.customActions,
    this.automaticallyImplyLeading = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      titleSpacing: 16,
      elevation: 0,
      scrolledUnderElevation: 1,
      bottom: bottom,
      title: customTitle ??
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF131D2E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1F2A40) : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/branding/app-icon.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.apartment_rounded,
                      color: AppColors.contractorNavy,
                      size: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'প্রজেক্ট খাতা',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.contractorNavy,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFEA619),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    summaryAsync.when(
                      data: (summary) => Row(
                        children: [
                          Flexible(
                            child: Text(
                              summary.companyName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: isDark
                                ? const Color(0xFF93A8F4)
                                : const Color(0xFF2563EB),
                          ),
                        ],
                      ),
                      loading: () => Text(
                        'লোড হচ্ছে...',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      error: (_, __) => Text(
                        ContractorStrings.defaultCompanyName,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      actions: customActions ??
          [
            summaryAsync.when(
              data: (summary) => Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    tooltip: 'নোটিফিকেশন',
                    icon: const Icon(Icons.notifications_none_rounded, size: 23),
                    onPressed: () => context.push(ContractorRoutes.notifications),
                  ),
                  if (summary.pendingApprovalsCount > 0)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? const Color(0xFF0F172A) : Colors.white,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              loading: () => IconButton(
                tooltip: 'নোটিফিকেশন',
                icon: const Icon(Icons.notifications_none_rounded, size: 23),
                onPressed: () => context.push(ContractorRoutes.notifications),
              ),
              error: (_, __) => IconButton(
                tooltip: 'নোটিফিকেশন',
                icon: const Icon(Icons.notifications_none_rounded, size: 23),
                onPressed: () => context.push(ContractorRoutes.notifications),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 14.0),
              child: InkWell(
                onTap: () => context.push(ContractorRoutes.myProfile),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? const Color(0xFF2563EB) : AppColors.contractorNavy,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.contractorNavy.withValues(alpha: 0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
    );
  }
}
