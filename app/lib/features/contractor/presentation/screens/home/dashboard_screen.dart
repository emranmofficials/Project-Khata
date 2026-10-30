import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_khata/core/constants/app_colors.dart';
import 'package:project_khata/core/constants/contractor_routes.dart';
import 'package:project_khata/core/constants/contractor_strings.dart';
import 'package:project_khata/core/utils/bengali_formatter.dart';
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

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Center(
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    AppColors.contractorNavy,
                    Color(0xFF2563EB),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.contractorNavy.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'খাতা',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        title: summaryAsync.when(
          data: (summary) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greetingByHour(DateTime.now()),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      summary.companyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.verified_rounded,
                    size: 16,
                    color: isDark ? const Color(0xFF93A8F4) : const Color(0xFF2563EB),
                  ),
                ],
              ),
            ],
          ),
          loading: () => const Text(
            ContractorStrings.defaultUserName,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          error: (_, __) => const Text(
            ContractorStrings.defaultUserName,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          summaryAsync.when(
            data: (summary) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded),
                  onPressed: () => context.push(ContractorRoutes.notifications),
                ),
                if (summary.pendingApprovalsCount > 0)
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            loading: () => IconButton(
              icon: const Icon(Icons.notifications_none_rounded),
              onPressed: () => context.push(ContractorRoutes.notifications),
            ),
            error: (_, __) => IconButton(
              icon: const Icon(Icons.notifications_none_rounded),
              onPressed: () => context.push(ContractorRoutes.notifications),
            ),
          ),
          const SizedBox(width: 8),
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

                  // ৩. QuickActions (৪টি আধুনিক অ্যাকশন বাটন)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      QuickAction(
                        icon: Icons.add_business_rounded,
                        label: ContractorStrings.quickActionNewProject,
                        onTap: () => context.push(ContractorRoutes.projectNew),
                      ),
                      QuickAction(
                        icon: Icons.person_add_rounded,
                        label: ContractorStrings.quickActionNewWorker,
                        onTap: () => context.push(ContractorRoutes.workerNew),
                      ),
                      QuickAction(
                        icon: Icons.fact_check_rounded,
                        label: ContractorStrings.quickActionEntryApproval,
                        badgeCount: summary.pendingApprovalsCount,
                        onTap: () => context.push(ContractorRoutes.approvals),
                      ),
                      QuickAction(
                        icon: Icons.receipt_long_rounded,
                        label: ContractorStrings.quickActionBillStatement,
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
}
