import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/attendance/data/attendance_repository.dart';
import '../../features/attendance/domain/models/attendance_record.dart';
import '../../features/attendance/domain/models/daily_entry.dart';

/// অফলাইন কিউতে থাকা এন্ট্রির মডেল
class QueuedSyncItem {
  final String id;
  final String type; // 'daily_entry'
  final String projectId;
  final String projectName;
  final DateTime entryDate;
  final Map<String, dynamic> entryData;
  final List<Map<String, dynamic>> recordsData;
  final DateTime queuedAt;
  final int retryCount;
  final String? lastError;

  const QueuedSyncItem({
    required this.id,
    this.type = 'daily_entry',
    required this.projectId,
    required this.projectName,
    required this.entryDate,
    required this.entryData,
    required this.recordsData,
    required this.queuedAt,
    this.retryCount = 0,
    this.lastError,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'projectId': projectId,
      'projectName': projectName,
      'entryDate': entryDate.toIso8601String(),
      'entryData': entryData,
      'recordsData': recordsData,
      'queuedAt': queuedAt.toIso8601String(),
      'retryCount': retryCount,
      'lastError': lastError,
    };
  }

  factory QueuedSyncItem.fromJson(Map<String, dynamic> json) {
    return QueuedSyncItem(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'daily_entry',
      projectId: json['projectId'] as String? ?? '',
      projectName: json['projectName'] as String? ?? '',
      entryDate: DateTime.tryParse(json['entryDate'] as String? ?? '') ?? DateTime.now(),
      entryData: (json['entryData'] as Map<String, dynamic>?) ?? {},
      recordsData: (json['recordsData'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      queuedAt: DateTime.tryParse(json['queuedAt'] as String? ?? '') ?? DateTime.now(),
      retryCount: json['retryCount'] as int? ?? 0,
      lastError: json['lastError'] as String?,
    );
  }

  QueuedSyncItem copyWith({
    int? retryCount,
    String? lastError,
  }) {
    return QueuedSyncItem(
      id: id,
      type: type,
      projectId: projectId,
      projectName: projectName,
      entryDate: entryDate,
      entryData: entryData,
      recordsData: recordsData,
      queuedAt: queuedAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
    );
  }
}

/// সিঙ্ক ফলাফল সামারি
class SyncResult {
  final int totalAttempted;
  final int successCount;
  final int failedCount;
  final String? errorMessage;

  const SyncResult({
    required this.totalAttempted,
    required this.successCount,
    required this.failedCount,
    this.errorMessage,
  });

  bool get isAllSuccess => failedCount == 0 && totalAttempted > 0;
  bool get isEmpty => totalAttempted == 0;
}

/// অফলাইন সিঙ্ক ম্যানেজার
class OfflineSyncManager {
  static const String _queueKey = 'offline_sync_queue';
  final SharedPreferences? _injectedPrefs;

  OfflineSyncManager({SharedPreferences? prefs}) : _injectedPrefs = prefs;

  Future<SharedPreferences> _getPrefs() async {
    return _injectedPrefs ?? await SharedPreferences.getInstance();
  }

  /// কিউতে থাকা সমস্ত আইটেম আনা
  Future<List<QueuedSyncItem>> getQueue() async {
    final prefs = await _getPrefs();
    final rawList = prefs.getStringList(_queueKey);
    if (rawList == null || rawList.isEmpty) return [];

    final result = <QueuedSyncItem>[];
    for (final raw in rawList) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        result.add(QueuedSyncItem.fromJson(map));
      } catch (_) {
        // ত্রুটিযুক্ত আইটেম বাদ
      }
    }
    return result;
  }

