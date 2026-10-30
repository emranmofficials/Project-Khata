import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class ContractorTheme {
  ContractorTheme._();

  static const Color primaryNavy = Color(0xFF1E3A8A);
  static const Color darkPrimaryNavy = Color(0xFF93A8F4);
  static const Color accentNavy = Color(0xFF2563EB);
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color darkBg = Color(0xFF0F172A);
  static const Color lightSurface = Colors.white;
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color lightBorderColor = Color(0xFFE2E8F0);
  static const Color darkBorderColor = Color(0xFF334155);

  static ThemeData getTheme({required bool isDark}) {
    final baseColorScheme = isDark
        ? const ColorScheme.dark(
            primary: darkPrimaryNavy,
            secondary: accentNavy,
            surface: darkSurface,
            error: AppColors.error,
            onPrimary: Color(0xFF0F172A),
            onSurface: Colors.white,
          )
        : const ColorScheme.light(
            primary: primaryNavy,
            secondary: accentNavy,
            surface: lightSurface,
            error: AppColors.error,
            onPrimary: Colors.white,
            onSurface: AppColors.lightTextPrimary,
          );

    final baseTextTheme = isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;
    final textTheme = GoogleFonts.notoSansBengaliTextTheme(baseTextTheme).apply(
      bodyColor: isDark ? Colors.white : AppColors.lightTextPrimary,
      displayColor: isDark ? Colors.white : AppColors.lightTextPrimary,
    );

    final borderColor = isDark ? darkBorderColor : lightBorderColor;

    return ThemeData(
      useMaterial3: true,
      colorScheme: baseColorScheme,
      scaffoldBackgroundColor: isDark ? darkBg : lightBg,
      textTheme: textTheme,

      // 1. AppBar: স্বচ্ছ ও বড় শিরোনাম (22, w700), কোনো ব্যাকগ্রাউন্ড রঙ বা টিন্ট নেই
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : AppColors.lightTextPrimary,
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : AppColors.lightTextPrimary,
        ),
      ),

      // 2. কার্ড: ২০ px গোল কোণ ও পরিষ্কার ১ px বর্ডার, প্রিমিয়াম সফট এলিভেশন
      cardTheme: CardThemeData(
        color: isDark ? darkSurface : lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: borderColor,
            width: 1,
          ),
        ),
      ),

      // 3. ইনপুট ফিল্ড: filled, radius 16, প্রিমিয়াম ফোকাস বর্ডার
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? darkSurface : lightSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? darkPrimaryNavy : primaryNavy,
            width: 1.8,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.8),
        ),
        hintStyle: TextStyle(
          fontSize: 14,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
      ),

      // 4. NavigationBar: উচ্চতা 72, আধুনিক ইন্ডিকেটর শেপ
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: isDark ? darkSurface : lightSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        indicatorColor: (isDark ? darkPrimaryNavy : primaryNavy).withValues(alpha: 0.12),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? darkPrimaryNavy : primaryNavy,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
              color: isDark ? darkPrimaryNavy : primaryNavy,
              size: 24,
            );
          }
          return IconThemeData(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            size: 24,
          );
        }),
      ),

      // 5. বোতাম থিম: উচ্চতা ৫২, radius 16, সেফ টাইপোগ্রাফি
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: isDark ? darkPrimaryNavy : primaryNavy,
          foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? darkPrimaryNavy : primaryNavy,
          foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? darkPrimaryNavy : primaryNavy,
          side: BorderSide(
            color: (isDark ? darkPrimaryNavy : primaryNavy).withValues(alpha: 0.4),
            width: 1.2,
          ),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(color: borderColor),
        selectedColor: (isDark ? darkPrimaryNavy : primaryNavy).withValues(alpha: 0.12),
        backgroundColor: isDark ? darkSurface : lightSurface,
      ),
    );
  }
}
