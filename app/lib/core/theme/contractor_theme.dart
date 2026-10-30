import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class ContractorTheme {
  ContractorTheme._();

  static const Color primaryNavy = Color(0xFF1E3A8A);
  static const Color darkPrimaryNavy = Color(0xFF93A8F4);
  static const Color accentNavy = Color(0xFF2563EB);
  static const Color lightBg = Color(0xFFF5F7FB);
  static const Color darkBg = Color(0xFF0B1220);
  static const Color lightBorderColor = Color(0xFFE8ECF4);
  static const Color darkBorderColor = Color(0xFF1F2A40);

  static ThemeData getTheme({required bool isDark}) {
    final baseColorScheme = isDark
        ? const ColorScheme.dark(
            primary: darkPrimaryNavy,
            secondary: accentNavy,
            surface: Color(0xFF131D31),
            error: AppColors.error,
            onPrimary: Color(0xFF0B1220),
            onSurface: Colors.white,
          )
        : const ColorScheme.light(
            primary: primaryNavy,
            secondary: accentNavy,
            surface: Colors.white,
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

      // 1. AppBar: স্বচ্ছ ও বড় শিরোনাম (22, w700), কোনো tint নেই
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
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : AppColors.lightTextPrimary,
        ),
      ),

      // 2. কার্ড: ২০ px গোল কোণ ও হালকা বর্ডার (#E8ECF4 / ডার্কে #1F2A40), কোনো শ্যাডো নেই
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF131D31) : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: borderColor,
            width: 1,
          ),
        ),
      ),

      // 3. ইনপুট: filled, radius 14
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF131D31) : Colors.white,
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
          borderSide: BorderSide(
            color: isDark ? darkPrimaryNavy : primaryNavy,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),

      // 4. NavigationBar: উচ্চতা 72, লেবেল সবসময়, সক্রিয় লেবেল w600
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: isDark ? const Color(0xFF131D31) : Colors.white,
        elevation: 0,
        indicatorColor: (isDark ? darkPrimaryNavy : primaryNavy).withValues(alpha: 0.15),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
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

      // 5. FilledButton: উচ্চতা ৫২, radius 14
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: isDark ? darkPrimaryNavy : primaryNavy,
          foregroundColor: isDark ? const Color(0xFF0B1220) : Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? darkPrimaryNavy : primaryNavy,
          foregroundColor: isDark ? const Color(0xFF0B1220) : Colors.white,
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
