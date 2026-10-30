import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_khata/core/constants/app_colors.dart';
import 'package:project_khata/core/constants/contractor_routes.dart';
import 'package:project_khata/core/constants/contractor_strings.dart';
import 'package:project_khata/core/utils/bengali_formatter.dart';
import 'package:project_khata/features/auth/presentation/controllers/auth_controller.dart';
import 'package:project_khata/widgets/contractor_widgets.dart';
import '../../contractor_providers.dart';
import '../../../domain/models/contractor_models.dart';

class ContractorDashboardScreen extends ConsumerWidget {
  const ContractorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final projectsAsync = ref.watch(projectsProvider(ProjectStatus.active));
    final entriesAsync = ref.watch(todayEntriesProvider);
    final userProfile = ref.watch(currentUserProvider).value;
    final userName = (userProfile?.name != null && userProfile!.name.trim().isNotEmpty)
        ? userProfile.name.trim()
        : ContractorStrings.defaultUserName;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Row(
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
                      'মেসার্স ঠিকাদার কনস্ট্রাকশন',
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
        actions: [
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
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardSummaryProvider);
          ref.invalidate(projectsProvider(ProjectStatus.active));
          ref.invalidate(todayEntriesProvider);
        },
        child: summaryAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 12),
                const Text(ContractorStrings.errorOccurred),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(dashboardSummaryProvider),
                  child: const Text(ContractorStrings.retry),
                ),
              ],
            ),
          ),
          data: (summary) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ০. Top Greeting Header (তারিখ পিল, স্বাগতম ও সাইট মনিটরিং)
                  _buildGreetingHeader(context, isDark, userName),

                  const SizedBox(height: 16),

                  // ১. HeroSummaryCard: আজ উপস্থিত শ্রমিক ও ব্যালেন্স
                  HeroSummaryCard(
                    title: ContractorStrings.workersPresentToday,
                    amount: '${toBn(summary.workersPresentToday)} জন',
                    badgeText: '${toBn(summary.activeProjectsCount)}টি ${ContractorStrings.activeProjectsTitle}',
                    subtitle: ContractorStrings.budgetHealthGood,
                    secondaryText: summary.companyName,
                    onTap: () => context.go(ContractorRoutes.workers),
                  ),

                  const SizedBox(height: 16),

                  // ২. ModernOverviewStrip: ৩টি দ্রুত পরিসংখ্যান এক নজরে
                  ModernOverviewStrip(
                    activeProjects: summary.activeProjectsCount,
                    workersPresent: summary.workersPresentToday,
                    pendingApprovals: summary.pendingApprovalsCount,
                    onProjectsTap: () => context.go(ContractorRoutes.projects),
                    onWorkersTap: () => context.go(ContractorRoutes.workers),
                    onApprovalsTap: () => context.push(ContractorRoutes.approvals),
                  ),

                  const SizedBox(height: 24),

                  // ৩. QuickActions (৪টি আধুনিক অ্যাকশন বাটন + নতুন প্রজেক্ট CTA)
                  const SectionTitleRow(
                    title: 'দ্রুত কার্যক্রম',
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEA619),
                        foregroundColor: const Color(0xFF684000),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => context.push(ContractorRoutes.projectNew),
                      icon: const Icon(
                        Icons.add_circle_rounded,
                        size: 22,
                        color: Color(0xFF684000),
                      ),
                      label: const Text(
                        'নতুন প্রজেক্ট তৈরি করুন',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF684000),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      QuickAction(
                        icon: Icons.person_add_rounded,
                        label: 'শ্রমিক যোগ',
                        onTap: () => context.push(ContractorRoutes.workerNew),
                      ),
                      QuickAction(
                        icon: Icons.engineering_rounded,
                        label: 'সুপারভাইজার',
                        onTap: () => context.push(ContractorRoutes.supervisors),
                      ),
                      QuickAction(
                        icon: Icons.fact_check_rounded,
                        label: 'হাজিরা নিন',
                        badgeCount: summary.pendingApprovalsCount,
                        onTap: () => context.push(ContractorRoutes.approvals),
                      ),
                      QuickAction(
                        icon: Icons.menu_book_rounded,
                        label: 'হিসাব খাতা',
                        onTap: () => context.push(ContractorRoutes.billStatements),
                      ),
                    ],
                  ),

                  // ৪. সতর্কতা কার্ড (যদি শূন্যের বেশি হয়)
                  if (summary.handoverRequiredCount > 0 || summary.pendingApprovalsCount > 0) ...[
                    const SizedBox(height: 24),
                    _buildAlertCard(context, summary, isDark),
                  ],

                  const SizedBox(height: 28),

                  // ৫. চলমান প্রজেক্ট তালিকা
                  SectionTitleRow(
                    title: ContractorStrings.activeProjectsTitle,
                    actionTitle: ContractorStrings.seeAll,
                    onActionTap: () => context.go(ContractorRoutes.projects),
                  ),
                  const SizedBox(height: 12),
                  projectsAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (_, __) => const Text(ContractorStrings.errorOccurred),
                    data: (projects) {
                      if (projects.isEmpty) {
                        return EmptyState(
                          icon: Icons.apartment_rounded,
                          title: ContractorStrings.noOngoingProjects,
                          subtitle: ContractorStrings.createProjectPrompt,
                          actionLabel: ContractorStrings.createNewProject,
                          onActionTap: () => context.push(ContractorRoutes.projectNew),
                        );
                      }
                      return Column(
                        children: projects.take(3).map((p) {
                          return IconTile(
                            icon: Icons.apartment_rounded,
                            title: p.name,
                            subtitle: '${p.clientName} • ${toBn(p.workerCount)} জন শ্রমিক',
                            trailingTitle: p.budget != null ? BengaliFormatter.toCurrency(p.budget!) : null,
                            trailingSubtitle: p.status.displayName,
                            trailingColor: isDark ? const Color(0xFF93A8F4) : AppColors.contractorNavy,
                            onTap: () => context.push(ContractorRoutes.projectDetailsPath(p.id)),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // ৬. আজকের এন্ট্রি তালিকা
                  SectionTitleRow(
                    title: ContractorStrings.todayEntries,
                    actionTitle: ContractorStrings.seeAll,
                    onActionTap: () => context.push(ContractorRoutes.approvals),
                  ),
                  const SizedBox(height: 12),
                  entriesAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (_, __) => const Text(ContractorStrings.errorOccurred),
                    data: (entries) {
                      if (entries.isEmpty) {
                        return const EmptyState(
                          icon: Icons.pending_actions_rounded,
                          title: ContractorStrings.noEntriesToday,
                        );
                      }
                      return Column(
                        children: entries.map((e) {
                          return IconTile(
                            icon: Icons.assignment_turned_in_rounded,
                            title: e.projectName,
                            subtitle: 'সুপারভাইজার: ${e.supervisorName} • ${toBn(e.workerCount)} জন',
                            trailingSubtitle: e.status,
                            trailingColor: isDark ? const Color(0xFF93A8F4) : AppColors.contractorNavy,
                            onTap: () => context.push(ContractorRoutes.approvals),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, DashboardSummary summary, bool isDark) {
    final alertTitle = summary.handoverRequiredCount > 0
        ? ContractorStrings.alertHandoverTitle
        : ContractorStrings.alertPendingApprovalTitle;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2E200B) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF78350F) : const Color(0xFFFDE68A),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFD97706),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alertTitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  summary.handoverRequiredCount > 0
                      ? '${toBn(summary.handoverRequiredCount)}টি প্রজেক্ট হস্তান্তরের সময় হয়েছে'
                      : '${toBn(summary.pendingApprovalsCount)}টি এন্ট্রি অনুমোদনের অপেক্ষায় আছে',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : const Color(0xFF78350F),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              if (summary.pendingApprovalsCount > 0) {
                context.push(ContractorRoutes.approvals);
              } else {
                context.go(ContractorRoutes.projects);
              }
            },
            child: Text(
              summary.pendingApprovalsCount > 0
                  ? ContractorStrings.approve
                  : 'দেখুন',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingHeader(BuildContext context, bool isDark, String userName) {
    final greeting = greetingByHour(DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    BengaliFormatter.formatDate(DateTime.now()),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 14,
                  color: Color(0xFFD97706),
                ),
                const SizedBox(width: 3),
                Text(
                  'ঢাকা, সদর দপ্তর',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.normal,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '$greeting, $userName 👋',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.contractorNavy,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
