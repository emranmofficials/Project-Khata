import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client.dart';
import '../../data/supabase_attendance_repository.dart';
import '../../domain/attendance_repository.dart';
import '../../domain/models/attendance_record_model.dart';
import '../../domain/models/daily_entry_model.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseAttendanceRepository(client);
});

// নির্দিষ্ট প্রজেক্টের এন্ট্রি তালিকা
final projectDailyEntriesProvider = FutureProvider.family<List<DailyEntryModel>, String>((ref, projectId) async {
  final repository = ref.watch(attendanceRepositoryProvider);
  return repository.getDailyEntries(projectId: projectId);
});

// এন্ট্রি ডিটেইলস
final dailyEntryDetailsProvider = FutureProvider.family<DailyEntryModel, String>((ref, entryId) async {
  final repository = ref.watch(attendanceRepositoryProvider);
  return repository.getEntryDetails(entryId);
});

// এন্ট্রির কর্মীবৃন্দের হাজিরা তালিকা
final entryAttendanceListProvider = FutureProvider.family<List<AttendanceRecordModel>, String>((ref, entryId) async {
  final repository = ref.watch(attendanceRepositoryProvider);
  return repository.getEntryAttendance(entryId);
});

// ঠিকাদারের অনুমোদনের অপেক্ষমাণ হাজিরা তালিকা (সাইটের বাইরে / ব্যাকডেটেড)
final pendingAttendanceApprovalsProvider = FutureProvider<List<AttendanceRecordModel>>((ref) async {
  final repository = ref.watch(attendanceRepositoryProvider);
  return repository.getPendingApprovals();
});

// হস্তান্তর প্রয়োজন এন্ট্রির তালিকা
final handoverEntriesProvider = FutureProvider<List<DailyEntryModel>>((ref) async {
  final repository = ref.watch(attendanceRepositoryProvider);
  return repository.getHandoverRequiredEntries();
});

// হাজিরা অ্যাকশন নোটিফায়ার
class AttendanceActionNotifier extends StateNotifier<AsyncValue<void>> {
  final AttendanceRepository _repository;
  final Ref _ref;

  AttendanceActionNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<Map<String, dynamic>> openDailyEntry({
    required String projectId,
    required DateTime entryDate,
    String? backdateReason,
  }) async {
    state = const AsyncValue.loading();
    try {
      final res = await _repository.openDailyEntry(
        projectId: projectId,
        entryDate: entryDate,
        backdateReason: backdateReason,
      );
      state = const AsyncValue.data(null);
      _ref.invalidate(projectDailyEntriesProvider(projectId));
      return res;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> submitDailyEntry(String entryId, String projectId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.submitDailyEntry(entryId);
      state = const AsyncValue.data(null);
      _ref.invalidate(dailyEntryDetailsProvider(entryId));
      _ref.invalidate(projectDailyEntriesProvider(projectId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> approveDailyEntry(String entryId, String projectId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.approveDailyEntry(entryId);
      state = const AsyncValue.data(null);
      _ref.invalidate(dailyEntryDetailsProvider(entryId));
      _ref.invalidate(projectDailyEntriesProvider(projectId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> markAttendance({
    required String entryId,
    required String workerId,
    required String status,
    double overtimeHours = 0.0,
    double? lat,
    double? lng,
    double? accuracy,
    String? backdateReason,
  }) async {
    state = const AsyncValue.loading();
    try {
      final res = await _repository.markAttendance(
        entryId: entryId,
        workerId: workerId,
        status: status,
        overtimeHours: overtimeHours,
        lat: lat,
        lng: lng,
        accuracy: accuracy,
        backdateReason: backdateReason,
      );
      state = const AsyncValue.data(null);
      _ref.invalidate(entryAttendanceListProvider(entryId));
      return res;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> decideApproval({
    required String attendanceId,
    required bool approved,
    String? rejectionReason,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.decideAttendanceApproval(
        attendanceId: attendanceId,
        approved: approved,
        rejectionReason: rejectionReason,
      );
      state = const AsyncValue.data(null);
      _ref.invalidate(pendingAttendanceApprovalsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> resolveHandover({
    required String entryId,
    required String action,
    String? newSupervisorId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.resolveHandoverEntry(
        entryId: entryId,
        action: action,
        newSupervisorId: newSupervisorId,
      );
      state = const AsyncValue.data(null);
      _ref.invalidate(handoverEntriesProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final attendanceActionProvider = StateNotifierProvider<AttendanceActionNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(attendanceRepositoryProvider);
  return AttendanceActionNotifier(repository, ref);
});
