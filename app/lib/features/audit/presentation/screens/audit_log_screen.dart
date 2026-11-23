import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../providers/audit_provider.dart';

/// PRD সেকশন ৬.৬ (৯) অনুযায়ী অপরিবর্তনীয় অডিট লগ ভিউয়ার স্ক্রিন (শুধুমাত্র পাঠযোগ্য)
class AuditLogScreen extends ConsumerWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditLogsAsync = ref.watch(auditLogsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('অডিট লগ ট্রেইল'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(auditLogsProvider);
        },
        child: auditLogsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSizes.paddingMedium),
            child: LoadingSkeletonList(count: 6, itemHeight: 80),
          ),
          error: (err, _) => Center(child: Text('অডিট লগ লোড ত্রুটি: $err')),
          data: (logs) {
            if (logs.isEmpty) {
              return const EmptyStateView(
                icon: Icons.history_edu_rounded,
                title: 'কোনো অডিট রেকর্ড পাওয়া যায়নি',
                subtitle: 'গুরুত্বপূর্ণ ডেটা পরিবর্তনের রেকর্ড এখানে স্বয়ংক্রিয়ভাবে সংরক্ষিত হবে।',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              itemCount: logs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final log = logs[index];
                return Container(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.verified_user_outlined, size: 16, color: AppColors.contractorPrimary),
                              const SizedBox(width: 6),
                              Text(
                                log.actionBengaliDescription,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.contractorPrimary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              log.tableName,
                              style: const TextStyle(fontSize: 10, color: AppColors.contractorPrimary, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'ব্যবহারকারী: ${log.actorName} (${log.actorRole})',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'সময়: ${BengaliFormatter.toFullDate(log.createdAt)}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
