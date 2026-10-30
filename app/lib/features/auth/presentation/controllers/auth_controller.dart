import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/auth_repository.dart';
import '../../domain/models/app_user.dart';

final authRepositoryProvider = Provider<AuthRepository?>((ref) {
  try {
    return AuthRepository(Supabase.instance.client);
  } catch (_) {
    return null;
  }
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<UserProfile?>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthController(repo);
});

final currentUserProvider = Provider<AsyncValue<UserProfile?>>((ref) {
  return ref.watch(authControllerProvider);
});

final needsOrganizationProvider = Provider<bool>((ref) {
  ref.watch(authControllerProvider);
  return ref.read(authControllerProvider.notifier).needsOrganization;
});

class AuthController extends StateNotifier<AsyncValue<UserProfile?>> {
  final AuthRepository? _repository;
  bool _needsOrganization = false;

  bool get needsOrganization => _needsOrganization;

  AuthController(this._repository) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    final repo = _repository;
    if (repo == null) {
      _needsOrganization = false;
      state = const AsyncValue.data(null);
      return;
    }
    final user = repo.currentUser;
    if (user == null) {
      _needsOrganization = false;
      state = const AsyncValue.data(null);
      return;
    }
    try {
      final profile = await repo.getUserProfile(user.id);
      if (profile == null) {
        _needsOrganization = true;
        state = const AsyncValue.data(null);
      } else {
        _needsOrganization = false;
        state = AsyncValue.data(profile);
      }
    } catch (e, st) {
      _needsOrganization = false;
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loginContractor({
    required String email,
    required String password,
  }) async {
    final repo = _repository;
    if (repo == null) throw const AuthException('সার্ভিস প্রস্তুত নয়');
    state = const AsyncValue.loading();
    try {
      final profile = await repo.loginWithEmail(
        email: email,
        password: password,
      );
      if (profile == null) {
        _needsOrganization = true;
        state = const AsyncValue.data(null);
      } else {
        _needsOrganization = false;
        state = AsyncValue.data(profile);
      }
    } catch (e, st) {
      _needsOrganization = false;
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> loginMember({
    required String mobile,
    required String password,
  }) async {
    final repo = _repository;
    if (repo == null) throw const AuthException('সার্ভিস প্রস্তুত নয়');
    state = const AsyncValue.loading();
    try {
      final profile = await repo.loginWithMobile(
        mobile: mobile,
        password: password,
      );
      if (profile == null) {
        await repo.signOut();
        _needsOrganization = false;
        throw const AuthException(
            'আপনার কোনো প্রোফাইল পাওয়া যায়নি। অনুগ্রহ করে ঠিকাদারের সাথে যোগাযোগ করুন।');
      }
      _needsOrganization = false;
      state = AsyncValue.data(profile);
    } catch (e, st) {
      _needsOrganization = false;
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
    final repo = _repository;
    if (repo == null) throw const AuthException('সার্ভিস প্রস্তুত নয়');
    state = const AsyncValue.loading();
    try {
      final profile = await repo.registerContractor(
        name: name,
        email: email,
        password: password,
        organizationName: organizationName,
        address: address,
        phone: phone,
      );
      _needsOrganization = false;
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    final repo = _repository;
    if (repo == null) throw const AuthException('সার্ভিস প্রস্তুত নয়');
    final current = state.value;
    state = const AsyncValue.loading();
    try {
      final updated = await repo.updatePassword(newPassword: newPassword);
      _needsOrganization = false;
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      if (current != null) state = AsyncValue.data(current);
      rethrow;
    }
  }

  Future<void> signOut() async {
    final repo = _repository;
    _needsOrganization = false;
    if (repo != null) {
      await repo.signOut();
    }
    state = const AsyncValue.data(null);
  }
}
