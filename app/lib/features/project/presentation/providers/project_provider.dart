import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client.dart';
import '../../data/supabase_project_repository.dart';
import '../../domain/models/project_model.dart';
import '../../domain/models/supervisor_assignment_model.dart';
import '../../domain/project_repository.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseProjectRepository(client);
});

// ফিল্টার স্টেট
final projectStatusFilterProvider = StateProvider<String>((ref) => 'all');
final projectSearchQueryProvider = StateProvider<String>((ref) => '');

// প্রজেক্ট তালিকা লোডার
final projectsListProvider = FutureProvider<List<ProjectModel>>((ref) async {
  final repository = ref.watch(projectRepositoryProvider);
  final status = ref.watch(projectStatusFilterProvider);
  final search = ref.watch(projectSearchQueryProvider);

  return repository.getProjects(
    statusFilter: status,
    searchQuery: search,
  );
});

// নির্দিষ্ট প্রজেক্ট ডিটেইলস লোডার
final projectDetailsProvider = FutureProvider.family<ProjectModel, String>((ref, projectId) async {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.getProjectDetails(projectId);
});

// প্রজেক্টের সুপারভাইজার তালিকা লোডার
final projectSupervisorsProvider = FutureProvider.family<List<SupervisorAssignmentModel>, String>((ref, projectId) async {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.getProjectSupervisors(projectId);
});

// প্রতিষ্ঠানের সমস্ত সুপারভাইজার তালিকা
final allSupervisorsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.getAllSupervisors();
});

// প্রজেক্ট অ্যাকশন নোটিফায়ার
class ProjectActionNotifier extends StateNotifier<AsyncValue<void>> {
  final ProjectRepository _repository;
  final Ref _ref;

  ProjectActionNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

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
    state = const AsyncValue.loading();
    try {
      final result = await _repository.createProject(
        name: name,
        type: type,
        address: address,
        lat: lat,
        lng: lng,
        geofenceRadiusM: geofenceRadiusM,
        budget: budget,
        clientName: clientName,
        clientMobile: clientMobile,
        status: status,
      );
      state = const AsyncValue.data(null);
      _ref.invalidate(projectsListProvider);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateProjectStatus(String projectId, String newStatus) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateProjectStatus(
        projectId: projectId,
        newStatus: newStatus,
      );
      state = const AsyncValue.data(null);
      _ref.invalidate(projectDetailsProvider(projectId));
      _ref.invalidate(projectsListProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> syncSupervisors(String projectId, List<String> supervisorIds) async {
    state = const AsyncValue.loading();
    try {
      await _repository.syncSupervisors(
        projectId: projectId,
        supervisorIds: supervisorIds,
      );
      state = const AsyncValue.data(null);
      _ref.invalidate(projectSupervisorsProvider(projectId));
      _ref.invalidate(projectDetailsProvider(projectId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final projectActionProvider = StateNotifierProvider<ProjectActionNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(projectRepositoryProvider);
  return ProjectActionNotifier(repository, ref);
});
