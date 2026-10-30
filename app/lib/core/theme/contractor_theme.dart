import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class ContractorTheme {
  ContractorTheme._();

  static const Color primaryNavy = AppColors.contractorNavy; // #1E3A8A
  static const Color primaryDarkNavy = Color(0xFF0F172A);
  static const Color accentNavy = Color(0xFF2563EB);
  static const Color lightBorderColor = Color(0xFFE2E8F0);
  static const Color darkBorderColor = Color(0xFF334155);

  static ThemeData getTheme({required bool isDark}) {
    final baseColorScheme = isDark
        ? const ColorScheme.dark(
            primary: primaryNavy,
            secondary: accentNavy,
            surface: AppColors.darkSurface,
            error: AppColors.error,
            onPrimary: Colors.white,
            onSurface: AppColors.darkTextPrimary,
          )
        : const ColorScheme.light(
            primary: primaryNavy,
            secondary: accentNavy,
            surface: Colors.white,
            error: AppColors.error,
            onPrimary: Colors.white,
            onSurface: AppColors.lightTextPrimary,
          );

    final textTheme = isDark
        ? GoogleFonts.hindSiliguriTextTheme(ThemeData.dark().textTheme).apply(
            bodyColor: AppColors.darkTextPrimary,
            displayColor: AppColors.darkTextPrimary,
          )
        : GoogleFonts.hindSiliguriTextTheme(ThemeData.light().textTheme).apply(
            bodyColor: AppColors.lightTextPrimary,
            displayColor: AppColors.lightTextPrimary,
          );

    final borderColor = isDark ? darkBorderColor : lightBorderColor;

    return ThemeData(
      useMaterial3: true,
      colorScheme: baseColorScheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
      textTheme: textTheme,

      // 1. AppBar: স্বচ্ছ ও বড় শিরোনাম
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : AppColors.lightTextPrimary,
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : AppColors.lightTextPrimary,
        ),
      ),

      // 2. কার্ড: ২০ px গোল কোণ ও হালকা বর্ডার (ছায়া নয়)
      cardTheme: CardThemeData(
        color: isDark ? AppColors.darkCard : Colors.white,
        elevation: 0, // ছায়া নয়
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // ২০ px গোল কোণ
          side: BorderSide(
            color: borderColor, // হালকা বর্ডার
            width: 1,
          ),
        ),
      ),

      // 3. ইনপুট স্টাইল
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryNavy, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),

      // 4. NavigationBar স্টাইল
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        indicatorColor: primaryNavy.withValues(alpha: 0.12),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: primaryNavy,
            );
          }
          return TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryNavy, size: 24);
          }
          return IconThemeData(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            size: 24,
          );
        }),
      ),

      // 5. FilledButton-এর উচ্চতা ৫২
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryNavy,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52), // উচ্চতা ৫২
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ElevatedButton ফলব্যাক একই ৫২ উচ্চতা বজায় রাখবে
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNavy,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
