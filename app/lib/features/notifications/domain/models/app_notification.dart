import 'package:flutter/material.dart';

enum NotificationType {
  assignmentChanged,
  entryOpened,
  outsideSiteAttendance,
  billStatementSent,
  wagePaid,
  general;

  static NotificationType fromString(String? type) {
    switch (type) {
      case 'assignment_changed':
        return NotificationType.assignmentChanged;
      case 'entry_opened':
        return NotificationType.entryOpened;
      case 'outside_site_attendance':
        return NotificationType.outsideSiteAttendance;
      case 'bill_statement_sent':
        return NotificationType.billStatementSent;
      case 'wage_paid':
        return NotificationType.wagePaid;
      default:
        return NotificationType.general;
    }
  }

  String toDbString() {
    switch (this) {
      case NotificationType.assignmentChanged:
        return 'assignment_changed';
      case NotificationType.entryOpened:
        return 'entry_opened';
      case NotificationType.outsideSiteAttendance:
        return 'outside_site_attendance';
      case NotificationType.billStatementSent:
        return 'bill_statement_sent';
      case NotificationType.wagePaid:
        return 'wage_paid';
      case NotificationType.general:
        return 'general';
    }
  }

  String get labelBn {
    switch (this) {
      case NotificationType.assignmentChanged:
        return 'অ্যাসাইনমেন্ট';
      case NotificationType.entryOpened:
        return 'দৈনিক এন্ট্রি';
      case NotificationType.outsideSiteAttendance:
        return 'হাজিরা সতর্কতা';
      case NotificationType.billStatementSent:
        return 'বিল স্টেটমেন্ট';
      case NotificationType.wagePaid:
        return 'মজুরি পেমেন্ট';
      case NotificationType.general:
        return 'নোটিফিকেশন';
    }
  }

  IconData get iconData {
    switch (this) {
      case NotificationType.assignmentChanged:
        return Icons.assignment_ind_outlined;
      case NotificationType.entryOpened:
        return Icons.edit_calendar_outlined;
      case NotificationType.outsideSiteAttendance:
        return Icons.location_off_outlined;
      case NotificationType.billStatementSent:
        return Icons.receipt_long_outlined;
      case NotificationType.wagePaid:
        return Icons.payments_outlined;
      case NotificationType.general:
        return Icons.notifications_outlined;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.assignmentChanged:
        return const Color(0xFFC2410C); // Amber / orange
      case NotificationType.entryOpened:
        return const Color(0xFF1E3A8A); // Navy
      case NotificationType.outsideSiteAttendance:
        return Colors.red;
      case NotificationType.billStatementSent:
        return const Color(0xFF0F766E); // Teal
      case NotificationType.wagePaid:
        return const Color(0xFF16A34A); // Green
      case NotificationType.general:
        return Colors.blueGrey;
    }
  }
}

class AppNotification {
  final String id;
  final String organizationId;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.organizationId,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.data = const {},
    this.isRead = false,
    required this.createdAt,
  });

  String? get projectId => data['project_id'] as String?;
  String? get entryId => data['entry_id'] as String?;
  String? get statementId => data['statement_id'] as String?;
  String? get workerId => data['worker_id'] as String?;

  AppNotification copyWith({
    String? id,
    String? organizationId,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      organizationId: (json['organization_id'] ?? json['org_id'] ?? '') as String,
      userId: (json['user_id'] ?? '') as String,
      type: NotificationType.fromString(json['type'] as String? ?? json['kind'] as String?),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      data: json['data'] != null ? Map<String, dynamic>.from(json['data'] as Map) : {},
      isRead: json['is_read'] as bool? ?? (json['read_at'] != null),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'organization_id': organizationId,
      'user_id': userId,
      'type': type.toDbString(),
      'title': title,
      'body': body,
      'data': data,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
