import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../controllers/notifications_controller.dart';

class NotificationBadgeButton extends ConsumerWidget {
  final Color? color;

  const NotificationBadgeButton({super.key, this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return IconButton(
      tooltip: 'নোটিফিকেশন',
      icon: Badge(
        isLabelVisible: unreadCount > 0,
        label: Text(
          BengaliFormatter.toBnNumber(unreadCount > 99 ? '99+' : unreadCount),
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
        child: Icon(
          unreadCount > 0 ? Icons.notifications_active : Icons.notifications_outlined,
          color: color,
        ),
      ),
      onPressed: () {
        context.push('/notifications');
      },
    );
  }
}
