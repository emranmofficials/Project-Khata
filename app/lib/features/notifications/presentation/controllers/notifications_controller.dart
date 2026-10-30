import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/notifications_repository.dart';
import '../../domain/models/app_notification.dart';

class NotificationsState {
  final bool isLoading;
  final List<AppNotification> notifications;
  final String? errorMessage;

  const NotificationsState({
    this.isLoading = false,
    this.notifications = const [],
    this.errorMessage,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  List<AppNotification> get unreadNotifications =>
      notifications.where((n) => !n.isRead).toList();

  NotificationsState copyWith({
    bool? isLoading,
    List<AppNotification>? notifications,
    String? errorMessage,
  }) {
    return NotificationsState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
      errorMessage: errorMessage,
    );
  }
}

final notificationsControllerProvider =
    StateNotifierProvider<NotificationsController, NotificationsState>((ref) {
  final repo = ref.watch(notificationsRepositoryProvider);
  final userAsync = ref.watch(currentUserProvider);
  final userId = userAsync.value?.id;
  return NotificationsController(repo, userId);
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final state = ref.watch(notificationsControllerProvider);
  return state.unreadCount;
});

class NotificationsController extends StateNotifier<NotificationsState> {
  final NotificationsRepository _repository;
  final String? _userId;
  StreamSubscription<List<AppNotification>>? _subscription;

  NotificationsController(this._repository, this._userId)
      : super(const NotificationsState(isLoading: true)) {
    final uid = _userId;
    if (uid != null && uid.isNotEmpty) {
      _loadNotifications();
      _subscribeRealtime();
    } else {
      state = const NotificationsState(isLoading: false);
    }
  }

  Future<void> _loadNotifications() async {
    final uid = _userId;
    if (uid == null) return;
    state = state.copyWith(isLoading: true);
    final items = await _repository.getNotifications(uid);
    state = state.copyWith(isLoading: false, notifications: items);
  }

  void _subscribeRealtime() {
    final uid = _userId;
    if (uid == null) return;
    _subscription?.cancel();
    _subscription = _repository.streamNotifications(uid).listen((items) {
      state = state.copyWith(notifications: items);
    }, onError: (_) {
      // Handled silently
    });
  }

  Future<void> refresh() async {
    await _loadNotifications();
  }

  Future<void> markAsRead(String notificationId) async {
    final updated = state.notifications.map((n) {
      if (n.id == notificationId) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    state = state.copyWith(notifications: updated);

    await _repository.markAsRead(notificationId);
  }

  Future<void> markAllAsRead() async {
    final uid = _userId;
    if (uid == null) return;
    final updated = state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    state = state.copyWith(notifications: updated);

    await _repository.markAllAsRead(uid);
  }

  Future<void> deleteNotification(String notificationId) async {
    final updated = state.notifications.where((n) => n.id != notificationId).toList();
    state = state.copyWith(notifications: updated);

    await _repository.deleteNotification(notificationId);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
