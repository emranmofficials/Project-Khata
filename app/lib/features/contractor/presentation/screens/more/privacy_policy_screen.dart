import 'package:flutter/material.dart';
import 'package:project_khata/core/constants/app_colors.dart';
import 'package:project_khata/core/constants/contractor_strings.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          ContractorStrings.privacyPolicyTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // হেডার ইন্ট্রো
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
                  const Icon(Icons.shield_outlined, color: Color(0xFF0F766E), size: 32),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'আপনার তথ্যের সর্বোচ্চ নিরাপত্তা',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'প্রজেক্ট খাতা কঠোর এন্টারপ্রাইজ-গ্রেড ডাটা সিকিউরিটি এবং ভূমিকা-ভিত্তিক গোপনীয়তা নীতি অনুসরণ করে।',
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

            _buildPolicySection(
              number: '১',
              title: 'ডেটাবেস নিরাপত্তা ও প্রতিষ্ঠানগত আইসোলেশন',
              content:
                  'প্রতিটি প্রতিষ্ঠানের তথ্য Row-Level Security (RLS) দ্বারা সম্পূর্ণরূপে আলাদা ও সুরক্ষিত। একজন ঠিকাদারের প্রতিষ্ঠানের ডেটা অন্য কোনো প্রতিষ্ঠান বা বহিরাগত ব্যক্তির দ্বারা দৃশ্যমান নয়।',
              icon: Icons.lock_outline_rounded,
              isDark: isDark,
            ),

            _buildPolicySection(
              number: '২',
              title: 'GPS লোকেশন ও সাইট যাচাই নীতি',
              content:
                  'GPS লোকেশন কেবল সুপারভাইজার যখন সাইটে দৈনিক হাজিরার এন্ট্রি খোলেন বা যাচাই করেন, ঠিক সেই মুহূর্তেই সংগৃহীত হয়। কোনো ধরণের ব্যাকগ্রাউন্ড লোকেশন ট্র্যাকিং করা হয় না। সাইট ব্যাসার্ধের (১০০-২০০ মিটার) বাইরে হলে তা "সাইটের বাইরে" চিহ্নিত হয়।',
              icon: Icons.location_on_outlined,
              isDark: isDark,
            ),

            _buildPolicySection(
              number: '৩',
              title: 'ক্লায়েন্ট তথ্যের গোপনীয়তা',
              content:
                  'ক্লায়েন্ট কেবলমাত্র তার সংশ্লিষ্ট প্রজেক্টের কাজের আপডেট, মালামালের রেকর্ড এবং হিসাব খতিয়ান দেখতে পাবেন। শ্রমিক ও সুপারভাইজারদের অভ্যন্তরীণ দৈনিক হাজিরা ও ব্যক্তিগত লোকেশন ক্লায়েন্টের কাছে গোপন থাকে।',
              icon: Icons.visibility_off_outlined,
              isDark: isDark,
            ),

            _buildPolicySection(
              number: '৪',
              title: 'অনুমোদিত এন্ট্রি ও অডিট ট্রেইল',
              content:
                  'একবার অনুমোদিত ও লক করা এন্ট্রি সরাসরি ডাটাবেস থেকে সম্পাদনা বা মুছে ফেলা সম্পূর্ণ নিষিদ্ধ। কোনো সংশোধন প্রয়োজন হলে তা অডিট লগে কারণ ও সময় সহ নতুন রেকর্ড হিসেবে সংরক্ষিত হয়।',
              icon: Icons.history_edu_outlined,
              isDark: isDark,
            ),

            _buildPolicySection(
              number: '৫',
              title: 'অফলাইন ক্যাশ ও নিরাপদ সিঙ্ক',
              content:
                  'কনস্ট্রাকশন সাইটে ইন্টারনেট সংযোগ না থাকলেও ডিভাইসে নিরাপদ এনক্রিপ্টেড ফরম্যাটে এন্ট্রি ড্রাফট থাকে এবং ইন্টারনেট সংযোগ পেলেই স্বয়ংক্রিয়ভাবে সিঙ্ক সম্পন্ন হয়।',
              icon: Icons.sync_lock_outlined,
              isDark: isDark,
            ),

            const SizedBox(height: 20),

            Center(
              child: Text(
                'সর্বশেষ হালনাগাদ: অক্টোবর ২০২৬',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicySection({
    required String number,
    required String title,
    required String content,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: (isDark ? const Color(0xFF93A8F4) : AppColors.contractorNavy)
                    .withValues(alpha: 0.15),
                child: Text(
                  number,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF93A8F4) : AppColors.contractorNavy,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
