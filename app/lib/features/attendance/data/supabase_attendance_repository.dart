import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/attendance_repository.dart';
import '../domain/models/attendance_record_model.dart';
import '../domain/models/daily_entry_model.dart';

/// Supabase বাস্তবায়িত AttendanceRepository
class SupabaseAttendanceRepository implements AttendanceRepository {
  final SupabaseClient _client;

  SupabaseAttendanceRepository(this._client);

  @override
  Future<List<DailyEntryModel>> getDailyEntries({
    String? projectId,
    DateTime? date,
    String? status,
  }) async {
    var query = _client.from('daily_entries').select('''
      *,
      projects:project_id(name),
      profiles:opened_by(name)
    ''');

    if (projectId != null && projectId.isNotEmpty) {
      query = query.eq('project_id', projectId);
    }

    if (date != null) {
      final dateStr = date.toIso8601String().substring(0, 10);
      query = query.eq('entry_date', dateStr);
    }

    if (status != null && status.isNotEmpty && status != 'all') {
      query = query.eq('status', status);
    }

    final response = await query.order('entry_date', ascending: false);
    final list = response as List<dynamic>;

    return list.map((item) => DailyEntryModel.fromJson(Map<String, dynamic>.from(item))).toList();
  }

  @override
  Future<DailyEntryModel> getEntryDetails(String entryId) async {
    final response = await _client.from('daily_entries').select('''
      *,
      projects:project_id(name),
      profiles:opened_by(name)
    ''').eq('id', entryId).single();

    return DailyEntryModel.fromJson(Map<String, dynamic>.from(response));
  }

  @override
  Future<Map<String, dynamic>> openDailyEntry({
    required String projectId,
    required DateTime entryDate,
    String? backdateReason,
  }) async {
    final result = await _client.rpc('open_daily_entry', params: {
      'p_project_id': projectId,
      'p_entry_date': entryDate.toIso8601String().substring(0, 10),
      'p_backdate_reason': backdateReason,
    });

    if (result == null || result['success'] != true) {
      throw Exception('দৈনিক এন্ট্রি খুলতে ব্যর্থ হয়েছে।');
    }

    return Map<String, dynamic>.from(result);
  }

  @override
  Future<void> submitDailyEntry(String entryId) async {
    await _client.rpc('submit_daily_entry', params: {
      'p_entry_id': entryId,
    });
  }

  @override
  Future<void> approveDailyEntry(String entryId) async {
    await _client.rpc('approve_daily_entry', params: {
      'p_entry_id': entryId,
    });
  }

  @override
  Future<List<AttendanceRecordModel>> getEntryAttendance(String entryId) async {
    final response = await _client.from('attendance').select('''
      *,
      profiles:worker_id(
        name,
        mobile,
        designations:designation_id(name, daily_rate, overtime_rate_per_hour)
      )
    ''').eq('entry_id', entryId).order('marked_at');

    final list = response as List<dynamic>;
    return list.map((item) => AttendanceRecordModel.fromJson(Map<String, dynamic>.from(item))).toList();
  }

  @override
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
    final result = await _client.rpc('mark_attendance', params: {
      'p_entry_id': entryId,
      'p_worker_id': workerId,
      'p_status': status,
      'p_overtime_hours': overtimeHours,
      'p_lat': lat,
      'p_lng': lng,
      'p_accuracy': accuracy,
      'p_backdate_reason': backdateReason,
    });

    if (result == null || result['success'] != true) {
      throw Exception('হাজিরা সংরক্ষণে ত্রুটি হয়েছে।');
    }

    return Map<String, dynamic>.from(result);
  }

  @override
  Future<List<AttendanceRecordModel>> getPendingApprovals() async {
    final response = await _client.from('attendance').select('''
      *,
      profiles:worker_id(
        name,
        mobile,
        designations:designation_id(name, daily_rate, overtime_rate_per_hour)
      )
    ''').eq('approval_status', 'pending').order('entry_date', ascending: false);

    final list = response as List<dynamic>;
    return list.map((item) => AttendanceRecordModel.fromJson(Map<String, dynamic>.from(item))).toList();
  }

  @override
  Future<void> decideAttendanceApproval({
    required String attendanceId,
    required bool approved,
    String? rejectionReason,
  }) async {
    await _client.rpc('decide_attendance_approval', params: {
      'p_attendance_id': attendanceId,
      'p_approved': approved,
      'p_rejection_reason': rejectionReason,
    });
  }

  @override
  Future<List<DailyEntryModel>> getHandoverRequiredEntries() async {
    final response = await _client.from('daily_entries').select('''
      *,
      projects:project_id(name),
      profiles:opened_by(name)
    ''').eq('status', 'handover_required').order('entry_date', ascending: false);

    final list = response as List<dynamic>;
    return list.map((item) => DailyEntryModel.fromJson(Map<String, dynamic>.from(item))).toList();
  }

  @override
  Future<void> resolveHandoverEntry({
    required String entryId,
    required String action,
    String? newSupervisorId,
  }) async {
    await _client.rpc('resolve_handover_entry', params: {
      'p_entry_id': entryId,
      'p_action': action,
      'p_new_supervisor_id': newSupervisorId,
    });
  }
}
