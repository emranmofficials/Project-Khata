import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../../core/widgets/quick_action_button.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/summary_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../project/presentation/screens/new_project_screen.dart';
import '../../../attendance/presentation/screens/contractor_approval_screen.dart';
import '../../../accounting/presentation/screens/accounts_dashboard_screen.dart';
import '../../../notifications/presentation/screens/notifications_inbox_screen.dart';
import '../../../offline/presentation/widgets/offline_sync_banner.dart';

/// PRD সেকশন ৬.২ অনুযায়ী ঠিকাদার হোম ট্যাব
class ContractorHomeScreen extends ConsumerWidget {
  const ContractorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsInboxScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => ref.read(authStateProvider.notifier).signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineSyncBanner(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                // ডেটা রিফ্রেশ
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ১ ও ২: অভিবাদন ও সারাংশ কার্ড (নেভি গ্রেডিয়েন্ট)
              SummaryCard(
                role: 'contractor',
                orgName: user?.name ?? 'আমার প্রতিষ্ঠান',
                title: 'আজ সাইটে উপস্থিত শ্রমিক',
                kpiValue: '২৪', // মক/লাইভ কাউন্ট
                subText: 'মোট ৩টি চলমান প্রজেক্টে কাজ চলছে',
                onProfileTap: () {
                  // প্রোফাইল
                },
              ),

              const SizedBox(height: 24),

              // ৩: দ্রুত কাজ (চারটি গোল আইকন বাটন)
              const Text(
                'দ্রুত কাজ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: QuickActionButton(
                      icon: Icons.add_business_rounded,
                      label: 'নতুন প্রজেক্ট',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const NewProjectScreen()),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: QuickActionButton(
                      icon: Icons.person_add_alt_1_rounded,
                      label: 'নতুন শ্রমিক',
                      onTap: () {
                        // নতুন শ্রমিক ফর্ম
                      },
                    ),
                  ),
                  Expanded(
                    child: QuickActionButton(
                      icon: Icons.verified_user_outlined,
                      label: 'এন্ট্রি অনুমোদন',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ContractorApprovalScreen()),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: QuickActionButton(
                      icon: Icons.receipt_long_rounded,
                      label: 'বিল খতিয়ান',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AccountsDashboardScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ৪: সতর্কতা কার্ড (সতর্কতা সংখ্যা শূন্যের বেশি হলে দেখাবে)
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    _buildAlertItem(
                      icon: Icons.swap_horiz_rounded,
                      label: 'হস্তান্তর প্রয়োজন এন্ট্রি',
                      count: '১',
                      color: AppColors.danger,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ContractorApprovalScreen()),
                        );
                      },
                    ),
                    const Divider(height: 16),
                    _buildAlertItem(
                      icon: Icons.location_off_outlined,
                      label: 'সাইটের বাইরে হাজিরা অনুমোদন',
                      count: '৩',
                      color: AppColors.warning,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ContractorApprovalScreen()),
                        );
                      },
                    ),
                    const Divider(height: 16),
                    _buildAlertItem(
                      icon: Icons.history_rounded,
                      label: 'ব্যাকডেটেড এন্ট্রি অনুমোদনের অপেক্ষায়',
                      count: '২',
                      color: AppColors.warning,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ContractorApprovalScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ৫: চলমান প্রজেক্ট সারাংশ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'চলমান প্রজেক্ট',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('সব দেখুন', style: TextStyle(color: AppColors.contractorPrimary)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              _buildProjectPreviewCard(
                projectName: 'ধানমন্ডি লেকভিউ রেসিডেন্স',
                clientName: 'জনাব কামরুল হাসান',
                type: AppStrings.typeSqft,
                workersCount: '১২',
                status: 'খোলা',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildProjectPreviewCard(
                projectName: 'উত্তরা সেক্টর ৭ কমার্শিয়াল ভবন',
                clientName: 'মেসার্স ডেল্টা লিমিটেড',
                type: AppStrings.typeContract,
                workersCount: '৮',
                status: 'জমা',
                isDark: isDark,
              ),

              const SizedBox(height: 24),

              // ৬: আজকের এন্ট্রি সারাংশ
              const Text(
                'আজকের এন্ট্রি সারাংশ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _buildEntrySummaryCard(
                projectName: 'ধানমন্ডি লেকভিউ রেসিডেন্স',
                supervisorName: 'আব্দুল করিম',
                workersCount: '১২',
                status: 'খোলা',
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem({
    required IconData icon,
    required String label,
    required String count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              BengaliFormatter.toBengaliNumber(count),
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildProjectPreviewCard({
    required String projectName,
    required String clientName,
    required String type,
    required String workersCount,
    required String status,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  projectName,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              StatusChip.forStatus(status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'ক্লায়েন্ট: $clientName • $type',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.people_outline_rounded, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                'উপস্থিত শ্রমিক: ${BengaliFormatter.toBengaliNumber(workersCount)} জন',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEntrySummaryCard({
    required String projectName,
    required String supervisorName,
    required String workersCount,
    required String status,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.contractorPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.assignment_outlined, color: AppColors.contractorPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(projectName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  'সুপারভাইজার: $supervisorName • শ্রমিক: ${BengaliFormatter.toBengaliNumber(workersCount)} জন',
                  style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                ),
              ],
            ),
          ),
          StatusChip.forStatus(status),
        ],
      ),
    );
  }
}
