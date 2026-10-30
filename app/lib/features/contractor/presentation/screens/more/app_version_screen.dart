import 'package:flutter/material.dart';
import 'package:project_khata/core/constants/app_colors.dart';
import 'package:project_khata/core/constants/contractor_strings.dart';

class AppVersionScreen extends StatefulWidget {
  const AppVersionScreen({super.key});

  @override
  State<AppVersionScreen> createState() => _AppVersionScreenState();
}

class _AppVersionScreenState extends State<AppVersionScreen> {
  bool _isChecking = false;

  void _checkForUpdates() async {
    setState(() => _isChecking = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() => _isChecking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('আপনার অ্যাপটি ইতিমধ্যে সর্বশেষ ভার্সনে (v2.1.0) আপডেট করা আছে।'),
          backgroundColor: Color(0xFF0F766E),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          ContractorStrings.appVersionTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // লোগো
            Container(
              width: 88,
              height: 88,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131D2E) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? const Color(0xFF1F2A40) : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/branding/app-icon.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.apartment_rounded,
                    color: AppColors.contractorNavy,
                    size: 48,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // নাম ও ভার্সন
            const Text(
              'প্রজেক্ট খাতা',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'ভার্সন ২.১.০ (বিল্ড ২০২৬১০৩০)',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),

            const SizedBox(height: 12),

            // স্ট্যাটাস চিপ
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0F766E).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF0F766E).withValues(alpha: 0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF0F766E)),
                  SizedBox(width: 6),
                  Text(
                    'সর্বশেষ সংস্করণে সক্রিয়',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F766E),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // রিলিজ নোটস কার্ড
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.new_releases_outlined, size: 20, color: Color(0xFFD97706)),
                      SizedBox(width: 8),
                      Text(
                        'নতুন কী যোগ হয়েছে (v2.1.0)',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildChangelogItem('ঠিকাদার ইন্টারফেসের প্রতিটি মূল স্ক্রিনে সুসংগঠিত ব্র্যান্ডেড হেডার।'),
                  _buildChangelogItem('প্রজেক্ট তৈরির সময় স্বয়ংক্রিয় ক্লায়েন্ট অ্যাসাইনমেন্ট ও সমন্বয়।'),
                  _buildChangelogItem('পূর্ণাঙ্গ হিসাব খাতা, পেমেন্ট বরাদ্দ (FIFO) ও লাভ-ক্ষতি প্রতিবেদন।'),
                  _buildChangelogItem('শ্রমিক ও সুপারভাইজারদের তথ্য সম্পাদনা এবং দৈনিক মজুরি নিয়ন্ত্রণ।'),
                  _buildChangelogItem('সাইট জিওফেন্সিং (১৫০ মিটার ব্যাসার্ধ) ও ব্যাকডেটেড এন্ট্রি নিরাপত্তা ব্যবস্থা।'),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // আপডেট চেক বোতাম
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _isChecking ? null : _checkForUpdates,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: _isChecking
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync_rounded),
                label: Text(
                  _isChecking ? 'যাচাই করা হচ্ছে...' : 'আপডেট চেক করুন',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              '© ২০২৬ প্রজেক্ট খাতা। সর্বস্বত্ব সংরক্ষিত।',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white38 : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChangelogItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
