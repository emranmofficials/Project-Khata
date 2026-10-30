import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/app_user.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  User? get currentUser => _client.auth.currentUser;

  /// Contractor Registration: Creates Auth User, Organization, and Contractor Profile
  Future<UserProfile> registerContractor({
    required String name,
    required String email,
    required String password,
    required String organizationName,
    String? address,
    String? phone,
  }) async {
    // 1. Sign up user in Supabase Auth
    final authResponse = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'name': name.trim(), 'role': 'contractor'},
    );

    final user = authResponse.user;
    if (user == null) {
      throw const AuthException('রেজিস্ট্রেশন ব্যর্থ হয়েছে। আবার চেষ্টা করুন।');
    }

    // সেশন নিশ্চিত করা
    if (_client.auth.currentSession == null) {
      await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    }

    // 2 & 3. পরমাণুকভাবে প্রতিষ্ঠান ও প্রোফাইল তৈরি (RPC অথবা সরাসরি ইনসার্ট)
    try {
      final rpcRes = await _client.rpc('register_contractor', params: {
        'p_org_name': organizationName.trim(),
        'p_org_address': address?.trim(),
        'p_org_phone': phone?.trim(),
        'p_name': name.trim(),
      });
      return UserProfile.fromJson(rpcRes as Map<String, dynamic>);
    } catch (_) {
      // RPC ব্যর্থ হলে সরাসরি ইনসার্ট ফলব্যাক
      final orgResponse = await _client.from('organizations').insert({
        'name': organizationName.trim(),
        'address': address?.trim(),
        'phone': phone?.trim(),
        'owner_id': user.id,
      }).select().single();

      final orgId = orgResponse['id'] as String;

      final profileResponse = await _client.from('profiles').insert({
        'id': user.id,
        'organization_id': orgId,
        'role': 'contractor',
        'name': name.trim(),
        'email': email.trim(),
        'mobile': phone?.trim(),
        'must_change_password': false,
        'status': 'active',
      }).select().single();

      return UserProfile.fromJson(profileResponse);
    }
  }

  /// Contractor Login via Email & Password
  Future<UserProfile> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException('লগইন ব্যর্থ হয়েছে।');
    }

    return await getUserProfile(user.id);
  }

  /// Member Login (Client, Supervisor, Worker) via Mobile & Password
  /// Uses synthetic email: {mobile}@members.projectkhata.app
  Future<UserProfile> loginWithMobile({
    required String mobile,
    required String password,
  }) async {
    final cleanMobile = mobile.trim();
    final syntheticEmail = '$cleanMobile@members.projectkhata.app';

    final response = await _client.auth.signInWithPassword(
      email: syntheticEmail,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException('লগইন ব্যর্থ হয়েছে। মোবাইল ও পাসওয়ার্ড পরীক্ষা করুন।');
    }

    return await getUserProfile(user.id);
  }

  /// Fetches UserProfile from public.profiles
  Future<UserProfile> getUserProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return UserProfile.fromJson(response);
  }

  /// Mandatory Password Change on first login
  Future<UserProfile> updatePassword({
    required String newPassword,
  }) async {
    final user = currentUser;
    if (user == null) throw const AuthException('ইউজার অথেন্টিকেশন পাওয়া যায়নি।');

    // 1. Update Auth password
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );

    // 2. Mark must_change_password = false in profiles
    final response = await _client
        .from('profiles')
        .update({'must_change_password': false})
        .eq('id', user.id)
        .select()
        .single();

    return UserProfile.fromJson(response);
  }

  /// Invokes create-member Edge Function to add member
  Future<Map<String, dynamic>> createMember({
    required String name,
    required String mobile,
    required UserRole role,
    String? designationId,
  }) async {
    final response = await _client.functions.invoke(
      'create-member',
      body: {
        'name': name.trim(),
        'mobile': mobile.trim(),
        'role': role.toDbString(),
        if (designationId != null) 'designation_id': designationId,
      },
    );

    if (response.status >= 400) {
      final errorMsg = response.data?['error'] ?? 'সদস্য তৈরি ব্যর্থ হয়েছে।';
      throw Exception(errorMsg);
    }

    return response.data as Map<String, dynamic>;
  }

  /// Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
