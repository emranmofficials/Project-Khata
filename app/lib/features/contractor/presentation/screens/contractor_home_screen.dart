import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/quick_action_button.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/summary_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../project/domain/models/project_model.dart';
import '../../../project/presentation/providers/project_provider.dart';
import '../../../project/presentation/screens/new_project_screen.dart';
import '../../../project/presentation/screens/project_details_screen.dart';
import '../../../project/presentation/screens/project_list_screen.dart';
import '../../../worker/presentation/providers/worker_provider.dart';
import '../../../worker/presentation/screens/workers_management_screen.dart';
import '../../../attendance/presentation/providers/attendance_provider.dart';
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
    final projectsAsync = ref.watch(projectsListProvider);
    final workersAsync = ref.watch(workersListProvider);
    final pendingApprovalsAsync = ref.watch(pendingAttendanceApprovalsProvider);
    final handoverEntriesAsync = ref.watch(handoverEntriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pendingCount = pendingApprovalsAsync.valueOrNull?.length ?? 0;
    final handoverCount = handoverEntriesAsync.valueOrNull?.length ?? 0;
    final totalAlerts = pendingCount + handoverCount;

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
                ref.invalidate(projectsListProvider);
                ref.invalidate(workersListProvider);
                ref.invalidate(pendingAttendanceApprovalsProvider);
                ref.invalidate(handoverEntriesProvider);
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ১. সারসংক্ষেপ কার্ড
                    projectsAsync.when(
                      loading: () => const LoadingSkeletonCard(height: 140),
                      error: (_, __) => _buildSummaryCard(user?.name, 0, 0),
                      data: (projects) {
                        final activeCount = projects.where((p) => p.status == 'active').length;
                        final totalWorkers = workersAsync.valueOrNull?.length ?? 0;
                        return _buildSummaryCard(user?.name, activeCount, totalWorkers);
                      },
                    ),

                    const SizedBox(height: 24),

                    // ২. দ্রুত কাজ (চারটি অ্যাকশন বোতাম)
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
                            label: 'নতুন কর্মী',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const WorkersManagementScreen()),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: QuickActionButton(
                            icon: Icons.verified_user_outlined,
                            label: 'অনুমোদন',
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
                            label: 'হিসাব খতিয়ান',
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

                    // ৩. সতর্কতা ও অপেক্ষমাণ অনুমোদন
                    if (totalAlerts > 0) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSizes.paddingMedium),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                          border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            if (handoverCount > 0) ...[
                              _buildAlertItem(
                                icon: Icons.swap_horiz_rounded,
                                label: 'হস্তান্তর প্রয়োজন এন্ট্রি',
                                count: handoverCount.toString(),
                                color: AppColors.danger,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const ContractorApprovalScreen()),
                                  );
                                },
                              ),
                            ],
                            if (handoverCount > 0 && pendingCount > 0)
                              const Divider(height: 16),
                            if (pendingCount > 0) ...[
                              _buildAlertItem(
                                icon: Icons.location_off_outlined,
                                label: 'অপেক্ষমাণ হাজিরা অনুমোদন',
                                count: pendingCount.toString(),
                                color: AppColors.warning,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const ContractorApprovalScreen()),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // ৪. চলমান প্রজেক্ট তালিকা
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'চলমান প্রজেক্ট',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ProjectListScreen()),
                            );
                          },
                          child: const Text('সব দেখুন', style: TextStyle(color: AppColors.contractorPrimary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    projectsAsync.when(
                      loading: () => const LoadingSkeletonCard(height: 110),
                      error: (err, _) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text('প্রজেক্ট লোড করা সম্ভব হয়নি: $err'),
                        ),
                      ),
                      data: (projects) {
                        if (projects.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSizes.paddingLarge),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : AppColors.lightCard,
                              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.apartment_outlined, size: 48, color: Colors.grey),
                                const SizedBox(height: 10),
                                const Text(
                                  'এখনো কোনো প্রজেক্ট তৈরি করা হয়নি',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'কাজ শুরু করতে আপনার প্রথম কনস্ট্রাকশন প্রজেক্ট তৈরি করুন।',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(height: 14),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => const NewProjectScreen()),
                                    );
                                  },
                                  icon: const Icon(Icons.add_rounded),
                                  label: const Text('নতুন প্রজেক্ট তৈরি করুন'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.contractorPrimary,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        // প্রথম ৩টি প্রজেক্ট দেখানো
                        final displayProjects = projects.take(3).toList();
                        return Column(
                          children: displayProjects.map((project) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildProjectCard(context, project, isDark),
                            );
                          }).toList(),
                        );
                      },
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

  Widget _buildSummaryCard(String? name, int activeProjects, int totalWorkers) {
    return SummaryCard(
      role: 'contractor',
      orgName: name ?? 'আমার প্রতিষ্ঠান',
      title: 'চলমান প্রজেক্ট',
      kpiValue: BengaliFormatter.toBengaliNumber(activeProjects.toString()),
      subText: 'মোট কর্মী: ${BengaliFormatter.toBengaliNumber(totalWorkers.toString())} জন নিবন্ধিত',
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

  Widget _buildProjectCard(BuildContext context, ProjectModel project, bool isDark) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProjectDetailsScreen(projectId: project.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: Container(
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
                    project.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                StatusChip.forStatus(project.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'ঠিকানা: ${project.address} • ${project.type}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  'বাজেট: ${BengaliFormatter.toCurrency(project.budget)}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                const Text(
                  'বিস্তারিত দেখুন',
                  style: TextStyle(fontSize: 12, color: AppColors.contractorPrimary, fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.contractorPrimary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
