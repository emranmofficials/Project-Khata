import 'models/notification_model.dart';

/// নোটিফিকেশন রিপোজিটরি ইন্টারফেস
abstract class NotificationRepository {
  /// ব্যবহারকারীর নোটিফিকেশন তালিকা আনা
  Future<List<NotificationModel>> getNotifications({bool? unreadOnly});

  /// নির্দিষ্ট নোটিফিকেশন পঠিত হিসেবে চিহ্নিত করা
  Future<void> markAsRead(String notificationId);

  /// সমস্ত নোটিফিকেশন এক ক্লিকে পঠিত করা
  Future<void> markAllAsRead();

  /// অপঠিত নোটিফিকেশন সংখ্যা
  Future<int> getUnreadCount();
}
