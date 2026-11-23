import 'models/attendance_record_model.dart';
import 'models/daily_entry_model.dart';

/// দৈনিক এন্ট্রি, দল গঠন ও হাজিরা ব্যবস্থাপনা রিপোজিটরি
abstract class AttendanceRepository {
  /// দৈনিক এন্ট্রি তালিকা
  Future<List<DailyEntryModel>> getDailyEntries({
    String? projectId,
    DateTime? date,
    String? status,
  });

  /// নির্দিষ্ট এন্ট্রি বিবরণ
  Future<DailyEntryModel> getEntryDetails(String entryId);

  /// নতুন দৈনিক এন্ট্রি খোলা
  Future<Map<String, dynamic>> openDailyEntry({
    required String projectId,
    required DateTime entryDate,
    String? backdateReason,
  });

  /// এন্ট্রি জমা দেওয়া (সুপারভাইজার)
  Future<void> submitDailyEntry(String entryId);

  /// এন্ট্রি অনুমোদন ও লক করা (ঠিকাদার)
  Future<void> approveDailyEntry(String entryId);

  /// এন্ট্রির অন্তর্ভুক্ত কর্মীদের হাজিরা তালিকা
  Future<List<AttendanceRecordModel>> getEntryAttendance(String entryId);

  /// হাজিরা প্রদান (জিও-ফেন্সিং ও ব্যাকডেট যাচাই সহ)
  Future<Map<String, dynamic>> markAttendance({
    required String entryId,
    required String workerId,
    required String status,
    double overtimeHours = 0.0,
    double? lat,
    double? lng,
    double? accuracy,
    String? backdateReason,
  });

  /// ঠিকাদারের অনুমোদনের অপেক্ষায় থাকা হাজিরা (সাইটের বাইরে বা ব্যাকডেটেড)
  Future<List<AttendanceRecordModel>> getPendingApprovals();

  /// হাজিরার অনুমোদন বা প্রত্যাখ্যান সিদ্ধান্ত
  Future<void> decideAttendanceApproval({
    required String attendanceId,
    required bool approved,
    String? rejectionReason,
  });

  /// হস্তান্তর প্রয়োজন এন্ট্রির তালিকা
  Future<List<DailyEntryModel>> getHandoverRequiredEntries();

  /// হস্তান্তর প্রয়োজন এন্ট্রি সমাধান
  Future<void> resolveHandoverEntry({
    required String entryId,
    required String action, // 'close' অথবা 'reassign'
    String? newSupervisorId,
  });
}
