import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_khata/features/offline/domain/offline_sync_queue.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('OfflineSyncQueue Tests', () {
    test('Enqueue attendance adds items to shared preferences queue', () async {
      expect(await OfflineSyncQueue.getPendingCount(), 0);

      final payload1 = {
        'entry_id': 'ent-101',
        'worker_id': 'wrk-001',
        'status': 'present',
        'overtime_hours': 1.5,
        'lat': 23.7330,
        'lng': 90.4172,
        'accuracy': 12.0,
      };

      await OfflineSyncQueue.enqueueAttendance(payload1);
      expect(await OfflineSyncQueue.getPendingCount(), 1);

      final payload2 = {
        'entry_id': 'ent-101',
        'worker_id': 'wrk-002',
        'status': 'half',
        'overtime_hours': 0.0,
      };

      await OfflineSyncQueue.enqueueAttendance(payload2);
      expect(await OfflineSyncQueue.getPendingCount(), 2);
    });
  });
}
