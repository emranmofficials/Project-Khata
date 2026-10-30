import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/app_notification.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepository(Supabase.instance.client);
});

class NotificationsRepository {
  final SupabaseClient _client;

  NotificationsRepository(this._client);

  /// Fetch notifications for a user
  Future<List<AppNotification>> getNotifications(String userId) async {
    try {
      final data = await _client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      return (data as List<dynamic>)
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Real-time stream of notifications for a user
  Stream<List<AppNotification>> streamNotifications(String userId) {
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((list) => list
            .map((item) => AppNotification.fromJson(item))
            .toList());
  }

  /// Mark single notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _client.from('notifications').update({
        'is_read': true,
        'read_at': DateTime.now().toIso8601String(),
      }).eq('id', notificationId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Mark all notifications as read for a user
  Future<bool> markAllAsRead(String userId) async {
    try {
      await _client.from('notifications').update({
        'is_read': true,
        'read_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId).eq('is_read', false);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete a notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _client.from('notifications').delete().eq('id', notificationId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Send/create a custom notification
  Future<bool> sendNotification(AppNotification notification) async {
    try {
      await _client.from('notifications').insert(notification.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }
}
