import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../domain/models/worker_model.dart';
import '../domain/worker_repository.dart';

class SupabaseWorkerRepository implements WorkerRepository {
  final SupabaseClient _client;

  SupabaseWorkerRepository(this._client);

  @override
  Future<List<WorkerModel>> getWorkers({String? roleFilter, String? searchQuery}) async {
    var query = _client
        .from('profiles')
        .select('*, designations(*)')
        .inFilter('role', ['worker', 'supervisor']);

    if (roleFilter != null && roleFilter != 'all') {
      query = query.eq('role', roleFilter);
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final term = searchQuery.trim();
      query = query.or('name.ilike.%$term%,mobile.ilike.%$term%');
    }

    final data = await query.order('name');
    return (data as List<dynamic>)
        .map((e) => WorkerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getDesignations() async {
    final data = await _client
        .from('designations')
        .select('*')
        .order('name');
    return List<Map<String, dynamic>>.from(data as List<dynamic>);
  }

  @override
  Future<Map<String, dynamic>> addDesignation({
    required String name,
    required double dailyRate,
    double overtimeRatePerHour = 0.0,
  }) async {
    final orgId = await _getOrgId();
    final res = await _client.from('designations').insert({
      'organization_id': orgId,
      'name': name.trim(),
      'daily_rate': dailyRate,
      'overtime_rate_per_hour': overtimeRatePerHour,
    }).select().single();
    return res;
  }

  @override
  Future<WorkerModel> addWorker({
    required String name,
    required String mobile,
    required String role,
    String? designationId,
    String? email,
  }) async {
    final orgId = await _getOrgId();
    final workerId = const Uuid().v4();

    final res = await _client.from('profiles').insert({
      'id': workerId,
      'organization_id': orgId,
      'role': role,
      'name': name.trim(),
      'mobile': mobile.trim(),
      if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
      if (designationId != null) 'designation_id': designationId,
      'status': 'active',
      'must_change_password': true,
    }).select('*, designations(*)').single();

    return WorkerModel.fromJson(res);
  }

  @override
  Future<void> toggleWorkerStatus({
    required String workerId,
    required bool isActive,
  }) async {
    await _client
        .from('profiles')
        .update({'status': isActive ? 'active' : 'inactive'})
        .eq('id', workerId);
  }

  Future<String> _getOrgId() async {
    final profile = await _client
        .from('profiles')
        .select('organization_id')
        .eq('id', _client.auth.currentUser!.id)
        .single();
    final orgId = profile['organization_id'] as String?;
    if (orgId == null || orgId.isEmpty) {
      throw Exception('কোনো প্রতিষ্ঠান পাওয়া যায়নি।');
    }
    return orgId;
  }
}
