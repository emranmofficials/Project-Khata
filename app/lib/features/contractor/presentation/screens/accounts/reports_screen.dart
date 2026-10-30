import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_khata/core/constants/app_colors.dart';
import 'package:project_khata/core/constants/contractor_strings.dart';
import 'package:project_khata/core/utils/bengali_formatter.dart';
import 'package:project_khata/widgets/contractor_widgets.dart';
import '../../contractor_providers.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String _selectedPeriod = 'চলতি মাস';

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(accountsSummaryProvider);
    final projectsAsync = ref.watch(projectsProvider(null));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          ContractorStrings.reportsTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(accountsSummaryProvider);
          ref.invalidate(projectsProvider(null));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // সময়কাল ফিল্টার
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['চলতি মাস', 'গত মাস', 'চলতি ত্রৈমাসিক', 'চলতি বছর'].map((p) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(p),
                        selected: _selectedPeriod == p,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedPeriod = p);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // আর্থিক সারসংক্ষেপ রিপোর্ট
              reportAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text(ContractorStrings.errorOccurred)),
                data: (report) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero কার্ড
                      HeroSummaryCard(
                        title: 'আর্থিক প্রতিবেদন',
                        amount: BengaliFormatter.toCurrency(report.totalIncome),
                        subtitle: 'মোট ব্যয়: ${BengaliFormatter.toCurrency(report.totalExpense)}',
                        badgeText: 'নিট লাভ: ${BengaliFormatter.toCurrency(report.netBalance)}',
                        secondaryText: 'বকেয়া মজুরি: ${BengaliFormatter.toCurrency(report.totalPendingWages)}',
                      ),

                      const SizedBox(height: 16),

                      // রেশিও বার
                      FinancialRatioBar(
                        income: report.totalIncome,
                        expense: report.totalExpense,
                      ),

                      const SizedBox(height: 24),

                      // খরচ বিভাজন
                      const Text(
                        'ব্যয়ের খাতভিত্তিক বিশ্লেষণ',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildExpenseRow(
                              title: 'মোট প্রজেক্ট ব্যয়',
                              amount: report.totalExpense,
                              icon: Icons.inventory_2_outlined,
                              color: const Color(0xFF2563EB),
                              isDark: isDark,
                            ),
                            const Divider(height: 20),
                            _buildExpenseRow(
                              title: 'মোট প্রাপ্ত আয়',
                              amount: report.totalIncome,
                              icon: Icons.account_balance_wallet_outlined,
                              color: const Color(0xFF0F766E),
                              isDark: isDark,
                            ),
                            const Divider(height: 20),
                            _buildExpenseRow(
                              title: 'নিট স্থিতি (লাভ/উদ্বৃত্ত)',
                              amount: report.netBalance,
                              icon: Icons.trending_up_rounded,
                              color: const Color(0xFFD97706),
                              isDark: isDark,
                            ),
                            const Divider(height: 20),
                            _buildExpenseRow(
                              title: 'বকেয়া মজুরি দায়',
                              amount: report.totalPendingWages,
                              icon: Icons.pending_actions_outlined,
                              color: const Color(0xFFEF4444),
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 28),

              // প্রজেক্টভিত্তিক ব্যয় ও লাভ
              const Text(
                'প্রজেক্টভিত্তিক আর্থিক অবস্থা',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              projectsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('প্রজেক্ট রিপোর্ট লোড করা যায়নি'),
                data: (projects) {
                  if (projects.isEmpty) {
                    return const EmptyState(
                      icon: Icons.apartment_rounded,
                      title: 'কোনো প্রজেক্ট নেই',
                    );
                  }
                  return Column(
                    children: projects.map((p) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: (isDark
                                    ? const Color(0xFF93A8F4)
                                    : AppColors.contractorNavy)
                                .withValues(alpha: 0.12),
                            child: Icon(
                              Icons.apartment_rounded,
                              color: isDark
                                  ? const Color(0xFF93A8F4)
                                  : AppColors.contractorNavy,
                            ),
                          ),
                          title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('ক্লায়েন্ট: ${p.clientName} • ${toBn(p.workerCount)} জন শ্রমিক'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                p.budget != null ? BengaliFormatter.toCurrency(p.budget!) : 'বাজেট নেই',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFF93A8F4) : AppColors.contractorNavy,
                                ),
                              ),
                              Text(
                                p.status.displayName,
                                style: TextStyle(fontSize: 11, color: p.status.color),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 28),

              // এক্সপোর্ট ও ডাউনলোড বোতাম
              const Text(
                'প্রতিবেদন এক্সপোর্ট',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('পিডিএফ রিপোর্ট ডাউনলোড শুরু হচ্ছে...')),
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFEF4444)),
                      label: const Text('PDF ডাউনলোড'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('এক্সেল শিট এক্সপোর্ট প্রস্তুত হচ্ছে...')),
                        );
                      },
                      icon: const Icon(Icons.table_view_rounded, color: Color(0xFF0F766E)),
                      label: const Text('Excel এক্সপোর্ট'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseRow({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13.5,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
        Text(
          BengaliFormatter.toCurrency(amount),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
