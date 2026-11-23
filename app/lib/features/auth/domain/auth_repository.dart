import 'models/user_profile.dart';

/// অথেনটিকেশন ও প্রোফাইল রিপোজিটরি ইন্টারফেস
abstract class AuthRepository {
  /// ঠিকাদার লগইন (ইমেইল ও পাসওয়ার্ড)
  Future<UserProfile> loginWithEmail({
    required String email,
    required String password,
  });

  /// ক্লায়েন্ট, সুপারভাইজার ও শ্রমিক লগইন (মোবাইল ও পাসওয়ার্ড)
  Future<UserProfile> loginWithMobile({
    required String mobile,
    required String password,
  });

  /// ঠিকাদার প্রাথমিক সাইন-আপ (ধাপ ১)
  Future<void> contractorSignUp({
    required String name,
    required String email,
    required String password,
    required String mobile,
  });

  /// ঠিকাদারের প্রতিষ্ঠান সেটআপ (ধাপ ২ - RPC কল)
  Future<UserProfile> setupOrganization({
    required String orgName,
    required String orgAddress,
    required String orgPhone,
    required String contractorMobile,
  });

  /// প্রথম লগইনে বা সাধারণ পাসওয়ার্ড পরিবর্তন
  Future<void> changePassword({
    required String newPassword,
  });

  /// বর্তমান লগইনকৃত ইউজারের প্রোফাইল আনা
  Future<UserProfile?> getCurrentUserProfile();

  /// সাইন আউট
  Future<void> signOut();
}
