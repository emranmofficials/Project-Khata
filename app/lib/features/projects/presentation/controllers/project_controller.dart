import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/project_repository.dart';
import '../../domain/models/project.dart';

export '../../data/project_repository.dart' show projectRepositoryProvider;

final projectsListProvider =
    AsyncNotifierProvider<ProjectsListNotifier, List<Project>>(() {
  return ProjectsListNotifier();
});

class ProjectsListNotifier extends AsyncNotifier<List<Project>> {
  @override
  Future<List<Project>> build() async {
    final repo = ref.watch(projectRepositoryProvider);
    return await repo.getProjects();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(projectRepositoryProvider);
      return await repo.getProjects();
    });
  }

  Future<void> addProject({
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
    final repo = ref.read(projectRepositoryProvider);
    final created = await repo.createProject(
      organizationId: organizationId,
      clientId: clientId,
      name: name,
      type: type,
      address: address,
      lat: lat,
      lng: lng,
      geofenceRadiusM: geofenceRadiusM,
      startDate: startDate,
      endDate: endDate,
      status: status,
      budget: budget,
      ratePerSqft: ratePerSqft,
      totalSqft: totalSqft,
      dailyWage: dailyWage,
      note: note,
    );

    final current = state.value ?? [];
    state = AsyncValue.data([created, ...current]);
  }
}
