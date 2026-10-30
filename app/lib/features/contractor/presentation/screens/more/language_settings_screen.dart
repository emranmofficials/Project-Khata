import 'package:flutter/material.dart';
import 'package:project_khata/core/constants/app_colors.dart';
import 'package:project_khata/core/constants/contractor_strings.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String _selectedLanguage = 'bn';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          ContractorStrings.languageSettingsTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // তথ্য কার্ড
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.language_rounded, color: Color(0xFF2563EB), size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'অ্যাপের ভাষা',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'প্রজেক্ট খাতা বাংলাদেশের নির্মাণ খাতের উপযোগী করে সম্পূর্ণ বাংলায় সাজানো হয়েছে।',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // বাংলা
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: _selectedLanguage == 'bn'
                      ? (isDark ? const Color(0xFF93A8F4) : AppColors.contractorNavy)
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: ListTile(
                leading: const Text('🇧🇩', style: TextStyle(fontSize: 26)),
                title: const Text('বাংলা (বাংলাদেশ)', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('ডিফল্ট ভাষা'),
                trailing: Radio<String>(
                  value: 'bn',
                  groupValue: _selectedLanguage,
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedLanguage = val);
                  },
                ),
                onTap: () => setState(() => _selectedLanguage = 'bn'),
              ),
            ),

            // English
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: _selectedLanguage == 'en'
                      ? (isDark ? const Color(0xFF93A8F4) : AppColors.contractorNavy)
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: ListTile(
                leading: const Text('🇺🇸', style: TextStyle(fontSize: 26)),
                title: const Text('English (US)', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('শিঘ্রই আসছে (Coming Soon)'),
                trailing: Radio<String>(
                  value: 'en',
                  groupValue: _selectedLanguage,
                  onChanged: null, // Disabled for now
                ),
              ),
            ),

            const Spacer(),

            // সংরক্ষণ বাটন
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ভাষা পছন্দ সংরক্ষিত হয়েছে')),
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
}
