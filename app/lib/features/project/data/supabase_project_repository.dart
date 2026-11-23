import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/project_model.dart';
import '../domain/models/supervisor_assignment_model.dart';
import '../domain/project_repository.dart';

/// Supabase বাস্তবায়িত ProjectRepository
class SupabaseProjectRepository implements ProjectRepository {
  final SupabaseClient _client;

  SupabaseProjectRepository(this._client);

  @override
  Future<List<ProjectModel>> getProjects({
    String? statusFilter,
    String? searchQuery,
  }) async {
    var query = _client.from('projects').select('''
      *,
      project_clients(
        profiles:client_profile_id(name, mobile)
      ),
      supervisor_assignments(count)
    ''');

    if (statusFilter != null && statusFilter.isNotEmpty && statusFilter != 'all') {
      query = query.eq('status', statusFilter);
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      query = query.ilike('name', '%${searchQuery.trim()}%');
    }

    final response = await query.order('created_at', ascending: false);
    final list = response as List<dynamic>;

    return list.map((item) {
      final map = Map<String, dynamic>.from(item);
      // ক্লায়েন্টের নাম ও মোবাইল বের করা
      final clients = map['project_clients'] as List<dynamic>?;
      if (clients != null && clients.isNotEmpty) {
        final profile = clients[0]['profiles'] as Map<String, dynamic>?;
        map['client_name'] = profile?['name'];
        map['client_mobile'] = profile?['mobile'];
      }
      return ProjectModel.fromJson(map);
    }).toList();
  }

  @override
  Future<ProjectModel> getProjectDetails(String projectId) async {
    final response = await _client.from('projects').select('''
      *,
      project_clients(
        profiles:client_profile_id(name, mobile)
      )
    ''').eq('id', projectId).single();

    final map = Map<String, dynamic>.from(response);
    final clients = map['project_clients'] as List<dynamic>?;
    if (clients != null && clients.isNotEmpty) {
      final profile = clients[0]['profiles'] as Map<String, dynamic>?;
      map['client_name'] = profile?['name'];
      map['client_mobile'] = profile?['mobile'];
    }

    // আজকের উপস্থিত শ্রমিকের সংখ্যা আনা
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final attendanceCount = await _client
        .from('attendance')
        .select('id')
        .eq('entry_date', today)
        .eq('status', 'present');

    map['today_workers_count'] = (attendanceCount as List<dynamic>).length;

    return ProjectModel.fromJson(map);
  }

  @override
  Future<Map<String, dynamic>> createProject({
    required String name,
    required String type,
    required String address,
    required double lat,
    required double lng,
    int geofenceRadiusM = 150,
    double budget = 0.0,
    required String clientName,
    required String clientMobile,
    String status = 'active',
  }) async {
    final result = await _client.rpc('create_project_with_client', params: {
      'p_name': name.trim(),
      'p_type': type,
      'p_address': address.trim(),
      'p_lat': lat,
      'p_lng': lng,
      'p_geofence_radius_m': geofenceRadiusM,
      'p_budget': budget,
      'p_client_name': clientName.trim(),
      'p_client_mobile': clientMobile.trim(),
      'p_status': status,
    });

    if (result == null || result['success'] != true) {
      throw Exception('প্রজেক্ট তৈরিতে সমস্যা হয়েছে। আবার চেষ্টা করুন।');
    }

    return Map<String, dynamic>.from(result);
  }

  @override
  Future<void> updateProject({
    required String projectId,
    required String name,
    required String type,
    required String address,
    required double lat,
    required double lng,
    required int geofenceRadiusM,
    required String clientName,
    double budget = 0.0,
  }) async {
    // প্রজেক্ট টেবিল আপডেট
    await _client.from('projects').update({
      'name': name.trim(),
      'type': type,
      'address': address.trim(),
      'lat': lat,
      'lng': lng,
      'geofence_radius_m': geofenceRadiusM,
      'budget': budget,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', projectId);

    // ক্লায়েন্টের নাম আপডেট (PRD নিয়ম ১৪: মোবাইল বদলানো যাবে না)
    final projectClients = await _client
        .from('project_clients')
        .select('client_profile_id')
        .eq('project_id', projectId);

    if ((projectClients as List<dynamic>).isNotEmpty) {
      final clientProfileId = projectClients[0]['client_profile_id'] as String;
      await _client.from('profiles').update({
        'name': clientName.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', clientProfileId);
    }
  }

  @override
  Future<void> updateProjectStatus({
    required String projectId,
    required String newStatus,
  }) async {
    await _client.from('projects').update({
      'status': newStatus,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', projectId);
  }

  @override
  Future<List<SupervisorAssignmentModel>> getProjectSupervisors(String projectId) async {
    final response = await _client.from('supervisor_assignments').select('''
      id,
      supervisor_id,
      assigned_at,
      unassigned_at,
      profiles:supervisor_id(name, mobile)
    ''').eq('project_id', projectId).isFilter('unassigned_at', null);

    final list = response as List<dynamic>;
    return list.map((item) => SupervisorAssignmentModel.fromJson(Map<String, dynamic>.from(item))).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getAllSupervisors() async {
    final response = await _client
        .from('profiles')
        .select('id, name, mobile')
        .eq('role', 'supervisor')
        .eq('status', 'active')
        .order('name');

    return (response as List<dynamic>).map((e) => Map<String, dynamic>.from(e)).toList();
  }

  @override
  Future<void> syncSupervisors({
    required String projectId,
    required List<String> supervisorIds,
  }) async {
    await _client.rpc('sync_project_supervisors', params: {
      'p_project_id': projectId,
      'p_supervisor_ids': supervisorIds,
    });
  }
}
