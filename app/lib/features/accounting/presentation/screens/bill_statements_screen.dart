import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../providers/accounting_provider.dart';

/// PRD সেকশন ৩.৯ ও ৬.৫ (৯) অনুযায়ী শ্রমিক-বিল খতিয়ান ও ক্লায়েন্ট স্ন্যাপশট স্ক্রিন
class BillStatementsScreen extends ConsumerWidget {
  final String projectId;
  final String projectName;

  const BillStatementsScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  void _showGenerateDialog(BuildContext context, WidgetRef ref) {
    DateTime fromDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
    DateTime toDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
          title: const Text('বিল খতিয়ান স্ন্যাপশট তৈরি'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('প্রজেক্ট: $projectName', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('সময়কাল নির্বাচন করুন:'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('শুরু: ${BengaliFormatter.toShortDate(fromDate)}'),
                  Text('শেষ: ${BengaliFormatter.toShortDate(toDate)}'),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'নোট: খতিয়ান পাঠানোর মুহূর্তে একটি স্ন্যাপশট লক হবে। পরবর্তীতে হিসাব বদলালেও ক্লায়েন্টের পাঠানো খতিয়ান অপরিবর্তিত থাকবে।',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('বাতিল')),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                try {
                  await ref.read(accountingActionProvider.notifier).generateAndSendBillStatement(
                    projectId: projectId,
                    periodFrom: fromDate,
                    periodTo: toDate,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('খতিয়ান সফলভাবে লক করে ক্লায়েন্টকে পাঠানো হয়েছে!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('ত্রুটি: $e'), backgroundColor: AppColors.danger),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.contractorPrimary),
              child: const Text('স্ন্যাপশট তৈরি ও পাঠান', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statementsAsync = ref.watch(projectBillStatementsProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('শ্রমিক-বিল খতিয়ান'),
            Text(projectName, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGenerateDialog(context, ref),
        backgroundColor: AppColors.contractorPrimary,
        icon: const Icon(Icons.send_rounded, color: Colors.white),
        label: const Text('খতিয়ান তৈরি ও পাঠান', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: statementsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSizes.paddingMedium),
          child: LoadingSkeletonList(count: 3, itemHeight: 120),
        ),
        error: (err, _) => Center(child: Text('লোড ত্রুটি: $err')),
        data: (statements) {
          if (statements.isEmpty) {
            return EmptyStateView(
              icon: Icons.receipt_long_rounded,
              title: 'এখনো কোনো বিল খতিয়ান পাঠানো হয়নি',
              subtitle: 'ক্লায়েন্টের কাছে নির্দিষ্ট সময়কালের খতিয়ান পাঠাতে নিচের বোতামে চাপ দিন।',
              buttonLabel: 'খতিয়ান তৈরি ও পাঠান',
              onButtonPressed: () => _showGenerateDialog(context, ref),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            itemCount: statements.length,
            itemBuilder: (context, index) {
              final item = statements[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.lock_rounded, size: 16, color: AppColors.success),
                              const SizedBox(width: 6),
                              Text(
                                '${BengaliFormatter.toShortDate(item.periodFrom)} - ${BengaliFormatter.toShortDate(item.periodTo)}',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('লককৃত স্ন্যাপশট', style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('মোট কার্যদিবস: ${BengaliFormatter.toBengaliNumber(item.totalWorkingDays)} দিন'),
                          Text('মজুরি: ${BengaliFormatter.toCurrency(item.totalWage)}'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('মালামাল: ${BengaliFormatter.toCurrency(item.totalMaterial)}'),
                          Text('সাইট খরচ: ${BengaliFormatter.toCurrency(item.totalSiteExpense)}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('মোট দাবি:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            BengaliFormatter.toCurrency(item.totalBilled),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.contractorPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('পরিশোধিত:', style: TextStyle(color: Colors.grey)),
                          Text(BengaliFormatter.toCurrency(item.totalClientPaid), style: const TextStyle(color: AppColors.success)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('অবশিষ্ট বাকি:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger)),
                          Text(
                            BengaliFormatter.toCurrency(item.netDue),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
