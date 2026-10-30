import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_khata/core/network/offline_sync_manager.dart';
import 'package:project_khata/core/utils/bengali_formatter.dart';
import 'package:project_khata/features/attendance/domain/models/attendance_record.dart';
import 'package:project_khata/features/attendance/domain/models/daily_entry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('QueuedSyncItem Model Tests', () {
    test('QueuedSyncItem should serialize to and deserialize from JSON', () {
      final now = DateTime(2026, 10, 30, 10, 30);
      final item = QueuedSyncItem(
        id: 'sync_123',
        type: 'daily_entry',
        projectId: 'proj_001',
        projectName: 'ধানমন্ডি রেসিডেন্সিয়াল ভবন',
        entryDate: DateTime(2026, 10, 30),
        entryData: {
          'project_id': 'proj_001',
          'work_description': '৩য় তলার বিম ঢালাই সম্পন্ন',
          'status': 'submitted',
        },
        recordsData: [
          {
            'worker_id': 'w1',
            'status': 'full_day',
            'ot_hours': 2.0,
          },
          {
            'worker_id': 'w2',
            'status': 'half_day',
            'ot_hours': 0.0,
          },
        ],
        queuedAt: now,
        retryCount: 1,
        lastError: 'SocketException: Connection timed out',
      );

      final json = item.toJson();
      expect(json['id'], 'sync_123');
      expect(json['type'], 'daily_entry');
      expect(json['projectId'], 'proj_001');
      expect(json['projectName'], 'ধানমন্ডি রেসিডেন্সিয়াল ভবন');
      expect(json['retryCount'], 1);
      expect(json['lastError'], contains('Connection timed out'));

      final parsed = QueuedSyncItem.fromJson(json);
      expect(parsed.id, item.id);
      expect(parsed.projectId, item.projectId);
      expect(parsed.projectName, item.projectName);
      expect(parsed.entryData['work_description'], '৩য় তলার বিম ঢালাই সম্পন্ন');
      expect(parsed.recordsData.length, 2);
      expect(parsed.retryCount, 1);
      expect(parsed.lastError, 'SocketException: Connection timed out');
    });

    test('QueuedSyncItem copyWith updates retry count and error message', () {
      final item = QueuedSyncItem(
        id: 'sync_1',
        projectId: 'p1',
        projectName: 'প্রজেক্ট ১',
        entryDate: DateTime(2026, 10, 30),
        entryData: {},
        recordsData: [],
        queuedAt: DateTime.now(),
        retryCount: 0,
      );

      final updated = item.copyWith(
        retryCount: item.retryCount + 1,
        lastError: 'Network unreachable',
      );

      expect(updated.retryCount, 1);
      expect(updated.lastError, 'Network unreachable');
      expect(updated.id, item.id);
      expect(updated.projectName, item.projectName);
    });
  });

  group('SyncResult Tests', () {
    test('SyncResult properties evaluate correctly', () {
      const empty = SyncResult(totalAttempted: 0, successCount: 0, failedCount: 0);
      expect(empty.isEmpty, isTrue);
      expect(empty.isAllSuccess, isFalse);

      const allSuccess = SyncResult(totalAttempted: 3, successCount: 3, failedCount: 0);
      expect(allSuccess.isEmpty, isFalse);
      expect(allSuccess.isAllSuccess, isTrue);

      const partial = SyncResult(totalAttempted: 3, successCount: 2, failedCount: 1);
      expect(partial.isEmpty, isFalse);
      expect(partial.isAllSuccess, isFalse);
    });
  });

  group('OfflineSyncManager Storage Tests', () {
    test('Enqueue, list, and clear offline daily entries', () async {
      final manager = OfflineSyncManager();

      // শুরুতে কিউ খালি
      var queue = await manager.getQueue();
      expect(queue, isEmpty);

      final entry1 = DailyEntry(
        id: '',
        organizationId: 'org_1',
        projectId: 'proj_alpha',
        supervisorId: 'sup_1',
        entryDate: DateTime(2026, 10, 30),
        workDescription: 'গ্রাউন্ড ফ্লোর কলাম প্লাস্টার',
        status: EntryStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final records1 = [
        AttendanceRecord(
          id: '',
          organizationId: 'org_1',
          dailyEntryId: '',
          projectId: 'proj_alpha',
          workerId: 'w_1',
          entryDate: DateTime(2026, 10, 30),
          status: AttendanceStatus.fullDay,
          otHours: 1.5,
          locationStatus: LocationStatus.insideSite,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      // ১. আইটেম কিউতে যোগ করা
      final queuedItem = await manager.enqueueDailyEntry(
        entry: entry1,
        records: records1,
        projectName: 'আলফা টাওয়ার',
      );

      expect(queuedItem.id, isNotEmpty);
      expect(queuedItem.projectName, 'আলফা টাওয়ার');

      queue = await manager.getQueue();
      expect(queue.length, 1);
      expect(queue.first.projectName, 'আলফা টাওয়ার');
      expect(queue.first.recordsData.length, 1);

      // ২. একই প্রজেক্ট ও তারিখের নতুন এন্ট্রি আপডেট হবে, ডুপ্লিকেট হবে না
      final updatedEntry = entry1.copyWith(workDescription: 'গ্রাউন্ড ফ্লোর ঢালাই ও প্লাস্টার সম্পন্ন');
      await manager.enqueueDailyEntry(
        entry: updatedEntry,
        records: records1,
        projectName: 'আলফা টাওয়ার',
      );

      queue = await manager.getQueue();
      expect(queue.length, 1);
      expect(queue.first.entryData['work_description'], 'গ্রাউন্ড ফ্লোর ঢালাই ও প্লাস্টার সম্পন্ন');

      // ৩. অন্য প্রজেক্টের এন্ট্রি যোগ
      final entry2 = DailyEntry(
        id: '',
        organizationId: 'org_1',
        projectId: 'proj_beta',
        supervisorId: 'sup_1',
        entryDate: DateTime(2026, 10, 30),
        workDescription: 'বেসমেন্ট ড্রেনেজ লাইন কাজ',
        status: EntryStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await manager.enqueueDailyEntry(
        entry: entry2,
        records: [],
        projectName: 'বিটা প্লাজা',
      );

      queue = await manager.getQueue();
      expect(queue.length, 2);

      // ৪. একটি নির্দিষ্ট আইটেম মুছে ফেলা
      await manager.removeQueueItem(queue.first.id);
      queue = await manager.getQueue();
      expect(queue.length, 1);
      expect(queue.first.projectName, 'বিটা প্লাজা');

      // ৫. কিউ সম্পূর্ণ খালি করা
      await manager.clearQueue();
      queue = await manager.getQueue();
      expect(queue, isEmpty);
    });

    test('Bengali representation of offline sync notifications', () {
      final pendingCount = 5;
      final bnCount = BengaliFormatter.toBnNumber(pendingCount);
      expect(bnCount, '৫');

      final message = 'অফলাইনে $bnCountটি এন্ট্রি সিঙ্ক বাকি রয়েছে';
      expect(message, contains('৫টি'));
    });
  });
}
