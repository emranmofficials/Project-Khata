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
        title: summaryAsync.when(
          data: (summary) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greetingByHour(DateTime.now()),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                summary.companyName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => context.push(ContractorRoutes.notifications),
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
                  // 1. HeroSummaryCard: আজ উপস্থিত শ্রমিক
                  HeroSummaryCard(
                    title: ContractorStrings.workersPresentToday,
                    amount: '${toBn(summary.workersPresentToday)} জন',
                    badgeText: '${toBn(summary.activeProjectsCount)}টি ${ContractorStrings.activeProjectsTitle}',
                    subtitle: ContractorStrings.budgetHealthGood,
                    secondaryText: summary.companyName,
                    onTap: () => context.go(ContractorRoutes.workers),
                  ),

                  const SizedBox(height: 24),

                  // 2. QuickActions (৪টি বোতাম)
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

                  // 3. সতর্কতা কার্ড (যদি শূন্যের বেশি হয়)
                  if (summary.handoverRequiredCount > 0 || summary.pendingApprovalsCount > 0) ...[
                    const SizedBox(height: 24),
                    _buildAlertCard(context, summary, isDark),
                  ],

                  const SizedBox(height: 24),

                  // 4. চলমান প্রজেক্ট তালিকা
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
                            trailingColor: AppColors.contractorNavy,
                            onTap: () => context.push(ContractorRoutes.projectDetailsPath(p.id)),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // 5. আজকের এন্ট্রি
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
                            trailingColor: AppColors.contractorNavy,
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
        color: isDark ? const Color(0xFF261D11) : const Color(0xFFFEF3C7),
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
              color: Colors.amber.shade700.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: isDark ? Colors.amber.shade300 : Colors.amber.shade800,
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
                    color: isDark ? Colors.amber.shade200 : Colors.amber.shade900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'পর্যালোচনা করতে ট্যাপ করুন (${toBn(summary.pendingApprovalsCount)}টি অনুমোদন বাকি)',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push(ContractorRoutes.approvals),
            child: const Text('দেখুন'),
          ),
        ],
      ),
    );
  }
}
