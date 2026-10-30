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

    return Scaffold(
      appBar: AppBar(
        title: const Text(ContractorStrings.accountsDashboard),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(accountsSummaryProvider),
        child: reportAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(ContractorStrings.errorOccurred)),
          data: (report) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ১. HeroSummaryCard: মোট আয় ও নেট অবস্থা
                  HeroSummaryCard(
                    title: ContractorStrings.totalIncome,
                    amount: BengaliFormatter.toCurrency(report.totalIncome),
                    badgeText: 'নেট স্থিতি: ${BengaliFormatter.toCurrency(report.netBalance)}',
                    subtitle: 'মোট ব্যয়: ${BengaliFormatter.toCurrency(report.totalExpense)}',
                    secondaryText: 'বকেয়া মজুরি: ${BengaliFormatter.toCurrency(report.totalPendingWages)}',
                  ),

                  const SizedBox(height: 24),

                  // সাব-স্ক্রিনের নেভিগেশন গ্রিড / লিস্ট
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
                          color: const Color(0xFFC2410C),
                          onTap: () => context.push(ContractorRoutes.siteExpenses),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildAccountActionCard(
                          context,
                          title: ContractorStrings.billStatementsTitle,
                          icon: Icons.document_scanner_rounded,
                          color: const Color(0xFF4338CA),
                          onTap: () => context.push(ContractorRoutes.billStatements),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ২. প্রজেক্ট অনুযায়ী তালিকা
                  const Text(
                    ContractorStrings.projectAccountsBreakdown,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...report.projectBreakdowns.map((p) {
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
                                  Expanded(
                                    child: Text(
                                      p.projectName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('মোট আয়', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                      Text(
                                        BengaliFormatter.toCurrency(p.totalIncome),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('মোট ব্যয়', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                      Text(
                                        BengaliFormatter.toCurrency(p.totalExpense),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('বাকি/পাওনা', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                      Text(
                                        BengaliFormatter.toCurrency(p.pendingDues),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: AppColors.contractorNavy,
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

                  const SizedBox(height: 24),

                  // ডোনাট চার্ট প্লেসহোল্ডার
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.pie_chart_outline_rounded, color: AppColors.contractorNavy),
                              SizedBox(width: 8),
                              Text(
                                ContractorStrings.projectExpenseShare,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 120,
                            alignment: Alignment.center,
                            child: const Text(
                              'প্রজেক্টভিত্তিক ব্যয় বিশ্লেষণ চার্ট (পরের ধাপে যুক্ত হবে)',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
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
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
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
