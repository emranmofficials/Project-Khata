import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client.dart';
import '../../data/supabase_notification_repository.dart';
import '../../domain/models/notification_model.dart';
import '../../domain/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseNotificationRepository(client);
});

final notificationUnreadFilterProvider = StateProvider<bool>((ref) => false);

final notificationsListProvider = FutureProvider<List<NotificationModel>>((ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  final unreadOnly = ref.watch(notificationUnreadFilterProvider);
  return repository.getNotifications(unreadOnly: unreadOnly);
});

final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getUnreadCount();
});

class NotificationActionNotifier extends StateNotifier<AsyncValue<void>> {
  final NotificationRepository _repository;
  final Ref _ref;

  NotificationActionNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<void> markAsRead(String id) async {
    await _repository.markAsRead(id);
    _ref.invalidate(notificationsListProvider);
    _ref.invalidate(unreadNotificationCountProvider);
  }

  Future<void> markAllAsRead() async {
    await _repository.markAllAsRead();
    _ref.invalidate(notificationsListProvider);
    _ref.invalidate(unreadNotificationCountProvider);
  }
}

final notificationActionProvider = StateNotifierProvider<NotificationActionNotifier, AsyncValue<void>>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return NotificationActionNotifier(repo, ref);
});
