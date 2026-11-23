import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// নোটিফিকেশন মডেল (Notification Model)
class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final Map<String, dynamic>? data;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.isRead = false,
    this.data,
    required this.createdAt,
  });

  IconData get icon {
    switch (type.toUpperCase()) {
      case 'ENTRY_SUBMITTED':
        return Icons.assignment_turned_in_rounded;
      case 'HANDOVER_REQUIRED':
        return Icons.swap_horiz_rounded;
      case 'ATTENDANCE_PENDING':
        return Icons.wrong_location_outlined;
      case 'NEW_BILL_STATEMENT':
        return Icons.receipt_long_rounded;
      case 'PAYMENT_RECEIVED':
        return Icons.monetization_on_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color get iconColor {
    switch (type.toUpperCase()) {
      case 'ENTRY_SUBMITTED':
        return AppColors.success;
      case 'HANDOVER_REQUIRED':
        return AppColors.danger;
      case 'ATTENDANCE_PENDING':
        return AppColors.warning;
      case 'NEW_BILL_STATEMENT':
        return AppColors.contractorPrimary;
      default:
        return AppColors.contractorPrimary;
    }
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'GENERAL',
      title: json['title'] as String? ?? 'বিজ্ঞপ্তি',
      body: json['body'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      data: json['data'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }
}
