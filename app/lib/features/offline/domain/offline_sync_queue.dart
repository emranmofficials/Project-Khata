import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../attendance/domain/attendance_repository.dart';

/// PRD সেকশন ১০.৪ অনুযায়ী অফলাইন সিঙ্ক কিউ (Offline Queue Manager)
class OfflineSyncQueue {
  static const String _queueKey = 'project_khata_offline_attendance_queue';

  /// অফলাইনে থাকা অবস্থায় হাজিরা কিউতে যুক্ত করা
  static Future<void> enqueueAttendance(Map<String, dynamic> attendancePayload) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> queue = prefs.getStringList(_queueKey) ?? [];
    queue.add(jsonEncode(attendancePayload));
    await prefs.setStringList(_queueKey, queue);
  }

  /// অপেক্ষমাণ আইটেমের সংখ্যা
  static Future<int> getPendingCount() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> queue = prefs.getStringList(_queueKey) ?? [];
    return queue.length;
  }

  /// নেটওয়ার্ক ফিরলে কিউ থেকে স্বয়ংক্রিয় সিঙ্ক সম্পাদন
  static Future<int> syncQueue(AttendanceRepository repository) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> queue = prefs.getStringList(_queueKey) ?? [];
    if (queue.isEmpty) return 0;

    List<String> remainingQueue = [];
    int syncedCount = 0;

    for (String itemStr in queue) {
      try {
        final payload = jsonDecode(itemStr) as Map<String, dynamic>;
        await repository.markAttendance(
          entryId: payload['entry_id'],
          workerId: payload['worker_id'],
          status: payload['status'],
          overtimeHours: (payload['overtime_hours'] as num?)?.toDouble() ?? 0.0,
          lat: (payload['lat'] as num?)?.toDouble(),
          lng: (payload['lng'] as num?)?.toDouble(),
          accuracy: (payload['accuracy'] as num?)?.toDouble(),
          backdateReason: payload['backdate_reason'],
        );
        syncedCount++;
      } catch (e) {
        // কোনো আইটেম সিঙ্ক না হলে সেটি কিউতে রেখে দেওয়া হবে
        remainingQueue.add(itemStr);
      }
    }

    await prefs.setStringList(_queueKey, remainingQueue);
    return syncedCount;
  }
}

final pendingOfflineCountProvider = FutureProvider<int>((ref) async {
  return OfflineSyncQueue.getPendingCount();
});
