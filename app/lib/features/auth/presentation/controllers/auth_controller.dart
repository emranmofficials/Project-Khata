import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/auth_repository.dart';
import '../../domain/models/app_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(Supabase.instance.client);
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<UserProfile?>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthController(repo);
});

final currentUserProvider = Provider<AsyncValue<UserProfile?>>((ref) {
  return ref.watch(authControllerProvider);
});

class AuthController extends StateNotifier<AsyncValue<UserProfile?>> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    final user = _repository.currentUser;
    if (user == null) {
      state = const AsyncValue.data(null);
      return;
    }
    try {
      final profile = await _repository.getUserProfile(user.id);
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loginContractor({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final profile = await _repository.loginWithEmail(
        email: email,
        password: password,
      );
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> loginMember({
    required String mobile,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final profile = await _repository.loginWithMobile(
        mobile: mobile,
        password: password,
      );
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> registerContractor({
    required String name,
    required String email,
    required String password,
    required String organizationName,
    String? address,
    String? phone,
  }) async {
    state = const AsyncValue.loading();
    try {
      final profile = await _repository.registerContractor(
        name: name,
        email: email,
        password: password,
        organizationName: organizationName,
        address: address,
        phone: phone,
      );
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    final current = state.value;
    state = const AsyncValue.loading();
    try {
      final updated = await _repository.updatePassword(newPassword: newPassword);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      if (current != null) state = AsyncValue.data(current);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AsyncValue.data(null);
  }
}
