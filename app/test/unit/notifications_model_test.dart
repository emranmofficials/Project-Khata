import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_khata/core/utils/bengali_formatter.dart';
import 'package:project_khata/features/notifications/domain/models/app_notification.dart';
import 'package:project_khata/features/accounts/domain/models/bill_statement.dart';

void main() {
  group('AppNotification Model Tests', () {
    test('AppNotification parses fromJson correctly', () {
      final json = {
        'id': 'notif-001',
        'organization_id': 'org-001',
        'user_id': 'user-001',
        'type': 'entry_opened',
        'title': 'দৈনিক এন্ট্রি খোলা হয়েছে',
        'body': 'আজকের এন্ট্রি খোলা হয়েছে।',
        'data': {
          'project_id': 'proj-123',
          'entry_id': 'entry-456',
        },
        'is_read': false,
        'created_at': '2026-10-30T01:00:00Z',
      };

      final notif = AppNotification.fromJson(json);

      expect(notif.id, 'notif-001');
      expect(notif.organizationId, 'org-001');
      expect(notif.userId, 'user-001');
      expect(notif.type, NotificationType.entryOpened);
      expect(notif.title, 'দৈনিক এন্ট্রি খোলা হয়েছে');
      expect(notif.body, 'আজকের এন্ট্রি খোলা হয়েছে।');
      expect(notif.projectId, 'proj-123');
      expect(notif.entryId, 'entry-456');
      expect(notif.isRead, false);
      expect(notif.type.labelBn, 'দৈনিক এন্ট্রি');
    });

    test('NotificationType maps all enum types correctly', () {
      expect(NotificationType.fromString('assignment_changed'),
          NotificationType.assignmentChanged);
      expect(NotificationType.fromString('entry_opened'),
          NotificationType.entryOpened);
      expect(NotificationType.fromString('outside_site_attendance'),
          NotificationType.outsideSiteAttendance);
      expect(NotificationType.fromString('bill_statement_sent'),
          NotificationType.billStatementSent);
      expect(NotificationType.fromString('wage_paid'),
          NotificationType.wagePaid);
      expect(NotificationType.fromString('unknown'),
          NotificationType.general);

      expect(NotificationType.assignmentChanged.toDbString(),
          'assignment_changed');
      expect(NotificationType.outsideSiteAttendance.toDbString(),
          'outside_site_attendance');
      expect(NotificationType.billStatementSent.toDbString(),
          'bill_statement_sent');
    });

    test('AppNotification copyWith modifies isRead and fields', () {
      final notif = AppNotification(
        id: '1',
        organizationId: 'org1',
        userId: 'u1',
        type: NotificationType.outsideSiteAttendance,
        title: 'সতর্কতা',
        body: 'সাইটের বাইরে হাজিরা',
        isRead: false,
        createdAt: DateTime(2026, 10, 30),
      );

      final readNotif = notif.copyWith(isRead: true);
      expect(readNotif.isRead, true);
      expect(readNotif.title, 'সতর্কতা');
      expect(readNotif.type.color, Colors.red);
    });
  });

  group('Bengali Relative Time Formatter Tests', () {
    test('Formats recent seconds as এইমাত্র', () {
      final now = DateTime.now().subtract(const Duration(seconds: 15));
      expect(BengaliFormatter.formatRelativeTime(now), 'এইমাত্র');
    });

    test('Formats minutes ago in Bengali numerals', () {
      final fiveMinAgo = DateTime.now().subtract(const Duration(minutes: 5));
      expect(BengaliFormatter.formatRelativeTime(fiveMinAgo), '৫ মিনিট আগে');
    });

    test('Formats hours ago in Bengali numerals', () {
      final now = DateTime.now();
      if (now.hour >= 2) {
        final twoHoursAgo = now.subtract(const Duration(hours: 2));
        expect(BengaliFormatter.formatRelativeTime(twoHoursAgo), '২ ঘণ্টা আগে');
      }
    });
  });

  group('BillStatement Report Tests', () {
    test('toFormattedReport generates formatted string with snapshot details', () {
      final statement = BillStatement(
        id: 'stmt-001',
        organizationId: 'org-001',
        projectId: 'proj-001',
        periodFrom: DateTime(2026, 10, 1),
        periodTo: DateTime(2026, 10, 7),
        preset: 'weekly',
        generatedBy: 'contractor-001',
        isLocked: true,
        sentToClientAt: DateTime(2026, 10, 7, 18, 0),
        lockedSnapshot: {
          'summary': {
            'total_budget': 500000.0,
            'total_client_paid': 200000.0,
            'client_due': 300000.0,
            'total_project_expenses': 180000.0,
            'total_wages_earned': 100000.0,
            'total_wages_paid': 80000.0,
            'total_materials_cost': 70000.0,
            'total_expenses_cost': 10000.0,
          }
        },
        createdAt: DateTime(2026, 10, 7),
      );

      final report = statement.toFormattedReport(
        projectName: 'ধানমন্ডি আবাসিক ভবন',
        clientName: 'মো: রফিকুল ইসলাম',
      );

      expect(report.contains('প্রজেক্ট খাতা — প্রজেক্ট বিল স্টেটমেন্ট'), true);
      expect(report.contains('ধানমন্ডি আবাসিক ভবন'), true);
      expect(report.contains('মো: রফিকুল ইসলাম'), true);
      expect(report.contains('মোট চুক্তি/বাজেট: ৳ 500000.0'), true);
      expect(report.contains('বর্তমান ক্লায়েন্ট বাকি: ৳ 300000.0'), true);
    });
  });
}
