import '../constants/app_strings.dart';

/// ফোন নম্বর ও সিন্থেটিক ইমেইল রূপান্তর এবং যাচাই হেলপার (PRD Rule 2.0 & AGENTS.md)
const String kMembersEmailDomain = 'members.projectkhata.app';

class PhoneEmailHelper {
  PhoneEmailHelper._();

  static const String domain = kMembersEmailDomain;
  static final RegExp _bdPhoneRegex = RegExp(r'^01[3-9]\d{8}$');

  /// বাংলাদেশি মোবাইল নম্বর যাচাই (01[3-9] দিয়ে শুরু, মোট ১১ সংখ্যা)
  static bool isValidBangladeshiMobile(String? phone) {
    if (phone == null) return false;
    final clean = cleanMobile(phone);
    return _bdPhoneRegex.hasMatch(clean);
  }

  /// মোবাইল নম্বর ক্লিন করা (স্পেস, ড্যাশ ও +88 উপসর্গ বাদ দেওয়া)
  static String cleanMobile(String phone) {
    var clean = phone.trim().replaceAll(RegExp(r'[\s\-()]'), '');
    if (clean.startsWith('+88')) {
      clean = clean.substring(3);
    } else if (clean.startsWith('88')) {
      clean = clean.substring(2);
    }
    return clean;
  }

  /// মোবাইল থেকে সিন্থেটিক ইমেইলে রূপান্তর: <মোবাইল>@members.projectkhata.app
  static String toSyntheticEmail(String mobile) {
    final clean = cleanMobile(mobile);
    return '$clean@$domain';
  }

  /// প্রাথমিক পাসওয়ার্ড (মোবাইলের শেষ ৬ সংখ্যা)
  static String getInitialPassword(String mobile) {
    final clean = cleanMobile(mobile);
    if (clean.length < 6) return clean;
    return clean.substring(clean.length - 6);
  }

  /// নতুন পাসওয়ার্ড যাচাই (কমপক্ষে ৮ অক্ষর, প্রাথমিক পাসওয়ার্ড গ্রহণযোগ্য নয়)
  static String? validateNewPassword({
    required String? password,
    String? mobile,
  }) {
    if (password == null || password.isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (mobile != null && mobile.trim().isNotEmpty) {
      try {
        final initial = getInitialPassword(mobile);
        if (initial.isNotEmpty && password == initial) {
          return AppStrings.passwordCannotBeInitial;
        }
      } catch (_) {}
    }
    if (password.length < 8) {
      return AppStrings.passwordMinLength8;
    }
    return null;
  }
}

/// টপ-লেভেল হেলপার ফাংশনসমূহ
bool isValidBangladeshiMobile(String? phone) =>
    PhoneEmailHelper.isValidBangladeshiMobile(phone);

String mobileToSyntheticEmail(String mobile) =>
    PhoneEmailHelper.toSyntheticEmail(mobile);

String getInitialPassword(String mobile) =>
    PhoneEmailHelper.getInitialPassword(mobile);

String? validateNewPassword({required String? password, String? mobile}) =>
    PhoneEmailHelper.validateNewPassword(password: password, mobile: mobile);

