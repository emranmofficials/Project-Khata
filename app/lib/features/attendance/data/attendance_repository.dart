import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/attendance_record.dart';
import '../domain/models/daily_entry.dart';
import '../../../auth/domain/models/app_user.dart';

class AttendanceRepository {
  final SupabaseClient _supabase;

  AttendanceRepository(this._supabase);

  // ১. প্রজেক্টের দৈনিক এন্ট্রি তালিকা
  Future<List<DailyEntry>> getDailyEntries(String projectId) async {
    final response = await _supabase
        .from('daily_entries')
        .select('*, projects(name), profiles(name)')
        .eq('project_id', projectId)
        .order('entry_date', ascending: false);

    return (response as List<dynamic>)
        .map((e) => DailyEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ২. নির্দিষ্ট এন্ট্রির হাজিরা রেকর্ডসমূহ
  Future<List<AttendanceRecord>> getAttendanceForEntry(String entryId) async {
    final response = await _supabase
        .from('attendance_records')
        .select('*, profiles(name, mobile, designations(title, daily_wage))')
        .eq('daily_entry_id', entryId)
        .order('created_at', ascending: true);

    return (response as List<dynamic>)
        .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ৩. প্রতিষ্ঠানের সকল শ্রমিক তালিকা (টিম গঠনের জন্য)
  Future<List<AppUser>> getOrganizationWorkers(String organizationId) async {
    final response = await _supabase
        .from('profiles')
        .select('*, designations(title, daily_wage)')
        .eq('organization_id', organizationId)
        .eq('role', 'worker')
        .order('name', ascending: true);

    return (response as List<dynamic>)
        .map((e) => AppUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ৪. দৈনিক এন্ট্রি ও হাজিরা সেভ করা (সার্ভারে)
  Future<DailyEntry> submitDailyEntry({
    required DailyEntry entry,
    required List<AttendanceRecord> records,
  }) async {
    // এন্ট্রি ইনসার্ট বা আপডেট
    final entryData = entry.toJson();
    if (entry.id.isEmpty) {
      entryData.remove('id');
    }

    final entryResponse = await _supabase
        .from('daily_entries')
        .upsert(entryData)
        .select()
        .single();

    final savedEntry = DailyEntry.fromJson(entryResponse);

    // হাজিরা রেকর্ড ইনসার্ট/আপডেট
    if (records.isNotEmpty) {
      final recordsData = records.map((r) {
        final map = r.toJson();
        map['daily_entry_id'] = savedEntry.id;
        if (r.id.isEmpty) {
          map.remove('id');
        }
        return map;
      }).toList();

      await _supabase.from('attendance_records').upsert(
        recordsData,
        onConflict: 'worker_id, entry_date',
      );
    }

    // ড্রাফট সফলভাবে সাবমিট হলে লোকাল ড্রাফট মুছে ফেলা
    await clearLocalDraft(entry.projectId);

    return savedEntry;
  }

  // ৫. ড্রাফট লোকাল স্টোরেজে সংরক্ষণ (অফলাইন সাপোর্ট)
  Future<void> saveLocalDraft({
    required String projectId,
    required DailyEntry entry,
    required List<AttendanceRecord> records,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final draftKey = 'draft_entry_$projectId';
    final payload = {
      'entry': entry.toJson(),
      'records': records.map((r) => r.toJson()).toList(),
      'saved_at': DateTime.now().toIso8601String(),
    };
    await prefs.setString(draftKey, jsonEncode(payload));
  }

  // ৬. লোকাল ড্রাফট পড়া
  Future<Map<String, dynamic>?> loadLocalDraft(String projectId) async {
    final prefs = await SharedPreferences.getInstance();
    final draftKey = 'draft_entry_$projectId';
    final jsonStr = prefs.getString(draftKey);
    if (jsonStr == null) return null;

    try {
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ৭. লোকাল ড্রাফট মোছা
  Future<void> clearLocalDraft(String projectId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('draft_entry_$projectId');
  }

  // ৮. শ্রমিকের নিজস্ব হাজিরা ইতিহাস দেখা (Rule 114)
  Future<List<AttendanceRecord>> getWorkerAttendanceHistory(String workerId) async {
    final response = await _supabase
        .from('attendance_records')
        .select('*, projects(name), profiles(name, designations(title, daily_wage))')
        .eq('worker_id', workerId)
        .order('entry_date', ascending: false);

    return (response as List<dynamic>)
        .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(Supabase.instance.client);
});
