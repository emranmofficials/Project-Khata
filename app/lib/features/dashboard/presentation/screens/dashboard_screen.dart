import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/contractor_strings.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../../widgets/contractor_widgets.dart';
import '../../../auth/domain/models/app_user.dart';
import '../../../projects/domain/models/project.dart';
import '../../../projects/presentation/controllers/project_controller.dart';
import '../../../users/presentation/widgets/create_member_dialog.dart';

class DashboardScreen extends ConsumerWidget {
  final UserProfile? user;
  final ValueChanged<int>? onSwitchTab;
  final VoidCallback? onRefresh;

  const DashboardScreen({
    super.key,
    this.user,
    this.onSwitchTab,
    this.onRefresh,
  });

  /// সময়ভিত্তিক অভিবাদন (সকাল, দুপুর, বিকেল, সন্ধ্যা)
  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return ContractorStrings.goodMorning;
    } else if (hour >= 12 && hour < 15) {
      return ContractorStrings.goodNoon;
    } else if (hour >= 15 && hour < 18) {
      return ContractorStrings.goodAfternoon;
    } else {
      return ContractorStrings.goodEvening;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final projectsAsync = ref.watch(projectsListProvider);
    final projects = projectsAsync.valueOrNull ?? <Project>[];

    // সর্বমোট বাজেট হিসাব
    final totalBudget = projects.fold<double>(
      0,
      (sum, p) => sum + (p.budget ?? 0),
    );

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(projectsListProvider);
        onRefresh?.call();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ১. সময়ভিত্তিক অভিবাদন ও ইউজার প্রোফাইল হেডার
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTimeBasedGreeting(),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${user?.name ?? ContractorStrings.defaultUserName} 👋',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : AppColors.darkTextPrimary,
                          ),
                    ),
                  ],
                ),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.contractorNavy.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.contractorNavy.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      (user?.name != null && user!.name.isNotEmpty)
                          ? user!.name.characters.first
                          : 'ঠ',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.contractorNavy,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ২. HeroSummaryCard (রেফারেন্স স্ক্রিনশটের অনুকরণে নেভি কার্ড)
            HeroSummaryCard(
              title: ContractorStrings.totalBudget,
              amount: totalBudget > 0
                  ? BengaliFormatter.toCurrency(totalBudget)
                  : '৳ ০.০০',
              badgeText:
                  '${BengaliFormatter.toBnNumber(projects.length)}টি ${ContractorStrings.activeProjectsCount}',
              badgeIcon: Icons.business_center_rounded,
              subtitle: ContractorStrings.budgetHealthGood,
              secondaryText: 'প্রজেক্ট খাতা',
              onTap: () => onSwitchTab?.call(1),
            ),
            const SizedBox(height: 24),

            // ৩. চার QuickAction (নতুন প্রজেক্ট, দৈনিক এন্ট্রি, হিসাব ও বিল, কর্মী যোগ)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  QuickAction(
                    icon: Icons.add_business_rounded,
                    label: ContractorStrings.quickActionNewProject,
                    onTap: () => context.push('/create-project'),
                  ),
                  QuickAction(
                    icon: Icons.edit_note_rounded,
                    label: ContractorStrings.quickActionDailyEntry,
                    onTap: () => context.push('/daily-entry'),
                  ),
                  QuickAction(
                    icon: Icons.account_balance_wallet_rounded,
                    label: ContractorStrings.quickActionAccounts,
                    onTap: () {
                      if (onSwitchTab != null) {
                        onSwitchTab!(3);
                      } else {
                        context.push('/organization-payments');
                      }
                    },
                  ),
                  QuickAction(
                    icon: Icons.person_add_rounded,
                    label: ContractorStrings.quickActionAddMember,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => CreateMemberDialog(
                          onMemberCreated: () => ref.invalidate(projectsListProvider),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ৪. সতর্কতা কার্ড (Alert Card - রেফারেন্স টিপস কার্ডের অনুরূপ)
            _buildAlertCard(context, isDark),
            const SizedBox(height: 20),

            // ৫. চলমান প্রজেক্টের IconTile তালিকা
            SectionTitleRow(
              title: ContractorStrings.ongoingProjects,
              actionTitle: ContractorStrings.seeAll,
              onActionTap: () => onSwitchTab?.call(1),
            ),
            const SizedBox(height: 6),
            projectsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => IconTile(
                icon: Icons.error_outline_rounded,
                iconColor: AppColors.error,
                title: 'প্রজেক্ট লোড করতে সমস্যা হয়েছে',
                subtitle: err.toString(),
                trailingWidget: IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () => ref.invalidate(projectsListProvider),
                ),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return IconTile(
                    icon: Icons.apartment_outlined,
                    title: ContractorStrings.noOngoingProjects,
                    subtitle: ContractorStrings.createProjectPrompt,
                    trailingWidget: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppColors.contractorNavy,
                    ),
                    onTap: () => context.push('/create-project'),
                  );
                }

                // সর্বোচ্চ ৪টি প্রজেক্ট দেখানো হচ্ছে
                final displayProjects = list.take(4).toList();
                return Column(
                  children: displayProjects.map((project) {
                    return IconTile(
                      icon: Icons.apartment_rounded,
                      title: project.name,
                      subtitle: project.address ?? ContractorStrings.locationNotSet,
                      trailingTitle: project.budget != null
                          ? BengaliFormatter.toCurrency(project.budget!)
                          : null,
                      trailingSubtitle: project.status.displayName,
                      trailingColor: AppColors.contractorNavy,
                      onTap: () => context.push(
                        '/project-details',
                        extra: project,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 16),

            // ৬. আজকের এন্ট্রি সেকশন
            SectionTitleRow(
              title: ContractorStrings.todayEntries,
              actionTitle: ContractorStrings.viewDetails,
              onActionTap: () => context.push('/daily-entry'),
            ),
            const SizedBox(height: 6),
            IconTile(
              icon: Icons.how_to_reg_rounded,
              iconColor: AppColors.supervisorAmber,
              iconBackgroundColor:
                  AppColors.supervisorAmber.withValues(alpha: 0.12),
              title: ContractorStrings.todayAttendance,
              subtitle: 'মাঠপর্যায়ের সাইট রিপোর্ট ও উপস্থিতি যাচাই',
              trailingTitle: 'হাজিরা দেখুন',
              trailingSubtitle: 'দৈনিক শিট',
              onTap: () => context.push('/daily-entry'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// সতর্কতা কার্ড (Alert Card) উইজেট
  Widget _buildAlertCard(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20), // ২০ px গোল কোণ
        border: Border.all(
          color: AppColors.supervisorAmber.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.push('/daily-entry'),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.supervisorAmber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.supervisorAmber,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            ContractorStrings.alertCardTitle,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.amber.shade300
                                  : Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        ContractorStrings.alertReviewEntries,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ContractorStrings.alertReviewSubtitle,
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
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
