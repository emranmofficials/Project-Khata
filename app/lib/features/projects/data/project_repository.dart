import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/domain/models/app_user.dart';
import '../domain/models/project.dart';
import '../domain/models/supervisor_assignment.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository(Supabase.instance.client);
});

class ProjectRepository {
  final SupabaseClient _client;

  ProjectRepository(this._client);

  /// Fetch all projects accessible to current user (governed by RLS)
  Future<List<Project>> getProjects() async {
    final response = await _client
        .from('projects')
        .select('*, client:profiles!projects_client_id_fkey(name, mobile)')
        .order('created_at', ascending: false);

    return (response as List).map((e) => Project.fromJson(e)).toList();
  }

  /// Fetch single project details
  Future<Project> getProjectById(String id) async {
    final response = await _client
        .from('projects')
        .select('*, client:profiles!projects_client_id_fkey(name, mobile)')
        .eq('id', id)
        .single();

    return Project.fromJson(response);
  }

  /// Create a new project (Contractor only)
  Future<Project> createProject({
    required String organizationId,
    required String clientId,
    required String name,
    required ProjectType type,
    String? address,
    required double lat,
    required double lng,
    int geofenceRadiusM = 150,
    required DateTime startDate,
    DateTime? endDate,
    ProjectStatus status = ProjectStatus.active,
    double? budget,
    double? ratePerSqft,
    double? totalSqft,
    double? dailyWage,
    String? note,
  }) async {
    final response = await _client.from('projects').insert({
      'organization_id': organizationId,
      'client_id': clientId,
      'name': name.trim(),
      'type': type.toDbString(),
      'address': address?.trim(),
      'lat': lat,
      'lng': lng,
      'geofence_radius_m': geofenceRadiusM,
      'start_date': startDate.toIso8601String().split('T').first,
      if (endDate != null)
        'end_date': endDate.toIso8601String().split('T').first,
      'status': status.toDbString(),
      if (budget != null) 'budget': budget,
      if (ratePerSqft != null) 'rate_per_sqft': ratePerSqft,
      if (totalSqft != null) 'total_sqft': totalSqft,
      if (dailyWage != null) 'daily_wage': dailyWage,
      if (note != null) 'note': note.trim(),
    }).select('*, client:profiles!projects_client_id_fkey(name, mobile)').single();

    return Project.fromJson(response);
  }

  /// Assign Supervisor to Project
  Future<void> assignSupervisor({
    required String organizationId,
    required String projectId,
    required String supervisorId,
  }) async {
    await _client.from('supervisor_assignments').insert({
      'organization_id': organizationId,
      'project_id': projectId,
      'supervisor_id': supervisorId,
      'assigned_at': DateTime.now().toIso8601String(),
    });
  }

  /// Remove/Unassign Supervisor from Project (Rule 7 & 10: sets unassigned_at)
  Future<void> unassignSupervisor(String assignmentId) async {
    await _client
        .from('supervisor_assignments')
        .update({'unassigned_at': DateTime.now().toIso8601String()})
        .eq('id', assignmentId);
  }

  /// Get active supervisor assignments for a project
  Future<List<SupervisorAssignment>> getActiveAssignments(String projectId) async {
    final response = await _client
        .from('supervisor_assignments')
        .select('*, supervisor:profiles!supervisor_assignments_supervisor_id_fkey(name, mobile)')
        .eq('project_id', projectId)
        .isFilter('unassigned_at', null)
        .order('assigned_at', ascending: true);

    return (response as List)
        .map((e) => SupervisorAssignment.fromJson(e))
        .toList();
  }

  /// Get all clients of the organization
  Future<List<UserProfile>> getClients(String organizationId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('organization_id', organizationId)
        .eq('role', 'client')
        .eq('status', 'active')
        .order('name');

    return (response as List).map((e) => UserProfile.fromJson(e)).toList();
  }

  /// Get all supervisors of the organization
  Future<List<UserProfile>> getSupervisors(String organizationId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('organization_id', organizationId)
        .eq('role', 'supervisor')
        .eq('status', 'active')
        .order('name');

    return (response as List).map((e) => UserProfile.fromJson(e)).toList();
  }
}
