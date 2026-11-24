import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client.dart';
import '../../data/supabase_auth_repository.dart';
import '../../domain/auth_repository.dart';
import '../../domain/models/user_profile.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseAuthRepository(client);
});

class AuthState {
  final bool isLoading;
  final UserProfile? user;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isLoading,
    UserProfile? user,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    checkCurrentUser();
  }

  Future<void> checkCurrentUser() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _repository.getCurrentUserProfile();
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> loginWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final profile = await _repository.loginWithEmail(email: email, password: password);
      state = state.copyWith(isLoading: false, user: profile);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> loginWithMobile(String mobile, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final profile = await _repository.loginWithMobile(mobile: mobile, password: password);
      state = state.copyWith(isLoading: false, user: profile);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> contractorSignUp({
    required String name,
    required String email,
    required String password,
    required String mobile,
    String? orgName,
    String? orgAddress,
    String? orgPhone,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.contractorSignUp(
        name: name,
        email: email,
        password: password,
        mobile: mobile,
        orgName: orgName,
        orgAddress: orgAddress,
        orgPhone: orgPhone,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> setupOrganization({
    required String orgName,
    required String orgAddress,
    required String orgPhone,
    required String contractorMobile,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final updatedProfile = await _repository.setupOrganization(
        orgName: orgName,
        orgAddress: orgAddress,
        orgPhone: orgPhone,
        contractorMobile: contractorMobile,
      );
      state = state.copyWith(isLoading: false, user: updatedProfile);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> changePassword(String newPassword) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.changePassword(newPassword: newPassword);
      if (state.user != null) {
        state = state.copyWith(
          isLoading: false,
          user: state.user!.copyWith(mustChangePassword: false),
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AuthState();
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
