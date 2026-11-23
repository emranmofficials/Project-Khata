import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../providers/accounting_provider.dart';
import '../widgets/add_material_dialog.dart';

/// PRD সেকশন ৩.১০ ও ৬.৫ (৭) অনুযায়ী মালামাল তালিকা স্ক্রিন
class MaterialsScreen extends ConsumerWidget {
  final String projectId;
  final String projectName;

  const MaterialsScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialsAsync = ref.watch(projectMaterialsProvider(projectId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('মালামালের হিসাব'),
            Text(projectName, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AddMaterialDialog(projectId: projectId),
          );
        },
        backgroundColor: AppColors.contractorPrimary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('মালামাল যোগ করুন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: materialsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSizes.paddingMedium),
          child: LoadingSkeletonList(count: 5, itemHeight: 90),
        ),
        error: (err, _) => EmptyStateView(
          icon: Icons.error_outline_rounded,
          title: 'মালামাল লোড করা যায়নি',
          subtitle: err.toString(),
          isError: true,
          onButtonPressed: () => ref.invalidate(projectMaterialsProvider(projectId)),
        ),
        data: (materials) {
          if (materials.isEmpty) {
            return EmptyStateView(
              icon: Icons.inventory_2_outlined,
              title: 'এখনো কোনো মালামাল যোগ করা হয়নি',
              subtitle: 'সাইটের মালামাল বা ক্রয়ের রসিদ রেকর্ড করতে নিচের বোতাম ব্যবহার করুন।',
              buttonLabel: 'মালামাল যোগ করুন',
              onButtonPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AddMaterialDialog(projectId: projectId),
                );
              },
            );
          }

          double totalMaterialsCost = 0.0;
          for (var m in materials) {
            totalMaterialsCost += m.totalPrice;
          }

          return Column(
            children: [
              // মোট মালামাল খরচ সারসংক্ষেপ কার্ড
              Container(
                margin: const EdgeInsets.all(AppSizes.paddingMedium),
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('মোট মালামাল ক্রয়:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    Text(
                      BengaliFormatter.toCurrency(totalMaterialsCost),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.contractorPrimary),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
                  itemCount: materials.length,
                  itemBuilder: (context, index) {
                    final item = materials[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.paddingMedium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  BengaliFormatter.toCurrency(item.totalPrice),
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'পরিমাণ: ${BengaliFormatter.toBengaliNumber(item.qty)} ${item.unit} • দর: ${BengaliFormatter.toCurrency(item.unitPrice)}',
                              style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: item.isAddedByClient
                                        ? AppColors.clientPrimary.withOpacity(0.1)
                                        : AppColors.contractorPrimary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.isAddedByClient ? 'ক্লায়েন্ট যুক্ত করেছে' : 'সাইট থেকে যুক্ত',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: item.isAddedByClient ? AppColors.clientPrimary : AppColors.contractorPrimary,
                                    ),
                                  ),
                                ),
                                Text(
                                  BengaliFormatter.toShortDate(item.purchaseDate),
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
