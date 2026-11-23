import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../providers/notification_provider.dart';

/// PRD সেকশন ৬.৬ (৮) অনুযায়ী নোটিফিকেশন ইনবক্স স্ক্রিন
class NotificationsInboxScreen extends ConsumerWidget {
  const NotificationsInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsListProvider);
    final isUnreadFilter = ref.watch(notificationUnreadFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('বিজ্ঞপ্তি ও নোটিফিকেশন'),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(notificationActionProvider.notifier).markAllAsRead();
            },
            child: const Text('সব পড়া হয়েছে', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          // ফিল্টার ট্যাব
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('সব বিজ্ঞপ্তি'),
                  selected: !isUnreadFilter,
                  onSelected: (_) => ref.read(notificationUnreadFilterProvider.notifier).state = false,
                  selectedColor: AppColors.contractorPrimary,
                  labelStyle: TextStyle(color: !isUnreadFilter ? Colors.white : null),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('অপঠিত'),
                  selected: isUnreadFilter,
                  onSelected: (_) => ref.read(notificationUnreadFilterProvider.notifier).state = true,
                  selectedColor: AppColors.contractorPrimary,
                  labelStyle: TextStyle(color: isUnreadFilter ? Colors.white : null),
                ),
              ],
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(notificationsListProvider);
              },
              child: notificationsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppSizes.paddingMedium),
                  child: LoadingSkeletonList(count: 5, itemHeight: 80),
                ),
                error: (err, _) => Center(child: Text('লোড ত্রুটি: $err')),
                data: (notifications) {
                  if (notifications.isEmpty) {
                    return const EmptyStateView(
                      icon: Icons.notifications_none_rounded,
                      title: 'কোনো নতুন বিজ্ঞপ্তি নেই',
                      subtitle: 'সাইটের উপস্থিতি, এন্ট্রি জমা বা বিল সংক্রান্ত আপডেট এখানে দেখতে পাবেন।',
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: item.isRead
                              ? (isDark ? AppColors.darkCard : AppColors.lightCard)
                              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF)),
                          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                          border: Border.all(
                            color: item.isRead
                                ? (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                                : AppColors.contractorPrimary.withOpacity(0.3),
                            width: item.isRead ? 1 : 1.5,
                          ),
                        ),
                        child: ListTile(
                          onTap: () {
                            if (!item.isRead) {
                              ref.read(notificationActionProvider.notifier).markAsRead(item.id);
                            }
                          },
                          leading: CircleAvatar(
                            backgroundColor: item.iconColor.withOpacity(0.12),
                            child: Icon(item.icon, color: item.iconColor, size: 22),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: TextStyle(
                                    fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              if (!item.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.contractorPrimary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                item.body,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                BengaliFormatter.toFullDate(item.createdAt),
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
