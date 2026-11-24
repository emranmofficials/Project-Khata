import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client.dart';
import '../../data/supabase_worker_repository.dart';
import '../../domain/models/worker_model.dart';
import '../../domain/worker_repository.dart';

final workerRepositoryProvider = Provider<WorkerRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseWorkerRepository(client);
});

// ফিল্টার ও সার্চ স্টেট
final workerRoleFilterProvider = StateProvider<String>((ref) => 'all');
final workerSearchQueryProvider = StateProvider<String>((ref) => '');

// কর্মী তালিকা
final workersListProvider = FutureProvider<List<WorkerModel>>((ref) async {
  final repository = ref.watch(workerRepositoryProvider);
  final role = ref.watch(workerRoleFilterProvider);
  final search = ref.watch(workerSearchQueryProvider);

  return repository.getWorkers(
    roleFilter: role,
    searchQuery: search,
  );
});

// পদবি তালিকা
final designationsListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(workerRepositoryProvider);
  return repository.getDesignations();
});

// একশন নোটিফায়ার
class WorkerActionNotifier extends StateNotifier<AsyncValue<void>> {
  final WorkerRepository _repository;
  final Ref _ref;

  WorkerActionNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<WorkerModel> addWorker({
    required String name,
    required String mobile,
    required String role,
    String? designationId,
    String? email,
  }) async {
    state = const AsyncValue.loading();
    try {
      final res = await _repository.addWorker(
        name: name,
        mobile: mobile,
        role: role,
        designationId: designationId,
        email: email,
      );
      state = const AsyncValue.data(null);
      _ref.invalidate(workersListProvider);
      return res;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addDesignation({
    required String name,
    required double dailyRate,
    double overtimeRatePerHour = 0.0,
  }) async {
    state = const AsyncValue.loading();
    try {
      final res = await _repository.addDesignation(
        name: name,
        dailyRate: dailyRate,
        overtimeRatePerHour: overtimeRatePerHour,
      );
      state = const AsyncValue.data(null);
      _ref.invalidate(designationsListProvider);
      return res;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> toggleWorkerStatus({
    required String workerId,
    required bool isActive,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.toggleWorkerStatus(
        workerId: workerId,
        isActive: isActive,
      );
      state = const AsyncValue.data(null);
      _ref.invalidate(workersListProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final workerActionProvider = StateNotifierProvider<WorkerActionNotifier, AsyncValue<void>>((ref) {
  final repo = ref.watch(workerRepositoryProvider);
  return WorkerActionNotifier(repo, ref);
});
