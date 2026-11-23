import 'package:flutter/material.dart';

/// PRD সেকশন ১১.২ অনুযায়ী Project Khata কালার প্যালেট
class AppColors {
  // ভূমিকা অনুযায়ী প্রাইমারি রং
  static const Color contractorPrimary = Color(0xFF1E3A8A); // নেভি
  static const Color contractorPrimaryDark = Color(0xFF93A8F4);

  static const Color clientPrimary = Color(0xFF0F766E); // টিল
  static const Color clientPrimaryDark = Color(0xFF2DD4BF);

  static const Color supervisorPrimary = Color(0xFFC2410C); // অ্যাম্বার
  static const Color supervisorPrimaryDark = Color(0xFFFB923C);

  static const Color workerPrimary = Color(0xFF6D28D9); // ইন্ডিগো
  static const Color workerPrimaryDark = Color(0xFFA78BFA);

  // স্ট্যাটাস ও প্রতিক্রিয়া রং
  static const Color success = Color(0xFF15803D); // সফল / অনুমোদিত
  static const Color warning = Color(0xFFB45309); // সতর্ক / অপেক্ষমাণ
  static const Color danger = Color(0xFFB91C1C);  // বিপদ / প্রত্যাখ্যাত

  // লাইট থিম সারফেস
  static const Color lightBackground = Color(0xFFF5F7FB);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE8ECF4);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // ডার্ক থিম সারফেস
  static const Color darkBackground = Color(0xFF0B1220);
  static const Color darkCard = Color(0xFF131C2E);
  static const Color darkBorder = Color(0xFF1F2A40);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // ভূমিকা অনুযায়ী প্রাইমারি কালার পাওয়ার হেল্পার
  static Color getPrimaryForRole(String role, {bool isDark = false}) {
    switch (role.toLowerCase()) {
      case 'contractor':
        return isDark ? contractorPrimaryDark : contractorPrimary;
      case 'client':
        return isDark ? clientPrimaryDark : clientPrimary;
      case 'supervisor':
        return isDark ? supervisorPrimaryDark : supervisorPrimary;
      case 'worker':
        return isDark ? workerPrimaryDark : workerPrimary;
      default:
        return isDark ? contractorPrimaryDark : contractorPrimary;
    }
  }

  // সারাংশ কার্ডের গ্রেডিয়েন্ট
  static LinearGradient getGradientForRole(String role) {
    switch (role.toLowerCase()) {
      case 'contractor':
        return const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'client':
        return const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'supervisor':
        return const LinearGradient(
          colors: [Color(0xFFC2410C), Color(0xFFF97316)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'worker':
        return const LinearGradient(
          colors: [Color(0xFF6D28D9), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
}
