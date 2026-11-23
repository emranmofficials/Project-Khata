import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/accounting_provider.dart';

/// PRD সেকশন ৩.১০ ও ৬.৫ (৮) অনুযায়ী সাইট খরচ তালিকা ও অনুমোদন স্ক্রিন
class SiteExpensesScreen extends ConsumerWidget {
  final String projectId;
  final String projectName;

  const SiteExpensesScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  void _handleDecide(BuildContext context, WidgetRef ref, String expenseId, bool approve) async {
    String? rejectionReason;

    if (!approve) {
      final controller = TextEditingController();
      final reasonConfirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
          title: const Text('খরচ প্রত্যাখানের কারণ'),
          content: TextField(
            controller: controller,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'কারণ লিখুন *',
              hintText: 'কেন এই খরচ প্রত্যাখান করা হচ্ছে...',
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('বাতিল')),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.of(ctx).pop(true);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              child: const Text('প্রত্যাখ্যান করুন', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (reasonConfirmed != true) return;
      rejectionReason = controller.text.trim();
    }

    try {
      await ref.read(accountingActionProvider.notifier).decideSiteExpense(
        expenseId: expenseId,
        status: approve ? 'approved' : 'rejected',
        projectId: projectId,
        reason: rejectionReason,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approve ? 'সাইট খরচ অনুমোদিত হয়েছে' : 'সাইট খরচ প্রত্যাখ্যাত হয়েছে'),
            backgroundColor: approve ? AppColors.success : AppColors.danger,
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
  }

  void _showAddExpenseDialog(BuildContext context, WidgetRef ref) {
    final catController = TextEditingController(text: 'যাতায়াত');
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
        title: const Text('নতুন সাইট খরচ যোগ করুন'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: catController,
              decoration: const InputDecoration(labelText: 'খরচের ধরন (যেমন: যাতায়াত, খাবার, জরুরি ক্রয়)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'পরিমাণ (টাকা) *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'নোট বা বিবরণ (ঐচ্ছিক)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('বাতিল')),
          ElevatedButton(
            onPressed: () async {
              final amt = double.tryParse(amountController.text.trim());
              if (amt != null && amt > 0) {
                Navigator.of(ctx).pop();
                await ref.read(accountingActionProvider.notifier).addSiteExpense(
                  projectId: projectId,
                  category: catController.text.trim(),
                  amount: amt,
                  expenseDate: DateTime.now(),
                  note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.supervisorPrimary),
            child: const Text('সংরক্ষণ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(projectSiteExpensesProvider(projectId));
    final user = ref.watch(authStateProvider).user;
    final isContractor = user?.isContractor ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('সাইট খরচ'),
            Text(projectName, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExpenseDialog(context, ref),
        backgroundColor: AppColors.supervisorPrimary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('সাইট খরচ যোগ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: expensesAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSizes.paddingMedium),
          child: LoadingSkeletonList(count: 4, itemHeight: 90),
        ),
        error: (err, _) => Center(child: Text('লোড ত্রুটি: $err')),
        data: (expenses) {
          if (expenses.isEmpty) {
            return const EmptyStateView(
              icon: Icons.receipt_long_outlined,
              title: 'কোনো সাইট খরচ নেই',
              subtitle: 'জরুরি যাতায়াত বা খাবার খরচ থাকলে যোগ করতে পারেন।',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final exp = expenses[index];
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
                          Text(exp.category, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(
                            BengaliFormatter.toCurrency(exp.amount),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.danger),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'যোগ করেছে: ${exp.addedByName ?? 'সুপারভাইজার'} • তারিখ: ${BengaliFormatter.toShortDate(exp.expenseDate)}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      if (exp.note != null) ...[
                        const SizedBox(height: 4),
                        Text('বিবরণ: ${exp.note}', style: const TextStyle(fontSize: 13)),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          StatusChip.forStatus(exp.statusBengaliLabel),
                          if (isContractor && exp.isPending) ...[
                            Row(
                              children: [
                                OutlinedButton(
                                  onPressed: () => _handleDecide(context, ref, exp.id, false),
                                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                                  child: const Text('প্রত্যাখ্যান'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () => _handleDecide(context, ref, exp.id, true),
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                                  child: const Text('অনুমোদন', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ],
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
