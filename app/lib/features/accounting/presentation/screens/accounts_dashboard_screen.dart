import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../project/domain/models/project_model.dart';
import '../../../project/presentation/providers/project_provider.dart';
import '../../../worker/presentation/providers/worker_provider.dart';
import '../providers/accounting_provider.dart';
import '../widgets/new_payment_bottom_sheet.dart';
import 'bill_statements_screen.dart';
import 'materials_screen.dart';
import 'site_expenses_screen.dart';

/// PRD সেকশন ৬.৫ (১) অনুযায়ী হিসাব ড্যাশবোর্ড স্ক্রিন
class AccountsDashboardScreen extends ConsumerWidget {
  const AccountsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(financialOverviewProvider);
    final projectsAsync = ref.watch(projectsListProvider);
    final workersAsync = ref.watch(workersListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('হিসাব ও খতিয়ান'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(financialOverviewProvider);
          ref.invalidate(projectsListProvider);
          ref.invalidate(workersListProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ১. আর্থিক সারাংশ কার্ড
              overviewAsync.when(
                loading: () => const LoadingSkeletonCard(height: 180),
                error: (err, _) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('আর্থিক সারাংশ লোড ত্রুটি: $err'),
                ),
                data: (data) {
                  final totalIncome = (data['total_income'] as num?)?.toDouble() ?? 0.0;
                  final totalCost = (data['total_cost'] as num?)?.toDouble() ?? 0.0;
                  final dueWage = (data['due_wage'] as num?)?.toDouble() ?? 0.0;
                  final netProfit = (data['net_profit'] as num?)?.toDouble() ?? 0.0;

                  return Container(
                    padding: const EdgeInsets.all(AppSizes.paddingLarge),
                    decoration: BoxDecoration(
                      gradient: AppColors.getGradientForRole('contractor'),
                      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'সার্বিক ব্যালেন্স ও নেট অবস্থা',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          BengaliFormatter.toCurrency(netProfit),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSummaryItem('মোট আয়', totalIncome),
                            _buildSummaryItem('মোট ব্যয়', totalCost),
                            _buildSummaryItem('বকেয়া মজুরি', dueWage, isWarning: true),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // ২. দ্রুত অ্যাকশন বোতামসমূহ
              const Text(
                'হিসাবের শাখা ও কাজ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionTile(
                      icon: Icons.payments_outlined,
                      label: 'শ্রমিক পেমেন্ট',
                      color: AppColors.success,
                      onTap: () {
                        final workers = workersAsync.valueOrNull ?? [];
                        if (workers.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('কোনো কর্মী পাওয়া যায়নি। আগে কর্মী যুক্ত করুন।'),
                              backgroundColor: AppColors.warning,
                            ),
                          );
                          return;
                        }

                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          builder: (_) => NewPaymentBottomSheet(
                            workers: workers
                                .map((w) => {
                                      'id': w.id,
                                      'name':
                                          '${w.name}${w.designationName != null ? " (${w.designationName})" : ""}',
                                      'mobile': w.mobile,
                                    })
                                .toList(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionTile(
                      icon: Icons.receipt_long_outlined,
                      label: 'বিল খতিয়ান',
                      color: AppColors.contractorPrimary,
                      onTap: () {
                        final projects = projectsAsync.valueOrNull;
                        _openProjectFeature(
                          context,
                          projects,
                          'বিল খতিয়ান',
                          (p) => BillStatementsScreen(
                            projectId: p.id,
                            projectName: p.name,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildActionTile(
                      icon: Icons.inventory_2_outlined,
                      label: 'মালামাল হিসাব',
                      color: AppColors.clientPrimary,
                      onTap: () {
                        final projects = projectsAsync.valueOrNull;
                        _openProjectFeature(
                          context,
                          projects,
                          'মালামাল হিসাব',
                          (p) => MaterialsScreen(
                            projectId: p.id,
                            projectName: p.name,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionTile(
                      icon: Icons.receipt_outlined,
                      label: 'সাইট খরচ',
                      color: AppColors.supervisorPrimary,
                      onTap: () {
                        final projects = projectsAsync.valueOrNull;
                        _openProjectFeature(
                          context,
                          projects,
                          'সাইট খরচ',
                          (p) => SiteExpensesScreen(
                            projectId: p.id,
                            projectName: p.name,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ৩. প্রজেক্টভিত্তিক সারসংক্ষেপ তালিকা
              const Text(
                'প্রজেক্ট ভিত্তিক আর্থিক হিসাব',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              projectsAsync.when(
                loading: () => const LoadingSkeletonList(count: 3, itemHeight: 80),
                error: (err, _) => Text('প্রজেক্ট তালিকা লোড ত্রুটি: $err'),
                data: (projects) {
                  if (projects.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.paddingMedium),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.folder_open_rounded, size: 36, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'কোনো প্রজেক্ট নেই',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'প্রজেক্ট তৈরি করলে প্রতিটি সাইটের বাজেট ও খরচের হিসাব এখানে দেখতে পাবেন।',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: projects.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final p = projects[index];
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BillStatementsScreen(
                                projectId: p.id,
                                projectName: p.name,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                        child: Container(
                          padding: const EdgeInsets.all(AppSizes.paddingMedium),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : AppColors.lightCard,
                            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    AppColors.contractorPrimary.withOpacity(0.1),
                                child: const Icon(
                                  Icons.apartment_rounded,
                                  color: AppColors.contractorPrimary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'বাজেট: ${BengaliFormatter.toCurrency(p.budget)} • ${p.type}',
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
                              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openProjectFeature(
    BuildContext context,
    List<ProjectModel>? projects,
    String featureName,
    Widget Function(ProjectModel project) screenBuilder,
  ) {
    if (projects == null || projects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('অনুগ্রহ করে প্রথমে একটি প্রজেক্ট তৈরি করুন।'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (projects.length == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => screenBuilder(projects.first)),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$featureName দেখতে প্রজেক্ট নির্বাচন করুন',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...projects.map((p) => ListTile(
                    leading: const Icon(Icons.apartment_rounded,
                        color: AppColors.contractorPrimary),
                    title: Text(p.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(p.address),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => screenBuilder(p)),
                      );
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(String label, double amount, {bool isWarning = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          BengaliFormatter.toCurrency(amount),
          style: TextStyle(
            color: isWarning ? const Color(0xFFFDE047) : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
