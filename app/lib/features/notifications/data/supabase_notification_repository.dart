import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/notification_model.dart';
import '../domain/notification_repository.dart';

/// Supabase বাস্তবায়িত NotificationRepository
class SupabaseNotificationRepository implements NotificationRepository {
  final SupabaseClient _client;

  SupabaseNotificationRepository(this._client);

  @override
  Future<List<NotificationModel>> getNotifications({bool? unreadOnly}) async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    var query = _client.from('notifications').select().eq('user_id', user.id);

    if (unreadOnly == true) {
      query = query.eq('is_read', false);
    }

    final response = await query.order('created_at', ascending: false);
    return (response as List<dynamic>).map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _client.from('notifications').update({'is_read': true}).eq('id', notificationId);
  }

  @override
  Future<void> markAllAsRead() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    await _client.from('notifications').update({'is_read': true}).eq('user_id', user.id).eq('is_read', false);
  }

  @override
  Future<int> getUnreadCount() async {
    final user = _client.auth.currentUser;
    if (user == null) return 0;

    final response = await _client.from('notifications').select('id').eq('user_id', user.id).eq('is_read', false);

    return (response as List<dynamic>).length;
  }
}
