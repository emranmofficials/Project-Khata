import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/auth_repository.dart';
import '../domain/models/user_profile.dart';

/// Supabase বাস্তবায়িত AuthRepository
class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _client;

  SupabaseAuthRepository(this._client);

  @override
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
      throw Exception('লগইন ব্যর্থ হয়েছে। দয়া করে পুনরায় চেষ্টা করুন।');
    }

    final profile = await getCurrentUserProfile();
    if (profile == null) {
      // যদি ঠিকাদারের প্রোফাইল এখনও প্রতিষ্ঠান তৈরি না করে থাকে
      return UserProfile(
        id: user.id,
        role: 'contractor',
        name: user.userMetadata?['name'] ?? 'ঠিকাদার',
        mobile: user.userMetadata?['mobile'] ?? '',
        email: user.email,
        mustChangePassword: false,
      );
    }

    if (!profile.isActive) {
      await signOut();
      throw Exception('আপনার অ্যাকাউন্টটি নিষ্ক্রিয় অবস্থায় রয়েছে। ঠিকাদারের সাথে যোগাযোগ করুন।');
    }

    return profile;
  }

  @override
  Future<UserProfile> loginWithMobile({
    required String mobile,
    required String password,
  }) async {
    // বাংলাদেশি ফরম্যাট নিশ্চিতকরণ (+880...)
    String cleanMobile = mobile.trim().replaceAll(RegExp(r'\s+|-'), '');
    String phoneAuth = cleanMobile.startsWith('+88') 
        ? cleanMobile 
        : cleanMobile.startsWith('88') 
            ? '+$cleanMobile' 
            : '+88$cleanMobile';

    final response = await _client.auth.signInWithPassword(
      phone: phoneAuth,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw Exception('মোবাইল বা পাসওয়ার্ড সঠিক নয়।');
    }

    final profile = await getCurrentUserProfile();
    if (profile == null) {
      await signOut();
      throw Exception('প্রোফাইল পাওয়া যায়নি। ঠিকাদারের সাথে যোগাযোগ করুন।');
    }

    if (!profile.isActive) {
      await signOut();
      throw Exception('আপনার অ্যাকাউন্টটি নিষ্ক্রিয় করা হয়েছে।');
    }

    return profile;
  }

  @override
  Future<void> contractorSignUp({
    required String name,
    required String email,
    required String password,
    required String mobile,
  }) async {
    await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'name': name.trim(),
        'mobile': mobile.trim(),
        'role': 'contractor',
      },
    );
  }

  @override
  Future<UserProfile> setupOrganization({
    required String orgName,
    required String orgAddress,
    required String orgPhone,
    required String contractorMobile,
  }) async {
    final response = await _client.rpc('create_organization', params: {
      'org_name': orgName.trim(),
      'org_address': orgAddress.trim(),
      'org_phone': orgPhone.trim(),
      'contractor_mobile': contractorMobile.trim(),
    });

    if (response == null || response['success'] != true) {
      throw Exception('প্রতিষ্ঠান তৈরিতে সমস্যা হয়েছে। আবার চেষ্টা করুন।');
    }

    final profile = await getCurrentUserProfile();
    if (profile == null) {
      throw Exception('প্রোফাইল লোড করা সম্ভব হয়নি।');
    }
    return profile;
  }

  @override
  Future<void> changePassword({required String newPassword}) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('অননুমোদিত অ্যাক্সেস।');

    // Supabase Auth-এ পাসওয়ার্ড আপডেট
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );

    // প্রোফাইলে must_change_password ফ্ল্যাগ ফলস করা
    await _client.from('profiles').update({
      'must_change_password': false,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', user.id);
  }

  @override
  Future<UserProfile?> getCurrentUserProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final data = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) return null;
    return UserProfile.fromJson(data);
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
