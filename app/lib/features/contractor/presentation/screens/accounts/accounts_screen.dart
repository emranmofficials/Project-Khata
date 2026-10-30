import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_khata/core/constants/app_colors.dart';
import 'package:project_khata/core/constants/contractor_routes.dart';
import 'package:project_khata/core/constants/contractor_strings.dart';
import 'package:project_khata/core/utils/bengali_formatter.dart';
import 'package:project_khata/widgets/contractor_widgets.dart';
import '../../contractor_providers.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(accountsSummaryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const ContractorAppBar(),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(accountsSummaryProvider),
        child: reportAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => const Center(child: Text(ContractorStrings.errorOccurred)),
          data: (report) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        ContractorStrings.accountsDashboard,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.contractorNavy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // ১. HeroSummaryCard: মোট আয় ও নেট অবস্থা
                  HeroSummaryCard(
                    title: ContractorStrings.totalIncome,
                    amount: BengaliFormatter.toCurrency(report.totalIncome),
                    badgeText: 'নেট স্থিতি: ${BengaliFormatter.toCurrency(report.netBalance)}',
                    subtitle: 'মোট ব্যয়: ${BengaliFormatter.toCurrency(report.totalExpense)}',
                    secondaryText: 'বকেয়া মজুরি: ${BengaliFormatter.toCurrency(report.totalPendingWages)}',
                  ),

                  const SizedBox(height: 16),

                  // ২. FinancialRatioBar: আয় বনাম ব্যয়ের ভিজ্যুয়াল রেশিও বার
                  FinancialRatioBar(
                    income: report.totalIncome,
                    expense: report.totalExpense,
                  ),

                  const SizedBox(height: 24),

                  // ৩. সাব-স্ক্রিনের নেভিগেশন গ্রিড / লিস্ট
                  const Text(
                    'হিসাবের খাত সমূহ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildAccountActionCard(
                          context,
                          title: ContractorStrings.wagesTitle,
                          icon: Icons.payments_rounded,
                          color: const Color(0xFF2563EB),
                          onTap: () => context.push(ContractorRoutes.wages),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildAccountActionCard(
                          context,
                          title: ContractorStrings.paymentsTitle,
                          icon: Icons.account_balance_wallet_rounded,
                          color: const Color(0xFF1E3A8A),
                          onTap: () => context.push(ContractorRoutes.payments),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildAccountActionCard(
                          context,
                          title: ContractorStrings.clientPaymentsTitle,
                          icon: Icons.attach_money_rounded,
                          color: const Color(0xFF0F766E),
                          onTap: () => context.push(ContractorRoutes.clientPayments),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildAccountActionCard(
                          context,
                          title: ContractorStrings.materialsTitle,
                          icon: Icons.inventory_2_rounded,
                          color: const Color(0xFFD97706),
                          onTap: () => context.push(ContractorRoutes.materials),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildAccountActionCard(
                          context,
                          title: ContractorStrings.siteExpensesTitle,
                          icon: Icons.receipt_long_rounded,
                          color: const Color(0xFF7C3AED),
                          onTap: () => context.push(ContractorRoutes.siteExpenses),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildAccountActionCard(
                          context,
                          title: ContractorStrings.billStatementsTitle,
                          icon: Icons.description_rounded,
                          color: const Color(0xFF0284C7),
                          onTap: () => context.push(ContractorRoutes.billStatements),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ৪. প্রজেক্ট অনুযায়ী হিসাবের ব্রেকডাউন
                  const Text(
                    ContractorStrings.projectAccountsBreakdown,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...report.projectBreakdowns.map((p) {
                    final netVal = p.totalIncome - p.totalExpense;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => context.push(ContractorRoutes.accountsProjectPath(p.projectId)),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDark ? const Color(0xFF93A8F4) : AppColors.contractorNavy,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      p.projectName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'মোট আয়',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        BengaliFormatter.toCurrency(p.totalIncome),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'মোট ব্যয়',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        BengaliFormatter.toCurrency(p.totalExpense),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'নেট ব্যালেন্স',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        BengaliFormatter.toCurrency(netVal),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: netVal >= 0
                                              ? (isDark ? const Color(0xFF93A8F4) : AppColors.contractorNavy)
                                              : AppColors.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // ৫. প্রজেক্টভিত্তিক ব্যয় অ্যানালিটিক্স
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.bar_chart_rounded,
                                size: 20,
                                color: isDark ? const Color(0xFF93A8F4) : AppColors.contractorNavy,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'প্রজেক্টভিত্তিক ব্যয় বণ্টন',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (report.totalExpense > 0)
                            ...report.projectBreakdowns.map((p) {
                              final ratio = (p.totalExpense / report.totalExpense).clamp(0.0, 1.0);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: ProjectProgressBar(
                                  progress: ratio,
                                  label: p.projectName,
                                  percentageText: BengaliFormatter.toCurrency(p.totalExpense),
                                  height: 6,
                                ),
                              );
                            })
                          else
                            Container(
                              height: 80,
                              alignment: Alignment.center,
                              child: Text(
                                'এখনও কোনো ব্যয়ের রেকর্ড নেই',
                                style: TextStyle(
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
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

  Widget _buildAccountActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
