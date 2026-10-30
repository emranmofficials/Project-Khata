import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../controllers/notifications_controller.dart';
import '../../domain/models/app_notification.dart';

class NotificationCenterScreen extends ConsumerStatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  ConsumerState<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState
    extends ConsumerState<NotificationCenterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsControllerProvider);
    final controller = ref.read(notificationsControllerProvider.notifier);
    final unreadCount = state.unreadCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('নোটিফিকেশন সেন্টার'),
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: () => controller.markAllAsRead(),
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('সব পঠিত'),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'সব (${BengaliFormatter.toBnNumber(state.notifications.length)})'),
            Tab(
              text: unreadCount > 0
                  ? 'অপঠিত (${BengaliFormatter.toBnNumber(unreadCount)})'
                  : 'অপঠিত',
            ),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationList(state.notifications, controller),
                _buildNotificationList(state.unreadNotifications, controller, isUnreadTab: true),
              ],
            ),
    );
  }

  Widget _buildNotificationList(
    List<AppNotification> items,
    NotificationsController controller, {
    bool isUnreadTab = false,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isUnreadTab ? Icons.mark_email_read_outlined : Icons.notifications_none_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                isUnreadTab
                    ? 'সব নোটিফিকেশন পড়া হয়েছে!'
                    : 'বর্তমানে কোনো নোটিফিকেশন নেই',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isUnreadTab
                    ? 'নতুন কোনো আপডেট আসলে এখানে দেখতে পাবেন।'
                    : 'আপনার প্রজেক্টের যাবতীয় আপডেট ও সতর্কবার্তা এখানে জমা হবে।',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
        itemBuilder: (context, index) {
          final item = items[index];
          return Dismissible(
            key: Key(item.id),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red.shade600,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete_outline, color: Colors.white),
            ),
            onDismissed: (_) {
              controller.deleteNotification(item.id);
            },
            child: InkWell(
              onTap: () {
                if (!item.isRead) {
                  controller.markAsRead(item.id);
                }
                _handleNotificationTap(item);
              },
              child: Container(
                color: item.isRead ? Colors.transparent : AppColors.primary.withValues(alpha: 0.05),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: item.type.color.withValues(alpha: 0.15),
                      child: Icon(item.type.iconData, color: item.type.color, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: item.type.color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.type.labelBn,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: item.type.color,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                BengaliFormatter.toRelativeTime(item.createdAt),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: item.isRead ? FontWeight.w500 : FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          if (item.body.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              item.body,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (!item.isRead) ...[
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleNotificationTap(AppNotification item) {
    if (item.projectId != null && item.projectId!.isNotEmpty) {
      if (item.type == NotificationType.billStatementSent) {
        // Navigate or prompt to open project accounts
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.title} বিস্তারিত দেখতে প্রজেক্ট অ্যাকাউন্টে যান'),
            action: SnackBarAction(
              label: 'প্রজেক্ট দেখুন',
              onPressed: () => context.push('/projects/${item.projectId}'),
            ),
          ),
        );
      } else {
        context.push('/projects/${item.projectId}');
      }
    }
  }
}
