import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_khata/core/constants/app_colors.dart';
import 'package:project_khata/core/constants/contractor_strings.dart';
import 'package:project_khata/core/utils/bengali_formatter.dart';
import 'package:project_khata/widgets/contractor_widgets.dart';
import '../../contractor_providers.dart';

typedef ProjectAccountsScreen = ContractorProjectAccountsScreen;

class ContractorProjectAccountsScreen extends ConsumerWidget {
  final String projectId;

  const ContractorProjectAccountsScreen({
    super.key,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectDetailsProvider(projectId));
    final clientPaymentsAsync = ref.watch(clientPaymentsProvider(projectId));
    final materialsAsync = ref.watch(materialsProvider(projectId));

    return projectAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(e.toString())),
      ),
      data: (project) {
        return Scaffold(
          appBar: AppBar(
            title: Text('${project.name} - হিসাব'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ওভারভিউ হিরো কার্ড
                HeroSummaryCard(
                  title: 'মোট চুক্তি / বাজেট',
                  amount: project.budget != null ? BengaliFormatter.toCurrency(project.budget!) : '৳ ০',
                  badgeText: project.status.displayName,
                  subtitle: 'ক্লায়েন্ট: ${project.client.name}',
                  secondaryText: 'প্রজেক্ট খাতা',
                ),

                const SizedBox(height: 20),

                // হিসাব সারাংশ মেট্রিকস
                Row(
                  children: const [
                    Expanded(
                      child: KpiCard(
                        title: ContractorStrings.totalIncome,
                        value: '৳ ৫,০০,০০০',
                        subtitle: 'প্রাপ্ত ক্লায়েন্ট পেমেন্ট',
                        icon: Icons.arrow_downward_rounded,
                        iconColor: AppColors.contractorNavy,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: KpiCard(
                        title: ContractorStrings.totalExpense,
                        value: '৳ ৩,৮০,০০০',
                        subtitle: 'মালামাল ও মজুরি খরচ',
                        icon: Icons.arrow_upward_rounded,
                        iconColor: AppColors.error,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                const Text(
                  'সাম্প্রতিক ক্লায়েন্ট পেমেন্ট',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                clientPaymentsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('লোড করা যায়নি'),
                  data: (payments) {
                    if (payments.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: Text('কোনো পেমেন্ট রেকর্ড নেই')),
                        ),
                      );
                    }
                    return Column(
                      children: payments.map((p) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(BengaliFormatter.toCurrency(p.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('তারিখ: ${toBn(p.paymentDate.day)}/${toBn(p.paymentDate.month)} • ${p.note ?? ""}'),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 20),

                const Text(
                  'মালামাল ব্যয় বিবরণী',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                materialsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('লোড করা যায়নি'),
                  data: (materials) {
                    if (materials.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: Text('কোনো মালামাল রেকর্ড নেই')),
                        ),
                      );
                    }
                    return Column(
                      children: materials.map((m) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(m.name),
                            subtitle: Text('${toBn(m.qty)} ${m.unit} • ${m.isClientAdded ? "ক্লায়েন্ট ক্রয়" : "ঠিকাদার ক্রয়"}'),
                            trailing: Text(BengaliFormatter.toCurrency(m.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