  /// নতুন দৈনিক এন্ট্রি অফলাইন কিউতে যোগ করা
  Future<QueuedSyncItem> enqueueDailyEntry({
    required DailyEntry entry,
    required List<AttendanceRecord> records,
    String? projectName,
  }) async {
    final prefs = await _getPrefs();
    final queue = await getQueue();

    final item = QueuedSyncItem(
      id: 'sync_${DateTime.now().millisecondsSinceEpoch}_${entry.projectId}',
      type: 'daily_entry',
      projectId: entry.projectId,
      projectName: projectName ?? entry.projectName ?? 'প্রজেক্ট',
      entryDate: entry.entryDate,
      entryData: entry.toJson(),
      recordsData: records.map((r) => r.toJson()).toList(),
      queuedAt: DateTime.now(),
      retryCount: 0,
    );

    // পূর্বে একই প্রোজেক্ট ও তারিখের কোনো পেন্ডিং আইটেম থাকলে আপডেট
    final existingIdx = queue.indexWhere(
      (q) => q.projectId == item.projectId &&
          q.entryDate.year == item.entryDate.year &&
          q.entryDate.month == item.entryDate.month &&
          q.entryDate.day == item.entryDate.day,
    );

    if (existingIdx >= 0) {
      queue[existingIdx] = item;
    } else {
      queue.add(item);
    }

    final rawList = queue.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_queueKey, rawList);
    return item;
  }

  /// নির্দিষ্ট আইটেম মুছে ফেলা
  Future<void> removeQueueItem(String id) async {
    final prefs = await _getPrefs();
    final queue = await getQueue();
    queue.removeWhere((item) => item.id == id);
    final rawList = queue.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_queueKey, rawList);
  }

  /// কিউ সম্পূর্ণ মুছে ফেলা
  Future<void> clearQueue() async {
    final prefs = await _getPrefs();
    await prefs.remove(_queueKey);
  }

  /// কিউতে থাকা সমস্ত আইটেম সার্ভারে সিঙ্ক করা
  Future<SyncResult> syncQueue(AttendanceRepository repository) async {
    final queue = await getQueue();
    if (queue.isEmpty) {
      return const SyncResult(totalAttempted: 0, successCount: 0, failedCount: 0);
    }

    int success = 0;
    int failed = 0;
    final remainingQueue = <QueuedSyncItem>[];

    for (final item in queue) {
      try {
        final entry = DailyEntry.fromJson(item.entryData);
        final records = item.recordsData
            .map((r) => AttendanceRecord.fromJson(r))
            .toList();

        await repository.submitDailyEntry(
          entry: entry,
          records: records,
        );
        success++;
      } catch (e) {
        failed++;
        remainingQueue.add(
          item.copyWith(
            retryCount: item.retryCount + 1,
            lastError: e.toString(),
          ),
        );
      }
    }

    // বাকি থাকা ব্যর্থ আইটেম সংরক্ষণ
    final prefs = await _getPrefs();
    if (remainingQueue.isEmpty) {
      await prefs.remove(_queueKey);
    } else {
      final rawList = remainingQueue.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList(_queueKey, rawList);
    }

    return SyncResult(
      totalAttempted: queue.length,
      successCount: success,
      failedCount: failed,
    );
  }
}

/// পেন্ডিং সিঙ্ক স্টেট নোটিফায়ার
class PendingSyncNotifier extends StateNotifier<List<QueuedSyncItem>> {
  final OfflineSyncManager _manager;

  PendingSyncNotifier(this._manager) : super([]) {
    refresh();
  }

  Future<void> refresh() async {
    final list = await _manager.getQueue();
    state = list;
  }

  Future<QueuedSyncItem> enqueueDailyEntry({
    required DailyEntry entry,
    required List<AttendanceRecord> records,
    String? projectName,
  }) async {
    final item = await _manager.enqueueDailyEntry(
      entry: entry,
      records: records,
      projectName: projectName,
    );
    await refresh();
    return item;
  }

  Future<SyncResult> syncAll(AttendanceRepository repository) async {
    final result = await _manager.syncQueue(repository);
    await refresh();
    return result;
  }

  Future<void> removeItem(String id) async {
    await _manager.removeQueueItem(id);
    await refresh();
  }

  Future<void> clear() async {
    await _manager.clearQueue();
    await refresh();
  }
}

final offlineSyncManagerProvider = Provider<OfflineSyncManager>((ref) {
  return OfflineSyncManager();
});

final pendingSyncNotifierProvider =
    StateNotifierProvider<PendingSyncNotifier, List<QueuedSyncItem>>((ref) {
  final manager = ref.watch(offlineSyncManagerProvider);
  return PendingSyncNotifier(manager);
});

final pendingSyncCountProvider = Provider<int>((ref) {
  return ref.watch(pendingSyncNotifierProvider).length;
});

final isSyncingProvider = StateProvider<bool>((ref) => false);
