import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Role-based Brand Colors (From AGENTS.md & PRD)
  static const Color contractorNavy = Color(0xFF1E3A8A); // ঠিকাদার
  static const Color clientTeal = Color(0xFF0F766E);      // ক্লায়েন্ট
  static const Color supervisorAmber = Color(0xFFC2410C); // সুপারভাইজার
  static const Color workerIndigo = Color(0xFF6D28D9);    // শ্রমিক

  // Light Mode Palette
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Dark Mode Palette
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Feedback Colors
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);
}
