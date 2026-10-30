import 'package:flutter/material.dart';
import 'package:project_khata/core/constants/app_colors.dart';
import 'package:project_khata/core/constants/contractor_strings.dart';

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  String _selectedTheme = 'system'; // 'system', 'light', 'dark'

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          ContractorStrings.themeSettingsTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'অ্যাপের ভিজ্যুয়াল থিম বেছে নিন',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'আপনার পছন্দসই মোড নির্বাচন করুন। রাতের ব্যবহারে ডার্ক মোড চোখের আরাম দেয়।',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // সিস্টেম মোড
            _buildThemeOption(
              key: 'system',
              title: 'সিস্টেম ডিফল্ট',
              subtitle: 'ফোনের ডিসপ্লে সেটিংস অনুযায়ী স্বয়ংক্রিয় পরিবর্তিত হবে',
              icon: Icons.brightness_auto_rounded,
              color: const Color(0xFF64748B),
              isDark: isDark,
            ),

            const SizedBox(height: 12),

            // লাইট মোড
            _buildThemeOption(
              key: 'light',
              title: 'লাইট মোড',
              subtitle: 'উজ্জ্বল ডিসপ্লে, কনস্ট্রাকশন সাইটে দিনের আলোতে ব্যবহারের জন্য উপযোগী',
              icon: Icons.light_mode_rounded,
              color: const Color(0xFFD97706),
              isDark: isDark,
            ),

            const SizedBox(height: 12),

            // ডার্ক মোড
            _buildThemeOption(
              key: 'dark',
              title: 'ডার্ক মোড',
              subtitle: 'ডার্ক ব্যাকগ্রাউন্ড ও নেভি ব্লু অ্যাকসেন্ট, কম আলোতে ব্যবহারের জন্য সেরা',
              icon: Icons.dark_mode_rounded,
              color: const Color(0xFF93A8F4),
              isDark: isDark,
            ),

            const Spacer(),

            // সংরক্ষণ বাটন
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('থিম পছন্দ সংরক্ষিত হয়েছে')),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF93A8F4) : AppColors.contractorNavy,
                  foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'সংরক্ষণ করুন',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required String key,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    final isSelected = _selectedTheme == key;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected
              ? (isDark ? const Color(0xFF93A8F4) : AppColors.contractorNavy)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _selectedTheme = key),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Radio<String>(
                value: key,
                groupValue: _selectedTheme,
                onChanged: (val) {
                  if (val != null) setState(() => _selectedTheme = val);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
