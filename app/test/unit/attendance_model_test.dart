import 'package:flutter_test/flutter_test.dart';
import 'package:project_khata/features/attendance/domain/models/attendance_record.dart';
import 'package:project_khata/features/attendance/domain/models/daily_entry.dart';

void main() {
  group('DailyEntry Model Tests', () {
    test('DailyEntry should correctly parse from JSON', () {
      final json = {
        'id': 'entry-123',
        'organization_id': 'org-123',
        'project_id': 'proj-123',
        'supervisor_id': 'sup-123',
        'entry_date': '2026-10-29',
        'work_description': '২য় তলার ছাদ ঢালাই সম্পন্ন',
        'status': 'submitted',
        'notes': 'বৃষ্টির কারণে কাজ ১ ঘণ্টা বন্ধ ছিল',
        'photos': ['https://example.com/photo1.jpg'],
        'created_at': '2026-10-29T10:00:00Z',
        'updated_at': '2026-10-29T10:00:00Z',
      };

      final entry = DailyEntry.fromJson(json);

      expect(entry.id, 'entry-123');
      expect(entry.projectId, 'proj-123');
      expect(entry.status, EntryStatus.submitted);
      expect(entry.status.bengaliLabel, 'জমা হয়েছে');
      expect(entry.workDescription, '২য় তলার ছাদ ঢালাই সম্পন্ন');
      expect(entry.photos.length, 1);
    });

    test('DailyEntry status defaults to draft if unknown or null', () {
      expect(EntryStatus.fromString(null), EntryStatus.draft);
      expect(EntryStatus.fromString('invalid_status'), EntryStatus.draft);
      expect(EntryStatus.fromString('approved'), EntryStatus.approved);
      expect(EntryStatus.fromString('handover_required'), EntryStatus.handoverRequired);
    });

    test('DailyEntry toJson formats entry_date as YYYY-MM-DD', () {
      final entry = DailyEntry(
        id: 'entry-1',
        organizationId: 'org-1',
        projectId: 'proj-1',
        supervisorId: 'sup-1',
        entryDate: DateTime(2026, 10, 29),
        workDescription: 'কাজের বিবরণ',
        status: EntryStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final json = entry.toJson();
      expect(json['entry_date'], '2026-10-29');
      expect(json['status'], 'draft');
      expect(json['work_description'], 'কাজের বিবরণ');
    });
  });

  group('AttendanceRecord & Wage Rules Tests', () {
    test('AttendanceStatus wageMultiplier complies with PRD business rules', () {
      // পূর্ণদিবস = ১.০ গুণ
      expect(AttendanceStatus.fullDay.wageMultiplier, 1.0);
      expect(AttendanceStatus.fullDay.bengaliLabel, 'পূর্ণদিবস');

      // অর্ধদিবস = ০.৫ গুণ
      expect(AttendanceStatus.halfDay.wageMultiplier, 0.5);
      expect(AttendanceStatus.halfDay.bengaliLabel, 'অর্ধদিবস');

      // অনুপস্থিত = ০.০ গুণ
      expect(AttendanceStatus.absent.wageMultiplier, 0.0);
      expect(AttendanceStatus.absent.bengaliLabel, 'অনুপস্থিত');
    });

    test('AttendanceRecord correctly parses from JSON with joined profile & designation', () {
      final json = {
        'id': 'att-123',
        'organization_id': 'org-1',
        'daily_entry_id': 'entry-1',
        'project_id': 'proj-1',
        'worker_id': 'worker-1',
        'entry_date': '2026-10-29',
        'status': 'full_day',
        'ot_hours': 2.5,
        'supervisor_lat': 23.8103,
        'supervisor_lng': 90.4125,
        'site_distance_meters': 45.5,
        'location_status': 'inside_site',
        'is_approved': true,
        'created_at': '2026-10-29T08:00:00Z',
        'updated_at': '2026-10-29T08:00:00Z',
        'profiles': {
          'name': 'আব্দুল করিম',
          'mobile': '01711223344',
          'designations': {
            'title': 'রাজমিস্ত্রি',
            'daily_wage': 800.0,
          }
        }
      };

      final record = AttendanceRecord.fromJson(json);

      expect(record.id, 'att-123');
      expect(record.status, AttendanceStatus.fullDay);
      expect(record.otHours, 2.5);
      expect(record.locationStatus, LocationStatus.insideSite);
      expect(record.siteDistanceMeters, 45.5);
      expect(record.workerName, 'আব্দুল করিম');
      expect(record.workerMobile, '01711223344');
      expect(record.designationName, 'রাজমিস্ত্রি');
      expect(record.dailyWage, 800.0);
    });

    test('LocationStatus handles inside_site, outside_site, and unavailable', () {
      expect(LocationStatus.fromString('inside_site'), LocationStatus.insideSite);
      expect(LocationStatus.fromString('outside_site'), LocationStatus.outsideSite);
      expect(LocationStatus.fromString('location_unavailable'), LocationStatus.locationUnavailable);
      expect(LocationStatus.fromString('unknown'), LocationStatus.insideSite);
    });

    test('Calculated wage with OT hours', () {
      final dailyWage = 800.0;
      final otRatePerHour = dailyWage / 8.0; // ১০০ টাকা প্রতি ঘণ্টা
      final otHours = 3.0;

      // পূর্ণদিবস + ৩ ঘণ্টা ওভারটাইম
      final fullDayWage = (dailyWage * AttendanceStatus.fullDay.wageMultiplier) + (otHours * otRatePerHour);
      expect(fullDayWage, 1100.0);

      // অর্ধদিবস + ০ ঘণ্টা ওভারটাইম
      final halfDayWage = (dailyWage * AttendanceStatus.halfDay.wageMultiplier);
      expect(halfDayWage, 400.0);

      // অনুপস্থিত
      final absentWage = (dailyWage * AttendanceStatus.absent.wageMultiplier);
      expect(absentWage, 0.0);
    });
  });
}
